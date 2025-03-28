import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';
import '../services/preferences_service.dart';
import '../utils/date_utils.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with SingleTickerProviderStateMixin {
  final NewsService _newsService = NewsService();
  final PreferencesService _preferencesService = PreferencesService();
  
  late TabController _tabController;
  List<WeatherNews> _generalNews = [];
  List<WeatherNews> _locationNews = [];
  List<WeatherNews> _alertNews = [];
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';
  String _currentLocation = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNews();
  }
  
  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });
    
    try {
      // Get last location from preferences
      final lastLocation = await _preferencesService.getLastLocation();
      _currentLocation = lastLocation ?? 'London';
      
      // Get general weather news
      final generalNewsResponse = await _newsService.getWeatherNews();
      _generalNews = generalNewsResponse.articles;
      
      // Get location-specific news
      final locationNewsResponse = await _newsService.getLocationWeatherNews(_currentLocation);
      _locationNews = locationNewsResponse.articles;
      
      // Get weather alerts
      final alertNewsResponse = await _newsService.getWeatherAlerts();
      _alertNews = alertNewsResponse.articles;
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading news: $e');
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = 'Error loading weather news. Please try again.';
      });
    }
  }
  
  Future<void> _openNewsUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      print('Error opening URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the article. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather News'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'Local'),
            Tab(text: 'Alerts'),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading weather news...')
          : _isError
              ? ErrorMessage(
                  message: _errorMessage,
                  onRetry: _loadNews,
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNewsList(_generalNews),
                    _buildNewsList(_locationNews),
                    _buildNewsList(_alertNews),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadNews,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
  
  Widget _buildNewsList(List<WeatherNews> news) {
    if (news.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.newspaper,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No news available',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh or try again later',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadNews,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: news.length,
        itemBuilder: (context, index) {
          final article = news[index];
          return _buildNewsCard(article);
        },
      ),
    );
  }
  
  Widget _buildNewsCard(WeatherNews article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _openNewsUrl(article.url),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.urlToImage.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    article.urlToImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.source,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        article.source,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateTimeUtils.getRelativeTime(article.publishedAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
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
