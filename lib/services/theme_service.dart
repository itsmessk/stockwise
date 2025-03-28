import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockwise/constants/theme_constants.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  late ThemeMode _themeMode;
  bool _isInitialized = false;

  ThemeService() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isInitialized => _isInitialized;

  // Initialize theme from shared preferences
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeMode = prefs.getString(_themeKey);
      
      if (savedThemeMode == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (savedThemeMode == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error loading theme mode: $e');
      _themeMode = ThemeMode.system;
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Set theme mode and save to shared preferences
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (mode == ThemeMode.dark) {
        await prefs.setString(_themeKey, 'dark');
      } else if (mode == ThemeMode.light) {
        await prefs.setString(_themeKey, 'light');
      } else {
        await prefs.setString(_themeKey, 'system');
      }
    } catch (e) {
      print('Error saving theme mode: $e');
    }
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  // Get the current theme data
  ThemeData getThemeData(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? ThemeConstants.darkTheme 
        : ThemeConstants.lightTheme;
  }
  
  // Get light theme
  ThemeData getLightTheme() {
    return ThemeConstants.lightTheme;
  }
  
  // Get dark theme
  ThemeData getDarkTheme() {
    return ThemeConstants.darkTheme;
  }
}
