import 'package:flutter/material.dart';

class ThemeConstants {
  // Light theme colors
  static const Color lightPrimaryColor = Color(0xFF2196F3);
  static const Color lightAccentColor = Color(0xFF03A9F4);
  static const Color lightBackgroundColor = Color(0xFFFFFFFF);
  static const Color lightCardColor = Color(0xFFF5F5F5);
  static const Color lightTextColor = Color(0xFF212121);
  static const Color lightSecondaryTextColor = Color(0xFF757575);
  static const Color lightDividerColor = Color(0xFFBDBDBD);
  static const Color lightErrorColor = Color(0xFFD32F2F);
  static const Color lightSuccessColor = Color(0xFF4CAF50);
  static const Color lightWarningColor = Color(0xFFFFC107);
  static const Color lightInfoColor = Color(0xFF2196F3);
  
  // Dark theme colors
  static const Color darkPrimaryColor = Color(0xFF1976D2);
  static const Color darkAccentColor = Color(0xFF0288D1);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkTextColor = Color(0xFFFFFFFF);
  static const Color darkSecondaryTextColor = Color(0xFFB0B0B0);
  static const Color darkDividerColor = Color(0xFF424242);
  static const Color darkErrorColor = Color(0xFFEF5350);
  static const Color darkSuccessColor = Color(0xFF66BB6A);
  static const Color darkWarningColor = Color(0xFFFFD54F);
  static const Color darkInfoColor = Color(0xFF42A5F5);
  
  // Weather condition colors
  static const Color sunnyColor = Color(0xFFFFB300);
  static const Color cloudyColor = Color(0xFF90A4AE);
  static const Color rainyColor = Color(0xFF42A5F5);
  static const Color stormyColor = Color(0xFF5C6BC0);
  static const Color snowyColor = Color(0xFFE0E0E0);
  static const Color foggyColor = Color(0xFFBDBDBD);
  static const Color windyColor = Color(0xFF78909C);
  
  // Temperature colors
  static const Color coldColor = Color(0xFF42A5F5);
  static const Color coolColor = Color(0xFF29B6F6);
  static const Color mildColor = Color(0xFF26C6DA);
  static const Color warmColor = Color(0xFFFFB74D);
  static const Color hotColor = Color(0xFFFF8A65);
  static const Color extremeHotColor = Color(0xFFEF5350);
  
  // Gradient colors
  static const List<Color> dayGradient = [
    Color(0xFF4FC3F7),
    Color(0xFF2196F3),
  ];
  
  static const List<Color> nightGradient = [
    Color(0xFF303F9F),
    Color(0xFF1A237E),
  ];
  
  static const List<Color> sunriseGradient = [
    Color(0xFFFFB74D),
    Color(0xFFFF9800),
    Color(0xFF4FC3F7),
  ];
  
  static const List<Color> sunsetGradient = [
    Color(0xFFFF9800),
    Color(0xFFEF5350),
    Color(0xFF303F9F),
  ];
  
  // Get color based on temperature
  static Color getTemperatureColor(double temperature) {
    if (temperature < 0) {
      return coldColor;
    } else if (temperature < 10) {
      return coolColor;
    } else if (temperature < 20) {
      return mildColor;
    } else if (temperature < 30) {
      return warmColor;
    } else if (temperature < 35) {
      return hotColor;
    } else {
      return extremeHotColor;
    }
  }
  
  // Get color based on weather condition
  static Color getWeatherConditionColor(String condition) {
    condition = condition.toLowerCase();
    
    if (condition.contains('sunny') || condition.contains('clear')) {
      return sunnyColor;
    } else if (condition.contains('cloud') || condition.contains('overcast')) {
      return cloudyColor;
    } else if (condition.contains('rain') || condition.contains('drizzle')) {
      return rainyColor;
    } else if (condition.contains('storm') || condition.contains('thunder')) {
      return stormyColor;
    } else if (condition.contains('snow') || condition.contains('sleet') || condition.contains('ice')) {
      return snowyColor;
    } else if (condition.contains('fog') || condition.contains('mist')) {
      return foggyColor;
    } else if (condition.contains('wind')) {
      return windyColor;
    } else {
      return mildColor;
    }
  }
  
  // Get gradient based on time of day
  static List<Color> getTimeGradient(bool isDay, String time) {
    if (!isDay) {
      return nightGradient;
    }
    
    final hour = int.tryParse(time.split(':')[0]) ?? 12;
    
    if (hour >= 5 && hour < 8) {
      return sunriseGradient;
    } else if (hour >= 17 && hour < 20) {
      return sunsetGradient;
    } else {
      return dayGradient;
    }
  }
}
