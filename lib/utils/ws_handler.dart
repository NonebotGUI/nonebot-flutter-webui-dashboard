import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:NoneBotWebUI/utils/core.dart';
import 'package:NoneBotWebUI/utils/global.dart';

/// 处理WebSocket消息
Future<void> wsHandler(MessageEvent msg) async {
  /// 解析json
  String? msg0 = msg.data;
  // 检查是否为json
  if (msg0 != null) {
    Map<String, dynamic> msgJson = jsonDecode(msg0);
    String type = msgJson['type'];
    switch (type) {
      // 111真pong吗
      case 'pong?':
        Data.isConnected = false;
        // 尝试重连
        reconnect();
        break;
      // 服务器返回pong
      case 'pong':
        Data.isConnected = true;
        break;
      // 从服务器获取Agent版本信息
      case 'version':
        Data.isConnected = true;
        if (msgJson['data'] is Map) {
          Data.agentVersion = msgJson['data'];
        } else {}
        break;
      // 从服务器获取系统状态
      case 'systemStatus':
        Data.isConnected = true;
        if (msgJson['data'] is Map) {
          Data.cpuUsage = msgJson['data']["cpu_usage"];
          Data.ramUsage = msgJson['data']["ram_usage"];
        } else {}
        break;
      // 从服务器获取平台信息
      case 'platformInfo':
        Data.isConnected = true;
        if (msgJson['data'] is Map) {
          String platform = msgJson['data']['platform'];
          Data.platform = platform;
        } else {}
        break;
      // Bot列表
      case 'botList':
        Data.isConnected = true;
        if (msgJson['data'] is List) {
          Data.botList = msgJson['data'];
        } else {}
        break;
      // Bot信息
      case 'botInfo':
        Data.isConnected = true;
        if (msgJson['data'] is Map) {
          Data.botInfo = msgJson['data'];
        } else {}
        break;
      // Bot日志
      case 'botLog':
        Data.isConnected = true;
        if (msgJson['data'] is String) {
          Data.botLog = msgJson['data'];
        } else {}
        break;
      // Bot错误日志
      case 'botStderr':
        Data.isConnected = true;
        if (msgJson['hasLog']) {
          if (msgJson['data'] is String) {
            Data.hasStderr = true;
            Data.botStderr = msgJson['data'];
          } else {
            Data.hasStderr = false;
            Data.botStderr = '';
          }
        }
        break;
      default:
        break;
    }
  }
}
