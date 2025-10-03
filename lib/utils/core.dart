import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:NoneBotWebUI/utils/global.dart';
import 'package:NoneBotWebUI/utils/ws_handler.dart';

Timer? timer;

void connectToWebSocket() {
  //连接到WebSocket
  late String wsUrl;
  if (debug) {
    wsUrl = 'ws://localhost:2519/nbgui/v1/ws';
    Config.token = '1823dbcd';
  } else {
    wsUrl = (Config.connectionMode == 1)
        ? (window.location.protocol == 'https:')
            ? 'wss://${Config.wsHost}:${Config.wsPort}/nbgui/v1/ws'
            : 'ws://${Config.wsHost}:${Config.wsPort}/nbgui/v1/ws'
        : (window.location.protocol == 'https:')
            ? 'wss://${window.location.hostname}:${Uri.base.port}/app/protocol/ws'
            : 'ws://${window.location.hostname}:${Uri.base.port}/app/protocol/ws';
  }
  socket = WebSocket(wsUrl);
  // socket = WebSocket('ws://localhost:2519/nbgui/v1/ws');
  socket.onMessage.listen((event) {
    MessageEvent msg = event;
    wsHandler(msg);
  }, cancelOnError: false);
}

void reconnect() {
  //循环重连
  timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
    if (Data.isConnected) {
      timer.cancel();
    } else {
      socket.close();
      connectToWebSocket();
    }
  });
}
