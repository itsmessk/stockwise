class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final List<String> favoriteLocations;
  final Map<String, dynamic> preferences;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.favoriteLocations,
    required this.preferences,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      favoriteLocations: List<String>.from(json['favoriteLocations'] ?? []),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'favoriteLocations': favoriteLocations,
      'preferences': preferences,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    List<String>? favoriteLocations,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      favoriteLocations: favoriteLocations ?? this.favoriteLocations,
      preferences: preferences ?? this.preferences,
    );
  }
}

class UserPreferences {
  final bool darkMode;
  final String temperatureUnit; // 'celsius' or 'fahrenheit'
  final String windSpeedUnit; // 'kph' or 'mph'
  final bool notificationsEnabled;
  final bool isFirstLaunch;
  final int forecastDays; // Number of days to show in forecast (1-7)

  UserPreferences({
    this.darkMode = false,
    this.temperatureUnit = 'celsius',
    this.windSpeedUnit = 'kph',
    this.notificationsEnabled = true,
    this.isFirstLaunch = true,
    this.forecastDays = 5,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      darkMode: json['darkMode'] ?? false,
      temperatureUnit: json['temperatureUnit'] ?? 'celsius',
      windSpeedUnit: json['windSpeedUnit'] ?? 'kph',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      isFirstLaunch: json['isFirstLaunch'] ?? true,
      forecastDays: json['forecastDays'] ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'darkMode': darkMode,
      'temperatureUnit': temperatureUnit,
      'windSpeedUnit': windSpeedUnit,
      'notificationsEnabled': notificationsEnabled,
      'isFirstLaunch': isFirstLaunch,
      'forecastDays': forecastDays,
    };
  }

  UserPreferences copyWith({
    bool? darkMode,
    String? temperatureUnit,
    String? windSpeedUnit,
    bool? notificationsEnabled,
    bool? isFirstLaunch,
    int? forecastDays,
  }) {
    return UserPreferences(
      darkMode: darkMode ?? this.darkMode,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      windSpeedUnit: windSpeedUnit ?? this.windSpeedUnit,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      forecastDays: forecastDays ?? this.forecastDays,
    );
  }
}
