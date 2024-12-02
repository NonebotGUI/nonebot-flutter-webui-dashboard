import 'dart:io';
import 'global.dart';
import 'logger.dart';

Future<void> connectToWs() async {
  try {
    socket = await WebSocket.connect(
        'ws://${Config.wsHost}:${Config.wsPort}/nbgui/v1/ws');
    socket.add('ping?token=${Config.wsToken}');
    socket.listen((event) async {
      if (event.toString().contains('pong!')) {
        Logger.success(
            'WebSocket connection to ${Config.wsHost}:${Config.wsPort} established');
      }
    }, onDone: () {
      Logger.warn('WebSocket connection closed. Reconnecting...');
      _reconnectToWs();
    }, onError: (error) {
      Logger.error('Error with WebSocket connection: $error');
      _reconnectToWs();
    });
  } catch (e) {
    Logger.error('Failed to connect to WebSocket server: $e');
    Logger.error('Retrying connection in 5 seconds...');
    _reconnectToWs();
  }
}
Future<void> _reconnectToWs() async {
  await Future.delayed(Duration(seconds: 5));
  await connectToWs();
}
