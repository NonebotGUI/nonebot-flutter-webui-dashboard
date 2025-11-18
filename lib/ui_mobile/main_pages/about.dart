import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:NoneBotWebUI/assets/my_flutter_app_icons.dart';
import 'package:NoneBotWebUI/utils/global.dart';
import 'dart:ui_web' as ui;
import 'dart:html' as html;

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
  void initState() {
    super.initState();
    socket.send('version&token=${Config.token}');
    Future.delayed(const Duration(milliseconds: 850), () {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  final List<Map<String, String>> _acknowledgements = [
    {
      'avatar': 'http://q1.qlogo.cn/g?b=qq&nk=2125714976&s=100',
      'name': '【夜风】NightWind',
      'contribution': '项目主要维护者',
    },
    {
      'avatar': 'http://q1.qlogo.cn/g?b=qq&nk=1651930562&s=100',
      'name': 'xuebi',
      'contribution': 'WebUI Docker 镜像维护者',
    },
    {
      'avatar': 'http://q1.qlogo.cn/g?b=qq&nk=2740324073&s=100',
      'name': 'Komorebi',
      'contribution': '项目Readme格式贡献者',
    },
    {
      'avatar': 'http://q1.qlogo.cn/g?b=qq&nk=1113956005&s=100',
      'name': 'concy',
      'contribution': '早期测试与反馈',
    },
  ];

  void _showAcknowledgementsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('鸣谢'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: _acknowledgements.length,
              itemBuilder: (context, index) {
                final person = _acknowledgements[index];
                final imageUrl = person['avatar']!;
                final String viewType = 'html-image-$imageUrl-$index';
                ui.platformViewRegistry.registerViewFactory(
                  viewType,
                  (int viewId) {
                    final html.ImageElement imageElement = html.ImageElement()
                      ..src = imageUrl
                      ..style.width = '100%'
                      ..style.height = '100%'
                      ..style.objectFit = 'cover';
                    return imageElement;
                  },
                );

                return ListTile(
                  leading: SizedBox(
                    width: 40.0,
                    height: 40.0,
                    child: ClipOval(
                      child: HtmlElementView(
                        viewType: viewType,
                      ),
                    ),
                  ),
                  title: Text(person['name']!),
                  subtitle: Text(person['contribution']!),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('关闭'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
            width: MediaQuery.of(context).size.height * 0.2,
            height: null,
            fit: BoxFit.contain,
          ),
        ),
        const Center(
            child: Text(
          "NoneBot WebUI",
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        const Center(
          child: Text(
            "_✨新一代NoneBot图形化界面✨_",
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
            ),
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
        ListTile(
          title: const Text('Dashboard 版本',
              textScaler: TextScaler.linear(1.05),
              style: TextStyle(fontWeight: FontWeight.bold)),
          trailing: Text(
            version,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        ListTile(
          title: const Text('Agent 版本',
              textScaler: TextScaler.linear(1.05),
              style: TextStyle(fontWeight: FontWeight.bold)),
          trailing: Text(
            Data.agentVersion['version'],
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        ListTile(
          title: const Text('Python 版本',
              textScaler: TextScaler.linear(1.05),
              style: TextStyle(fontWeight: FontWeight.bold)),
          trailing: Text(
            Data.agentVersion['python'],
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        ListTile(
          title: const Text('nb-cli 版本',
              textScaler: TextScaler.linear(1.05),
              style: TextStyle(fontWeight: FontWeight.bold)),
          trailing: Text(
            Data.agentVersion['nbcli'],
          ),
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
                    text:
                        'https://github.com/NoneBotWebUI/nonebot-flutter-webui-dashboard'));
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
                    const ClipboardData(text: 'https://webui.nbgui.top'));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('已复制到剪贴板'),
                  duration: Duration(seconds: 3),
                ));
              },
              icon: const Icon(Icons.book_rounded),
              tooltip: '文档地址',
              iconSize: 30,
            ),
            // 新增的鸣谢按钮
            IconButton(
              onPressed: _showAcknowledgementsDialog,
              icon: const Icon(Icons.people_alt_rounded),
              tooltip: '鸣谢',
              iconSize: 30,
            ),
          ],
        )
      ]),
    ));
  }
}
