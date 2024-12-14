import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:html';

import 'package:NoneBotWebUI/utils/global.dart';
import 'package:NoneBotWebUI/utils/wsHandler.dart';

Timer? timer;

void connectToWebSocket() {
  socket = WebSocket(
      'ws://${window.location.hostname}:${Uri.base.port}/app/protocol/ws');
  // socket = WebSocket('ws://127.0.0.1:2519/nbgui/v1/ws');
  // socket = WebSocket('ws://127.0.0.1:8080/app/protocol/ws');
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
