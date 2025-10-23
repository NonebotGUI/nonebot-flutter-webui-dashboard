import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import '../utils/global.dart';
import '../utils/logger.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

WebSocket? socketToAgent;
int wsStatus = 0;
bool isReconnecting = false;
StreamController<dynamic>? agentStreamController;
var uuid = Uuid();
void main() async {
  Logger.rainbow('logo',
      '  _   _                  ____        _    __        __   _     _   _ ___ ');
  Logger.rainbow('logo',
      ' | \\ | | ___  _ __   ___| __ )  ___ | |_  \\ \\      / /__| |__ | | | |_ _|');
  Logger.rainbow('logo',
      ' |  \\| |/ _ \\| \'_ \\ / _ \\  _ \\ / _ \\| __|  \\ \\ /\\ / / _ \\ \'_ \\| | | || | ');
  Logger.rainbow('logo',
      ' | |\\  | (_) | | | |  __/ |_) | (_) | |_    \\ V  V /  __/ |_) | |_| || | ');
  Logger.rainbow('logo',
      ' |_| \\_|\\___/|_| |_|\\___|____/ \\___/ \\__|    \\_/\\_/ \\___|_.__/ \\___/|___|');
  // 读取配置
  if (!File('config.json').existsSync()) {
    Logger.warn('Configuration file not found, creating a new one...');
    Logger.info('Generating a random password for you...');
    String password = uuid.v4().replaceAll('-', '').substring(0, 8);
    Map<String, dynamic> cfg = {
      "host": "127.0.0.1",
      "port": 8025,
      "password": password,
      "connection": {"host": "127.0.0.1", "port": 2519, "token": ""},
      "connectionMode": 2,
      "checkUpdate": true,
      "theme": {
        "color": "light",
        "img": "default",
        "text": "default",
        "hitokoto": true
      }
    };
    Logger.info('Your random password is: $password');
    Logger.info('You can change it in the config.json file later.');
    String cfgStr = JsonEncoder.withIndent('  ').convert(cfg);
    File('config.json').writeAsStringSync(cfgStr);
  }
  String config = File('config.json').readAsStringSync();
  Map<String, dynamic> configJson = jsonDecode(config);
  Config.dashboradPassword = configJson['password'];
  Config.port = configJson['port'];
  Config.host = configJson['host'];
  Config.wsHost = configJson['connection']['host'];
  Config.wsPort = configJson['connection']['port'];
  Config.wsToken = configJson['connection']['token'];
  Config.checkUpdate = (configJson.containsKey('checkUpdate'))
      ? configJson['checkUpdate']
      : true;
  Config.connectionMode = (configJson.containsKey('connectionMode'))
      ? configJson['connectionMode']
      : 2;
  Config.theme = (configJson.containsKey('theme'))
      ? configJson['theme']
      : {
          "color": "light",
          "img": "default",
          "text": "default",
          "hitokoto": true
        };
  if (!configJson.containsKey('connectionMode')) {
    configJson['connectionMode'] = 2;
    File('config.json')
        .writeAsStringSync(JsonEncoder.withIndent('  ').convert(configJson));
  }
  if (Config.dashboradPassword.isEmpty) {
    Logger.error('Please set the password in the configuration file.');
    Future.delayed(Duration(seconds: 5)).then((value) => exit(1));
  }
  if (!File("secret.key").existsSync()) {
    Logger.info('Generating secret key...');
    String secret = generateSecretKey(64);
    File("secret.key").writeAsStringSync(secret);
  }
  if (Config.wsToken.isEmpty) {
    Logger.error(
        'WebSocket connection token is empty, please set it in the configuration file.');
    Future.delayed(Duration(seconds: 5)).then((value) => exit(1));
  }

  // 设置 SIGINT 信号处理器
  ProcessSignal.sigint.watch().listen((signal) {
    Logger.info('Waiting for applications shutdown');
    Logger.info('Application shutdown completed');
    Logger.info('Finished server process [$pid]');
    exit(0);
  });

  // 连接Agent端
  if (Config.connectionMode == 2) {
    await connectToWs();
  }

  var router = Router();
  var staticHandler = createStaticHandler('web', defaultDocument: 'index.html');
  var staticHandlerWithLogging =
      Pipeline().addMiddleware(customLogRequests()).addHandler(staticHandler);

  router.get('/config', jwtMiddleware(_getConfigFile));

// 验证jwt
  router.post('/auth', (Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);
    if (data['password'] == Config.dashboradPassword) {
      String secret = File("secret.key").readAsStringSync();
      final now = DateTime.now();
      final formattedDate =
          '${now.year}:${now.month.toString().padLeft(2, '0')}:${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
      final jwt = JWT({"login_time": formattedDate, "Expire": "3 days"});
      final token = jwt.sign(SecretKey(secret), expiresIn: Duration(days: 3));
      return Response.ok(token);
    } else {
      return Response.forbidden('Invalid password');
    }
  });

  router.post('/log', (Request request) async {
    final body = await request.readAsString();
    Logger.debug(body);
    return Response.ok('Log received');
  });

  // 主题配置
  router.get('/theme', (Request request) {
    return Response.ok(jsonEncode(Config.theme),
        headers: {'Content-Type': 'application/json'});
  });

  // WebSocket 路由
  router.get('/app/protocol/ws', (Request request) {
    return wsHandler(request);
  });

  var handler =
      Pipeline().addMiddleware(customLogRequests()).addHandler(router.call);

  var finalHandler = const Pipeline().addHandler((Request request) {
    if (request.url.path.startsWith('config')) {
      return handler(request);
    } else if (request.url.path.startsWith('app/protocol/ws')) {
      return wsHandler(request);
    } else if (request.url.path.startsWith('log')) {
      return handler(request);
    } else if (request.url.path.startsWith('auth')) {
      return handler(request);
    } else if (request.url.path.startsWith('theme')) {
      return handler(request);
    } else {
      return staticHandlerWithLogging(request);
    }
  });

  var server = await shelf_io.serve(finalHandler, Config.host, Config.port,
      shared: true);
  Logger.info('Dashboard server started');
  Logger.info('Dashboard version: $version');
  if (Config.checkUpdate) {
    await check();
  }
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
Middleware jwtMiddleware = (Handler handler) {
  return (Request request) async {
    final authHeader = request.headers['Authorization'];
    if (authHeader != null && authHeader.startsWith('Bearer ')) {
      final token = authHeader.substring(7);
      try {
        String secret = File('secret.key').readAsStringSync();
        JWT.verify(token, SecretKey(secret));
        return handler(request);
      } catch (e) {
        return Response.forbidden('Invalid token');
      }
    } else {
      return Response.forbidden('Missing token');
    }
  };
};

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

// 生成密钥
String generateSecretKey(int length) {
  final random = Random.secure();
  final key = List<int>.generate(length, (_) => random.nextInt(256));
  return base64UrlEncode(key);
}

Future<void> check() async {
  try {
    final response = await http.get(Uri.parse(
        'https://api.github.com/repos/NonebotGUI/nonebot-flutter-webui-dashboard/releases/latest'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final tagName = jsonData['tag_name'];
      final url = jsonData['html_url'];
      if (tagName.toString().replaceAll('v', '') != version) {
        Logger.rainbow('New version',
            '################################################################');
        Logger.rainbow('New version',
            '##                                                            ##');
        Logger.rainbow('New version',
            '##       A new version of Nonebot WebUI is available!         ##');
        Logger.rainbow('New version',
            '##                                                            ##');
        Logger.rainbow('New version',
            '################################################################');
        Logger.info('New version found: $tagName');
        Logger.info('To download the latest version, please visit: $url');
      }
    } else {
      Logger.error('Failed to check for updates');
    }
  } catch (e) {
    Logger.error('Failed to check for updates: $e');
  }
}
