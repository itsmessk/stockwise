class Stock {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double percentChange;
  final int volume;
  final String currency;
  final String exchange;
  final DateTime lastUpdated;

  Stock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.percentChange,
    required this.volume,
    required this.currency,
    required this.exchange,
    required this.lastUpdated,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      change: (json['day_change'] ?? 0.0).toDouble(),
      percentChange: (json['change_pct'] ?? 0.0).toDouble(),
      volume: json['volume'] ?? 0,
      currency: json['currency'] ?? 'USD',
      exchange: json['exchange'] ?? '',
      lastUpdated: json['last_updated'] != null 
        ? DateTime.parse(json['last_updated']) 
        : DateTime.now(),
    );
  }

  // Helper method to determine if stock is up or down
  bool get isUp => change >= 0;
}
