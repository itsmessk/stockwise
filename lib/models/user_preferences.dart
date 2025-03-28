class UserPreferences {
  final String preferredCurrency;
  final String language;
  final bool darkMode;
  final List<String> watchlist;
  final bool isFirstLaunch;

  UserPreferences({
    required this.preferredCurrency,
    required this.language,
    required this.darkMode,
    required this.watchlist,
    this.isFirstLaunch = true,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      preferredCurrency: json['preferred_currency'] ?? 'USD',
      language: json['language'] ?? 'en',
      darkMode: json['dark_mode'] ?? false,
      watchlist: json['watchlist'] != null 
        ? List<String>.from(json['watchlist'])
        : [],
      isFirstLaunch: json['is_first_launch'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferred_currency': preferredCurrency,
      'language': language,
      'dark_mode': darkMode,
      'watchlist': watchlist,
      'is_first_launch': isFirstLaunch,
    };
  }

  UserPreferences copyWith({
    String? preferredCurrency,
    String? language,
    bool? darkMode,
    List<String>? watchlist,
    bool? isFirstLaunch,
  }) {
    return UserPreferences(
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      language: language ?? this.language,
      darkMode: darkMode ?? this.darkMode,
      watchlist: watchlist ?? this.watchlist,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    );
  }
}
