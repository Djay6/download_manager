import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/image_provider.dart';

class ShowDownloadedImage extends StatelessWidget {
  const ShowDownloadedImage({Key? key}) : super(key: key);
  static const routeNAme = '/downloaded';

  @override
  Widget build(BuildContext context) {
    Map files = {};
    final downData = Provider.of<ImageProviders>(context);
    files = downData.downs;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Download'),
      ),
      body: Center(
        child: Image.file(File(files['url'])),
      ),
    );
  }
}
