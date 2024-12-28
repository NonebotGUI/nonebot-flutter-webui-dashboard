// 全局变量

import 'dart:html';

late String version;
late WebSocket socket;
String gOnOpen = '';

/// 配置文件
class Config {
  /// 访问密码
  static String password = '';

  /// ws 主机
  static String wsHost = 'localhost';

  /// ws 端口
  static int wsPort = 2519;

  /// token
  static String token = 'yee';

  /// 连接模式
  /// 1;直连Agent
  /// 2;通过Self Host Protocol连接Agent
  static int connectionMode = 2;
}

/// 应用程序数据
class Data {
  static bool isConnected = false;

  ///Bot列表
  static List botList = [];

  ///CPU使用率
  static String cpuUsage = "NaN";

  ///RAM使用率
  static String ramUsage = "NaN";

  ///平台
  static String platform = "Unknown";

  ///Bot信息
  static Map botInfo = {
    "name": "Unknown",
    "path": "Unknown",
    "time": "Unknown",
    "isRunning": false,
    "pid": Null
  };

  ///Bot日志
  static String botLog = '';

  ///版本信息
  static Map agentVersion = {
    "version": "Unknown",
    "nbcli": "Unknown",
    "python": "Unknown",
  };

  /// 安装Bot时的日志
  static List installBotLog = [];
}
