import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:NoneBotWebUI/utils/global.dart';

class ManageBot extends StatefulWidget {
  const ManageBot({super.key});

  @override
  State<ManageBot> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ManageBot> {
  Timer? _scrollTimer;
  Timer? _updateTimer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
    //_refresh();
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startScrollToBottomTimer() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer(const Duration(seconds: 5), _scrollToBottom);
  }

  void _refresh() {
    _updateTimer?.cancel();
    _updateTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {});
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic size = MediaQuery.of(context).size;
    double height = size.height;
    return Scaffold(
        body: NotificationListener(
      onNotification: (ScrollNotification notification) {
        if (notification is UserScrollNotification ||
            notification is ScrollUpdateNotification) {
          _startScrollToBottomTimer();
        }
        return false;
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    children: <Widget>[
                      const Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Bot信息",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(),
                      _item('名称', Data.botInfo['name']),
                      _item('ID', Data.botInfo['id']),
                      _item('路径', Data.botInfo['path']),
                      _item('PID', Data.botInfo['pid'].toString()),
                      Expanded(
                          child: Column(
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.all(4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "状态",
                                textScaler: TextScaler.linear(1.4),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Data.botInfo['isRunning']
                                  ? const Text(
                                      "运行中",
                                      textScaler: TextScaler.linear(1.2),
                                      style: TextStyle(
                                        color: Colors.green,
                                      ),
                                    )
                                  : const Text(
                                      "未运行",
                                      style: TextStyle(
                                        color: Color.fromRGBO(234, 82, 82, 1),
                                      ),
                                      textScaler: TextScaler.linear(1.2),
                                    ),
                            ),
                          ),
                        ],
                      )),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: size.width * 0.2,
                        child: OutlinedButton(
                          child: const Icon(Icons.edit_rounded),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  TextEditingController _controller =
                                      TextEditingController();
                                  return AlertDialog(
                                    title: const Text('重命名Bot'),
                                    content: TextField(
                                      controller: _controller,
                                      decoration: const InputDecoration(
                                        hintText: '请输入新的Bot名称',
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('取消'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (_controller.text.isNotEmpty) {
                                            Map data = {
                                              'id': Data.botInfo['id'],
                                              'name': _controller.text
                                            };
                                            String res = jsonEncode(data);
                                            socket.send(
                                                'bot/rename?data=$res?token=${Config.token}');
                                            Navigator.of(context).pop();
                                          }
                                        },
                                        child: const Text('确定'),
                                      ),
                                    ],
                                  );
                                });
                          },
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.2,
                        child: OutlinedButton(
                          child: const Icon(Icons.delete_rounded),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('删除Bot'),
                                    content: const Text('确定删除Bot吗？'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('取消'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          socket.send(
                                              'bot/delete/${Data.botInfo['id']}?token=${Config.token}');
                                          gOnOpen = '';
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('确定(连同目录一起删除)',
                                            style: TextStyle(
                                              color: Colors.red,
                                            )),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          socket.send(
                                              'bot/remove/${Data.botInfo['id']}?token=${Config.token}');
                                          gOnOpen = '';
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          '确定',
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      )
                                    ],
                                  );
                                });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 8,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 15,
                      child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              margin: EdgeInsets.all(8),
                              child: Column(
                                children: <Widget>[
                                  const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "控制台输出",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      child: Stack(
                                    children: <Widget>[
                                      Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          color: const Color.fromARGB(
                                              255, 31, 28, 28),
                                          child: Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            margin: const EdgeInsets.all(8),
                                            child: SingleChildScrollView(
                                              controller: _scrollController,
                                              child: SelectableText.rich(
                                                TextSpan(
                                                  children:
                                                      _logSpans(Data.botLog),
                                                  style: const TextStyle(
                                                    fontFamily: 'JetBrainsMono',
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )),
                                      Positioned(
                                        bottom: 10,
                                        right: 10,
                                        child: FloatingActionButton(
                                          tooltip: '滚动到底部',
                                          onPressed: () {
                                            _scrollController.animateTo(
                                              _scrollController
                                                  .position.maxScrollExtent,
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              curve: Curves.easeOut,
                                            );
                                          },
                                          mini: true,
                                          backgroundColor: Colors.grey[800],
                                          child: const Icon(
                                              Icons.arrow_downward,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  )),
                                ],
                              ))),
                    ),
                    Expanded(
                      flex: 2,
                      child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            margin: const EdgeInsets.all(8),
                            child: Column(
                              children: <Widget>[
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      IconButton(
                                        icon: const Icon(
                                            Icons.play_arrow_rounded),
                                        onPressed: () {
                                          Data.botInfo['isRunning']
                                              ? ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Bot已经在运行了！'),
                                                  ),
                                                )
                                              : socket.send(
                                                  'bot/run/${Data.botInfo['id']}?token=${Config.token}');
                                        },
                                        tooltip: "启动",
                                        iconSize: height * 0.03,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.stop_rounded),
                                        onPressed: () {
                                          Data.botInfo['isRunning']
                                              ? socket.send(
                                                  'bot/stop/${Data.botInfo['id']}?token=${Config.token}')
                                              : ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Bot未运行！'),
                                                  ),
                                                );
                                        },
                                        tooltip: "停止",
                                        iconSize: height * 0.03,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.refresh_rounded),
                                        onPressed: () {
                                          Data.botInfo['isRunning']
                                              ? socket.send(
                                                  'bot/restart/${Data.botInfo['id']}?token=${Config.token}')
                                              : ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Bot未运行！'),
                                                  ),
                                                );
                                        },
                                        tooltip: "重启",
                                        iconSize: height * 0.03,
                                      ),
                                      // IconButton(
                                      //   icon:
                                      //       const Icon(Icons.terminal_outlined),
                                      //   tooltip: '管理Bot',
                                      //   iconSize: height * 0.03,
                                      //   onPressed: () {
                                      //     Navigator.pushNamed(
                                      //         context, '/manageBot');
                                      //   },
                                      // )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )),
                    ),
                  ],
                )),
          ],
        ),
      ),
    ));
  }
}

