import 'package:flutter/material.dart';
import 'package:iot_app/src/providers/floating_action_button_events.dart';
import 'package:iot_app/src/providers/tab_view_index.dart';
import 'package:iot_app/src/providers/led_ring.dart';
import 'package:iot_app/src/providers/micro_controller.dart';
import 'package:iot_app/src/providers/preferences.dart';
import 'package:iot_app/src/providers/sensors.dart';
import 'package:iot_app/src/screens/tabbed_home_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  Preferences.sharedPreferences = await SharedPreferences.getInstance();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Preferences>(
          create: (BuildContext context) => Preferences(),
        ),
        Provider<FloatingActionButtonEvents>(
          create: (BuildContext context) => FloatingActionButtonEvents(),
        ),
        ChangeNotifierProxyProvider<Preferences, TabViewIndex>(
          create: (BuildContext context) =>
              TabViewIndex(context.read<Preferences>()),
          update: (_, __, homePageEvents) => homePageEvents!,
        ),
        ProxyProvider<Preferences, MicroController>(
          create: (BuildContext context) =>
              MicroController(context.read<Preferences>()),
          update: (_, __, microController) => microController!,
        ),
        ChangeNotifierProxyProvider2<Preferences, MicroController, LedRing>(
          create: (BuildContext context) => LedRing(
              context.read<Preferences>(), context.read<MicroController>()),
          update: (_, __, ___, ledRing) => ledRing!,
        ),
        ChangeNotifierProxyProvider2<MicroController, LedRing, Sensors>(
          create: (BuildContext context) =>
              Sensors(context.read<MicroController>(), context.read<LedRing>()),
          update: (_, __, ___, sensors) => sensors!,
        ),
      ],
      child: MaterialApp(
        title: 'Flutter IoT Control',
        debugShowCheckedModeBanner: false,
        home: TabbedHomePage(),
      ),
    );
  }
}
