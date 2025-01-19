import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:NoneBotWebUI/utils/global.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:NoneBotWebUI/assets/my_flutter_app_icons.dart';
import 'package:flutter/services.dart';

class PluginStore extends StatefulWidget {
  const PluginStore({super.key});

  @override
  State<PluginStore> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<PluginStore> {
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
        await http.get(Uri.parse('https://registry.nonebot.dev/plugins.json'));
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
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: ' 搜索插件...',
                ),
                onChanged: _searchAdapters,
              ),
            )),
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
                margin: const EdgeInsets.fromLTRB(32, 20, 32, 12),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 3 / 1,
                  ),
                  itemCount: search.length,
                  itemBuilder: (BuildContext context, int index) {
                    final plugins = search[index];
                    return Card(
                      child: InkWell(
                        onTap: () {},
                        child: Stack(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    plugins['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    plugins['module_name'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    plugins['desc'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 8,
                              bottom: 8,
                              child: Text(
                                'By ${plugins['author']}',
                                style: const TextStyle(
                                  fontSize: 10,
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
                                        'name': plugins['module_name']
                                      };
                                      String dataStr = jsonEncode(data);
                                      socket.send(
                                          'plugin/install?data=$dataStr?token=${Config.token}');
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return const InstallingBot();
                                        },
                                      );
                                    },
                                    tooltip: '安装插件',
                                    icon: const Icon(Icons.download_rounded),
                                    iconSize: 25,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(
                                        text: plugins['homepage'],
                                      ));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('项目仓库链接已复制到剪贴板'),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    },
                                    tooltip: '复制仓库地址',
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
          case 'pluginInstallLog':
            String data = msgJson['data'];
            setState(() {
              _logList.add(data);
              _log = _logList.join('');
            });
            break;
          case 'installPluginStatus':
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
                    '正在安装插件',
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
                      padding: const EdgeInsets.all(8.0),
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
