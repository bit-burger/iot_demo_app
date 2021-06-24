import 'dart:convert';

class LED {
  final List<int> rgbValues;
  LED({required this.rgbValues});

  factory LED.empty() {
    return LED(rgbValues: [0, 0, 0]);
  }
  factory LED.formJSON(List<dynamic> json) {
    return LED(rgbValues: json.map((e) => e as int).toList());
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
  final List<LED> LEDValues;
  LEDs({required this.LEDValues});

  factory LEDs.fromJSON(List<dynamic> json) {
    return LEDs(LEDValues: json.map((e) => LED.formJSON(e)).toList());
  }

  factory LEDs.unknown() {
    return LEDs(LEDValues: List.generate(13, (index) => LED.empty()));
  }

  void allOFF() {
    this.LEDValues.forEach((led) {
      led.setRGB(0, 0, 0);
    });
  }

  void allON() {
    this.LEDValues.forEach((led) {
      led.setRGB(255, 255, 255);
    });
  }

  String toJson() {
    String json = "[";
    for (int i = 0; i < this.LEDValues.length; i++) {
      json = json + this.LEDValues[i].toJson();
      if (i < this.LEDValues.length - 1) json = json + ",";
    }
    json = json + "]";
    print("json: ${json}");
    return json;
  }
}
