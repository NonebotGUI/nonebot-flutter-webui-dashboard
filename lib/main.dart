import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:NoneBotWebUI/ui/main_page.dart';
import 'package:NoneBotWebUI/ui_mobile/main_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:NoneBotWebUI/utils/global.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/services.dart' show rootBundle;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  version = '0.1.12+2';
  debug = false;

  String initialThemeMode = 'light';

  if (!debug) {
    final themeResponse = await http.get(Uri.parse('/theme'));
    if (themeResponse.statusCode == 200) {
      final themeData = jsonDecode(themeResponse.body);
      Config.theme = themeData;
      Config.hitokoto = themeData['hitokoto'];
      initialThemeMode = themeData['color'] ?? 'light';
    }
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(initialThemeMode),
      child: const MyApp(),
    ),
  );
}

class ThemeNotifier extends ChangeNotifier {
  ThemeData _themeData;
  String _themeMode;

  ThemeNotifier(String initialMode)
      : _themeMode = initialMode,
        _themeData = _getTheme(initialMode);

  ThemeData get themeData => _themeData;

  void toggleTheme() {
    if (_themeMode == 'light') {
      _themeMode = 'dark';
      _themeData = _getTheme('dark');
    } else {
      _themeMode = 'light';
      _themeData = _getTheme('light');
    }
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      theme: themeNotifier.themeData,
      home: const LoginPage(),
    );
  }
}

