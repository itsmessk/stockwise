class News {
  final String title;
  final String description;
  final String url;
  final String source;
  final String imageUrl;
  final DateTime publishedAt;
  final List<String> relatedSymbols;

  News({
    required this.title,
    required this.description,
    required this.url,
    required this.source,
    required this.imageUrl,
    required this.publishedAt,
    required this.relatedSymbols,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    List<String> symbols = [];
    if (json['symbols'] != null) {
      symbols = List<String>.from(json['symbols']);
    }

    return News(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      source: json['source'] ?? '',
      imageUrl: json['image_url'] ?? '',
      publishedAt: json['published_at'] != null 
        ? DateTime.parse(json['published_at']) 
        : DateTime.now(),
      relatedSymbols: symbols,
    );
  }
}
