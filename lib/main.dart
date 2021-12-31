import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import './Screens/overview_screen.dart';
import './providers/image_provider.dart';
import './Screens/downloads.dart';
import './Screens/showDownloadedImage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: false);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (ctx) => ImageProviders())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          Downloads.routeNAme: (ctx) => Downloads(),
          ShowDownloadedImage.routeNAme: (ctx) => ShowDownloadedImage(),
        },
        home: const OverviewScreen(),
      ),
    );
  }
}
