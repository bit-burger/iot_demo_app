import 'package:flutter/material.dart';
import 'package:iot_app/src/models/led_state.dart';
import 'package:iot_app/src/models/sensor_data.dart';
import 'package:iot_app/src/models/sensor_state.dart';
import 'package:iot_app/src/providers/led_ring.dart';
import 'package:iot_app/src/providers/micro_controller.dart';

class Sensors extends ChangeNotifier {
  Sensors(this._microController, this._ledRing)
      : _sensorState = SensorState.loading,
        _sensorData = SensorData.noData() {
    refresh();
    _ledRing.addListener(() {
      if (_ledRing.state == LedState.connectionError) {
        _sensorState = SensorState.error;
      } else if (_sensorState == SensorState.error && _ledRing.isActive) {
        refresh();
      }
    });
  }

  MicroController _microController;
  LedRing _ledRing;

  SensorState _sensorState;
  SensorData _sensorData;

  SensorState get state => _sensorState;

  SensorData get sensorData => _sensorData;

  void refresh() async {
    _sensorState = SensorState.loading;
    notifyListeners();

    final result = await _microController.makeRequest('/sensors');
    if (result.isValue) {
      final json = result.asValue!.value!;
      _sensorData = SensorData.fromJson(json);
      _sensorState = SensorState.value;
    } else {
      _sensorData = SensorData.noData();
      _ledRing.connectionError();
      _sensorState = SensorState.error;
    }
    notifyListeners();
  }
}
