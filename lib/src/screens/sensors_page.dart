import 'package:flutter/material.dart';
import 'package:iot_app/src/models/led_state.dart';
import 'package:iot_app/src/models/sensor_state.dart';
import 'package:iot_app/src/providers/floating_action_button_events.dart';
import 'package:iot_app/src/providers/led_ring.dart';
import 'package:iot_app/src/providers/tab_view_index.dart';
import 'package:iot_app/src/providers/sensors.dart';
import 'package:provider/provider.dart';

class SensorsPage extends StatefulWidget {
  @override
  _SensorsPageState createState() => _SensorsPageState();
}

class _SensorsPageState extends State<SensorsPage>
    with AutomaticKeepAliveClientMixin {
  Iterable<Widget> _buildInformationArea() sync* {
    final sensors = context.read<Sensors>();
    final ledRing = context.read<LedRing>();
    yield Center(
      child: Padding(
        padding: EdgeInsets.all(25),
        child: Column(
          children: [
            ListTile(
              title: Text(
                'Temperature: ' + sensors.sensorData.temperature,
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Humidity: ' + sensors.sensorData.temperature,
              ),
            ),
          ],
        ),
      ),
    );
    if (sensors.state == SensorState.loading &&
        ledRing.state != LedState.loading) {
      yield CircularProgressIndicator();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Center(
        child: Column(
          children: [
            ..._buildInformationArea(),
          ],
        ),
      ),
    );
  }

  void _floatingActionButtonTapped() {
    final provider = context.read<TabViewIndex>();

    if (provider.index == 3) {
      context.read<Sensors>().refresh();
    }
  }

  @override
  void initState() {
    super.initState();
    context
        .read<FloatingActionButtonEvents>()
        .addListener(_floatingActionButtonTapped);
  }

  @override
  bool get wantKeepAlive => true;
}
