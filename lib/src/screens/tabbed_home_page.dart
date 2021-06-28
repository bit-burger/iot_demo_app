import 'package:flutter/material.dart';
import 'package:iot_app/src/models/tab_view_floating_action_button_event_provider.dart';
import 'package:iot_app/src/models/leds_model.dart';
import 'package:iot_app/src/screens/animation_control_page.dart';
import 'package:provider/provider.dart';
import 'color_control_page.dart';
import 'sensors_page.dart';
import 'settings_page.dart';
import 'led_control_page.dart';

class TabbedHomePage extends StatefulWidget {
  TabbedHomePage({required this.initialIndex});

  final int initialIndex;

  @override
  _TabbedHomePageState createState() => _TabbedHomePageState();
}

class _TabbedHomePageState extends State<TabbedHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _tabIndex;

  static const List<IconData?> tabIconList = [
    null,
    null,
    Icons.play_arrow,
    Icons.refresh,
    null,
  ];

  @override
  Widget build(BuildContext context) {
    final currentTabIcon = tabIconList[_tabIndex];
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
                Provider.of<LedsModel>(context, listen: false).resetLeds();
              },
        child: FloatingActionButton(
          onPressed: currentTabIcon != null
              ? () {
                  Provider.of<TabViewFloatingActionButtonEventProvider>(context,
                          listen: false)
                      .floatingActionButtonTapped();
                }
              : () {
                  Provider.of<LedsModel>(context, listen: false).refreshData();
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
      initialIndex: widget.initialIndex,
    );
    _tabIndex = widget.initialIndex;
    _tabController.addListener(() {
      if (_tabIndex != _tabController.index) {
        setState(() {
          _tabIndex = _tabController.index;
          Provider.of<TabViewFloatingActionButtonEventProvider>(context,
                  listen: false)
              .tabChanged(_tabIndex);
        });
      }
    });
    super.initState();
  }
}
