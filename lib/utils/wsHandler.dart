import 'dart:convert';
import 'dart:html';
import 'package:nonebot_webui/utils/global.dart';

/// 处理WebSocket消息
void wsHandler(MessageEvent msg) {
  /// 解析json
  String msg0 = msg.data;
  Map<String, dynamic> msgJson = jsonDecode(msg0);
  String type = msgJson['type'];
  switch (type) {
    // 111真pong吗
    case 'pong?':
      Data.isConnected = false;
      break;
    // 服务器返回pong
    case 'pong':
      Data.isConnected = true;
      break;
    // 从服务器获取系统状态
    case 'systemStatus':
      if (msgJson['data'] is Map) {
        Data.cpuUsage = msgJson['data']["cpu_usage"];
        Data.ramUsage = msgJson['data']["ram_usage"];
      } else {}
      break;
    // 从服务器获取平台信息
    case 'platformInfo':
      if (msgJson['data'] is Map) {
        String platform = msgJson['data']['platform'];
        Data.platform = platform;
      } else {}
      break;
    // Bot列表
    case 'botList':
      if (msgJson['data'] is List) {
        Data.botList = msgJson['data'];
      } else {}
      break;
    // Bot信息
    case 'botInfo':
      if (msgJson['data'] is Map) {
        Data.botInfo = msgJson['data'];
      } else {}
      break;
    default:
      break;
  }
}
