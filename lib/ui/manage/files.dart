import 'package:flutter/material.dart';
import 'package:NoneBotWebUI/utils/global.dart';
import 'dart:convert';

class Files extends StatefulWidget {
  const Files({super.key});

  @override
  State<Files> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Files> {
  final _fileContentController = TextEditingController();
  bool _isSelectionMode = false;
  final Set<int> _selectedIndices = {};

  // 复制/移动模式
  bool _isPasting = false;
  bool _isMoveOperation = false;
  List<String> _itemsForPaste = [];
  String _sourcePathForPaste = '';

  @override
  void initState() {
    super.initState();

    socket.send("file/list/$gOnOpen${Data.currentPath}&token=${Config.token}");
    socket.onMessage.listen((event) {
      var message = event.data;
      Map msgJson = jsonDecode(message);
      var type = msgJson['type'];
      var data = msgJson['data'];
      if (type == "fileList") {
        setState(() {
          if (!_isPasting) {
            _selectedIndices.clear();
            _isSelectionMode = false;
          }
          Data.fileList = data;
        });
      }
      if (type == "fileContent") {
        setState(() {
          _fileContentController.text = data;
          Data.fileContent = data;
        });
      }
    });
  }

  @override
  void dispose() {}

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedIndices.clear();
      }
    });
  }

  void _onItemTap(int index) {
    if (_isSelectionMode) {
      setState(() {
        if (_selectedIndices.contains(index)) {
          _selectedIndices.remove(index);
        } else {
          _selectedIndices.add(index);
        }
        if (_selectedIndices.isEmpty) {
          _isSelectionMode = false;
        }
      });
    } else {
      var file = Data.fileList[index];
      if (file['type'] == 'directory') {
        String newPath = Data.currentPath;
        if (!newPath.endsWith('/')) {
          newPath += '/';
        }
        newPath += file['name'];
        Data.currentPath = newPath;

        socket.send(
            "file/list/$gOnOpen${Data.currentPath}&token=${Config.token}");
      } else {
        socket.send(
            "file/read/$gOnOpen${Data.currentPath}?name=${file['name']}&token=${Config.token}");
        setState(() {
          _fileContentController.text = Data.fileContent;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('编辑 ${file['name']} 文件内容'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _fileContentController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '编辑文件内容',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    String fileContent = _fileContentController.text;
                    Map<String, dynamic> data = {
                      "filename": file['name'],
                      "content": fileContent,
                    };
                    String jsonData = jsonEncode(data);
                    String encodedData = Uri.encodeComponent(jsonData);
                    String path = 'file/write/$gOnOpen${Data.currentPath}';
                    String message =
                        '$path?data=$encodedData&token=${Config.token}';
                    socket.send(message);

                    setState(() {});
                    Navigator.of(context).pop();
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('你确定要删除这 ${_selectedIndices.length} 个项目吗？此操作无法撤销。'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('删除', style: TextStyle(color: Colors.red)),
              onPressed: () {
                for (var index in _selectedIndices) {
                  final item = Data.fileList[index];
                  final command =
                      "file/delete/$gOnOpen${Data.currentPath}?name=${item['name']}&token=${Config.token}";
                  socket.send(command);
                }

                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 500), () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedIndices.clear();

                    socket.send(
                        "file/list/$gOnOpen${Data.currentPath}&token=${Config.token}");
                  });
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _handleSingleDelete(int index) {
    final item = Data.fileList[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('你确定要删除 "${item['name']}" 吗？此操作无法撤销。'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('删除', style: TextStyle(color: Colors.red)),
              onPressed: () {
                final command =
                    "file/delete/$gOnOpen${Data.currentPath}?name=${item['name']}&token=${Config.token}";
                socket.send(command);
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 500), () {
                  socket.send(
                      "file/list/$gOnOpen${Data.currentPath}&token=${Config.token}");
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _handleSingleRename(int index) {
    final item = Data.fileList[index];
    final renameController = TextEditingController(text: item['name']);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('重命名'),
          content: TextField(
            controller: renameController,
            autofocus: true,
            decoration: const InputDecoration(hintText: '输入新名称'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('确认'),
              onPressed: () {
                final newName = renameController.text;
                if (newName.isNotEmpty && newName != item['name']) {
                  Map<String, String> data = {
                    "oldName": item['name'],
                    "newName": newName,
                  };
                  String jsonData = jsonEncode(data);
                  String encodedData = Uri.encodeComponent(jsonData);
                  String path = 'file/rename/$gOnOpen${Data.currentPath}';
                  String command =
                      '$path?data=$encodedData&token=${Config.token}';
                  socket.send(command);
                  Navigator.of(context).pop();
                  Future.delayed(const Duration(milliseconds: 500), () {
                    socket.send(
                        "file/list/$gOnOpen${Data.currentPath}&token=${Config.token}");
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _prepareSingleItemPaste(int index, {required bool isMove}) {
    final item = Data.fileList[index];
    setState(() {
      _isMoveOperation = isMove;
      _sourcePathForPaste = Data.currentPath;
      _itemsForPaste = [item['name']];
      _isPasting = true;
      _isSelectionMode = false;
      _selectedIndices.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已${isMove ? "剪切" : "复制"} "${item['name']}"，请到目标目录粘贴。'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // 准备复制或移动
  void _prepareForPaste({required bool isMove}) {
    setState(() {
      _isMoveOperation = isMove;
      _sourcePathForPaste = Data.currentPath;
      _itemsForPaste = _selectedIndices
          .map((index) => Data.fileList[index]['name'] as String)
          .toList();

      _isPasting = true;
      _isSelectionMode = false;
      _selectedIndices.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '已${isMove ? "剪切" : "复制"} ${_itemsForPaste.length} 个项目，请到目标目录粘贴。'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // 取消粘贴
  void _cancelPaste() {
    setState(() {
      _isPasting = false;
      _itemsForPaste.clear();
      _sourcePathForPaste = '';
    });
  }

  // 执行粘贴
  void _handlePaste() {
    final destPath = Data.currentPath;
    final operation = _isMoveOperation ? 'move' : 'copy';

    for (final itemName in _itemsForPaste) {
      Map<String, String> data = {
        "name": itemName,
        "target": destPath,
      };

      String jsonData = jsonEncode(data);
      String path = 'file/$operation/$gOnOpen$_sourcePathForPaste';
      final command = '$path?data=$jsonData&token=${Config.token}';
      socket.send(command);
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isPasting = false;
        _itemsForPaste.clear();
        _sourcePathForPaste = '';
        socket.send(
            "file/list/$gOnOpen${Data.currentPath}&token=${Config.token}");
      });
    });
  }

  AppBar _buildAppBar() {
    if (_isPasting) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          tooltip: '取消',
          onPressed: _cancelPaste,
        ),
        title: Text(
          '${_isMoveOperation ? "移动" : "复制"} ${_itemsForPaste.length} 项到...',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _handlePaste,
            child: const Text('粘贴到此处', style: TextStyle(color: Colors.white)),
          )
        ],
      );
    }

    if (_isSelectionMode) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          tooltip: '取消',
          onPressed: _toggleSelectionMode,
        ),
        title: Text(
          '已选择 ${_selectedIndices.length} 项',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white),
            tooltip: '复制',
            onPressed: _selectedIndices.isNotEmpty
                ? () => _prepareForPaste(isMove: false)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.drive_file_move, color: Colors.white),
            tooltip: '移动',
            onPressed: _selectedIndices.isNotEmpty
                ? () => _prepareForPaste(isMove: true)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            tooltip: '删除',
            onPressed: _selectedIndices.isNotEmpty ? _handleDelete : null,
          ),
        ],
      );
    } else {
      return AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: '返回',
          onPressed: () {
            Data.currentPath = '/';
            Data.fileList = [];
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'NoneBot WebUI',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.check_box_outline_blank, color: Colors.white),
            tooltip: '多选',
            onPressed: _toggleSelectionMode,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '当前路径: ${Data.currentPath}',
                          style: const TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                if (Data.currentPath != '/') {
                                  List<String> parts =
                                      Data.currentPath.split('/');
                                  parts.removeLast();
                                  String newPath = parts.join('/');
                                  if (newPath.isEmpty) {
                                    newPath = '/';
                                  }
                                  Data.currentPath = newPath;

                                  socket.send(
                                      "file/list/$gOnOpen${Data.currentPath}&token=${Config.token}");
                                }
                              },
                              child: const Text(
                                '上一级',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Data.currentPath = '/';

                                socket.send(
                                    "file/list/$gOnOpen${Data.currentPath}&token=${Config.token}");
                              },
                              child: const Text(
                                '根目录',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                            TextButton(
                              child: const Text("创建目录",
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    final dirNameController =
                                        TextEditingController();
                                    return AlertDialog(
                                      title: const Text('创建新目录'),
                                      content: TextField(
                                        controller: dirNameController,
                                        decoration: const InputDecoration(
                                            hintText: '输入目录名称'),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('取消'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('创建'),
                                          onPressed: () {
                                            final dirName =
                                                dirNameController.text;
                                            if (dirName.isNotEmpty) {
                                              final command =
                                                  "file/mkdir/$gOnOpen${Data.currentPath}?name=$dirName&token=${Config.token}";
                                              socket.send(command);
                                              Navigator.of(context).pop();
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 500), () {
                                                socket.send(
                                                    "file/list/$gOnOpen${Data.currentPath}&token=${Config.token}");
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            TextButton(
                              child: const Text(
                                "新建文件",
                                style: TextStyle(color: Colors.blue),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    final fileNameController =
                                        TextEditingController();
                                    return AlertDialog(
                                      title: const Text('创建新文件'),
                                      content: TextField(
                                        controller: fileNameController,
                                        decoration: const InputDecoration(
                                            hintText: '输入文件名称'),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('取消'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('创建'),
                                          onPressed: () {
                                            final fileName =
                                                fileNameController.text;
                                            if (fileName.isNotEmpty) {
                                              final command =
                                                  "file/touch/$gOnOpen${Data.currentPath}?name=$fileName&token=${Config.token}";
                                              socket.send(command);
                                              Navigator.of(context).pop();
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 500), () {
                                                socket.send(
                                                    "file/list/$gOnOpen${Data.currentPath}&token=${Config.token}");
                                              });
                                            }
                                          },
                                        ),
                                        TextButton(
                                          child: const Text(
                                            "刷新",
                                            style:
                                                TextStyle(color: Colors.blue),
                                          ),
                                          onPressed: () {
                                            socket.send(
                                                "file/list/$gOnOpen${Data.currentPath}&token=${Config.token}");
                                          },
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  )),
              Expanded(
                  flex: 9,
                  child: ListView.builder(
                    itemCount: Data.fileList.length,
                    itemBuilder: (context, index) {
                      var file = Data.fileList[index];
                      final bool isSelected = _selectedIndices.contains(index);
                      return ListTile(
                        title: Text(file['name']),
                        leading: (file['type'] == 'directory')
                            ? const Icon(Icons.folder)
                            : const Icon(Icons.insert_drive_file),
                        trailing: _isSelectionMode
                            ? Checkbox(
                                value: isSelected,
                                onChanged: (bool? value) {
                                  _onItemTap(index);
                                },
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  IconButton(
                                    icon: const Icon(
                                        Icons.drive_file_rename_outline),
                                    tooltip: '重命名',
                                    onPressed: () => _handleSingleRename(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy),
                                    tooltip: '复制',
                                    onPressed: () => _prepareSingleItemPaste(
                                        index,
                                        isMove: false),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.drive_file_move),
                                    tooltip: '移动',
                                    onPressed: () => _prepareSingleItemPaste(
                                        index,
                                        isMove: true),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    tooltip: '删除',
                                    onPressed: () => _handleSingleDelete(index),
                                  ),
                                ],
                              ),
                        tileColor:
                            isSelected ? Colors.blue.withOpacity(0.2) : null,
                        onTap: () => _onItemTap(index),
                        onLongPress: () {
                          if (!_isSelectionMode) {
                            setState(() {
                              _isSelectionMode = true;
                              _selectedIndices.add(index);
                            });
                          }
                        },
                      );
                    },
                  )),
            ],
          ),
        ));
  }
}
