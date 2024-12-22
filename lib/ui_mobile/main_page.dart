import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:NoneBotWebUI/ui_mobile/main_pages/about.dart';
import 'package:NoneBotWebUI/ui/main_pages/import_bot.dart';
import 'package:NoneBotWebUI/ui_mobile/main_pages/manage_bot.dart';
import 'package:NoneBotWebUI/ui/main_pages/createbot.dart';
import 'package:NoneBotWebUI/utils/core.dart';
import 'package:NoneBotWebUI/utils/global.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class MainPageMobile extends StatefulWidget {
  const MainPageMobile({super.key});

  @override
  State<MainPageMobile> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MainPageMobile> {
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
      socket.send('ping?token=${Config.token}');
      socket.send('system?token=${Config.token}');
      socket.send('platform?token=${Config.token}');
      socket.send('botList?token=${Config.token}');
      runningCount =
          Data.botList.where((bot) => bot['isRunning'] == true).length;
      // 拿到状态后刷新页面
      setState(() {});
    });
  }

  getBotLog() async {
    timer = Timer.periodic(const Duration(milliseconds: 1500), (timer2) async {
      if (gOnOpen.isNotEmpty) {
        socket.send("bot/log/$gOnOpen?token=${Config.token}");
        socket.send("botInfo/$gOnOpen?token=${Config.token}");
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
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                child: Column(
              children: <Widget>[
                Image.asset('lib/assets/logo.png', width: 100, height: 100),
                const Text('NoneBot WebUI',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            )),
            ListTile(
              leading: Icon(Icons.home,
                  color: _selectedIndex == 0
                      ? const Color.fromRGBO(234, 84, 84, 1)
                      : Colors.grey[900]),
              title: Text('主页',
                  style: TextStyle(
                      color: _selectedIndex == 0
                          ? const Color.fromRGBO(234, 84, 84, 1)
                          : Colors.grey[900])),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                  title = '主页';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.dashboard_rounded,
                  color: _selectedIndex == 1
                      ? const Color.fromRGBO(234, 84, 84, 1)
                      : Colors.grey[900]),
              title: Text('管理Bot',
                  style: TextStyle(
                      color: _selectedIndex == 1
                          ? const Color.fromRGBO(234, 84, 84, 1)
                          : Colors.grey[900])),
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                  title = '管理Bot';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.add_rounded,
                  color: _selectedIndex == 2
                      ? const Color.fromRGBO(234, 84, 84, 1)
                      : Colors.grey[900]),
              title: Text('创建Bot',
                  style: TextStyle(
                      color: _selectedIndex == 2
                          ? const Color.fromRGBO(234, 84, 84, 1)
                          : Colors.grey[900])),
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                  title = '创建Bot';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.download_rounded,
                  color: _selectedIndex == 3
                      ? const Color.fromRGBO(234, 84, 84, 1)
                      : Colors.grey[900]),
              title: Text('导入Bot',
                  style: TextStyle(
                      color: _selectedIndex == 3
                          ? const Color.fromRGBO(234, 84, 84, 1)
                          : Colors.grey[900])),
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                  title = '导入Bot';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.info,
                  color: _selectedIndex == 4
                      ? const Color.fromRGBO(234, 84, 84, 1)
                      : Colors.grey[900]),
              title: Text('关于',
                  style: TextStyle(
                      color: _selectedIndex == 4
                          ? const Color.fromRGBO(234, 84, 84, 1)
                          : Colors.grey[900])),
              onTap: () {
                setState(() {
                  _selectedIndex = 4;
                  title = '关于';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.balance_rounded,
                  color: _selectedIndex == 5
                      ? const Color.fromRGBO(234, 84, 84, 1)
                      : Colors.grey[900]),
              title: Text('开源许可证',
                  style: TextStyle(
                      color: _selectedIndex == 5
                          ? const Color.fromRGBO(234, 84, 84, 1)
                          : Colors.grey[900])),
              onTap: () {
                setState(() {
                  _selectedIndex = 5;
                  title = '开源许可证';
                });
              },
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                child: Column(
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
                                              width: width * 2 / 21,
                                              height: width * 2 / 21,
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
                                              width: width * 2 / 21,
                                              height: width * 2 / 21,
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
                              ],
                            )),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
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
                                                width: width * 2 / 21,
                                                height: width * 2 / 21,
                                                color: Colors.black,
                                              )),
                                              Center(
                                                child: Text('运行中',
                                                    style: TextStyle(
                                                        fontSize:
                                                            height * 0.02)),
                                              ),
                                              Center(
                                                child: Text(
                                                    '$runningCount/${Data.botList.length}',
                                                    style: TextStyle(
                                                        fontSize:
                                                            height * 0.03)),
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
                                                            fontSize: height *
                                                                0.025)),
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
                                                                color: Colors
                                                                    .green,
                                                                fontSize:
                                                                    height *
                                                                        0.025))
                                                        : Text('未连接',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize:
                                                                    height *
                                                                        0.025)),
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
                            )
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
                                              "botInfo/${Data.botList[index]['id']}?token=${Config.token}");
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
                                                                  'bot/stop/${Data.botList[index]['id']}?token=${Config.token}');
                                                            }),
                                                      )
                                                    : Center(
                                                        child: IconButton(
                                                            icon: const Icon(Icons
                                                                .play_arrow_rounded),
                                                            tooltip: '启动',
                                                            onPressed: () {
                                                              socket.send(
                                                                  'bot/run/${Data.botList[index]['id']}?token=${Config.token}');
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
                    ? const ManageBot()
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
                // Center(
                //   child: Column(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: <Widget>[
                //       Image.asset('lib/assets/loading.gif'),
                //       const SizedBox(height: 10),
                //       const Text('前面的区域以后再来探索吧'),
                //     ],
                //   ),
                // ),
                importBot(),
                const About(),
                LicensePage(
                  applicationName: 'NoneBot WebUI',
                  applicationVersion: version,
                  applicationIcon: const Image(
                    image: AssetImage('lib/assets/logo.png'),
                    width: 100,
                    height: 100,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
