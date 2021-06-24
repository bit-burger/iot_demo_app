import 'dart:convert';

class Led {
  final List<int> rgbValues;
  Led({required this.rgbValues});

  factory Led.empty() {
    return Led(rgbValues: [0, 0, 0]);
  }
  factory Led.formJSON(List<dynamic> json) {
    return Led(rgbValues: json.map((e) => e as int).toList());
  }
  setRGB(int r, int g, int b) {
    this.rgbValues[0] = r;
    this.rgbValues[1] = g;
    this.rgbValues[2] = b;
  }

  @override
  String toString() {
    return 'r: ${rgbValues[0]} g: ${rgbValues[1]} b: ${rgbValues[2]}';
  }

  String toJson() {
    return jsonEncode(rgbValues);
  }
}

class LEDs {
  final List<Led> ledValues;
  LEDs({required this.ledValues});

  factory LEDs.fromJSON(List<dynamic> json) {
    return LEDs(ledValues: json.map((e) => Led.formJSON(e)).toList());
  }

  factory LEDs.unknown() {
    return LEDs(ledValues: List.generate(13, (index) => Led.empty()));
  }

  void allOFF() {
    this.ledValues.forEach((led) {
      led.setRGB(0, 0, 0);
    });
  }

  void allON() {
    this.ledValues.forEach((led) {
      led.setRGB(255, 255, 255);
    });
  }

  String toJson() {
    String json = "[";
    for (int i = 0; i < this.ledValues.length; i++) {
      json = json + this.ledValues[i].toJson();
      if (i < this.ledValues.length - 1) json = json + ",";
    }
    json = json + "]";
    print("json: " + json);
    return json;
  }
}
