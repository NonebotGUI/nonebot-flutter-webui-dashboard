import 'dart:async';
import 'dart:convert';
import 'package:NoneBotWebUI/utils/global.dart';
import 'package:flutter/material.dart';

class ManagePlugin extends StatefulWidget {
  const ManagePlugin({super.key});

  @override
  State<ManagePlugin> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ManagePlugin> {
  int _selectedIndex = 0;
  Timer? _timer;
  List pluginList = [];
  List disabledPluginList = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
    socket.onMessage.listen((message) {
      String msg = message.data;
      String type = jsonDecode(msg)['type'];
      if (type == 'pluginList') {
        pluginList = jsonDecode(msg)['data'];
      }
      if (type == 'disabledPluginList') {
        disabledPluginList = jsonDecode(msg)['data'];
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  getData() async {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          socket
              .send('plugin/list/${Data.botInfo['id']}&token=${Config.token}');
          socket.send(
              'plugin/disabledList/${Data.botInfo['id']}&token=${Config.token}');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('管理插件', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: '返回',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        margin: const EdgeInsets.fromLTRB(8, 12, 8, 16),
        child: Column(
          children: <Widget>[
            _selectedIndex == 0
                ? pluginList.isEmpty
                    ? const Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('还没有安装任何插件'),
                              SizedBox(height: 3),
                              Text('你可以前往插件商店进行安装'),
                              SizedBox(height: 3),
                            ],
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.separated(
                          itemCount: pluginList.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider();
                          },
                          itemBuilder: (BuildContext context, int index) {
                            if (pluginList[index].isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return ListTile(
                              title: Text(pluginList[index]),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons
                                        .do_not_disturb_on_total_silence_rounded),
                                    tooltip: '禁用',
                                    onPressed: () {
                                      Map data = {
                                        'name': pluginList[index],
                                        'id': Data.botInfo['id'],
                                      };
                                      String dataStr = jsonEncode(data);
                                      setState(() {
                                        socket.send(
                                            'plugin/disable?data=$dataStr&token=${Config.token}');
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    tooltip: '卸载',
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('确定卸载插件'),
                                            content: Text(
                                                '你确定要卸载插件 ${pluginList[index]} 吗？'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('取消'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  _uninstall(pluginList[index]);
                                                  Navigator.of(context).pop();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text('卸载请求已发送'),
                                                    ),
                                                  );
                                                },
                                                child: const Text('确定'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                : disabledPluginList.isEmpty
                    ? const Expanded(
                        child: Center(
                          child: Text('空空如也...'),
                        ),
                      )
                    : Expanded(
                        child: ListView.separated(
                          itemCount: disabledPluginList.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider();
                          },
                          itemBuilder: (BuildContext context, int index) {
                            if (disabledPluginList[index].isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return ListTile(
                              title: Text(disabledPluginList[index]),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                        Icons.open_in_browser_rounded),
                                    tooltip: '启用',
                                    onPressed: () {
                                      Map data = {
                                        'name': disabledPluginList[index],
                                        'id': Data.botInfo['id'],
                                      };
                                      String dataStr = jsonEncode(data);
                                      setState(() {
                                        socket.send(
                                            'plugin/enable?data=$dataStr&token=${Config.token}');
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.open_in_browser_rounded),
            label: '已启用的插件',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.do_not_disturb_on_total_silence_rounded),
            label: '已禁用的插件',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(234, 82, 82, 1),
        onTap: _onItemTapped,
      ),
    );
  }
}

void _uninstall(name) async {
  Map data = {
    'name': name,
    'id': Data.botInfo['id'],
  };
  String dataStr = jsonEncode(data);
  socket.send('plugin/uninstall?data=$dataStr&token=${Config.token}');
}
