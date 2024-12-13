import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nonebot_webui/assets/my_flutter_app_icons.dart';
import 'package:nonebot_webui/utils/global.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _MoreState();
}

class _MoreState extends State<About> {
  int tapCount = 0;
  final int tapsToReveal = 9;
  bool showImage = false;

  void _handleTap() {
    setState(() {
      tapCount++;
      if (tapCount >= tapsToReveal) {
        showImage = true;
      }
    });
  }

  void _resetCounter() {
    setState(() {
      tapCount = 0;
      showImage = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(children: <Widget>[
        Center(
          child: Image.asset(
            'lib/assets/logo.png',
            width: MediaQuery.of(context).size.width * 0.2,
            height: null,
            fit: BoxFit.contain,
          ),
        ),
        Center(
            child: Text(
          "NoneBot WebUI",
          style: TextStyle(
              fontSize: MediaQuery.of(context).textScaleFactor * 35.0,
              fontWeight: FontWeight.bold),
        )),
        const Center(
          child: Text(
            "_✨新一代NoneBot图形化界面✨_",
          ),
        ),
        const Divider(
          height: 20,
          thickness: 2,
          indent: 20,
          endIndent: 20,
          color: Colors.grey,
        ),
        const SizedBox(
          height: 8,
        ),
        Row(children: <Widget>[
          const Expanded(
              child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '软件版本',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          )),
          Expanded(
              child: Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              child: Text(version.replaceAll('v', '').replaceAll('+fix', '.')),
              onTap: () {
                if (showImage) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Material(
                        color: Colors.transparent,
                        child: Center(
                          child: AlertDialog(
                            title: Row(
                              children: <Widget>[
                                Image.asset(
                                  'lib/assets/loading.gif',
                                  width: 180 * 0.15,
                                  height: 180 * 0.15,
                                ),
                                const Text('UWU')
                              ],
                            ),
                            content: InkWell(
                              child: Image.asset('lib/assets/colorEgg.png'),
                              onTap: () {
                                _resetCounter();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  _handleTap();
                }
              },
            ),
          ))
        ]),
        const SizedBox(
          height: 16,
        ),
        Row(
          children: <Widget>[
            const Expanded(
                child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '平台',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )),
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text("Web"),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              onPressed: () {
                Clipboard.setData(const ClipboardData(
                    text: 'https://github.com/NoneBotGUI/nonebot-flutter-gui'));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('项目仓库链接已复制到剪贴板'),
                  duration: Duration(seconds: 3),
                ));
              },
              icon: const Icon(MyFlutterApp.github),
              tooltip: '项目仓库地址',
              iconSize: 30,
            ),
            IconButton(
              onPressed: () {
                Clipboard.setData(
                    const ClipboardData(text: 'https://doc.nbgui.top'));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('已复制到剪贴板'),
                  duration: Duration(seconds: 3),
                ));
              },
              icon: const Icon(Icons.book_rounded),
              tooltip: '文档地址',
              iconSize: 30,
            ),
            IconButton(
              icon: const Icon(Icons.balance_rounded),
              tooltip: '开源许可证',
              onPressed: () => showLicensePage(
                  context: context,
                  applicationName: 'NoneBot WebUI',
                  applicationVersion: version,
                  applicationIcon: Image.asset(
                    'lib/assets/logo.png',
                  )),
            )
          ],
        )
      ]),
    ));
  }
}
