import 'package:flutter/widgets.dart';
import 'package:iot_app/src/providers/micro_controller.dart';
import 'package:iot_app/src/providers/preferences.dart';

import '../models/led.dart';
import '../models/leds.dart';
import '../models/led_state.dart';

class LedRing extends ChangeNotifier {
  LedRing(this._preferences, this._microController)
      : this._ledConfiguration = _preferences.ledColors {
    _updateLeds(
      () => _getLeds(),
      forceOverrideConfiguration: true,
      notifyLoading: false,
    );
  }

  Preferences _preferences;
  MicroController _microController;

  LedState _ledState = LedState.loading;
  Leds _ledConfiguration;

  Leds get ledConfiguration => _ledConfiguration;

  LedState get ledState => _ledState;

  bool get isActive => _ledState == LedState.on || _ledState == LedState.off;

  void _setLedConfiguration(Leds newConfiguration) {
    this._ledConfiguration = newConfiguration;
    _preferences.ledColors = newConfiguration;
  }

  bool get isOn {
    switch (_ledState) {
      case LedState.on:
        return true;
      case LedState.off:
        return false;
      default:
        throw Exception('Should only ask for this if checked for other states');
    }
  }


  void turnOn() async {
    assert(!isOn);
    _updateLeds(() =>
        _setLeds(_ledConfiguration.isOff ? Leds.on() : _ledConfiguration));
  }

  void turnOff() async {
    assert(isOn);
    _updateLeds(() => _setLeds(Leds.off()));
  }

  void updateLed(int replacingLedPosition, Led replacingLed) {
    assert(isActive);
    final ledCopy = _ledConfiguration.copy();
    ledCopy.ledValues[replacingLedPosition] = replacingLed;
    _updateLeds(() => _setLeds(ledCopy));
  }

  void updateLeds(Leds newLeds) {
    assert(isOn);
    _updateLeds(() => _setLeds(newLeds), forceOverrideConfiguration: true);
  }

  void refresh() async {
    _updateLeds(
      () => _getLeds(),
      forceOverrideConfiguration: true,
    );
  }

  void reset() async {
    _updateLeds(
      () async => _setLeds(Leds.off()),
      forceOverrideConfiguration: true,
    );
  }

  void _updateLeds(
    Future<Leds> updatingTask(), {
    bool forceOverrideConfiguration = false,
    bool notifyLoading = true,
  }) async {
    if (notifyLoading) {
      _ledState = LedState.loading;
      nL();
    }
    try {
      final leds = await updatingTask();
      if (!leds.isCompletelyOnOrOff) {
        _ledState = LedState.on;
        _setLedConfiguration(leds);
      } else {
        if (forceOverrideConfiguration) _setLedConfiguration(leds);
        _ledState = leds.isOff ? LedState.off : LedState.on;
      }
    } on Exception {
      _ledState = LedState.error;
    }
    nL();
  }

  Future<Leds> _getLeds() async {
    final result = await _microController.makeRequest('/leds');
    if (result.isError) throw Exception(result.asError!.error);
    final json = result.asValue!.value!;
    return Leds.fromJson(json);
  }

  Future<Leds> _setLeds(Leds leds) async {
    final result =
        await _microController.makeRequest('/leds', Method.PUT, leds);
    if (result.isError) throw Exception(result.asError!.error);
    final json = result.asValue!.value!;
    return Leds.fromJson(json);
  }

  void nL() {
    notifyListeners();
  }
}
