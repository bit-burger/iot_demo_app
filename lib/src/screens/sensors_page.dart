import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iot_app/src/models/tab_view_floating_action_button_event_provider.dart';
import 'package:iot_app/src/models/leds_model.dart';
import 'package:iot_app/src/models/sensor_data.dart';
import 'package:provider/provider.dart';

class SensorsPage extends StatefulWidget {
  @override
  _SensorsPageState createState() => _SensorsPageState();
}

class _SensorsPageState extends State<SensorsPage>
    with AutomaticKeepAliveClientMixin {
  late Future<SensorData> futureSensors;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    futureSensors = _fetchSensorData();
    Provider.of<TabViewFloatingActionButtonEventProvider>(context,
            listen: false)
        .addListener(_floatingActionButtonTapped);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Center(
        child: FutureBuilder<SensorData>(
          initialData: null,
          future: futureSensors,
          builder: (context, snapshot) {
            if (loading)
              return CircularProgressIndicator();
            else if (snapshot.hasError) {
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
            return Center(
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Column(
                  children: [
                    ListTile(
                      title: Text('Temperature: ' +
                          snapshot.data!.temperature.toString() +
                          "°C"),
                    ),
                    Divider(),
                    ListTile(
                      title: Text('Humidity: ' +
                          snapshot.data!.humidity.toString() +
                          "%"),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _floatingActionButtonTapped() {
    loading = true;
    final provider = Provider.of<TabViewFloatingActionButtonEventProvider>(
        context,
        listen: false);

    if (provider.tabIndex == 3) {
      setState(() {
        futureSensors = _fetchSensorData();
      });
    }
  }

  Future<SensorData> _fetchSensorData() async {
    final url = Provider.of<LedsModel>(context, listen: false).url;
    final response = await http.get(Uri.parse(url + '/sensors'));

    loading = false;
    if (response.statusCode == 200) {
      return SensorData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load sensor-data');
    }
  }

  @override
  bool get wantKeepAlive => true;
}
