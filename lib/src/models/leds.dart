import 'led.dart';

class Leds {
  final List<Led> ledValues;
  Leds({required this.ledValues});

  factory Leds.fromJSON(List<dynamic> json) {
    return Leds(ledValues: json.map((e) => Led.formJSON(e)).toList());
  }

  factory Leds.on() {
    return Leds(ledValues: List.generate(12, (index) => Led.on()));
  }

  factory Leds.off() {
    return Leds(ledValues: List.generate(12, (index) => Led.off()));
  }

  factory Leds.all(Led led) {
    return Leds(ledValues: List.generate(12, (_) => led.copy()));
  }

  void allOff() {
    this.ledValues.forEach((led) {
      led.setRGB(0, 0, 0);
    });
  }

  bool get isCompletelyOnOrOff {
    for (final led in ledValues) {
      if (!(led.rgbValues.every((e) => e == 0) ||
          led.rgbValues.every((e) => e == 255))) {
        return false;
      }
    }
    return true;
  }

  bool get allSameValue {
    var lastElement = ledValues[0];
    for (var i = 1; i < 12; i++) {
      final led = ledValues[i];
      if ((lastElement.rgbValues[0] != led.rgbValues[0]) ||
          (lastElement.rgbValues[1] != led.rgbValues[1]) ||
          (lastElement.rgbValues[2] != led.rgbValues[2])) {
        return false;
      }
    }
    return true;
  }

  bool get isOff {
    for (final led in ledValues) {
      if (!led.isOff) return false;
    }
    return true;
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
    return json;
  }

  Leds copy() {
    return new Leds(
      ledValues: List.generate(ledValues.length, (i) => ledValues[i].copy()),
    );
  }
}
