import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:NoneBotWebUI/utils/global.dart';

class importBot extends StatefulWidget {
  importBot({super.key});

  @override
  State<importBot> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<importBot> {
  final myController = TextEditingController();
  final pathController = TextEditingController();
  final protocolPathController = TextEditingController();
  final protocolCmdController = TextEditingController();
  String name = 'ImportBot';
  String path = '';
  String protocolPath = '';
  String protocolCmd = '';

  @override
  Widget build(BuildContext context) {
    dynamic size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    return Scaffold(
        body: Container(
            margin: const EdgeInsets.all(16.0),
            child: Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Container(
                    padding: const EdgeInsets.all(8),
                    width: width * 0.8,
                    height: height * 0.8,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          flex: 6,
                          child: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                SingleChildScrollView(
                                  child: Column(
                                    children: <Widget>[
                                      const Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "填入名称",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textScaler: TextScaler.linear(1.1),
                                          )),
                                      const SizedBox(height: 16),
                                      TextField(
                                        controller: myController,
                                        decoration: const InputDecoration(
                                          labelText: '名称',
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color.fromRGBO(
                                                  234, 82, 82, 1),
                                              width: 5.0,
                                            ),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          setState(() => name = value);
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      const Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "填入Bot根目录绝对路径",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textScaler: TextScaler.linear(1.1),
                                          )),
                                      const SizedBox(height: 16),
                                      TextField(
                                        controller: pathController,
                                        decoration: const InputDecoration(
                                          labelText: '路径',
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color.fromRGBO(
                                                  234, 82, 82, 1),
                                              width: 5.0,
                                            ),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          setState(() => path = value);
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey,
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Map res = {
                                    'name': name,
                                    'path': path,
                                    'withProtocol': false,
                                    'protocolPath': 'none',
                                    'cmd': 'none'
                                  };
                                  String data = jsonEncode(res);
                                  socket.send(
                                      'bot/import?data=$data?token=${Config.token}');
                                  setState(() {
                                    myController.clear();
                                    pathController.clear();
                                    protocolPathController.clear();
                                    protocolCmdController.clear();
                                    name = 'ImportBot';
                                    path = '';
                                    protocolPath = '';
                                    protocolCmd = '';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('导入请求已发送')));
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      const Color.fromRGBO(234, 82, 82, 1)),
                                  shape: MaterialStateProperty.all(
                                      const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)))),
                                  minimumSize: MaterialStateProperty.all(
                                      const Size(100, 40)),
                                ),
                                child: const Text(
                                  '导入',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
              ),
            )));
  }
}
