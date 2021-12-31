import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './downloads.dart';
import '../util/download_util.dart';
import '../providers/image_provider.dart';
import '../util/badge.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({Key? key}) : super(key: key);

  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  Future<void> _refreshImages(BuildContext context) async {
    await Provider.of<ImageProviders>(context, listen: false).fatchAndSet();
  }

  @override
  Widget build(BuildContext context) {
    final imageData = Provider.of<ImageProviders>(context, listen: false);
    var runningDown = [];
    runningDown = imageData.runningDown;
    return Scaffold(
      appBar: AppBar(
        actions: [
          Consumer<ImageProviders>(
            builder: (BuildContext context, value, Widget? child) => Badge(
              value: (value.runningDown.length).toString(),
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      Downloads.routeNAme,
                    );
                  },
                  icon: const Icon(Icons.download_outlined)),
            ),
          )
        ],
        title: const Text('Images'),
      ),
      body: FutureBuilder(
        future: _refreshImages(context),
        builder: (ctx, AsyncSnapshot<dynamic> snapshot) => snapshot
                    .connectionState ==
                ConnectionState.waiting
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => _refreshImages(context),
                child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: imageData.items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3),
                    itemBuilder: (ctx, i) {
                      final stackWidget = ValueNotifier<int>(0);
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: ValueListenableBuilder<int>(
                                valueListenable: stackWidget,
                                builder: (context, stackWidgetValue, child) {
                                  return Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      MyDownloader(
                                        fileName:
                                            imageData.items[i].id + '.jpg',
                                        child: Image.network(
                                          imageData.items[i].imgUrl,
                                          fit: BoxFit.cover,
                                        ),
                                        url: imageData.items[i].downUrl,
                                        onDownloadRunning: (taskId, progress,
                                            task, status, name) {
                                          stackWidget.value = 1;
                                          imageData.running(
                                              taskId!,
                                              task!.url,
                                              task.progress,
                                              status,
                                              task.filename.toString());
                                          // log(taskId.toString(),
                                          //     name: 'image data running');
                                          // log(progress.toString(),
                                          //     name: 'image data running');
                                        },
                                        onDownloadComplete: (taskId, task) {
                                          stackWidget.value = 2;
                                          // log(taskId.toString(),
                                          //     name: 'image data completed');
                                          // log(task!.filename.toString());

                                          imageData.addToDownloads(
                                            '/storage/emulated/0/Android/data/com.example.download_manager/files/Download/' +
                                                task!.filename.toString(),
                                          );
                                          imageData.removeFromDownload(taskId!);

                                          // print(imageData.pendingDownloads);
                                        },
                                        onDownloadFailed: (taskId) {
                                          stackWidget.value = 0;
                                          log(taskId.toString(),
                                              name: 'image data failed');

                                          imageData.removeFromDownload(taskId!);
                                        },
                                      ),
                                    ],
                                  );
                                })),
                      );
                    }),
              ),
      ),
    );
  }
}