///终端字体颜色
//这一段AI写的我什么也不知道😭
List<TextSpan> _logSpans(text) {
  RegExp regex = RegExp(
    r'(\[[A-Z]+\])|(nonebot \|)|(uvicorn \|)|(Env: dev)|(Env: prod)|(Config)|(nonebot_plugin_[\S]+)|("nonebot_plugin_[\S]+)|(使用 Python: [\S]+)|(Using Python: [\S]+)|(Loaded adapters: [\S]+)|(\d{2}-\d{2} \d{2}:\d{2}:\d{2})|(Calling API [\S]+)',
  );
  List<TextSpan> spans = [];
  int lastEnd = 0;

  for (Match match in regex.allMatches(text)) {
    if (match.start > lastEnd) {
      spans.add(TextSpan(
        text: text.substring(lastEnd, match.start),
        style: const TextStyle(color: Colors.white),
      ));
    }

    Color color;
    switch (match.group(0)) {
      case '[SUCCESS]':
        color = Colors.greenAccent;
        break;
      case '[INFO]':
        color = Colors.white;
        break;
      case '[WARNING]':
        color = Colors.orange;
        break;
      case '[ERROR]':
        color = Colors.red;
        break;
      case '[DEBUG]':
        color = Colors.blue;
        break;
      case 'nonebot |':
        color = Colors.green;
        break;
      case 'uvicorn |':
        color = Colors.green;
        break;
      case 'Env: dev':
        color = Colors.orange;
        break;
      case 'Env: prod':
        color = Colors.orange;
        break;
      case 'Config':
        color = Colors.orange;
        break;
      default:
        if (match.group(0)!.startsWith('nonebot_plugin_')) {
          color = Colors.yellow;
        } else if (match.group(0)!.startsWith('"nonebot_plugin_')) {
          color = Colors.yellow;
        } else if (match.group(0)!.startsWith('Loaded adapters:')) {
          color = Colors.greenAccent;
        } else if (match.group(0)!.startsWith('使用 Python:')) {
          color = Colors.greenAccent;
        } else if (match.group(0)!.startsWith('Using Python:')) {
          color = Colors.greenAccent;
        } else if (match.group(0)!.startsWith('Calling API')) {
          color = Colors.purple;
        } else if (match.group(0)!.contains('-') &&
            match.group(0)!.contains(':')) {
          color = Colors.green;
        } else {
          color = Colors.white;
        }
        break;
    }

    spans.add(TextSpan(
      text: match.group(0),
      style: TextStyle(color: color),
    ));

    lastEnd = match.end;
  }
  if (lastEnd < text.length) {
    spans.add(TextSpan(
      text: text.substring(lastEnd),
      style: const TextStyle(color: Colors.white),
    ));
  }

  return spans;
}

// 组件模板
Widget _item(String title, content) {
  return Column(
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            textScaler: const TextScaler.linear(1.4),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            content,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textScaler: const TextScaler.linear(1.2),
          ),
        ),
      ),
    ],
  );
}
