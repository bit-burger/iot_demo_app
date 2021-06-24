import 'package:flutter/material.dart';
import 'package:iot_app/src/models/leds_model.dart';
// import 'sensors_page.dart';
import 'settings_page.dart';
import 'led_control_page.dart';
import 'package:provider/provider.dart';

class TabbedHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('IOT-Control-App'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'LEDControl'),
              //Tab(text: 'Sensors'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: TabBarView(
            children: [
              LedControlPage(),
              //SensorsPage(),
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
