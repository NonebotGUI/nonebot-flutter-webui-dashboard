import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nonebot_webui/ui/MainPages/about.dart';
import 'package:nonebot_webui/ui/MainPages/importBot.dart';
import 'package:nonebot_webui/ui/MainPages/manageBot.dart';
import 'package:nonebot_webui/ui/createbot.dart';
import 'package:nonebot_webui/utils/core.dart';
import 'package:nonebot_webui/utils/global.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class MainPage extends StatefulWidget {
  const MainPage({super.key, required String title});

  @override
  State<MainPage> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MainPage> {
  final myController = TextEditingController();
  int _selectedIndex = 0;
  Timer? timer;
  Timer? timer2;
  int runningCount = 0;
  String title = '主页';

  @override
  void initState() {
    super.initState();
    connectToWebSocket();
    setState(() {
      getSystemStatus();
      getBotLog();
    });
  }

  //每过1.5秒获取一次
  getSystemStatus() async {
    timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) async {
      socket.send('ping?token=114514');
      socket.send('system?token=114514');
      socket.send('platform?token=114514');
      socket.send('botList?token=114514');
      runningCount =
          Data.botList.where((bot) => bot['isRunning'] == true).length;
      // 拿到状态后刷新页面
      setState(() {});
    });
  }

  getBotLog() async {
    timer = Timer.periodic(const Duration(milliseconds: 1500), (timer2) async {
      if (gOnOpen.isNotEmpty) {
        socket.send("bot/log/$gOnOpen?token=114514");
        socket.send("botInfo/$gOnOpen?token=114514");
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    timer2?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dynamic size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    html.document.title = '$title | NoneBot WebUI';
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('NoneBot WebUI', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromRGBO(234, 82, 82, 1),
        automaticallyImplyLeading: false,
      ),
      body: Row(
        children: [
          NavigationRail(
            useIndicator: false,
            selectedIconTheme: IconThemeData(
                color: const Color.fromRGBO(234, 82, 82, 1),
                size: height * 0.03),
            selectedLabelTextStyle: TextStyle(
                color: const Color.fromRGBO(234, 82, 82, 1),
                fontSize: height * 0.02,
                fontFamily: 'HarmonyOS_Sans_SC'),
            unselectedLabelTextStyle: TextStyle(
                fontSize: height * 0.02,
                color: Colors.grey[600],
                fontFamily: 'HarmonyOS_Sans_SC'),
            unselectedIconTheme:
                IconThemeData(color: Colors.grey, size: height * 0.03),
            elevation: 2,
            indicatorShape: const RoundedRectangleBorder(),
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
                switch (index) {
                  case 0:
                    title = '主页';
                    break;
                  case 1:
                    title = 'Bot控制台';
                    break;
                  case 2:
                    title = '创建Bot';
                    break;
                  case 3:
                    title = '导入Bot';
                    break;
                  case 4:
                    title = '关于';
                    break;
                }
                if (_selectedIndex == 1) {
                  socket.send("botInfo/$gOnOpen?token=114514");
                }
              });
            },
            selectedIndex: _selectedIndex,
            extended: true,
            destinations: <NavigationRailDestination>[
              NavigationRailDestination(
                  icon: Icon(
                    _selectedIndex == 0
                        ? Icons.home_rounded
                        : Icons.home_outlined,
                  ),
                  label: const Text('主页'),
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 15)),
              NavigationRailDestination(
                  icon: Icon(
                    _selectedIndex == 1
                        ? Icons.dashboard_rounded
                        : Icons.dashboard_outlined,
                  ),
                  label: const Text('Bot控制台'),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 15)),
              NavigationRailDestination(
                  icon: Icon(
                    _selectedIndex == 2
                        ? Icons.add_rounded
                        : Icons.add_outlined,
                  ),
                  label: const Text('创建Bot'),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 15)),
              NavigationRailDestination(
                  icon: Icon(
                    _selectedIndex == 3
                        ? Icons.file_download_rounded
                        : Icons.file_download_outlined,
                  ),
                  label: const Text('导入Bot'),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 15)),
              NavigationRailDestination(
                  icon: Icon(
                    _selectedIndex == 4
                        ? Icons.info_rounded
                        : Icons.info_outline_rounded,
                  ),
                  label: const Text('关于'),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 15)),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.fromLTRB(32, 20, 32, 12),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.all(4),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Center(
                                            child: SvgPicture.asset(
                                          'lib/assets/icons/CPU.svg',
                                          width: height * 2 / 21,
                                          height: height * 2 / 21,
                                          color: Colors.black,
                                        )),
                                        Center(
                                          child: Text('CPU',
                                              style: TextStyle(
                                                  fontSize: height * 0.02)),
                                        ),
                                        Center(
                                          child: Text(Data.cpuUsage,
                                              style: TextStyle(
                                                  fontSize: height * 0.03)),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.all(4),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Center(
                                            child: SvgPicture.asset(
                                          'lib/assets/icons/RAM.svg',
                                          width: height * 2 / 21,
                                          height: height * 2 / 21,
                                          color: Colors.black,
                                        )),
                                        Center(
                                          child: Text('RAM',
                                              style: TextStyle(
                                                  fontSize: height * 0.02)),
                                        ),
                                        Center(
                                          child: Text(Data.ramUsage,
                                              style: TextStyle(
                                                  fontSize: height * 0.03)),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.all(4),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Center(
                                            child: SvgPicture.asset(
                                          'lib/assets/icons/bot.svg',
                                          width: height * 2 / 21,
                                          height: height * 2 / 21,
                                          color: Colors.black,
                                        )),
                                        Center(
                                          child: Text('运行中',
                                              style: TextStyle(
                                                  fontSize: height * 0.02)),
                                        ),
                                        Center(
                                          child: Text(
                                              '$runningCount/${Data.botList.length}',
                                              style: TextStyle(
                                                  fontSize: height * 0.03)),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Container(
                                          margin: const EdgeInsets.all(4),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(
                                                Icons.computer,
                                                size: height * 0.050,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(Data.platform,
                                                  style: TextStyle(
                                                      fontSize:
                                                          height * 0.025)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Container(
                                          margin: const EdgeInsets.all(4),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(
                                                Icons
                                                    .electrical_services_outlined,
                                                size: height * 0.055,
                                              ),
                                              const SizedBox(
                                                width: 4,
                                              ),
                                              Data.isConnected
                                                  ? Text('已连接',
                                                      style: TextStyle(
                                                          color: Colors.green,
                                                          fontSize:
                                                              height * 0.025))
                                                  : Text('未连接',
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize:
                                                              height * 0.025)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // const Divider(
                      //   height: 20,
                      //   thickness: 2,
                      //   indent: 20,
                      //   endIndent: 20,
                      //   color: Colors.grey,
                      // ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      Expanded(
                          flex: 5,
                          child: Column(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Bot列表',
                                    style: TextStyle(
                                        fontSize: height * 0.03,
                                        fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(
                                height: height * 0.01,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Text('名称',
                                        style: TextStyle(
                                            fontSize: height * 0.02,
                                            fontWeight: FontWeight.bold,
                                            textBaseline:
                                                TextBaseline.alphabetic),
                                        textAlign: TextAlign.center),
                                  ),
                                  Expanded(
                                    child: Text('状态',
                                        style: TextStyle(
                                            fontSize: height * 0.02,
                                            fontWeight: FontWeight.bold,
                                            textBaseline:
                                                TextBaseline.alphabetic),
                                        textAlign: TextAlign.center),
                                  ),
                                  Expanded(
                                    child: Text('操作',
                                        style: TextStyle(
                                            fontSize: height * 0.02,
                                            fontWeight: FontWeight.bold,
                                            textBaseline:
                                                TextBaseline.alphabetic),
                                        textAlign: TextAlign.center),
                                  ),
                                ],
                              ),
                              const Divider(
                                height: 20,
                                thickness: 2,
                                indent: 20,
                                endIndent: 20,
                                color: Colors.grey,
                              ),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: Data.botList.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                        onTap: () {
                                          socket.send(
                                              "botInfo/${Data.botList[index]['id']}?token=114514");
                                          gOnOpen = Data.botList[index]['id'];
                                          setState(() {
                                            _selectedIndex = 1;
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                Data.botList[index]['name'],
                                                style: TextStyle(
                                                  fontSize: height * 0.02,
                                                  fontWeight: FontWeight.bold,
                                                  textBaseline:
                                                      TextBaseline.alphabetic,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Expanded(
                                              child: Data.botList[index]
                                                      ['isRunning']
                                                  ? Text(
                                                      '运行中',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: height * 0.02,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    )
                                                  : Text(
                                                      '未运行',
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: height * 0.02,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                            ),
                                            Expanded(
                                                child: Data.botList[index]
                                                        ['isRunning']
                                                    ? Center(
                                                        child: IconButton(
                                                            icon: const Icon(Icons
                                                                .stop_rounded),
                                                            tooltip: '停止',
                                                            onPressed: () {
                                                              socket.send(
                                                                  'bot/stop/${Data.botList[index]['id']}?token=114514');
                                                            }),
                                                      )
                                                    : Center(
                                                        child: IconButton(
                                                            icon: const Icon(Icons
                                                                .play_arrow_rounded),
                                                            tooltip: '启动',
                                                            onPressed: () {
                                                              socket.send(
                                                                  'bot/run/${Data.botList[index]['id']}?token=114514');
                                                            }),
                                                      )),
                                          ],
                                        ));
                                  },
                                  separatorBuilder: (context, index) {
                                    return Divider(
                                      height: 20,
                                      thickness: 2,
                                      indent: 20,
                                      endIndent: 20,
                                      color: Colors.grey[300],
                                    );
                                  },
                                ),
                              )
                            ],
                          ))
                    ],
                  ),
                ),
                gOnOpen.isNotEmpty
                    ? ManageBot()
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset('lib/assets/loading.gif'),
                            const SizedBox(height: 10),
                            const Text('你还没有选择要打开的bot'),
                          ],
                        ),
                      ),
                const CreateBot(),
                importBot(),
                const About(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
