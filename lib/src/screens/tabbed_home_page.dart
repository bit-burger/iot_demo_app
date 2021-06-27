import 'package:flutter/material.dart';
import 'package:iot_app/src/models/leds_model.dart';
import 'package:iot_app/src/screens/animation_control_page.dart';
import 'package:provider/provider.dart';
import 'color_control_page.dart';
import 'sensors_page.dart';
import 'settings_page.dart';
import 'led_control_page.dart';

class TabbedHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          leading: SizedBox(),
          title: const Text('IOT-Control-App'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'LEDControl'),
              Tab(
                text: 'ColorControl',
              ),
              Tab(
                text: 'AnimationControl',
              ),
              Tab(text: 'Sensors'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              LedControlPage(),
              ColorControlPage(),
              AnimationControlPage(),
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
