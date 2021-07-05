import 'package:flutter/material.dart';
import 'package:iot_app/src/providers/floating_action_button_events.dart';
import 'package:iot_app/src/providers/tab_view_index.dart';
import 'package:iot_app/src/providers/led_ring.dart';
import 'package:iot_app/src/screens/animation_control_page.dart';
import 'package:provider/provider.dart';
import 'color_control_page.dart';
import 'sensors_page.dart';
import 'settings_page.dart';
import 'led_control_page.dart';

class TabbedHomePage extends StatefulWidget {
  TabbedHomePage();

  @override
  _TabbedHomePageState createState() => _TabbedHomePageState();
}

class _TabbedHomePageState extends State<TabbedHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<IconData?> tabIconList = [
    null,
    null,
    Icons.play_arrow,
    Icons.refresh,
    null,
  ];

  @override
  Widget build(BuildContext context) {
    final tabIndex = context.watch<TabViewIndex>().index;
    final currentTabIcon = tabIconList[tabIndex];
    return Scaffold(
      appBar: AppBar(
        leading: SizedBox(),
        title: const Text('IOT-Control-App'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'LEDControl'),
            Tab(text: 'ColorControl'),
            Tab(text: 'AnimationControl'),
            Tab(text: 'Sensors'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: TabBarView(
          controller: _tabController,
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
        onLongPress: currentTabIcon != null
            ? null
            : () {
          Provider.of<LedRing>(context, listen: false).reset();
              },
        child: FloatingActionButton(
          onPressed: currentTabIcon != null
              ? () {
                  context
                      .read<FloatingActionButtonEvents>()
                      .floatingActionButtonPressed();
                }
              : () {
            context.read<LedRing>().refresh();
                },
          child: Icon(
            currentTabIcon ?? Icons.refresh,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: context.read<TabViewIndex>().index,
    );
    _tabController.addListener(() {
      context.read<TabViewIndex>().index = _tabController.index;
    });
    super.initState();
  }
}
