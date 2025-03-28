import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockwise/models/user_preferences.dart';

class PreferencesService {
  static const String _preferencesKey = 'user_preferences';

  // Save user preferences
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesJson = jsonEncode(preferences.toJson());
    await prefs.setString(_preferencesKey, preferencesJson);
  }

  // Get user preferences
  Future<UserPreferences> getUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesJson = prefs.getString(_preferencesKey);
    
    if (preferencesJson != null) {
      final Map<String, dynamic> preferencesMap = jsonDecode(preferencesJson);
      return UserPreferences.fromJson(preferencesMap);
    } else {
      // Return default preferences if none are saved
      return UserPreferences(
        preferredCurrency: 'USD',
        language: 'en',
        darkMode: false,
        watchlist: [],
        isFirstLaunch: true,
      );
    }
  }

  // Add stock to watchlist
  Future<void> addToWatchlist(String symbol) async {
    final preferences = await getUserPreferences();
    final watchlist = List<String>.from(preferences.watchlist);
    
    if (!watchlist.contains(symbol)) {
      watchlist.add(symbol);
      await saveUserPreferences(preferences.copyWith(watchlist: watchlist));
    }
  }

  // Remove stock from watchlist
  Future<void> removeFromWatchlist(String symbol) async {
    final preferences = await getUserPreferences();
    final watchlist = List<String>.from(preferences.watchlist);
    
    if (watchlist.contains(symbol)) {
      watchlist.remove(symbol);
      await saveUserPreferences(preferences.copyWith(watchlist: watchlist));
    }
  }

  // Toggle dark mode
  Future<void> toggleDarkMode() async {
    final preferences = await getUserPreferences();
    await saveUserPreferences(preferences.copyWith(darkMode: !preferences.darkMode));
  }

  // Set preferred currency
  Future<void> setPreferredCurrency(String currency) async {
    final preferences = await getUserPreferences();
    await saveUserPreferences(preferences.copyWith(preferredCurrency: currency));
  }

  // Set language
  Future<void> setLanguage(String language) async {
    final preferences = await getUserPreferences();
    await saveUserPreferences(preferences.copyWith(language: language));
  }

  // Update dark mode preference
  Future<void> updateDarkMode(bool darkMode) async {
    final prefs = await getUserPreferences();
    final updatedPrefs = prefs.copyWith(darkMode: darkMode);
    await saveUserPreferences(updatedPrefs);
  }

  // Update first launch preference
  Future<void> updateFirstLaunch(bool isFirstLaunch) async {
    final prefs = await getUserPreferences();
    final updatedPrefs = prefs.copyWith(isFirstLaunch: isFirstLaunch);
    await saveUserPreferences(updatedPrefs);
  }
}
