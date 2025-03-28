class ApiConstants {
  static const String baseUrl = 'https://www.alphavantage.co/query';

  // Note: In a real app, this should be stored securely and not hardcoded
  // For this demo, we're using a placeholder - you'll need to replace with your actual API key
  static const String apiKey = 'demo'; // Replace with your Alpha Vantage API key
  
  // API function names
  static const String timeSeriesDaily = 'TIME_SERIES_DAILY';
  static const String quoteEndpoint = 'GLOBAL_QUOTE';
  static const String searchEndpoint = 'SYMBOL_SEARCH';
  static const String companyOverview = 'OVERVIEW';
  static const String forexRate = 'CURRENCY_EXCHANGE_RATE';
  static const String forexDaily = 'FX_DAILY';
  static const String news = 'NEWS_SENTIMENT';
}
