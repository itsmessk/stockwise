import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class PreferencesService {
  // Keys for SharedPreferences
  static const String _darkModeKey = 'dark_mode';
  static const String _temperatureUnitKey = 'temperature_unit';
  static const String _windSpeedUnitKey = 'wind_speed_unit';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _forecastDaysKey = 'forecast_days';
  static const String _lastLocationKey = 'last_location';

  // Get user preferences from SharedPreferences
  Future<UserPreferences> getUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      return UserPreferences(
        darkMode: prefs.getBool(_darkModeKey) ?? false,
        temperatureUnit: prefs.getString(_temperatureUnitKey) ?? 'celsius',
        windSpeedUnit: prefs.getString(_windSpeedUnitKey) ?? 'kph',
        notificationsEnabled: prefs.getBool(_notificationsEnabledKey) ?? true,
        isFirstLaunch: prefs.getBool(_isFirstLaunchKey) ?? true,
        forecastDays: prefs.getInt(_forecastDaysKey) ?? 5,
      );
    } catch (e) {
      // Return default preferences if there's an error
      print('Error getting user preferences: $e');
      return UserPreferences();
    }
  }

  // Save user preferences to SharedPreferences
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool(_darkModeKey, preferences.darkMode);
      await prefs.setString(_temperatureUnitKey, preferences.temperatureUnit);
      await prefs.setString(_windSpeedUnitKey, preferences.windSpeedUnit);
      await prefs.setBool(_notificationsEnabledKey, preferences.notificationsEnabled);
      await prefs.setBool(_isFirstLaunchKey, preferences.isFirstLaunch);
      await prefs.setInt(_forecastDaysKey, preferences.forecastDays);
    } catch (e) {
      print('Error saving user preferences: $e');
      throw Exception('Failed to save preferences: $e');
    }
  }

  // Update dark mode preference
  Future<void> updateDarkMode(bool darkMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, darkMode);
    } catch (e) {
      print('Error updating dark mode: $e');
      throw Exception('Failed to update dark mode: $e');
    }
  }

  // Update temperature unit preference
  Future<void> updateTemperatureUnit(String unit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_temperatureUnitKey, unit);
    } catch (e) {
      print('Error updating temperature unit: $e');
      throw Exception('Failed to update temperature unit: $e');
    }
  }

  // Update wind speed unit preference
  Future<void> updateWindSpeedUnit(String unit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_windSpeedUnitKey, unit);
    } catch (e) {
      print('Error updating wind speed unit: $e');
      throw Exception('Failed to update wind speed unit: $e');
    }
  }

  // Update notifications preference
  Future<void> updateNotifications(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsEnabledKey, enabled);
    } catch (e) {
      print('Error updating notifications: $e');
      throw Exception('Failed to update notifications: $e');
    }
  }

  // Update first launch preference
  Future<void> updateFirstLaunch(bool isFirstLaunch) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isFirstLaunchKey, isFirstLaunch);
    } catch (e) {
      print('Error updating first launch: $e');
      throw Exception('Failed to update first launch: $e');
    }
  }

  // Update forecast days preference
  Future<void> updateForecastDays(int days) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_forecastDaysKey, days);
    } catch (e) {
      print('Error updating forecast days: $e');
      throw Exception('Failed to update forecast days: $e');
    }
  }

  // Save last searched location
  Future<void> saveLastLocation(String location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastLocationKey, location);
    } catch (e) {
      print('Error saving last location: $e');
      throw Exception('Failed to save last location: $e');
    }
  }

  // Get last searched location
  Future<String?> getLastLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastLocationKey);
    } catch (e) {
      print('Error getting last location: $e');
      return null;
    }
  }
}
