import 'package:flutter/material.dart';
import 'dart:html';

import 'package:nonebot_webui/utils/global.dart';
import 'package:nonebot_webui/utils/wsHandler.dart';

void connectToWebSocket() {
  // socket = WebSocket('ws://${Uri.base.host}:${Uri.base.port}/app/protocol/ws');
  socket = WebSocket('ws://127.0.0.1:2519/nbgui/v1/ws');
  socket.onMessage.listen((event) {
    MessageEvent msg = event;
    wsHandler(msg);
  }, cancelOnError: false);
}
