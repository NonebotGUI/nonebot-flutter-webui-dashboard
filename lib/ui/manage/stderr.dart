import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:NoneBotWebUI/utils/global.dart';

class StderrPage extends StatefulWidget {
  const StderrPage({super.key});

  @override
  State<StderrPage> createState() => _StderrPageState();
}

class _StderrPageState extends State<StderrPage> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    socket.onMessage.listen((event) {
      String msg = event.data;
      Map response = jsonDecode(msg);
      String type = response['type'];
      if (type == 'botStderr') {
        if (mounted) {
          setState(() {});
        }
      }
    });

    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {});
        _scrollToBottom();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _clearStderr() {
    if (gOnOpen.isNotEmpty) {
      socket.send("bot/clearStderr/$gOnOpen?token=${Config.token}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: '返回',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          '错误日志',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            color: Colors.white,
            tooltip: '复制全部',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: Data.botStderr));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('日志已复制到剪贴板')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: '清除日志',
            color: Colors.white,
            onPressed: () {
              _clearStderr();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('清除指令已发送')),
              );
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF1E1E1E),
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          child: SelectableText(
            Data.botStderr.isEmpty ? '暂无错误日志' : Data.botStderr,
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              color: Color(0xFFD4D4D4),
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
