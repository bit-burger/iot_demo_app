import 'package:flutter/material.dart';

class FloatingActionButtonEvents extends ChangeNotifier {
  void floatingActionButtonPressed() {
    notifyListeners();
  }
}
