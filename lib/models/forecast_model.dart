class Forecast {
  final String date;
  final double maxTemp;
  final double minTemp;
  final double avgTemp;
  final double maxWind;
  final double totalPrecip;
  final double avgHumidity;
  final String condition;
  final String conditionIcon;
  final double chanceOfRain;
  final double uv;

  Forecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.avgTemp,
    required this.maxWind,
    required this.totalPrecip,
    required this.avgHumidity,
    required this.condition,
    required this.conditionIcon,
    required this.chanceOfRain,
    required this.uv,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    final day = json['day'];
    
    return Forecast(
      date: json['date'],
      maxTemp: day['maxtemp_c'].toDouble(),
      minTemp: day['mintemp_c'].toDouble(),
      avgTemp: day['avgtemp_c'].toDouble(),
      maxWind: day['maxwind_kph'].toDouble(),
      totalPrecip: day['totalprecip_mm'].toDouble(),
      avgHumidity: day['avghumidity'].toDouble(),
      condition: day['condition']['text'],
      conditionIcon: 'https:${day['condition']['icon']}',
      chanceOfRain: json['day']['daily_chance_of_rain'].toDouble(),
      uv: day['uv'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'maxTemp': maxTemp,
      'minTemp': minTemp,
      'avgTemp': avgTemp,
      'maxWind': maxWind,
      'totalPrecip': totalPrecip,
      'avgHumidity': avgHumidity,
      'condition': condition,
      'conditionIcon': conditionIcon,
      'chanceOfRain': chanceOfRain,
      'uv': uv,
    };
  }
}

class HourlyForecast {
  final String time;
  final double temp;
  final String condition;
  final String conditionIcon;
  final double windSpeed;
  final String windDirection;
  final double humidity;
  final double chanceOfRain;
  final bool isDay;

  HourlyForecast({
    required this.time,
    required this.temp,
    required this.condition,
    required this.conditionIcon,
    required this.windSpeed,
    required this.windDirection,
    required this.humidity,
    required this.chanceOfRain,
    required this.isDay,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: json['time'],
      temp: json['temp_c'].toDouble(),
      condition: json['condition']['text'],
      conditionIcon: 'https:${json['condition']['icon']}',
      windSpeed: json['wind_kph'].toDouble(),
      windDirection: json['wind_dir'],
      humidity: json['humidity'].toDouble(),
      chanceOfRain: json['chance_of_rain'].toDouble(),
      isDay: json['is_day'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'temp': temp,
      'condition': condition,
      'conditionIcon': conditionIcon,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'humidity': humidity,
      'chanceOfRain': chanceOfRain,
      'isDay': isDay,
    };
  }
}

class WeatherForecast {
  final List<Forecast> dailyForecast;
  final List<HourlyForecast> hourlyForecast;

  WeatherForecast({
    required this.dailyForecast,
    required this.hourlyForecast,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    final forecastData = json['forecast']['forecastday'];
    
    List<Forecast> dailyForecasts = [];
    List<HourlyForecast> hourlyForecasts = [];
    
    for (var day in forecastData) {
      dailyForecasts.add(Forecast.fromJson(day));
      
      for (var hour in day['hour']) {
        hourlyForecasts.add(HourlyForecast.fromJson(hour));
      }
    }
    
    return WeatherForecast(
      dailyForecast: dailyForecasts,
      hourlyForecast: hourlyForecasts,
    );
  }
}
