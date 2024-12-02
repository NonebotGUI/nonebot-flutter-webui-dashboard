import 'dart:io';
import 'dart:math';
import 'package:ansicolor/ansicolor.dart';

class Logger {
  // 使用 AnsiPen 来设置颜色
  static final AnsiPen _darkGreenPen = AnsiPen()..green(bold: true);
  static final AnsiPen _redPen = AnsiPen()..red();
  static final AnsiPen _greenPen = AnsiPen()..green();
  static final AnsiPen _yellowPen = AnsiPen()..yellow();
  static final AnsiPen _bluePen = AnsiPen()..blue();
  static final AnsiPen _purplePen = AnsiPen()..magenta();
  static final AnsiPen _cyanPen = AnsiPen()..cyan();
  static final AnsiPen _lightGreenPen = AnsiPen()..xterm(118);

  static AnsiPen _getRandomRainbowColor() {
    final random = Random();
    return _rainbowColors[random.nextInt(_rainbowColors.length)];
  }

  static String _applyRainbowEffect(String text) {
    final random = Random();
    StringBuffer coloredText = StringBuffer();

    for (var char in text.split('')) {
      AnsiPen randomColor =
          _rainbowColors[random.nextInt(_rainbowColors.length)];
      coloredText.write(randomColor(char));
    }

    return coloredText.toString();
  }

  // 彩虹颜色数组
  static final List<AnsiPen> _rainbowColors = [
    AnsiPen()..red(),
    AnsiPen()..green(),
    AnsiPen()..yellow(),
    AnsiPen()..blue(),
    AnsiPen()..magenta(),
    AnsiPen()..cyan(),
    AnsiPen()..white(),
  ];

  static void _log(String logLevel, String message, AnsiPen levelColor) {
    String timestamp = _getTimestamp();
    String agent = " Dashboard ";
    String coloredTimestamp = _darkGreenPen(timestamp);
    String coloredLogLevel = levelColor(logLevel);
    String coloredAgent = _purplePen(agent);
    String coloredMessage = message;
    String coloredLog =
        '$coloredTimestamp [$coloredLogLevel] |$coloredAgent| $coloredMessage';
    stdout.writeln(coloredLog);
  }

  static void _apiLog(
      String method, int statusCode, String message, AnsiPen levelColor) {
    String timestamp = _getTimestamp();
    String agent = " Dashboard ";
    String coloredTimestamp = _darkGreenPen(timestamp);
    String coloredLogLevel = levelColor(method);
    String coloredAgent = _purplePen(agent);
    String coloredMessage = message;
    String coloredLog =
        '$coloredTimestamp [$coloredLogLevel][$statusCode] |$coloredAgent| $coloredMessage';
    stdout.writeln(coloredLog);
  }

  // 获取当前时间戳
  static String _getTimestamp() {
    DateTime now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  /// ERROR级别日志
  static void error(String message) {
    _log("ERROR", message, _redPen);
  }

  /// INFO级别日志
  static void info(String message) {
    _log("INFO", message, _greenPen);
  }

  /// WARN级别日志
  static void warn(String message) {
    _log("WARN", message, _yellowPen);
  }

  /// DEBUG级别日志
  static void debug(String message) {
    _log("DEBUG", message, _bluePen);
  }

  /// SUCCESS级别日志
  static void success(String message) {
    _log("SUCCESS", message, _lightGreenPen);
  }

  /// API请求日志
  static void api(String method, int statusCode, String message) {
    _apiLog(method, statusCode, message, _cyanPen);
  }

  /// RAINBOW!!!
  static void rainbow(String logLevel, String message) {
    String timestamp = _getTimestamp();
    String agent = " Dashboard ";
    String coloredTimestamp = _darkGreenPen(timestamp);
    String rainbowLogLevel = _applyRainbowEffect(logLevel);
    String coloredAgent = _purplePen(agent);
    String rainbowMessage = _applyRainbowEffect(message);

    String coloredLog =
        '$coloredTimestamp [$rainbowLogLevel] |$coloredAgent| $rainbowMessage';
    stdout.writeln(coloredLog);
  }
}
