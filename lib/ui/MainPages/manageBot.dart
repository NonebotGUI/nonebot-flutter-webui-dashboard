import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nonebot_webui/utils/global.dart';

class ManageBot extends StatefulWidget {
  const ManageBot({super.key});

  @override
  State<ManageBot> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ManageBot> {
  Timer? timer;

  // @override
  // void initState() {
  //   super.initState();
  //   refresh();
  // }

  // @override
  // void dispose() {
  //   timer?.cancel();
  //   super.dispose();
  // }

  // void refresh() {
  //   timer = Timer.periodic(const Duration(microseconds: 1500), (timer) {
  //     setState(() {
  //       print(Data.botInfo);
  //       print(gOnOpen);
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    dynamic size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    return Scaffold(
        body: Container(
      margin: EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Container(
                margin: EdgeInsets.all(8),
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
                    const Padding(
                      padding: EdgeInsets.all(4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "名称",
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
                        child: Text(
                          Data.botInfo['name'],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              flex: 7,
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
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    color:
                                        const Color.fromARGB(255, 31, 28, 28),
                                    child: Container(),
                                  ),
                                ),
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
                          margin: EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "操作",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    IconButton(
                                      icon:
                                          const Icon(Icons.play_arrow_rounded),
                                      onPressed: () {},
                                      tooltip: "启动",
                                      iconSize: height * 0.03,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.stop_rounded),
                                      onPressed: () {},
                                      tooltip: "停止",
                                      iconSize: height * 0.03,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.refresh_rounded),
                                      onPressed: () {},
                                      tooltip: "重启",
                                      iconSize: height * 0.03,
                                    ),
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
    ));
  }
}

///终端字体颜色
//这一段AI写的我什么也不知道😭
List<TextSpan> _logSpans(text) {
  RegExp regex = RegExp(
    r'(\[[A-Z]+\])|(nonebot \|)|(uvicorn \|)|(Env: dev)|(Env: prod)|(Config)|(nonebot_plugin_[\S]+)|("nonebot_plugin_[\S]+)|(使用 Python: [\S]+)|(Loaded adapters: [\S]+)|(\d{2}-\d{2} \d{2}:\d{2}:\d{2})|(Calling API [\S]+)',
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
      const Padding(
        padding: EdgeInsets.all(4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "名称",
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
          child: Text(
            Data.botInfo['name'],
          ),
        ),
      ),
    ],
  );
}
