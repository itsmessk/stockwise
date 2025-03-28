class ApiConstants {
  static const String baseUrl = 'https://www.alphavantage.co/query';
  
  // Function names
  static const String timeSeriesDaily = 'TIME_SERIES_DAILY';
  static const String timeSeriesIntraday = 'TIME_SERIES_INTRADAY';
  static const String globalQuote = 'GLOBAL_QUOTE';
  static const String symbolSearch = 'SYMBOL_SEARCH';
  static const String companyOverview = 'OVERVIEW';
  static const String topGainers = 'TOP_GAINERS_LOSERS';
  static const String forexDaily = 'FX_DAILY';
  static const String news = 'NEWS_SENTIMENT';
  
  // Parameters
  static const String functionParam = 'function';
  static const String symbolParam = 'symbol';
  static const String keywordsParam = 'keywords';
  static const String intervalParam = 'interval';
  static const String apiKeyParam = 'apikey';
  static const String dataTypeParam = 'datatype';
  static const String outputSizeParam = 'outputsize';
  static const String fromSymbolParam = 'from_symbol';
  static const String toSymbolParam = 'to_symbol';
  
  // Values
  static const String jsonDataType = 'json';
  static const String compactOutputSize = 'compact';
  static const String fullOutputSize = 'full';
  static const String fiveMinInterval = '5min';
  static const String fifteenMinInterval = '15min';
  static const String thirtyMinInterval = '30min';
  static const String sixtyMinInterval = '60min';
}
