class HistoricalData {
  final String date;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;

  HistoricalData({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory HistoricalData.fromJson(String date, Map<String, dynamic> json) {
    return HistoricalData(
      date: date,
      open: double.tryParse(json['1. open'] ?? '0') ?? 0,
      high: double.tryParse(json['2. high'] ?? '0') ?? 0,
      low: double.tryParse(json['3. low'] ?? '0') ?? 0,
      close: double.tryParse(json['4. close'] ?? '0') ?? 0,
      volume: int.tryParse(json['5. volume'] ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
    };
  }
}

class HistoricalDataList {
  final String symbol;
  final List<HistoricalData> dataPoints;

  HistoricalDataList({
    required this.symbol,
    required this.dataPoints,
  });
  
  // Getter for timeSeriesData to match usage in stock_details_screen.dart
  List<HistoricalData> get timeSeriesData => dataPoints;

  factory HistoricalDataList.fromJson(Map<String, dynamic> json) {
    final metaData = json['Meta Data'];
    final symbol = metaData['2. Symbol'] ?? '';
    final timeSeriesKey = json.keys.firstWhere(
      (key) => key.contains('Time Series'),
      orElse: () => '',
    );
    
    if (timeSeriesKey.isEmpty) {
      return HistoricalDataList(symbol: symbol, dataPoints: []);
    }

    final timeSeriesData = json[timeSeriesKey] as Map<String, dynamic>;
    final dataPoints = timeSeriesData.entries.map((entry) {
      return HistoricalData.fromJson(entry.key, entry.value);
    }).toList();

    // Sort by date (newest first)
    dataPoints.sort((a, b) => b.date.compareTo(a.date));

    return HistoricalDataList(
      symbol: symbol,
      dataPoints: dataPoints,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'dataPoints': dataPoints.map((dataPoint) => dataPoint.toJson()).toList(),
    };
  }
}
