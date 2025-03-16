import 'package:NoneBotWebUI/ui_mobile/manage/env.dart';
import 'package:NoneBotWebUI/ui_mobile/manage/manage/adapter.dart';
import 'package:NoneBotWebUI/ui_mobile/manage/manage/driver.dart';
import 'package:NoneBotWebUI/ui_mobile/manage/manage/manage_plugin.dart';
import 'package:NoneBotWebUI/ui_mobile/manage/manage/plugin.dart';
import 'package:flutter/material.dart';

class Managecli extends StatefulWidget {
  const Managecli({super.key});

  @override
  State<Managecli> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Managecli> {
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('NoneBot WebUI',
              style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            tooltip: '返回',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
            margin: const EdgeInsets.all(16.0),
            child: ListView(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const PluginStoreMobile();
                    }));
                  },
                  child: const ListTile(
                    title: Text('插件商店'),
                  ),
                ),
                const Divider(),
                InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const AdapterStoreMobile();
                    }));
                  },
                  child: const ListTile(
                    title: Text('适配器商店'),
                  ),
                ),
                const Divider(),
                InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const DriverStoreMobile();
                    }));
                  },
                  child: const ListTile(
                    title: Text('驱动器商店'),
                  ),
                ),
                const Divider(),
                InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const ManagePlugin();
                    }));
                  },
                  child: const ListTile(
                    title: Text('插件管理'),
                  ),
                ),
                const Divider(),
                InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const EditEnv();
                    }));
                  },
                  child: const ListTile(
                    title: Text('env配置'),
                  ),
                ),
              ],
            )));
  }
}
