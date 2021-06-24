import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iot_app/src/logic/app_config.dart';
import 'package:iot_app/src/logic/sensors.dart';



class SensorsPage extends StatefulWidget {
  SensorsPage(this.appConfig, {Key? key}) : super(key: key);

  final AppConfig appConfig;

  @override
  _SensorsPageState createState() => _SensorsPageState(appConfig);
}

class _SensorsPageState extends State<SensorsPage> {
  final AppConfig appConfig;
  late Future<Sensors> futureSensors;
  _SensorsPageState(this.appConfig);

  @override
  void initState() {
    super.initState();
    futureSensors = fetchSensorState(appConfig);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<Sensors>(
        future: futureSensors,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(snapshot.data!.temperature.toString());
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
      ),
    );
  }

  Future<Sensors> fetchSensorState(AppConfig appConfig) async {
    final response =
        await http.get(Uri.parse(appConfig.iotControllerUrl + '/sensors'));

    if (response.statusCode == 200) {
      return Sensors.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load sensor-data');
    }
  }
}
