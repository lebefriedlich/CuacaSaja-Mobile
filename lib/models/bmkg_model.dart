class BMKGModel {
  final String localDatetime;
  final double temperature;
  final String temperatureCondition;
  final String weatherDescription;
  final double humidity;
  final double windSpeed;
  final String visibilityText;
  final String image;
  final String village;

  BMKGModel({
    required this.localDatetime,
    required this.temperature,
    required this.temperatureCondition,
    required this.weatherDescription,
    required this.humidity,
    required this.windSpeed,
    required this.visibilityText,
    required this.image,
    required this.village,
  });

  factory BMKGModel.fromJson(Map<String, dynamic> json) {
    return BMKGModel(
      localDatetime: json['cuaca']['local_datetime'] ?? '',
      temperature: (json['cuaca']['t'] is String)
          ? double.tryParse(json['cuaca']['t']) ?? 0.0
          : (json['cuaca']['t'] as num).toDouble(),
      temperatureCondition: json['cuaca']['tcc'] ?? '',
      weatherDescription: json['cuaca']['weather_desc'] ?? '',
      humidity: (json['cuaca']['hu'] is String)
          ? double.tryParse(json['cuaca']['hu']) ?? 0.0
          : (json['cuaca']['hu'] as num).toDouble(),
      windSpeed: (json['cuaca']['ws'] is String)
          ? double.tryParse(json['cuaca']['ws']) ?? 0.0
          : (json['cuaca']['ws'] as num).toDouble(),
      visibilityText: json['cuaca']['vs_text'] ?? '',
      image: json['cuaca']['image'] ?? '',
      village: json['lokasi']['desa'] ?? '',
    );
  }
}
