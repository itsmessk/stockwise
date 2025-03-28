import 'package:flutter/material.dart';

class ThemeConstants {
  // Light Theme Colors
  static const Color primaryColorLight = Color(0xFF2E7D32);
  static const Color secondaryColorLight = Color(0xFF4CAF50);
  static const Color backgroundColorLight = Color(0xFFF5F5F5);
  static const Color cardColorLight = Colors.white;
  static const Color textColorLight = Color(0xFF212121);
  static const Color secondaryTextColorLight = Color(0xFF757575);
  static const Color dividerColorLight = Color(0xFFBDBDBD);
  static const Color positiveColorLight = Color(0xFF4CAF50);
  static const Color negativeColorLight = Color(0xFFE53935);

  // Dark Theme Colors
  static const Color primaryColorDark = Color(0xFF388E3C);
  static const Color secondaryColorDark = Color(0xFF66BB6A);
  static const Color backgroundColorDark = Color(0xFF121212);
  static const Color cardColorDark = Color(0xFF1E1E1E);
  static const Color textColorDark = Color(0xFFEEEEEE);
  static const Color secondaryTextColorDark = Color(0xFFB0B0B0);
  static const Color dividerColorDark = Color(0xFF424242);
  static const Color positiveColorDark = Color(0xFF81C784);
  static const Color negativeColorDark = Color(0xFFEF5350);

  // Text Styles
  static const String fontFamily = 'Poppins';

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColorLight,
    scaffoldBackgroundColor: backgroundColorLight,
    cardColor: cardColorLight,
    dividerColor: dividerColorLight,
    fontFamily: fontFamily,
    colorScheme: const ColorScheme.light(
      primary: primaryColorLight,
      secondary: secondaryColorLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      background: backgroundColorLight,
      surface: cardColorLight,
      onBackground: textColorLight,
      onSurface: textColorLight,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColorLight,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColorLight,
      ),
      displaySmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textColorLight,
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColorLight,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColorLight,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textColorLight,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textColorLight,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: secondaryTextColorLight,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColorLight,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColorLight,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColorLight,
        side: const BorderSide(color: primaryColorLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColorLight,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: dividerColorLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: dividerColorLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColorLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: negativeColorLight, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: CardTheme(
      color: cardColorLight,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColorDark,
    scaffoldBackgroundColor: backgroundColorDark,
    cardColor: cardColorDark,
    dividerColor: dividerColorDark,
    fontFamily: fontFamily,
    colorScheme: const ColorScheme.dark(
      primary: primaryColorDark,
      secondary: secondaryColorDark,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      background: backgroundColorDark,
      surface: cardColorDark,
      onBackground: textColorDark,
      onSurface: textColorDark,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColorDark,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColorDark,
      ),
      displaySmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textColorDark,
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColorDark,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColorDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textColorDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textColorDark,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: secondaryTextColorDark,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColorDark,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColorDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColorDark,
        side: const BorderSide(color: primaryColorDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColorDark,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColorDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: dividerColorDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: dividerColorDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColorDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: negativeColorDark, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: CardTheme(
      color: cardColorDark,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
