import 'package:flutter/material.dart';
import 'package:iot_app/src/models/sensor_state.dart';
import 'package:iot_app/src/providers/floating_action_button_events.dart';
import 'package:iot_app/src/providers/tab_view_index.dart';
import 'package:iot_app/src/providers/sensors.dart';
import 'package:provider/provider.dart';

class SensorsPage extends StatefulWidget {
  @override
  _SensorsPageState createState() => _SensorsPageState();
}

class _SensorsPageState extends State<SensorsPage>
    with AutomaticKeepAliveClientMixin {
  Widget _buildInformationArea() {
    final sensors = Provider.of<Sensors>(context);
    switch (sensors.state) {
      case SensorState.value:
        return Center(
          child: Padding(
            padding: EdgeInsets.all(25),
            child: Column(
              children: [
                ListTile(
                  title: Text('Temperature: ' +
                      sensors.sensorData.temperature.toString() +
                      "°C"),
                ),
                Divider(),
                ListTile(
                  title: Text('Humidity: ' +
                      sensors.sensorData.humidity.toString() +
                      "%"),
                ),
              ],
            ),
          ),
        );
      case SensorState.loading:
        return CircularProgressIndicator();
      case SensorState.error:
        return Center(
          child: Padding(
            padding: EdgeInsets.all(50),
            child: Text(
              'Something went wrong, '
              'make sure your sensors are connected, '
              'and your board is connected to your local wlan',
              textAlign: TextAlign.center,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Center(
        child: _buildInformationArea(),
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
