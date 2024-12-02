import 'package:flutter/material.dart';
import 'dart:html';

class WsTest extends StatefulWidget {
  const WsTest({super.key});

  @override
  State<WsTest> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<WsTest> {
  final myController = TextEditingController();
  List<String> serverResponse = [];
  late WebSocket socket; // WebSocket 对象

  String websocketUrl =
      'ws://${Uri.base.host}:${Uri.base.port}/app/protocol/ws';

  @override
  void initState() {
    super.initState();
    connectToWebSocket();
  }

  // 连接 WebSocket
  void connectToWebSocket() {
    try {
      socket = WebSocket(websocketUrl);
      // 监听消息
      socket.onMessage.listen((event) {
        setState(() {
          serverResponse.add(event.data.toString());
        });
      });

      // 监听连接关闭
      socket.onClose.listen((event) {
        setState(() {
          serverResponse.add('Socket disconnected.');
        });
      });

      // 监听错误
      socket.onError.listen((error) {
        setState(() {
          serverResponse.add('Socket error: $error');
        });
      });
    } catch (e) {
      setState(() {
        serverResponse.add('Failed to connect to the WebSocket server: $e');
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    socket.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 8,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              color: const Color.fromARGB(255, 31, 28, 28),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: serverResponse.length,
                  itemBuilder: (context, index) {
                    return Text(
                      serverResponse[index],
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: myController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Send message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded),
                  onPressed: () {
                    if (socket.readyState == WebSocket.OPEN) {
                      socket.send(myController.text); // 使用 add() 发送消息
                      myController.clear();
                    } else {
                      setState(() {
                        serverResponse.add('WebSocket is not connected.');
                      });
                    }
                  },
                  tooltip: "Send message",
                ),
                IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    setState(() {
                      serverResponse.clear();
                    });
                  },
                  tooltip: "Clear message",
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
