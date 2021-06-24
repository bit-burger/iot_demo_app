import 'dart:convert';

class Led {
  final List<int> rgbValues;
  Led({required this.rgbValues});

  factory Led.off() {
    return Led(rgbValues: [0, 0, 0]);
  }

  factory Led.on() {
    return Led(rgbValues: [255, 255, 255]);
  }

  factory Led.formJSON(List<dynamic> json) {
    return Led(rgbValues: json.map((e) => e as int).toList());
  }
  setRGB(int r, int g, int b) {
    this.rgbValues[0] = r;
    this.rgbValues[1] = g;
    this.rgbValues[2] = b;
  }

  bool get isOff => rgbValues.every((e) => e == 0);

  @override
  String toString() {
    return 'r: ${rgbValues[0]} g: ${rgbValues[1]} b: ${rgbValues[2]}';
  }

  String toJson() {
    return jsonEncode(rgbValues);
  }

  Led copy() {
    return new Led(rgbValues: List.from(this.rgbValues));
  }
}
