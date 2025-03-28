import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LocalizationService {
  // Supported locales
  static final List<Locale> supportedLocales = [
    const Locale('en', 'US'), // English
    const Locale('es', 'ES'), // Spanish
    const Locale('fr', 'FR'), // French
    const Locale('de', 'DE'), // German
    const Locale('ja', 'JP'), // Japanese
    const Locale('zh', 'CN'), // Chinese
  ];

  // Supported currencies
  static final List<String> supportedCurrencies = [
    'USD', // US Dollar
    'EUR', // Euro
    'GBP', // British Pound
    'JPY', // Japanese Yen
    'CNY', // Chinese Yuan
    'INR', // Indian Rupee
  ];

  // Get currency symbol
  static String getCurrencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      case 'INR':
        return '₹';
      default:
        return '\$';
    }
  }

  // Format currency
  static String formatCurrency(double amount, String currencyCode) {
    final format = NumberFormat.currency(
      symbol: getCurrencySymbol(currencyCode),
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  // Format percentage
  static String formatPercentage(double percentage) {
    final format = NumberFormat.percentPattern();
    return format.format(percentage / 100);
  }

  // Format date
  static String formatDate(DateTime date, {String locale = 'en_US'}) {
    final format = DateFormat.yMMMd(locale);
    return format.format(date);
  }

  // Format time
  static String formatTime(DateTime time, {String locale = 'en_US'}) {
    final format = DateFormat.Hm(locale);
    return format.format(time);
  }

  // Format date and time
  static String formatDateTime(DateTime dateTime, {String locale = 'en_US'}) {
    final format = DateFormat.yMMMd(locale).add_Hm();
    return format.format(dateTime);
  }

  // Format large numbers (e.g., volume)
  static String formatLargeNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
}
