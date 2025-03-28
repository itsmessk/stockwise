class NewsArticle {
  final String title;
  final String url;
  final String summary;
  final String source;
  final String imageUrl;
  final String publishedAt;
  final List<String> topics;
  final List<String> tickers;
  final double sentiment;

  NewsArticle({
    required this.title,
    required this.url,
    required this.summary,
    required this.source,
    required this.imageUrl,
    required this.publishedAt,
    required this.topics,
    required this.tickers,
    required this.sentiment,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      summary: json['summary'] ?? '',
      source: json['source'] ?? '',
      imageUrl: json['banner_image'] ?? '',
      publishedAt: json['time_published'] ?? '',
      topics: List<String>.from(json['topics']?.map((topic) => topic['topic']) ?? []),
      tickers: List<String>.from(json['ticker_sentiment']?.map((ticker) => ticker['ticker']) ?? []),
      sentiment: _calculateAverageSentiment(json['ticker_sentiment']),
    );
  }

  static double _calculateAverageSentiment(List<dynamic>? tickerSentiments) {
    if (tickerSentiments == null || tickerSentiments.isEmpty) {
      return 0.0;
    }

    double totalSentiment = 0.0;
    for (var sentiment in tickerSentiments) {
      totalSentiment += double.tryParse(sentiment['ticker_sentiment_score'].toString()) ?? 0.0;
    }
    return totalSentiment / tickerSentiments.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'summary': summary,
      'source': source,
      'imageUrl': imageUrl,
      'publishedAt': publishedAt,
      'topics': topics,
      'tickers': tickers,
      'sentiment': sentiment,
    };
  }
}

class NewsResponse {
  final List<NewsArticle> articles;
  final String feedType;
  final int itemsCount;

  NewsResponse({
    required this.articles,
    required this.feedType,
    required this.itemsCount,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    final feed = json['feed'] as List<dynamic>? ?? [];
    
    return NewsResponse(
      articles: feed.map((article) => NewsArticle.fromJson(article)).toList(),
      feedType: json['feed_type'] ?? '',
      itemsCount: json['items'] ?? 0,
    );
  }
}
