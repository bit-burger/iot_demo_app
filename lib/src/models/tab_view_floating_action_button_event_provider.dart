import 'package:flutter/material.dart';

class TabViewFloatingActionButtonEventProvider extends ChangeNotifier {
  TabViewFloatingActionButtonEventProvider(this._tabIndex);

  int _tabIndex;

  int get tabIndex => _tabIndex;

  void tabChanged(int tabIndex) {
    _tabIndex = tabIndex;
  }

  void floatingActionButtonTapped() {
    notifyListeners();
  }
}
