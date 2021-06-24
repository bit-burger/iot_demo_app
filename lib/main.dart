import 'package:flutter/material.dart';
import 'package:iot_app/src/models/leds_model.dart';
import 'package:iot_app/src/pages/tabbed_home_page.dart';
import 'package:provider/provider.dart';

import 'constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LedsModel>(
      create: (BuildContext context) {
        return LedsModel(defaultUrl);
      },
      child: MaterialApp(
        title: 'Flutter IoT Control',
        home: TabbedHomePage(),
      ),
    );
  }
}
