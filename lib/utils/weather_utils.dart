class WeatherUtils {
  // Convert temperature from Celsius to Fahrenheit
  static double celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  // Convert temperature from Fahrenheit to Celsius
  static double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  // Convert wind speed from kph to mph
  static double kphToMph(double kph) {
    return kph * 0.621371;
  }

  // Convert wind speed from mph to kph
  static double mphToKph(double mph) {
    return mph * 1.60934;
  }

  // Format temperature with unit
  static String formatTemperature(double temperature, String unit) {
    if (unit == 'fahrenheit') {
      temperature = celsiusToFahrenheit(temperature);
      return '${temperature.toStringAsFixed(1)}°F';
    } else {
      return '${temperature.toStringAsFixed(1)}°C';
    }
  }

  // Format wind speed with unit
  static String formatWindSpeed(double windSpeed, String unit) {
    if (unit == 'mph') {
      windSpeed = kphToMph(windSpeed);
      return '${windSpeed.toStringAsFixed(1)} mph';
    } else {
      return '${windSpeed.toStringAsFixed(1)} km/h';
    }
  }

  // Get weather condition description
  static String getWeatherDescription(String condition, double temperature) {
    condition = condition.toLowerCase();
    
    if (condition.contains('sunny') || condition.contains('clear')) {
      if (temperature > 30) {
        return 'It\'s a hot and sunny day. Don\'t forget your sunscreen!';
      } else {
        return 'It\'s a beautiful sunny day. Enjoy the weather!';
      }
    } else if (condition.contains('cloud') || condition.contains('overcast')) {
      return 'It\'s cloudy today. You might want to take a light jacket.';
    } else if (condition.contains('rain') || condition.contains('drizzle')) {
      return 'It\'s raining today. Don\'t forget your umbrella!';
    } else if (condition.contains('storm') || condition.contains('thunder')) {
      return 'There\'s a storm today. Stay safe and avoid open areas.';
    } else if (condition.contains('snow') || condition.contains('sleet') || condition.contains('ice')) {
      return 'It\'s snowing today. Dress warmly and be careful on the roads.';
    } else if (condition.contains('fog') || condition.contains('mist')) {
      return 'It\'s foggy today. Drive carefully and use fog lights.';
    } else if (condition.contains('wind')) {
      return 'It\'s windy today. Secure loose items and be careful outdoors.';
    } else {
      return 'Check the weather forecast for more details.';
    }
  }

  // Get clothing recommendation based on weather
  static String getClothingRecommendation(String condition, double temperature) {
    condition = condition.toLowerCase();
    
    if (temperature > 30) {
      return 'Wear light, breathable clothing. Don\'t forget sunscreen and a hat.';
    } else if (temperature > 20) {
      return 'Comfortable clothing like t-shirts and shorts or light pants are ideal.';
    } else if (temperature > 10) {
      return 'Consider wearing layers, like a light jacket or sweater.';
    } else if (temperature > 0) {
      return 'Wear warm clothing, including a jacket, scarf, and gloves.';
    } else {
      return 'Wear heavy winter clothing, including a thick coat, hat, scarf, and gloves.';
    }
  }

  // Get activity recommendation based on weather
  static String getActivityRecommendation(String condition, double temperature) {
    condition = condition.toLowerCase();
    
    if (condition.contains('rain') || condition.contains('drizzle') || 
        condition.contains('storm') || condition.contains('thunder')) {
      return 'Indoor activities are recommended today.';
    } else if (condition.contains('snow') || condition.contains('sleet') || condition.contains('ice')) {
      return 'Enjoy winter activities, but be careful on slippery surfaces.';
    } else if (temperature > 30) {
      return 'Stay hydrated and avoid prolonged sun exposure during peak hours.';
    } else if (condition.contains('sunny') || condition.contains('clear') || 
              (condition.contains('cloud') && temperature > 15)) {
      return 'Great day for outdoor activities!';
    } else {
      return 'Moderate outdoor activities are fine, but dress appropriately.';
    }
  }

  // Get UV index description
  static String getUVIndexDescription(double uv) {
    if (uv <= 2) {
      return 'Low';
    } else if (uv <= 5) {
      return 'Moderate';
    } else if (uv <= 7) {
      return 'High';
    } else if (uv <= 10) {
      return 'Very High';
    } else {
      return 'Extreme';
    }
  }

  // Get UV protection advice
  static String getUVProtectionAdvice(double uv) {
    if (uv <= 2) {
      return 'No protection needed for most people.';
    } else if (uv <= 5) {
      return 'Wear sunscreen, a hat, and sunglasses.';
    } else if (uv <= 7) {
      return 'Wear sunscreen SPF 30+, a hat, sunglasses, and seek shade during midday.';
    } else if (uv <= 10) {
      return 'Wear sunscreen SPF 30+, a hat, sunglasses, and avoid being outside during midday.';
    } else {
      return 'Take all precautions and avoid being outside during midday hours.';
    }
  }

  // Get humidity comfort level
  static String getHumidityComfort(double humidity) {
    if (humidity < 30) {
      return 'Very Dry';
    } else if (humidity < 40) {
      return 'Dry';
    } else if (humidity < 60) {
      return 'Comfortable';
    } else if (humidity < 70) {
      return 'Humid';
    } else {
      return 'Very Humid';
    }
  }

  // Get visibility description
  static String getVisibilityDescription(double visibility) {
    if (visibility < 1) {
      return 'Very Poor';
    } else if (visibility < 4) {
      return 'Poor';
    } else if (visibility < 10) {
      return 'Moderate';
    } else {
      return 'Good';
    }
  }
}
