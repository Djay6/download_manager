import 'package:flutter/material.dart';

class Images with ChangeNotifier {
  final String id;
  final String imgUrl;
  final String downUrl;
  final ValueNotifier<int> status;
  String? taskId;

  Images(
      {required this.id,
      required this.downUrl,
      required this.imgUrl,
      required this.status,
      this.taskId});
}
