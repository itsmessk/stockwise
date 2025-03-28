class Forex {
  final String baseCurrency;
  final String quoteCurrency;
  final double exchangeRate;
  final double change;
  final double percentChange;
  final DateTime lastUpdated;

  Forex({
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.exchangeRate,
    required this.change,
    required this.percentChange,
    required this.lastUpdated,
  });

  factory Forex.fromJson(Map<String, dynamic> json) {
    return Forex(
      baseCurrency: json['base_currency'] ?? '',
      quoteCurrency: json['quote_currency'] ?? '',
      exchangeRate: (json['exchange_rate'] ?? 0.0).toDouble(),
      change: (json['change'] ?? 0.0).toDouble(),
      percentChange: (json['percent_change'] ?? 0.0).toDouble(),
      lastUpdated: json['last_updated'] != null 
        ? DateTime.parse(json['last_updated']) 
        : DateTime.now(),
    );
  }

  // Helper method to determine if forex is up or down
  bool get isUp => change >= 0;
}
