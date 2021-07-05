import 'package:flutter/material.dart';
import 'package:iot_app/src/models/sensor_data.dart';
import 'package:iot_app/src/models/sensor_state.dart';
import 'package:iot_app/src/providers/micro_controller.dart';

class Sensors extends ChangeNotifier {
  Sensors(this._microController) : _sensorState = SensorState.loading {
    refresh();
  }

  MicroController _microController;

  SensorState _sensorState;
  SensorData? _sensorData;

  SensorState get sensorState => _sensorState;

  SensorData get sensorData => _sensorData!;

  void refresh() async {
    _sensorData = null;
    _sensorState = SensorState.loading;
    notifyListeners();

    final result = await _microController.makeRequest('/sensors');
    if (result.isValue) {
      final json = result.asValue!.value!;
      _sensorData = SensorData.fromJson(json);
      _sensorState = SensorState.value;
    } else {
      _sensorState = SensorState.error;
    }
    notifyListeners();
  }
}
