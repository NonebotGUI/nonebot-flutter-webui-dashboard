import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nonebot_webui/ui/mainPage.dart';
import 'package:nonebot_webui/utils/global.dart';

void main() async {
  version = '1.0.0';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'NoneBot WebUI',
      home: LoginPage(title: 'NoneBot WebUI Login'),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final myController = TextEditingController();
  String _password = '';

  String fileContent = '';

  /// 加载配置文件
  Future<void> _login() async {
    final headers = {
      'Authorization': 'Bearer $_password',
    };
    final response = await http.get(
      Uri.parse('/config'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> config = jsonDecode(response.body);
      final connection = config['connection'];
      Config.wsHost = connection['host'];
      Config.wsPort = connection['port'];
      Config.token = connection['token'];
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('欢迎回来！'),
        ),
      );
      Navigator.pushNamed(context, '/Home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('验证失败！'),
        ),
      );
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

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: screenWidth,
              height: screenHeight * 0.075,
            ),
            Image.asset(
              'lib/assets/logo.png',
              width: logoSize,
              height: logoSize,
            ),
            // const SizedBox(
            //   height: 4,
            // ),
            const Text(
              '登录到 NoneBot WebUI',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: inputFieldWidth,
              height: inputFieldWidth * 0.175,
              child: TextField(
                controller: myController,
                onChanged: (value) {
                  _password = value;
                },
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '密码',
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            SizedBox(
              child: ElevatedButton(
                onPressed: () {
                  //_login();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainPage(
                        title: 'NoneBot WebUI',
                      ),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      const Color.fromRGBO(238, 109, 109, 1)),
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
