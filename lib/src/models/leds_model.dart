import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'led.dart';
import 'leds.dart';
import 'led_state.dart';

import 'dart:convert' as convert;

class LedsModel extends ChangeNotifier {
  LedsModel(this._url) {
    _updateLeds(
      () => _getLeds(),
      forceOverrideConfiguration: true,
      notifyLoading: false,
    );
  }

  late String _url;

  LedState _ledState = LedState.loading;

  Leds? _ledConfiguration;

  Leds? get ledConfiguration => _ledConfiguration;

  String get url => _url;

  LedState get ledState => _ledState;

  bool get isActive => _ledState == LedState.on || _ledState == LedState.off;

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

  changeUrl(String newUrl) {
    _url = newUrl;
    nL();
  }

  // if config is completely off make config full on
  // after that just use config to update
  turnOn() async {
    assert(!isOn);
    if (_ledConfiguration!.isOff) _ledConfiguration = Leds.on();
    _updateLeds(() => _setLeds(_ledConfiguration!));
  }

  turnOff() async {
    assert(isOn);
    _updateLeds(() => _setLeds(Leds.off()));
  }

  updateLed(int replacingLedPosition, Led replacingLed) {
    assert(isActive);
    final ledCopy = _ledConfiguration!.copy();
    ledCopy.ledValues[replacingLedPosition] = replacingLed;
    _updateLeds(() => _setLeds(ledCopy));
  }

  updateLeds(Leds newLeds) {
    assert(isOn);
    _updateLeds(() => _setLeds(newLeds), forceOverrideConfiguration: true);
  }

  refreshData() async {
    _updateLeds(
      () => _getLeds(),
      forceOverrideConfiguration: true,
    );
  }

  resetLeds() async {
    _updateLeds(
      () async => _setLeds(Leds.off()),
      forceOverrideConfiguration: true,
    );
  }

  _updateLeds(
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
        _ledConfiguration = leds;
      } else {
        if (forceOverrideConfiguration) _ledConfiguration = leds;
        _ledState = leds.isOff ? LedState.off : LedState.on;
      }
    } on Exception {
      _ledState = LedState.error;
    }
    nL();
  }

  Future<Leds> _getLeds() async {
    final response = await http.get(Uri.parse(_url + '/leds'));
    return _processResponse(response);
  }

  Future<Leds> _setLeds(Leds leds) async {
    print('Client: ' + leds.toJson());
    final response = await http.put(
      Uri.parse(_url + '/leds'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: leds.toJson(),
    );
    return _processResponse(response);
  }

  Leds _processResponse(http.Response response) {
    if (response.statusCode == 200) {
      final leds = Leds.fromJSON(convert.jsonDecode(response.body));
      print('Micro: ' + leds.toJson());
      return leds;
    }
    throw Exception();
  }

  void nL() {
    notifyListeners();
  }
}