///颜色主题
ThemeData _getTheme(mode) {
  switch (mode) {
    case 'light':
      return ThemeData.light().copyWith(
          canvasColor: const Color.fromRGBO(254, 239, 239, 1),
          primaryColor: const Color.fromRGBO(234, 82, 82, 1),
          buttonTheme: const ButtonThemeData(
            buttonColor: Color.fromRGBO(234, 82, 82, 1),
          ),
          checkboxTheme: CheckboxThemeData(
            fillColor:
                MaterialStateProperty.resolveWith((Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return const Color.fromRGBO(234, 82, 82, 1);
              }
              return Colors.white;
            }),
            checkColor: MaterialStateProperty.all(Colors.white),
          ),
          progressIndicatorTheme: const ProgressIndicatorThemeData(
              color: Color.fromRGBO(234, 82, 82, 1)),
          appBarTheme: const AppBarTheme(color: Color.fromRGBO(234, 82, 82, 1)),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color.fromRGBO(234, 82, 82, 1)),
          switchTheme: const SwitchThemeData(
              trackColor:
                  MaterialStatePropertyAll(Color.fromRGBO(234, 82, 82, 1))));
    case 'dark':
      return ThemeData.dark().copyWith(
          canvasColor: const Color.fromRGBO(18, 18, 18, 1),
          primaryColor: const Color.fromRGBO(147, 112, 219, 1),
          buttonTheme: const ButtonThemeData(
            buttonColor: Color.fromRGBO(147, 112, 219, 1),
          ),
          checkboxTheme: const CheckboxThemeData(
              checkColor: MaterialStatePropertyAll(
            Color.fromRGBO(147, 112, 219, 1),
          )),
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Color.fromRGBO(147, 112, 219, 1),
          ),
          appBarTheme: const AppBarTheme(
            color: Color.fromRGBO(147, 112, 219, 1),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color.fromRGBO(147, 112, 219, 1)),
          switchTheme: const SwitchThemeData(
              trackColor:
                  MaterialStatePropertyAll(Color.fromRGBO(147, 112, 219, 1))));
    default:
      return ThemeData.light().copyWith(
        canvasColor: const Color.fromRGBO(254, 239, 239, 1),
        primaryColor: const Color.fromRGBO(234, 82, 82, 1),
        buttonTheme:
            const ButtonThemeData(buttonColor: Color.fromRGBO(234, 82, 82, 1)),
        checkboxTheme: const CheckboxThemeData(
            checkColor:
                MaterialStatePropertyAll(Color.fromRGBO(234, 82, 82, 1))),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Color.fromRGBO(234, 82, 82, 1)),
        appBarTheme: const AppBarTheme(color: Color.fromRGBO(234, 82, 82, 1)),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color.fromRGBO(234, 82, 82, 1)),
        switchTheme: const SwitchThemeData(
            trackColor:
                MaterialStatePropertyAll(Color.fromRGBO(234, 82, 82, 1))),
      );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final myController = TextEditingController();
  String fileContent = '';
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  // 注册许可证
  Future<void> _register() async {
    final String license = await rootBundle.loadString('lib/assets/LICENSE');
    LicenseRegistry.addLicense(() async* {
      yield LicenseEntryWithLineBreaks(['NoneBot WebUI Self Host'], license);
    });
  }

  @override
  void initState() {
    super.initState();
    _register();
    if (!debug) {
      autoLogin();
    }
  }

  // 自动登录
  Future<void> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await prefs.getString('token');
    if (token != null) {
      final res = await http.get(Uri.parse("/config"),
          headers: {"Authorization": 'Bearer $token'});
      if (res.statusCode == 200) {
        final config = jsonDecode(res.body);
        final connection = config['connection'];
        Config.wsHost = connection['host'];
        Config.wsPort = connection['port'];
        Config.token = connection['token'];
        Config.connectionMode = config['connectionMode'];
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => (MediaQuery.of(context).size.width >
                      MediaQuery.of(context).size.height)
                  ? const MainPage()
                  : const MainPageMobile()),
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('自动登录失败'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕的尺寸
    dynamic screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    double logoSize =
        (screenHeight > screenWidth) ? screenWidth * 0.4 : screenHeight * 0.4;
    double inputFieldWidth =
        (screenHeight > screenWidth) ? screenWidth * 0.75 : screenHeight * 0.5;
    double buttonWidth =
        (screenHeight > screenWidth) ? screenWidth * 0.09 : screenHeight * 0.07;
    html.document.title = '登录 | NoneBot WebUI';
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: screenWidth,
              height: screenHeight * 0.075,
            ),
            Config.theme['img'] == 'default'
                ? Image.asset(
                    'lib/assets/logo.png',
                    width: logoSize,
                    height: logoSize,
                  )
                : Image.network(
                    Config.theme['img'],
                    width: logoSize,
                    height: logoSize,
                  ),
            // const SizedBox(
            //   height: 4,
            // ),
            Text(
              Config.theme['text'] == 'default'
                  ? '登录到 NoneBot WebUI'
                  : Config.theme['text'],
              style: const TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: inputFieldWidth,
              height: inputFieldWidth * 0.175,
              child: TextField(
                controller: myController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '密码',
                ),
                onSubmitted: (String value) async {
                  final password = myController.text;
                  final res = await http.post(Uri.parse('/auth'),
                      body: jsonEncode({'password': password}),
                      headers: {"Content-Type": "application/json"});
                  if (res.statusCode == 200) {
                    final getConfig = await http.get(
                      Uri.parse('/config'),
                      headers: {"Authorization": 'Bearer ${res.body}'},
                    );
                    final config = jsonDecode(getConfig.body);
                    final connection = config['connection'];
                    Config.wsHost = connection['host'];
                    Config.wsPort = connection['port'];
                    Config.token = connection['token'];
                    Config.connectionMode = config['connectionMode'];
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('token', res.body);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('欢迎回来！'),
                    ));
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            (MediaQuery.of(context).size.width >
                                    MediaQuery.of(context).size.height)
                                ? const MainPage()
                                : const MainPageMobile(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('验证失败了喵'),
                    ));
                  }
                },
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            SizedBox(
              child: ElevatedButton(
                onPressed: () async {
                  if (debug) {
                    Config.token = '1823dbcd';
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            (MediaQuery.of(context).size.width >
                                    MediaQuery.of(context).size.height)
                                ? const MainPage()
                                : const MainPageMobile(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  } else {
                    final password = myController.text;
                    final res = await http.post(Uri.parse('/auth'),
                        body: jsonEncode({'password': password}),
                        headers: {"Content-Type": "application/json"});
                    if (res.statusCode == 200) {
                      final getConfig = await http.get(
                        Uri.parse('/config'),
                        headers: {"Authorization": 'Bearer ${res.body}'},
                      );
                      final config = jsonDecode(getConfig.body);
                      final connection = config['connection'];
                      Config.wsHost = connection['host'];
                      Config.wsPort = connection['port'];
                      Config.token = connection['token'];
                      Config.connectionMode = config['connectionMode'];
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('token', res.body);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('欢迎回来！'),
                      ));
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              (MediaQuery.of(context).size.width >
                                      MediaQuery.of(context).size.height)
                                  ? const MainPage()
                                  : const MainPageMobile(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('验证失败了喵'),
                      ));
                    }
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Config.theme['color'] == 'default' ||
                              Config.theme['color'] == 'light'
                          ? const Color.fromRGBO(234, 82, 82, 1)
                          : const Color.fromRGBO(147, 112, 219, 1)),
                  shape: MaterialStateProperty.all(const CircleBorder()),
                  iconSize: MaterialStateProperty.all(24),
                  minimumSize:
                      MaterialStateProperty.all(Size(buttonWidth, buttonWidth)),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: buttonWidth * 0.75,
                ),
              ),
            ),
            Expanded(child: Container()),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(2),
                child: Text(
                  'Powered by Flutter',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(2),
                child: Text(
                  'Released under the GPL-3 License',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
