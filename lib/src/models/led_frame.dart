import 'package:flutter/material.dart';
import 'leds.dart';

class LedFrame {
  Leds frame;
  double time;

  LedFrame(this.frame, this.time);

  factory LedFrame.fromJson(Map<String, dynamic> json) {
    return LedFrame(Leds.fromJson(json['frame']), json['time']);
  }

  void rotateToRight() {
    final lastElement = frame.ledValues[11];
    for (var i = 10; i >= 0; i--) {
      frame.ledValues[i + 1] = frame.ledValues[i];
    }
    frame.ledValues[0] = lastElement;
  }

  void rotateToLeft() {
    final firstElement = frame.ledValues[0];
    for (var i = 1; i < 12; i++) {
      frame.ledValues[i - 1] = frame.ledValues[i];
    }
    frame.ledValues[11] = firstElement;
  }

  List<Color> toColorList() => frame.ledValues
      .map((ledValue) => ledValue.toColor())
      .toList(growable: false);

  Map<String, dynamic> toJson() {
    return {
      "frame": frame.toJson(),
      "time": time,
    };
  }

  LedFrame copy() {
    return LedFrame(frame.copy(), time);
  }
}
