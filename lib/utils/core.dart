import 'dart:async';
import 'dart:html';
import 'package:NoneBotWebUI/utils/global.dart';
import 'package:NoneBotWebUI/utils/ws_handler.dart';

Timer? timer;

void connectToWebSocket() {
  //连接到WebSocket
  String wsUrl = (Config.connectionMode == 1)
      ? 'ws://${Config.wsHost}:${Config.wsPort}/nbgui/v1/ws'
      : 'ws://${window.location.hostname}:${Uri.base.port}/app/protocol/ws';
  socket = WebSocket(wsUrl);
  socket.onMessage.listen((event) {
    MessageEvent msg = event;
    wsHandler(msg);
  }, cancelOnError: false);
}

void reconnect() {
  //循环重连
  timer = Timer.periodic(Duration(milliseconds: 1500), (timer) {
    if (Data.isConnected) {
      timer.cancel();
    } else {
      socket.close();
      connectToWebSocket();
    }
  });
}
