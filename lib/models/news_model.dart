class WeatherNews {
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String publishedAt;
  final String source;
  final String category;
  final String content;

  WeatherNews({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.source,
    required this.category,
    required this.content,
  });

  factory WeatherNews.fromJson(Map<String, dynamic> json) {
    return WeatherNews(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      source: json['source']['name'] ?? '',
      category: json['category'] ?? 'weather',
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'source': source,
      'category': category,
      'content': content,
    };
  }
}

class NewsResponse {
  final String status;
  final int totalResults;
  final List<WeatherNews> articles;

  NewsResponse({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    var articlesList = <WeatherNews>[];
    
    if (json['articles'] != null) {
      json['articles'].forEach((article) {
        articlesList.add(WeatherNews.fromJson(article));
      });
    }
    
    return NewsResponse(
      status: json['status'] ?? '',
      totalResults: json['totalResults'] ?? 0,
      articles: articlesList,
    );
  }
}
