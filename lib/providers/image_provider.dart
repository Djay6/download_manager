import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_downloader/flutter_downloader.dart';

import '../models/image.dart';

class ImageProviders with ChangeNotifier {
  List<Images> _items = [];
  List downloaded = [];
  List runningDown = [];
  Map downs = {'url': ''};

  List<Images> get items {
    return [..._items];
  }

  running(String taskId, String url, int progress, DownloadTaskStatus? status,
      String name) {
    //log(url, name: ' running URL');
    var filteredData =
        runningDown.where((element) => element["taskId"] == taskId).toList();
    if (filteredData.isNotEmpty) {
      runningDown
          .where((element) => element["taskId"] == taskId)
          .toList()
          .first["progress"] = progress;
    } else
      runningDown.add(
          {"url": url, "progress": progress, "taskId": taskId, "name": name});

    //log(runningDown.toString(), name: 'running down');

    notifyListeners();
  }

  removeFromDownload(String taskId) {
    runningDown.removeWhere((element) => element["taskId"] == taskId);
    notifyListeners();
  }

  addToDownloads(String path) {
    downloaded.add(path);
    notifyListeners();
  }

  openDownloadedImage(String path) {
    downs.update('url', (value) => path);
  }

  addToPending(String path) {
    downloaded.add(path);
  }

  Future fatchAndSet() async {
    http.Response response = await http.get(
        Uri.parse("https://api.pexels.com/v1/curated?per_page=80"),
        headers: {
          "Authorization":
              "563492ad6f917000010000019fed7f2f08084e41be1c9942f6ba5bed"
        });
    //Uri.parse(
    //     'https://api.unsplash.com/photos/?per_page=30&client_id=HLoYnjR95gDUOyM8u84i7IWRbsi2ydDsokogXOp0Xhg'));
    final data = json.decode(response.body)["photos"];
    //log(data.toString());

    final List<Images> loadedImages = [];
    for (var i = 0; i < data.length; i++) {
      loadedImages.add(Images(
          id: data[i]["id"].toString(),
          imgUrl: data[i]["src"]["small"],
          downUrl: data[i]["src"]["original"],
          status: ValueNotifier<int>(0)));
    }

    _items = loadedImages;
  }
}
