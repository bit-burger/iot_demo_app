import 'led.dart';

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