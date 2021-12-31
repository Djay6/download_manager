import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/image_provider.dart';
import './showDownloadedImage.dart';

class Downloads extends StatefulWidget {
  static const routeNAme = '/downloads';

  const Downloads({Key? key}) : super(key: key);

  @override
  State<Downloads> createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  @override
  Widget build(BuildContext context) {
    final downData = Provider.of<ImageProviders>(context);
    var files = [];
    var runningDown = [];
    runningDown = downData.runningDown;
    files = downData.downloaded;
    // log(downData.runningDown.toString(), name: 'running down');
    // log(downData.downloaded.toString());
    return Scaffold(
      appBar: AppBar(title: const Text('Downloads')),
      body: runningDown.isEmpty && files.isEmpty
          ? const Center(
              child: Text('You Do not have any Download'),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (runningDown != null && runningDown.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: runningDown.length,
                      itemBuilder: (BuildContext context, int i) {
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  leading: SizedBox(
                                    height: 100,
                                    width: 80,
                                    child: Image.network(
                                      runningDown[i]["url"],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Column(
                                      children: [
                                        Text(runningDown[i]["name"]
                                            .toString()
                                            .split(".")
                                            .first),
                                        ElevatedButton(
                                            onPressed: () {},
                                            child: const Text(
                                              'Downloading...',
                                              softWrap: true,
                                            )),
                                        LinearProgressIndicator(
                                          color: Colors.amber,
                                          value:
                                              runningDown[i]["progress"] / 100,
                                        )
                                      ],
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.more_vert),
                                    onPressed: () {},
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: files.length,
                    itemBuilder: (BuildContext context, int i) {
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                leading: SizedBox(
                                  height: 100,
                                  width: 80,
                                  child: GestureDetector(
                                    onTap: () {
                                      downData.openDownloadedImage(files[i]);
                                      Navigator.of(context).pushNamed(
                                          ShowDownloadedImage.routeNAme);
                                    },
                                    child: Image.file(
                                      File(files[i]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                title: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Column(
                                    children: [
                                      Text(files[i]
                                          .toString()
                                          .split("/")
                                          .last
                                          .toString()
                                          .split(".")
                                          .first),
                                      ElevatedButton(
                                          onPressed: () {},
                                          child: const Text(
                                            'Downloaded',
                                            softWrap: true,
                                          )),
                                    ],
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () {},
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
