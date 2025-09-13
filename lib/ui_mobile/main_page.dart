import 'dart:async';
import 'package:NoneBotWebUI/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:NoneBotWebUI/ui_mobile/main_pages/about.dart';
import 'package:NoneBotWebUI/ui/main_pages/import_bot.dart';
import 'package:NoneBotWebUI/ui_mobile/main_pages/manage_bot.dart';
import 'package:NoneBotWebUI/ui/main_pages/createbot.dart';
import 'package:NoneBotWebUI/utils/core.dart';
import 'package:NoneBotWebUI/utils/global.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _visible = false;
  Map hitokoto = {'hitokoto': '加载中', 'from': 'XD'};

  @override
  void initState() {
    super.initState();
    connectToWebSocket();
    setState(() {
      getSystemStatus();
      getBotLog();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showHitokoto();
    });
    if (Config.hitokoto) {
      getHitokoto();
    }
  }

  void _showHitokoto() {
    setState(() => _visible = true);
    Timer(const Duration(seconds: 10), () {
      setState(() => _visible = false);
    });
  }

  getHitokoto() async {
    final response = await http.get(Uri.parse('https://v1.hitokoto.cn'));
    if (response.statusCode == 200) {
      hitokoto = jsonDecode(response.body);
      Future.delayed(const Duration(seconds: 1), () {
        _showHitokoto();
      });
    }
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

  logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Widget _buildDrawerItem(
      {required IconData icon, required String text, required int index}) {
    return ListTile(
      leading: Icon(
        icon,
        color: index == _selectedIndex
            ? Config.theme['color'] == 'light' ||
                    Config.theme['color'] == 'default'
                ? const Color.fromRGBO(234, 82, 82, 1)
                : const Color.fromRGBO(147, 112, 219, 1)
            : Config.theme['color'] == 'light' ||
                    Config.theme['color'] == 'default'
                ? Colors.grey[600]
                : Colors.white,
      ),
      title: Text(text,
          style: TextStyle(
              color: index == _selectedIndex
                  ? Config.theme['color'] == 'light' ||
                          Config.theme['color'] == 'default'
                      ? const Color.fromRGBO(234, 82, 82, 1)
                      : const Color.fromRGBO(147, 112, 219, 1)
                  : Config.theme['color'] == 'light' ||
                          Config.theme['color'] == 'default'
                      ? Colors.grey[600]
                      : Colors.white)),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    dynamic size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    html.document.title = '$title | NoneBot WebUI';
    return Scaffold(
        appBar: AppBar(
          title: const Text('NoneBot WebUI',
              style: TextStyle(color: Colors.white)),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.brightness_6),
              onPressed: () {
                themeNotifier.toggleTheme();
                setState(() {
                  if (Config.theme['color'] == 'light' ||
                      Config.theme['color'] == 'default') {
                    Config.theme['color'] = 'dark';
                  } else {
                    Config.theme['color'] = 'light';
                  }
                });
              },
              color: Colors.white,
            ),
            IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: '登出',
                color: Colors.white,
                onPressed: () {
                  logout();
                  html.window.location.reload();
                })
          ],
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
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              _buildDrawerItem(
                icon: Icons.home,
                text: '主页',
                index: 0,
              ),
              _buildDrawerItem(
                icon: Icons.dashboard_rounded,
                text: 'Bot控制台',
                index: 1,
              ),
              _buildDrawerItem(
                icon: Icons.add_rounded,
                text: '创建',
                index: 2,
              ),
              _buildDrawerItem(
                icon: Icons.download_rounded,
                text: '导入',
                index: 3,
              ),
              _buildDrawerItem(
                icon: Icons.balance_rounded,
                text: '开源许可证',
                index: 4,
              ),
              _buildDrawerItem(
                icon: Icons.info,
                text: '关于',
                index: 5,
              ),
            ],
          ),
        ),
        body: Stack(children: [
          Column(
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
                                                  'lib/assets/icons/CPU.svg',
                                                  width: width * 2 / 21,
                                                  height: width * 2 / 21,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black,
                                                )),
                                                Center(
                                                  child: Text('CPU',
                                                      style: TextStyle(
                                                          fontSize:
                                                              height * 0.02)),
                                                ),
                                                Center(
                                                  child: Text(Data.cpuUsage,
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
                                                  'lib/assets/icons/RAM.svg',
                                                  width: width * 2 / 21,
                                                  height: width * 2 / 21,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black,
                                                )),
                                                Center(
                                                  child: Text('RAM',
                                                      style: TextStyle(
                                                          fontSize:
                                                              height * 0.02)),
                                                ),
                                                Center(
                                                  child: Text(Data.ramUsage,
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
                                                    color: isDark
                                                        ? Colors.white
                                                        : Colors.black,
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
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.all(4),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.computer,
                                                          size: height * 0.050,
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(Data.platform,
                                                            style: TextStyle(
                                                                fontSize:
                                                                    height *
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
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.all(4),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
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
                                                                    color: Colors
                                                                        .red,
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
                                              gOnOpen =
                                                  Data.botList[index]['id'];
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      textBaseline: TextBaseline
                                                          .alphabetic,
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
                                                            fontSize:
                                                                height * 0.02,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        )
                                                      : Text(
                                                          '未运行',
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize:
                                                                height * 0.02,
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
                                                                icon: const Icon(
                                                                    Icons
                                                                        .stop_rounded),
                                                                tooltip: '停止',
                                                                onPressed: () {
                                                                  socket.send(
                                                                      'bot/stop/${Data.botList[index]['id']}?token=${Config.token}');
                                                                }),
                                                          )
                                                        : Center(
                                                            child: IconButton(
                                                                icon: const Icon(
                                                                    Icons
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
                    LicensePage(
                      applicationName: 'NoneBot WebUI',
                      applicationVersion: version,
                      applicationIcon: const Image(
                        image: AssetImage('lib/assets/logo.png'),
                        width: 100,
                        height: 100,
                      ),
                    ),
                    const About(),
                  ],
                ),
              )
            ],
          ),
          AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              top: 20,
              right: _visible ? 0 : width * -0.8,
              child: Card(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Text(
                              '一言',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                                child: Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  setState(() {
                                    _visible = false;
                                  });
                                },
                              ),
                            )),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(hitokoto['hitokoto'],
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.02)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              '——${hitokoto['from']}',
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height *
                                      0.02),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )),
        ]));
  }
}
