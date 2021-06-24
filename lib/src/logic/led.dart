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


