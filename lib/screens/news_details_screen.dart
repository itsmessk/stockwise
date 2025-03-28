import 'package:flutter/material.dart';
import 'package:stockwise/models/news.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailsScreen extends StatelessWidget {
  final NewsArticle news;

  const NewsDetailsScreen({
    Key? key,
    required this.news,
  }) : super(key: key);

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Format the published date
    String formattedDate = '';
    try {
      final date = DateTime.parse(news.publishedAt);
      formattedDate = DateFormat.yMMMMd().format(date);
    } catch (e) {
      formattedDate = news.publishedAt;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('News'),
        actions: [
          if (news.url != null && news.url!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.open_in_browser),
              onPressed: () => _launchUrl(news.url!),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // News image
            if (news.urlToImage != null && news.urlToImage!.isNotEmpty)
              SizedBox(
                height: 250,
                width: double.infinity,
                child: Image.network(
                  news.urlToImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      width: double.infinity,
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
              ),
            
            // News content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    news.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Source and date
                  Row(
                    children: [
                      if (news.source != null && news.source!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            news.source!,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onBackground.withOpacity(0.6),
                        ),
                      ),
                      if (news.author != null && news.author!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          '• ${news.author}',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Description
                  if (news.description != null && news.description!.isNotEmpty) ...[
                    Text(
                      news.description!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Content
                  if (news.content != null && news.content!.isNotEmpty)
                    Text(
                      news.content!,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onBackground.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Read more button
                  if (news.url != null && news.url!.isNotEmpty)
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _launchUrl(news.url!),
                        icon: const Icon(Icons.open_in_browser),
                        label: const Text('Read Full Article'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
