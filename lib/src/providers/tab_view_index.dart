import 'package:flutter/material.dart';
import 'package:iot_app/src/providers/preferences.dart';

class TabViewIndex extends ChangeNotifier {
  TabViewIndex(this._preferences) : _index = _preferences.tab;

  int _index;
  Preferences _preferences;

  int get index => _index;

  set index(int newIndex) {
    if (_index != newIndex) {
      _index = newIndex;
      notifyListeners();
      _preferences.tab = newIndex;
    }
  }
}
