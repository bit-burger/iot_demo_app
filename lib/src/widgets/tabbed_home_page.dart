import 'package:flutter/material.dart';
import 'package:iot_app/src/logic/app_config.dart';
import 'package:iot_app/src/widgets/sensors_page.dart';
import 'package:iot_app/src/widgets/settings_page.dart';

import 'led_control_page.dart';

class TabbedHomePage extends StatelessWidget {
  const TabbedHomePage(this.appConfig);
  final AppConfig appConfig;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('IOT-Control-App'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'LEDControl'),
              Tab(text: 'Sensors'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: TabBarView(
            children: [
              LEDControlPage(appConfig),
              SensorsPage(appConfig),
              SettingsPage(appConfig),
            ],
          ),
        ),
      ),
    );
  }
}