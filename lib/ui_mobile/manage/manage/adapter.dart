import 'dart:async';
import 'dart:convert';
import 'package:NoneBotWebUI/utils/global.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:NoneBotWebUI/assets/my_flutter_app_icons.dart';
import 'dart:html' as html;

class AdapterStoreMobile extends StatefulWidget {
  const AdapterStoreMobile({super.key});

  @override
  State<AdapterStoreMobile> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<AdapterStoreMobile> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  //初始化json列表
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> search = [];

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('https://registry.nonebot.dev/adapters.json'));
    if (response.statusCode == 200) {
      setState(() {
        String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonData = json.decode(decodedBody);
        data = jsonData.map((item) => item as Map<String, dynamic>).toList();
        search = data;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _searchAdapters(value) {
    setState(() {
      //根据名字，描述等搜索
      search = data.where((adapter) {
        //果然是个人都喜欢堆起来
        return adapter['name'].toLowerCase().contains(value.toLowerCase()) ||
            adapter['desc'].toLowerCase().contains(value.toLowerCase()) ||
            adapter['module_name']
                .toLowerCase()
                .contains(value.toLowerCase()) ||
            adapter['author'].toLowerCase().contains(value.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: '返回',
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: SafeArea(
              child: TextField(
            controller: _searchController,
            onChanged: _searchAdapters,
            style: const TextStyle(
                color: Colors.white), // Set input text color to white
            decoration: const InputDecoration(
                hintText: '搜索适配器...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white)),
          )),
        ),
        body: data.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('lib/assets/loading.gif'),
                  ],
                ),
              )
            : Container(
                margin: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    childAspectRatio: 2 / 1,
                  ),
                  itemCount: search.length,
                  itemBuilder: (BuildContext context, int index) {
                    final adapters = search[index];
                    return Card(
                      child: InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: ((context) {
                                return Center(
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    height: MediaQuery.of(context).size.height *
                                        0.8,
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      child: Container(
                                        margin: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 14,
                                              child: ListView(
                                                children: <Widget>[
                                                  _item(
                                                    '名称',
                                                    adapters['name'],
                                                  ),
                                                  _item('模块名',
                                                      adapters['module_name']),
                                                  _item(
                                                      '作者', adapters['author']),
                                                  _item(
                                                      '描述',
                                                      adapters['desc'] == ''
                                                          ? '无'
                                                          : adapters['desc']),
                                                ],
                                              ),
                                            ),
                                            const Divider(
                                              color: Colors.grey,
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: <Widget>[
                                                  IconButton(
                                                    onPressed: () {
                                                      Map data = {
                                                        'id': gOnOpen,
                                                        'name': adapters[
                                                                'module_name']
                                                            .toString()
                                                            .replaceAll(
                                                                'adapters',
                                                                'adapter')
                                                            .replaceAll(
                                                                '.', '-')
                                                            .replaceAll(
                                                                '-v11', ''),
                                                      };
                                                      String dataStr =
                                                          jsonEncode(data);
                                                      socket.send(
                                                          'adapter/install?data=$dataStr?token=${Config.token}');
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return const InstallingBot();
                                                        },
                                                      );
                                                    },
                                                    tooltip: '安装适配器',
                                                    icon: const Icon(
                                                        Icons.download_rounded),
                                                  ),
                                                  const SizedBox(
                                                    width: 8,
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      html.window.open(
                                                          adapters['homepage'],
                                                          'New tab');
                                                    },
                                                    tooltip: '查看主页',
                                                    icon: const Icon(
                                                        MyFlutterApp.github),
                                                  ),
                                                  const SizedBox(
                                                    width: 8,
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(const Color
                                                                  .fromRGBO(234,
                                                                  82, 82, 1)),
                                                      shape: MaterialStateProperty.all(
                                                          const RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10.0)))),
                                                      minimumSize:
                                                          MaterialStateProperty
                                                              .all(const Size(
                                                                  100, 40)),
                                                    ),
                                                    child: const Text(
                                                      '关闭',
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
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }));
                        },
                        child: Stack(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    adapters['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(adapters['module_name'],
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                      overflow: TextOverflow.fade),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 4,
                              bottom: 4,
                              child: Text(
                                'By ${adapters['author']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Row(
                                children: <Widget>[
                                  IconButton(
                                    onPressed: () {
                                      Map data = {
                                        'id': gOnOpen,
                                        'name': adapters['module_name']
                                            .toString()
                                            .replaceAll('adapters', 'adapter')
                                            .replaceAll('.', '-')
                                            .replaceAll('-v11', ''),
                                      };
                                      String dataStr = jsonEncode(data);
                                      socket.send(
                                          'adpater/install?data=$dataStr?token=${Config.token}');
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return const InstallingBot();
                                        },
                                      );
                                    },
                                    tooltip: '安装适配器',
                                    icon: const Icon(Icons.download_rounded),
                                    iconSize: 25,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      html.window.open(
                                          adapters['homepage'], 'New tab');
                                    },
                                    tooltip: '查看主页',
                                    icon: const Icon(MyFlutterApp.github),
                                    iconSize: 25,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ));
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
              textScaler: const TextScaler.linear(1.15),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              content,
            ),
          ),
        ),
        const SizedBox(
          height: 4,
        ),
      ],
    );
  }
}

class InstallingBot extends StatefulWidget {
  const InstallingBot({super.key});

  @override
  _InstallingBotState createState() => _InstallingBotState();
}

class _InstallingBotState extends State<InstallingBot> {
  String _log = '';
  List<String> _logList = [];
  @override
  void initState() {
    super.initState();
    socket.onMessage.listen((event) {
      String? msg = event.data;
      if (msg != null) {
        Map msgJson = jsonDecode(msg);
        String type = msgJson['type'];
        switch (type) {
          case 'adapterInstallLog':
            String data = msgJson['data'];
            setState(() {
              _logList.add(data);
              _log = _logList.join('');
            });
            break;
          case 'installAdapterStatus':
            String data = msgJson['data'];
            if (data == 'done') {
              Future.delayed(const Duration(seconds: 15), () {
                _log = '';
                Navigator.of(context).pop();
              });
            }
            break;
        }
      }
    }, cancelOnError: false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dynamic size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Container(
          width: (height > width) ? width * 0.9 : width * 0.6,
          height: (height > width) ? height * 0.8 : height * 0.8,
          margin: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    '正在安装适配器',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 14,
                child: Card(
                  color: const Color.fromARGB(255, 31, 28, 28),
                  child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      padding: const EdgeInsets.all(4.0),
                      child: SingleChildScrollView(
                        child: Text(
                          _log,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'JetBrainsMono',
                          ),
                        ),
                      )),
                ),
              ),
              const Divider(
                color: Colors.grey,
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        _log = '';
                        _logList.clear();
                        Navigator.of(context).pop();
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            const Color.fromRGBO(234, 82, 82, 1)),
                        shape: MaterialStateProperty.all(
                            const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)))),
                        minimumSize:
                            MaterialStateProperty.all(const Size(100, 40)),
                      ),
                      child: const Text(
                        '关闭',
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
          ),
        ),
      ),
    );
  }
}
