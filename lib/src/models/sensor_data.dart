class SensorData {
  final String temperature;
  final String humidity;

  SensorData._({required this.temperature, required this.humidity});

  SensorData._fromTemperature({
    required double temperature,
    required double humidity,
  })  : this.temperature = temperature.toStringAsFixed(1) + '°C',
        this.humidity = humidity.toStringAsFixed(2) + '%';

  factory SensorData.noData() {
    return SensorData._(temperature: 'No data', humidity: 'No data');
  }

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData._fromTemperature(
        temperature: json['temperature'], humidity: json['humidity']);
  }
}
