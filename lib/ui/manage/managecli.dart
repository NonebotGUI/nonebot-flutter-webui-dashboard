// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:NoneBotWebUI/ui/manage/adapter.dart';
import 'package:NoneBotWebUI/ui/manage/driver.dart';
// import 'package:NoneBotWebUI/ui/manage/driver.dart';
// import 'package:NoneBotWebUI/ui/manage/env.dart';
// import 'package:NoneBotWebUI/ui/manage/manage_cli.dart';
import 'package:NoneBotWebUI/ui/manage/manage_plugin.dart';
import 'package:NoneBotWebUI/ui/manage/plugin.dart';
import 'package:NoneBotWebUI/utils/global.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

class ManageCli extends StatefulWidget {
  const ManageCli({super.key});

  @override
  State<ManageCli> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ManageCli> {
  final myController = TextEditingController();
  int _selectedIndex = 0;
  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      html.document.title = '管理Bot | NoneBot WebUI';
    });
  }

  @override
  Widget build(BuildContext context) {
    dynamic size = MediaQuery.of(context).size;
    double height = size.height;
    return Scaffold(
        appBar: AppBar(
          title: const Text('管理Bot', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            tooltip: '返回',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Row(
          children: <Widget>[
            NavigationRail(
              useIndicator: false,
              selectedIconTheme: IconThemeData(
                  color: Config.theme['color'] == 'light' ||
                          Config.theme['color'] == 'default'
                      ? const Color.fromRGBO(234, 82, 82, 1)
                      : const Color.fromRGBO(147, 112, 219, 1),
                  size: height * 0.03),
              selectedLabelTextStyle: TextStyle(
                color: Config.theme['color'] == 'light' ||
                        Config.theme['color'] == 'default'
                    ? const Color.fromRGBO(234, 82, 82, 1)
                    : const Color.fromRGBO(147, 112, 219, 1),
                fontSize: height * 0.02,
              ),
              unselectedLabelTextStyle: TextStyle(
                fontSize: height * 0.02,
                color: Config.theme['color'] == 'light' ||
                        Config.theme['color'] == 'default'
                    ? Colors.grey[600]
                    : Colors.white,
              ),
              unselectedIconTheme: IconThemeData(
                  color: Config.theme['color'] == 'light' ||
                          Config.theme['color'] == 'default'
                      ? Colors.grey[600]
                      : Colors.white,
                  size: height * 0.03),
              elevation: 2,
              minExtendedWidth: 200,
              indicatorShape: const RoundedRectangleBorder(),
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              selectedIndex: _selectedIndex,
              extended: true,
              destinations: <NavigationRailDestination>[
                NavigationRailDestination(
                    icon: Icon(
                      _selectedIndex == 0
                          ? Icons.storefront_rounded
                          : Icons.storefront_outlined,
                    ),
                    label: const Text('插件商店'),
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 15)),
                NavigationRailDestination(
                    icon: Icon(
                      _selectedIndex == 1
                          ? Icons.storefront_rounded
                          : Icons.storefront_outlined,
                    ),
                    label: const Text('适配器商店'),
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 15)),
                NavigationRailDestination(
                    icon: Icon(
                      _selectedIndex == 2
                          ? Icons.storefront_rounded
                          : Icons.storefront_outlined,
                    ),
                    label: const Text('驱动器商店'),
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 15)),
                NavigationRailDestination(
                    icon: Icon(
                      _selectedIndex == 3
                          ? Icons.extension_rounded
                          : Icons.extension_outlined,
                    ),
                    label: const Text('管理插件'),
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 15)),
                // NavigationRailDestination(
                //     icon: Icon(
                //       _selectedIndex == 4
                //           ? Icons.settings_applications_rounded
                //           : Icons.settings_applications_outlined,
                //     ),
                //     label: const Text('管理cli本体'),
                //     padding: const EdgeInsets.fromLTRB(0, 0, 0, 15)),
                // NavigationRailDestination(
                //     icon: Icon(
                //       _selectedIndex == 5
                //           ? Icons.file_copy_rounded
                //           : Icons.file_copy_outlined,
                //     ),
                //     label: const Text('env配置'),
                //     padding: const EdgeInsets.fromLTRB(0, 0, 0, 15)),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: const <Widget>[
                  PluginStore(),
                  AdapterStore(),
                  DriverStore(),
                  ManagePlugin(),
                  // ManageCli(),
                  // EditEnv(),
                ],
              ),
            )
          ],
        ));
  }
}
