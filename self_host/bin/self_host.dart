import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import '../utils/global.dart';
import '../utils/logger.dart';

WebSocket? socketToAgent;
int wsStatus = 0;
bool isReconnecting = false;
StreamController<dynamic>? agentStreamController;

void main() async {
  // 读取配置
  if (!File('config.json').existsSync()) {
    Map cfg = {
      "host": "0.0.0.0",
      "port": 8025,
      "password": "123456",
      "connection": {"host": "127.0.0.1", "port": 2519, "token": "123456"}
    };
    String cfgStr = jsonEncode(cfg);
    File('config.json').writeAsStringSync(cfgStr);
  }
  String config = File('config.json').readAsStringSync();
  Map<String, dynamic> configJson = jsonDecode(config);
  Config.token = configJson['password'];
  Config.port = configJson['port'];
  Config.host = configJson['host'];
  Config.wsHost = configJson['connection']['host'];
  Config.wsPort = configJson['connection']['port'];
  Config.wsToken = configJson['connection']['token'];
  if (Config.token.isEmpty) {
    Logger.error('Please set the password in the configuration file.');
    exit(1);
  }

  // 设置 SIGINT 信号处理器
  ProcessSignal.sigint.watch().listen((signal) {
    Logger.info('Waiting for applications shutdown');
    Logger.info('Application shutdown completed');
    Logger.info('Finished server process [$pid]');
    exit(0);
  });

  // 连接Agent端
  await connectToWs();

  var router = Router();
  var staticHandler = createStaticHandler('web', defaultDocument: 'index.html');
  var staticHandlerWithLogging =
      Pipeline().addMiddleware(customLogRequests()).addHandler(staticHandler);

  router.get('/config', _getConfigFile);

  router.post('/log', (Request request) async {
    final body = await request.readAsString();
    Logger.debug(body);
    return Response.ok('Log received');
  });
  // WebSocket 路由
  router.get('/app/protocol/ws', (Request request) {
    return wsHandler(request);
  });

  var handler = Pipeline()
      .addMiddleware(customLogRequests())
      .addMiddleware(handleAuth(token: Config.token))
      .addHandler(router.call);

  var finalHandler = const Pipeline().addHandler((Request request) {
    if (request.url.path.startsWith('config')) {
      return handler(request);
    } else if (request.url.path.startsWith('app/protocol/ws')) {
      return wsHandler(request);
    } else if (request.url.path.startsWith('log')) {
      return handler(request);
    } else {
      return staticHandlerWithLogging(request);
    }
  });

  var server = await shelf_io.serve(finalHandler, Config.host, Config.port,
      shared: true);
  if (Config.host.contains('::')) {
    Logger.info('Listening on http://[${server.address.host}]:${server.port}');
  } else {
    Logger.info('Listening on http://${server.address.host}:${server.port}');
  }
}

Response _getConfigFile(Request request) {
  try {
    final file = File('config.json');
    if (file.existsSync()) {
      return Response.ok(file.readAsStringSync(),
          headers: {'Content-Type': 'application/json'});
    } else {
      return Response.notFound('Configuration file not found');
    }
  } catch (e) {
    return Response.internalServerError(
        body: 'Error reading the configuration file');
  }
}

// 认证中间件
Middleware handleAuth({required String token}) {
  return (Handler handler) {
    return (Request request) async {
      final authHeader = request.headers['Authorization'];

      if (authHeader == null || authHeader != 'Bearer $token') {
        return Response(
          401,
          body: '{"error": "401 Unauthorized!"}',
          headers: {'Content-Type': 'application/json'},
        );
      }
      return handler(request);
    };
  };
}

// 自定义日志中间件
Middleware customLogRequests() {
  return (Handler innerHandler) {
    return (Request request) async {
      final watch = Stopwatch()..start();
      final response = await innerHandler(request);
      final latency = watch.elapsed;
      Logger.api(request.method, response.statusCode,
          '${request.url}\t\t${latency.inMilliseconds}ms');
      return response;
    };
  };
}

/// WebSocket 桥梁，用于连接Agent端和客户端
var wsHandler = webSocketHandler((webSocket) async {
  // 监听客户端的消息，并转发给Agent端
  webSocket.stream.listen(
    (message) {
      if (wsStatus != 1 || socketToAgent == null) {
        Map<String, dynamic> res = {"type": "pong?", "data": "111真pong吗"};
        String resStr = jsonEncode(res);
        webSocket.sink.add(resStr);
      } else {
        socketToAgent!.add(message);
      }
    },
    onError: (error) {
      Logger.error('Error from client: $error');
    },
    onDone: () {
      Logger.info('Client WebSocket closed.');
    },
    cancelOnError: false,
  );

  // 检查与Agent端的连接状态
  if (wsStatus != 1 || socketToAgent == null) {
    Map<String, dynamic> res = {"type": "pong?", "data": "111真pong吗"};
    String resStr = jsonEncode(res);
    webSocket.sink.add(resStr);
  }

  // 监听Agent端的消息，并转发给客户端
  StreamSubscription? agentSubscription;
  agentSubscription = agentStreamController!.stream.listen(
    (data) {
      webSocket.sink.add(data);
    },
    onError: (error) {
      Logger.error('Error from agent: $error');
      webSocket.sink.add('Error from agent: $error');
    },
    onDone: () {
      Logger.info('Agent connection closed. Retrying after 5 seconds...');
      wsStatus = 0;
      socketToAgent = null;
      reconnectToWs();
      webSocket.sink.add(jsonEncode({"type": "pong?", "data": "111真pong吗"}));
    },
    cancelOnError: false,
  );

  // 使用 onDone 回调处理 WebSocket 关闭事件
  webSocket.stream.listen(
    (_) {},
    onDone: () {
      agentSubscription?.cancel();
    },
  );
});

// 与Agent端建立 WebSocket 连接
Future<void> connectToWs() async {
  if (isReconnecting) return;
  isReconnecting = true;
  try {
    if (Config.wsHost.contains(':')) {
      socketToAgent = await WebSocket.connect(
          'ws://[${Config.wsHost}]:${Config.wsPort}/nbgui/v1/ws');
    } else {
      socketToAgent = await WebSocket.connect(
          'ws://${Config.wsHost}:${Config.wsPort}/nbgui/v1/ws');
    }
    wsStatus = 1;
    Logger.success('WebSocket connection established.');
    agentStreamController = StreamController<dynamic>.broadcast();
    socketToAgent!.listen(
      (data) {
        agentStreamController!.add(data);
      },
      onError: (error) {
        Logger.error('Error from agent: $error');
      },
      onDone: () {
        Logger.warn('Agent connection closed.');
        wsStatus = 0;
        socketToAgent = null;
        reconnectToWs();
      },
      cancelOnError: false,
    );
  } catch (e) {
    wsStatus = 0;
    Logger.error(
        'Failed to connect to agent: $e. Reconnecting in 5 seconds...');
    reconnectToWs();
  } finally {
    isReconnecting = false;
  }
}

Future<void> reconnectToWs() async {
  await Future.delayed(Duration(seconds: 5));
  await connectToWs();
}
