import 'package:iot_app/src/models/led_frame.dart';
import 'package:iot_app/src/models/leds.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import 'package:iot_app/constants.dart' as constants;

class Preferences {
  static const String tabIndexKey = 'tabIndex';
  static const String ledAnimationFramesKey = 'ledAnimationFrames';
  static const String ledColorsKey = 'ledColors';
  static const String urlKey = 'url';
  static const String newFrameTimeKey = 'newFrameTime';
  static const String frameRepeatKey = 'frameRepeat';

  static late final SharedPreferences sharedPreferences;

  Preferences.specifySharedPreferences(this._sharedPreferences);

  Preferences()
      : assert(sharedPreferences == sharedPreferences),
        _sharedPreferences = sharedPreferences;

  final SharedPreferences _sharedPreferences;

  String get url =>
      _sharedPreferences.getString(urlKey) ?? constants.defaultUrl;

  set url(String newUrl) => _sharedPreferences.setString(urlKey, newUrl);

  int get tab =>
      _sharedPreferences.getInt(tabIndexKey) ?? constants.defaultTabIndex;

  set tab(int newTab) => _sharedPreferences.setInt(tabIndexKey, newTab);

  List<LedFrame> get ledAnimationFrames {
    if (!_sharedPreferences.containsKey(ledAnimationFramesKey)) return [];

    final rawJson = _sharedPreferences.getString(ledAnimationFramesKey)!;
    final parsedJson = convert.jsonDecode(rawJson);
    final ledFrames = <LedFrame>[];

    if (parsedJson is List) {
      for (final Map<String, dynamic> rawLedFrame in parsedJson) {
        ledFrames.add(LedFrame.fromJson(rawLedFrame));
      }
    } else {
      throw Error();
    }

    return ledFrames;
  }

  set ledAnimationFrames(List<LedFrame> newLedAnimationFrame) {
    Future.microtask(() {
      final json = newLedAnimationFrame
          .map<Map<String, dynamic>>((frame) => frame.toJson())
          .toList(growable: false);
      final jsonString = convert.jsonEncode(json);
      _sharedPreferences.setString(ledAnimationFramesKey, jsonString);
    });
  }

  double get newFrameTime =>
      _sharedPreferences.getDouble(newFrameTimeKey) ??
      constants.defaultNewFrameTime;

  set newFrameTime(double newNewFrameTime) =>
      _sharedPreferences.setDouble(newFrameTimeKey, newNewFrameTime);

  int get frameRepeat =>
      _sharedPreferences.getInt(frameRepeatKey) ?? constants.defaultFrameRepeat;

  set frameRepeat(newFrameRepeat) =>
      _sharedPreferences.setInt(frameRepeatKey, newFrameRepeat);

  Leds get ledColors {
    final rawJson = _sharedPreferences.getString(ledColorsKey);
    if (rawJson == null) return Leds.off();
    final parsedJson = convert.jsonDecode(rawJson);

    return Leds.fromJson(parsedJson);
  }

  set ledColors(Leds newLeds) {
    Future.microtask(() {
      final json = newLeds.toJson();
      final jsonString = convert.jsonEncode(json);

      _sharedPreferences.setString(ledColorsKey, jsonString);
    });
  }
}
