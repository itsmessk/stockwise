class UserPreferences {
  final String preferredCurrency;
  final String language;
  final bool darkMode;
  final List<String> watchlist;

  UserPreferences({
    required this.preferredCurrency,
    required this.language,
    required this.darkMode,
    required this.watchlist,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      preferredCurrency: json['preferred_currency'] ?? 'USD',
      language: json['language'] ?? 'en',
      darkMode: json['dark_mode'] ?? false,
      watchlist: json['watchlist'] != null 
        ? List<String>.from(json['watchlist'])
        : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferred_currency': preferredCurrency,
      'language': language,
      'dark_mode': darkMode,
      'watchlist': watchlist,
    };
  }

  UserPreferences copyWith({
    String? preferredCurrency,
    String? language,
    bool? darkMode,
    List<String>? watchlist,
  }) {
    return UserPreferences(
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      language: language ?? this.language,
      darkMode: darkMode ?? this.darkMode,
      watchlist: watchlist ?? this.watchlist,
    );
  }
}
