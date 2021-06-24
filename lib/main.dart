import 'package:flutter/material.dart';
import 'package:iot_app/src/logic/app_config.dart';
import 'package:iot_app/src/widgets/tabbed_home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AppConfig appConfig = new AppConfig();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter IoT Control',
      home: TabbedHomePage(appConfig),
    );
  }
}


