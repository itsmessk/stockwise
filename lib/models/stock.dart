class Stock {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double changePercent;
  final double high;
  final double low;
  final double open;
  final double previousClose;
  final int volume;
  final String lastUpdated;

  Stock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.high,
    required this.low,
    required this.open,
    required this.previousClose,
    required this.volume,
    required this.lastUpdated,
  });

  bool get isPositive => change >= 0;

  factory Stock.fromJson(Map<String, dynamic> json) {
    final quote = json['Global Quote'];
    
    return Stock(
      symbol: quote['01. symbol'] ?? '',
      name: '', // Name is not provided in GLOBAL_QUOTE, will be set separately
      price: double.tryParse(quote['05. price'] ?? '0') ?? 0,
      change: double.tryParse(quote['09. change'] ?? '0') ?? 0,
      changePercent: double.tryParse((quote['10. change percent'] ?? '0%').replaceAll('%', '')) ?? 0,
      high: double.tryParse(quote['03. high'] ?? '0') ?? 0,
      low: double.tryParse(quote['04. low'] ?? '0') ?? 0,
      open: double.tryParse(quote['02. open'] ?? '0') ?? 0,
      previousClose: double.tryParse(quote['08. previous close'] ?? '0') ?? 0,
      volume: int.tryParse(quote['06. volume'] ?? '0') ?? 0,
      lastUpdated: quote['07. latest trading day'] ?? '',
    );
  }

  factory Stock.fromSearchResult(Map<String, dynamic> json) {
    return Stock(
      symbol: json['1. symbol'] ?? '',
      name: json['2. name'] ?? '',
      price: 0,
      change: 0,
      changePercent: 0,
      high: 0,
      low: 0,
      open: 0,
      previousClose: 0,
      volume: 0,
      lastUpdated: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'price': price,
      'change': change,
      'changePercent': changePercent,
      'high': high,
      'low': low,
      'open': open,
      'previousClose': previousClose,
      'volume': volume,
      'lastUpdated': lastUpdated,
    };
  }

  Stock copyWith({
    String? symbol,
    String? name,
    double? price,
    double? change,
    double? changePercent,
    double? high,
    double? low,
    double? open,
    double? previousClose,
    int? volume,
    String? lastUpdated,
  }) {
    return Stock(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      price: price ?? this.price,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      high: high ?? this.high,
      low: low ?? this.low,
      open: open ?? this.open,
      previousClose: previousClose ?? this.previousClose,
      volume: volume ?? this.volume,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
