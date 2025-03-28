class Weather {
  final String location;
  final String country;
  final double temperature;
  final double feelsLike;
  final String condition;
  final String conditionIcon;
  final double windSpeed;
  final String windDirection;
  final double humidity;
  final double precipitation;
  final double pressure;
  final double visibility;
  final String lastUpdated;
  final double uv;
  final bool isDay;
  final double latitude;
  final double longitude;

  Weather({
    required this.location,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.conditionIcon,
    required this.windSpeed,
    required this.windDirection,
    required this.humidity,
    required this.precipitation,
    required this.pressure,
    required this.visibility,
    required this.lastUpdated,
    required this.uv,
    required this.isDay,
    required this.latitude,
    required this.longitude,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    final current = json['current'];
    
    return Weather(
      location: location['name'],
      country: location['country'],
      temperature: current['temp_c'].toDouble(),
      feelsLike: current['feelslike_c'].toDouble(),
      condition: current['condition']['text'],
      conditionIcon: 'https:${current['condition']['icon']}',
      windSpeed: current['wind_kph'].toDouble(),
      windDirection: current['wind_dir'],
      humidity: current['humidity'].toDouble(),
      precipitation: current['precip_mm'].toDouble(),
      pressure: current['pressure_mb'].toDouble(),
      visibility: current['vis_km'].toDouble(),
      lastUpdated: current['last_updated'],
      uv: current['uv'].toDouble(),
      isDay: current['is_day'] == 1,
      latitude: location['lat'].toDouble(),
      longitude: location['lon'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'country': country,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'condition': condition,
      'conditionIcon': conditionIcon,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'humidity': humidity,
      'precipitation': precipitation,
      'pressure': pressure,
      'visibility': visibility,
      'lastUpdated': lastUpdated,
      'uv': uv,
      'isDay': isDay,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
