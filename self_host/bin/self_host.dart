import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import '../utils/core.dart';
import '../utils/global.dart';
import '../utils/logger.dart';

void main() async {
  // 读取配置
  String config = File('self_host.json').readAsStringSync();
  Map<String, dynamic> configJson = jsonDecode(config);
  Config.token = configJson['password'];
  Config.port = configJson['port'];
  Config.host = configJson['host'];
  Config.wsHost = configJson['connection']['host'];
  Config.wsPort = configJson['connection']['port'];
  Config.wsToken = configJson['connection']['token'];

  // 设置SIGINT信号处理器
  ProcessSignal.sigint.watch().listen((signal) {
    Logger.info('Waiting for applications shutdown');
    Logger.info('Application shutdown completed');
    Logger.info('Finished server process [$pid]');
    exit(0);
  });


  connectToWs();
  var router = Router();
  var staticHandler = createStaticHandler('web', defaultDocument: 'index.html');
  var staticHandlerWithLogging =
      Pipeline().addMiddleware(customLogRequests()).addHandler(staticHandler);

  router.get('/config', _getConfigFile);

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
    } else {
      return staticHandlerWithLogging(request);
    }
  });

  await shelf_io.serve((Request request) {
    if (request.url.path == 'app/protocol/ws') {
      return wsHandler(request);
    }
    return finalHandler(request);
  }, Config.host, Config.port, shared: true);

  var server = await shelf_io.serve(finalHandler, Config.host, Config.port,
      shared: true);
  if (Config.host.contains('::')) {
    Logger.info('Serving at http://[${server.address.host}]:${server.port}');
  } else {
    Logger.info('Serving at http://${server.address.host}:${server.port}');
  }
}

Response _getConfigFile(Request request) {
  try {
    final file = File('self_host.json');
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

/// WebSocket 桥梁，用于连接主机

var wsHandler = webSocketHandler((webSocket) async {
  // 监听客户端消息，并处理错误
  webSocket.stream.listen(
    (message) async {
      message = message.toString().trim();
      socket.add(message);
      // 监听主机消息
      socket.listen((event) {
        webSocket.sink.add(event);
      },);
    },
    onError: (error, stackTrace) {
      Logger.error('$error\nStack Trace:\n$stackTrace');
      webSocket.sink.add('Error processing your request.$error');
    },
    cancelOnError: true,
  );
});
