import 'package:flutter/material.dart';
import 'package:iot_app/src/models/leds_model.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:iot_app/src/pages/single_color_control_page.dart';
import 'sensors_page.dart';
import 'settings_page.dart';
import 'led_control_page.dart';
import 'package:provider/provider.dart';

class TabbedHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('IOT-Control-App'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'LEDControl'),
              Tab(text: 'ColorControl',),
              Tab(text: 'Sensors'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: TabBarView(
            children: [
              LedControlPage(),
              SingleColorControlPage(),
              SensorsPage(),
              SettingsPage(),
            ],
          ),
        ),
        floatingActionButton: GestureDetector(
          onLongPress: () {
            Provider.of<LedsModel>(context, listen: false).resetLeds();
          },
          child: FloatingActionButton(
            onPressed: () {
              Provider.of<LedsModel>(context, listen: false).refreshData();
            },
            child: Icon(
              Icons.refresh,
            ),
          ),
        ),
      ),
    );
  }
}
