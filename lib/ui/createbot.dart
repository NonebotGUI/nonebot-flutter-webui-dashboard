import 'dart:async';
import 'dart:convert';
import 'package:NoneBotWebUI/utils/global.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateBot extends StatefulWidget {
  const CreateBot({super.key});

  @override
  State<CreateBot> createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<CreateBot> {
  final _pathController = TextEditingController();
  final _nameController = TextEditingController();
  bool isVENV = true;
  bool isDep = true;

//拉取适配器和驱动器列表
  @override
  void initState() {
    super.initState();
    _fetchAdapters();
  }

//驱动器，万年不更新一次的东西就不搞http请求了🤓
  Map<String, bool> drivers = {
    'None': false,
    'FastAPI': true,
    'Quart': false,
    'HTTPX': false,
    'websockets': false,
    'AIOHTTP': false,
  };

//适配器
  Map<String, bool> adapterMap = {};
  List adapterList = [];
  bool loadAdapter = true;
  Future<void> _fetchAdapters() async {
    final response =
        await http.get(Uri.parse('https://registry.nonebot.dev/adapters.json'));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> adapters = json.decode(decodedBody);
      setState(() {
        adapterList = adapters;
        adapterMap = {for (var item in adapters) item['name']: false};
        loadAdapter = false;
      });
    } else {
      setState(() {
        loadAdapter = false;
      });
    }
  }

  void onDriversChanged(String option, bool value) {
    setState(() {
      drivers[option] = value;
    });
  }

  void onAdaptersChanged(String option, bool value) {
    setState(() {
      adapterMap[option] = value;
    });
  }

  List<String> buildSelectedDriverOptions() {
    List<String> selectedOptions =
        drivers.keys.where((option) => drivers[option] == true).toList();
    return selectedOptions;
  }

  List<String> buildSelectedAdapterOptions() {
    // 获取选中的选项
    List<String> selectedOptions =
        adapterMap.keys.where((option) => adapterMap[option] == true).toList();

    // 提取选中项的 module_name 并进行替换操作
    List<String> selectedModuleNames = selectedOptions.map((option) {
      String moduleName = adapterList.firstWhere(
          (adapter) => adapter['name'] == option)['module_name'] as String;
      return moduleName
          .replaceAll('adapters', 'adapter')
          .replaceAll('.', '-')
          .replaceAll('-v11', '.v11')
          .replaceAll('-v12', '.v12');
    }).toList();

    return selectedModuleNames;
  }

  List<Widget> buildDriversCheckboxes() {
    return drivers.keys.map((driver) {
      return CheckboxListTile(
        title: Text(driver),
        value: drivers[driver],
        onChanged: (bool? value) => onDriversChanged(driver, value!),
      );
    }).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleVenv(bool newValue) {
    setState(() {
      isVENV = newValue;
    });
  }

  void _toggleDep(bool newValue) {
    setState(() {
      isDep = newValue;
    });
  }

  String name = 'NoneBot';
  final List<String> template = ['bootstrap(初学者或用户)', 'simple(插件开发者)'];
  late String dropDownValue = template.first;
  final List<String> pluginDir = ['在[bot名称]/[bot名称]下', '在src文件夹下'];
  late String dropDownValuePluginDir = pluginDir.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            //bot名称
            children: <Widget>[
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "填入名称",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    textScaler: TextScaler.linear(1.1),
                  )),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '名称',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(234, 82, 82, 1),
                      width: 5.0,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() => name = value);
                },
              ),
              const SizedBox(height: 20),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "填入存放Bot的路径",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    textScaler: TextScaler.linear(1.1),
                  )),
              const SizedBox(height: 16),
              TextField(
                controller: _pathController,
                decoration: const InputDecoration(
                  labelText: '路径',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(234, 82, 82, 1),
                      width: 5.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text(
                  '选择模板',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                trailing: DropdownButton<String>(
                  value: dropDownValue,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  elevation: 16,
                  onChanged: (String? value) {
                    setState(() => dropDownValue = value!);
                  },
                  items: template
                      .map<DropdownMenuItem<String>>(
                        (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(value),
                            )),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
              Visibility(
                visible: dropDownValue == template[1],
                child: ListTile(
                  title: const Text(
                    '选择插件存放位置',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  trailing: DropdownButton<String>(
                    value: dropDownValuePluginDir,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    elevation: 16,
                    onChanged: (String? value) {
                      setState(() {
                        dropDownValuePluginDir = value!;
                      });
                    },
                    items: pluginDir
                        .map<DropdownMenuItem<String>>(
                          (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(value),
                              )),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text("是否开启虚拟环境"),
                trailing: Switch(
                  value: isVENV,
                  onChanged: _toggleVenv,
                  focusColor: Colors.black,
                  inactiveTrackColor: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text("是否安装依赖"),
                trailing: Switch(
                  value: isDep,
                  onChanged: _toggleDep,
                  focusColor: Colors.black,
                  inactiveTrackColor: Colors.grey,
                ),
              ),
              const Divider(
                height: 20,
                thickness: 2,
                indent: 20,
                endIndent: 20,
                color: Colors.grey,
              ),
              const Center(
                child: Text("选择驱动器"),
              ),
              const SizedBox(height: 3),
              Column(children: buildDriversCheckboxes()),
              const Divider(
                height: 20,
                thickness: 2,
                indent: 20,
                endIndent: 20,
                color: Colors.grey,
              ),
              const Center(
                child: Text("选择适配器"),
              ),
              const SizedBox(height: 3),
              Column(
                children: [
                  if (loadAdapter)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: adapterList.map((adapter) {
                        String name = adapter['name'];
                        String moduleName = adapter['module_name']
                            .replaceAll('adapters', 'adapter')
                            .replaceAll('.', '-')
                            .replaceAll('-v11', '.v11')
                            .replaceAll('-v12', '.v12');
                        String showText = '$name($moduleName)';
                        return CheckboxListTile(
                          title: Text(showText),
                          value: adapterMap[name],
                          onChanged: (bool? value) =>
                              onAdaptersChanged(name, value!),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_pathController.text.isNotEmpty &&
              buildSelectedAdapterOptions().isNotEmpty &&
              buildDriversCheckboxes().isNotEmpty) {
            Map data = {
              'name': _nameController.text,
              'path': _pathController.text,
              'template': dropDownValue,
              'pluginDir': dropDownValuePluginDir,
              'venv': isVENV,
              'installDep': isDep,
              'drivers': buildSelectedDriverOptions(),
              'adapters': buildSelectedAdapterOptions(),
            };
            String dataJson = jsonEncode(data);
            socket.send('bots/create?data=$dataJson?token=114514');
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return installingBot();
              },
            );
          } else {
            print(buildSelectedAdapterOptions());
            print(buildSelectedDriverOptions());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('你是不是漏了什么？'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        tooltip: '完成',
        backgroundColor: Color.fromRGBO(234, 84, 84, 1),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.done_rounded,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class installingBot extends StatefulWidget {
  @override
  _installingBotState createState() => _installingBotState();
}

class _installingBotState extends State<installingBot> {
  String _log = '';
  @override
  void initState() {
    super.initState();
    socket.onMessage.listen((event) {
      String? msg = event.data;
      if (msg != null) {
        Map msgJson = jsonDecode(msg);
        String type = msgJson['type'];
        switch (type) {
          case 'installBotLog':
            String data = msgJson['data'];
            setState(() {
              Data.installBotLog.add(data);
              _log = Data.installBotLog.join('\n');
            });
            break;
          case 'installBotStatus':
            String data = msgJson['data'];
            if (data == 'done') {
              Navigator.of(context).pop();
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
          width: width * 0.6,
          height: height * 0.8,
          margin: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Bot正在创建',
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
                  child: SizedBox(
                    width: width * 0.58,
                    height: height * 0.6,
                    child: Container(
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
