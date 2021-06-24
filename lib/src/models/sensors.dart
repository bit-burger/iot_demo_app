class Sensors {
  final double temperature;
  final double humidity;

  Sensors({
    required this.temperature,
    required this.humidity,
  });

  factory Sensors.fromJson(Map<String, dynamic> json) {
    return Sensors(
        temperature: json['temperature'], humidity: json['humidity']);
  }
}