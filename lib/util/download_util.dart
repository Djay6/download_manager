import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MyDownloader extends StatefulWidget with WidgetsBindingObserver {
  final Widget? child;
  final String? url;
  final String? fileName;
  final Function(String? taskId, DownloadTask? task)? onDownloadComplete;
  final Function(String? taskId, int? progress, DownloadTask? task,
      DownloadTaskStatus? status, String? name)? onDownloadRunning;
  final Function(String? taskId)? onDownloadFailed;
  final Function(String taskId)? onDownloadPaused;

  MyDownloader({
    this.child,
    this.url,
    this.fileName,
    this.onDownloadComplete,
    this.onDownloadRunning,
    this.onDownloadFailed,
    this.onDownloadPaused,
  });

  @override
  _MyDownloaderState createState() => _MyDownloaderState();
}

class _MyDownloaderState extends State<MyDownloader> {
  _TaskInfo? _task;
  String? _localPath;
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    _bindBackgroundIsolate();

    FlutterDownloader.registerCallback(downloadCallback);

    _task = _TaskInfo(name: 'download', link: widget.url);

    _prepare();
  }

  @override
  void dispose() {
    _unbindBackgroundIso();
    super.dispose();
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIso();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) async {
      print('UI Iso Callback: $data');
      String? id = data[0];
      DownloadTaskStatus? status = data[1];
      int? progress = data[2];
      setState(() {});
      print(id);
      print(status);
      print(progress);
      print(_task);
      print(_task!.taskId);

      if (_task != null /*&& _task.link != null*/) {
        // _task.taskId = id;
        _task!.status = status;
        _task!.progress = progress;
        if (status == DownloadTaskStatus.running) {
          var tasks = await FlutterDownloader.loadTasks();
          var currentTask =
              tasks?.firstWhere((element) => element.taskId == id);
          widget.onDownloadRunning!(id, progress, currentTask, status,
              currentTask!.filename.toString());
        } else if (progress == 100 || status == DownloadTaskStatus.complete) {
          var tasks = await FlutterDownloader.loadTasks();
          var currentTask =
              tasks?.firstWhere((element) => element.taskId == id);
          widget.onDownloadComplete!(id, currentTask);
        } else if (status == DownloadTaskStatus.failed) {
          widget.onDownloadFailed!(id);
        } else if (status == DownloadTaskStatus.paused) {}
      }
    });
  }

  void _unbindBackgroundIso() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    print(
        'Background Iso Callback: task ($id) is in status ($status) and process ($progress)');
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) => _buildDownloadList());
  }

  Widget _buildDownloadList() {
    return InkWell(
        child: widget.child,
        onTap: () {
          if (widget.url != null) {
            print('${widget.url} ${_task!.status}');
            _task!.status = DownloadTaskStatus.undefined;

            if (Platform.isAndroid) {
              if (_task!.status == DownloadTaskStatus.undefined) {
                _requestDownload(_task!, widget.fileName.toString());
              } else if (_task!.status == DownloadTaskStatus.running) {
                _pauseDownload(_task!);
              } else if (_task!.status == DownloadTaskStatus.paused) {
                _resumeDownload(_task!);
              } else if (_task!.status == DownloadTaskStatus.complete) {
              } else if (_task!.status == DownloadTaskStatus.failed) {
                _retryDownload(_task!);
              }
            } else {}
          } else {}
        });
  }

  void _requestDownload(_TaskInfo task, String fileName) async {
    await _checkPermission();

    task.taskId = await FlutterDownloader.enqueue(
        fileName: fileName,
        url: task.link!,
        savedDir: _localPath!,
        showNotification: true,
        openFileFromNotification: true);
  }

  void _cancelDownload(_TaskInfo task) async {
    await FlutterDownloader.cancel(taskId: task.taskId!);
  }

  void _pauseDownload(_TaskInfo task) async {
    await FlutterDownloader.pause(taskId: task.taskId!);
  }

  void _resumeDownload(_TaskInfo task) async {
    String? newTaskId = await FlutterDownloader.resume(taskId: task.taskId!);
    task.taskId = newTaskId;
  }

  void _retryDownload(_TaskInfo task) async {
    String? newTaskId = await FlutterDownloader.retry(taskId: task.taskId!);
    task.taskId = newTaskId;
  }

  bool? _openDownloadedFile(_TaskInfo task) {
    print('open done ${task.progress}');
    if (task != null) {
      Future.delayed(Duration(seconds: 2), () async {
        return await FlutterDownloader.open(taskId: task.taskId!);
      });
    } else {
      return false;
    }
  }

  void _delete(_TaskInfo task) async {
    await FlutterDownloader.remove(
        taskId: task.taskId!, shouldDeleteContent: true);
    await _prepare();
    setState(() {});
  }

  Future<bool> _checkPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future<Null> _prepare() async {
    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath!);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory!.path;
  }
}

class _TaskInfo {
  final String? name;
  final String? link;

  String? taskId;
  int? progress = 0;
  DownloadTaskStatus? status = DownloadTaskStatus.undefined;

  _TaskInfo({this.name, this.link});
}
