import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _darkModeKey = 'dark_mode';
  static const String _currencyKey = 'currency';
  static const String _firstLaunchKey = 'first_launch';

  // Get user preferences
  Future<UserPreferences> getUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final darkMode = prefs.getBool(_darkModeKey) ?? false;
      final currency = prefs.getString(_currencyKey) ?? 'USD';
      final isFirstLaunch = prefs.getBool(_firstLaunchKey) ?? true;
      
      return UserPreferences(
        darkMode: darkMode,
        defaultCurrency: currency,
        isFirstLaunch: isFirstLaunch,
      );
    } catch (e) {
      print('Error getting user preferences: $e');
      return UserPreferences(
        darkMode: false,
        defaultCurrency: 'USD',
        isFirstLaunch: true,
      );
    }
  }

  // Save dark mode preference
  Future<void> updateDarkMode(bool isDarkMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, isDarkMode);
    } catch (e) {
      print('Error saving dark mode preference: $e');
    }
  }

  // Save currency preference
  Future<void> updateCurrency(String currency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currencyKey, currency);
    } catch (e) {
      print('Error saving currency preference: $e');
    }
  }

  // Update first launch preference
  Future<void> updateFirstLaunch(bool isFirstLaunch) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_firstLaunchKey, isFirstLaunch);
    } catch (e) {
      print('Error saving first launch preference: $e');
    }
  }
}

class UserPreferences {
  final bool darkMode;
  final String defaultCurrency;
  final bool isFirstLaunch;

  UserPreferences({
    required this.darkMode,
    required this.defaultCurrency,
    required this.isFirstLaunch,
  });
}
