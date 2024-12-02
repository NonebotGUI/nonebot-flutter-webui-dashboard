 import 'dart:io';

late WebSocket socket;


/// 用户配置
class Config {
  /// 面板端口
  static late int port;

  /// 面板密码
  static String token = '';

  /// 监听主机地址
  static String host = '0.0.0.0';

  /// ws连接地址
  static String wsHost = '';

  /// ws连接端口
  static late int wsPort;

  /// ws连接token
  static String wsToken = '';
}

