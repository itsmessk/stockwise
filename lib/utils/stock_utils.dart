import 'package:flutter/material.dart';
import 'package:stockwise/constants/theme_constants.dart';
import 'package:stockwise/models/historical_data.dart';
import 'package:intl/intl.dart';

class StockUtils {
  // Get color based on stock price change
  static Color getPriceChangeColor(double change) {
    return change >= 0 ? ThemeConstants.positiveColor : ThemeConstants.negativeColor;
  }

  // Get icon based on stock price change
  static IconData getPriceChangeIcon(double change) {
    return change >= 0 ? Icons.arrow_upward : Icons.arrow_downward;
  }

  // Format price with currency symbol
  static String formatPrice(double price, String currency) {
    final formatter = NumberFormat.currency(symbol: getCurrencySymbol(currency));
    return formatter.format(price);
  }

  // Format percentage change
  static String formatPercentageChange(double percentChange) {
    final sign = percentChange >= 0 ? '+' : '';
    return '$sign${percentChange.toStringAsFixed(2)}%';
  }

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

  // Format large numbers (e.g., volume, market cap)
  static String formatLargeNumber(num number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(2)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  // Calculate min and max values for chart
  static Map<String, double> getChartMinMax(List<HistoricalData> data) {
    if (data.isEmpty) {
      return {'min': 0, 'max': 100};
    }

    double min = double.infinity;
    double max = -double.infinity;

    for (var item in data) {
      if (item.low < min) min = item.low;
      if (item.high > max) max = item.high;
    }

    // Add some padding
    final padding = (max - min) * 0.1;
    min = min - padding;
    max = max + padding;

    return {'min': min, 'max': max};
  }

  // Get a list of popular stock symbols
  static List<String> getPopularStocks() {
    return [
      'AAPL',  // Apple
      'MSFT',  // Microsoft
      'GOOGL', // Alphabet (Google)
      'AMZN',  // Amazon
      'META',  // Meta (Facebook)
      'TSLA',  // Tesla
      'NVDA',  // NVIDIA
      'JPM',   // JPMorgan Chase
      'V',     // Visa
      'WMT',   // Walmart
    ];
  }

  // Get a list of popular crypto symbols
  static List<String> getPopularCryptos() {
    return [
      'BTC/USD',  // Bitcoin
      'ETH/USD',  // Ethereum
      'XRP/USD',  // Ripple
      'SOL/USD',  // Solana
      'ADA/USD',  // Cardano
    ];
  }

  // Get a list of popular forex pairs
  static List<String> getPopularForexPairs() {
    return [
      'EUR/USD',  // Euro / US Dollar
      'USD/JPY',  // US Dollar / Japanese Yen
      'GBP/USD',  // British Pound / US Dollar
      'USD/CAD',  // US Dollar / Canadian Dollar
      'AUD/USD',  // Australian Dollar / US Dollar
    ];
  }
}
