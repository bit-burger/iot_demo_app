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

class Leds {
  final List<Led> ledValues;
  Leds({required this.ledValues});

  factory Leds.fromJSON(List<dynamic> json) {
    return Leds(ledValues: json.map((e) => Led.formJSON(e)).toList());
  }

  factory Leds.unknown() {
    return Leds(ledValues: List.generate(13, (index) => Led.empty()));
  }

  void allOff() {
    this.ledValues.forEach((led) {
      led.setRGB(0, 0, 0);
    });
  }

  void allOn() {
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
