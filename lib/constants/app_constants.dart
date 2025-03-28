import 'package:flutter/material.dart';

class AppConstants {
  // App name
  static const String appName = 'WeatherWise';
  
  // API endpoints
  static const String weatherApiBaseUrl = 'https://api.weatherapi.com/v1';
  static const String newsApiBaseUrl = 'https://newsapi.org/v2';
  
  // Default values
  static const String defaultLocation = 'London';
  static const int defaultForecastDays = 5;
  
  // Temperature units
  static const String celsius = 'celsius';
  static const String fahrenheit = 'fahrenheit';
  
  // Wind speed units
  static const String kph = 'kph';
  static const String mph = 'mph';
  
  // Error messages
  static const String locationError = 'Unable to get location. Please check your permissions.';
  static const String weatherError = 'Unable to fetch weather data. Please try again.';
  static const String networkError = 'No internet connection. Please check your network.';
  static const String authError = 'Authentication failed. Please try again.';
  
  // Success messages
  static const String locationAdded = 'Location added to favorites.';
  static const String locationRemoved = 'Location removed from favorites.';
  static const String settingsSaved = 'Settings saved successfully.';
  static const String logoutSuccess = 'Logged out successfully.';
  
  // Routes
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String searchRoute = '/search';
  static const String favoritesRoute = '/favorites';
  static const String settingsRoute = '/settings';
  static const String newsRoute = '/news';
  static const String newsDetailsRoute = '/news_details';
  static const String weatherDetailsRoute = '/weather_details';
  
  // Shared preferences keys
  static const String darkModeKey = 'dark_mode';
  static const String temperatureUnitKey = 'temperature_unit';
  static const String windSpeedUnitKey = 'wind_speed_unit';
  static const String notificationsEnabledKey = 'notifications_enabled';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String forecastDaysKey = 'forecast_days';
  static const String lastLocationKey = 'last_location';
  
  // Firebase collections
  static const String usersCollection = 'users';
  static const String weatherHistoryCollection = 'weatherHistory';
  
  // UI constants
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 8.0;
  static const double inputBorderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
}
