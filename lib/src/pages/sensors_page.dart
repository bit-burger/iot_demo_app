import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iot_app/src/models/leds_model.dart';
import 'package:iot_app/src/models/sensor_data.dart';
import 'package:provider/provider.dart';

class SensorsPage extends StatefulWidget {

  @override
  _SensorsPageState createState() => _SensorsPageState();
}

class _SensorsPageState extends State<SensorsPage> {
  late Future<SensorData> futureSensors;

  @override
  void initState() {
    super.initState();
    futureSensors = fetchSensorState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<SensorData>(
        future: futureSensors,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(50),
                child: Text(
                  snapshot.data!.temperature.toString(),
                ),
              ),
            );
          } else if (snapshot.hasError) {
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
          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
      ),
    );
  }

  Future<SensorData> fetchSensorState() async {
    final url = Provider.of<LedsModel>(context, listen: false).url;
    final response =
        await http.get(Uri.parse(url + '/sensors'));

    if (response.statusCode == 200) {
      return SensorData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load sensor-data');
    }
  }
}
