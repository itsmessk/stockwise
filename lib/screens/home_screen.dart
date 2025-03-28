import 'package:flutter/material.dart';
import 'package:stockwise/services/api_service.dart';
import 'package:stockwise/services/database_service.dart';
import 'package:stockwise/models/stock.dart';
import 'package:stockwise/models/news.dart';
import 'package:stockwise/widgets/stock_list_item.dart';
import 'package:stockwise/widgets/news_card.dart';
import 'package:stockwise/widgets/market_overview_card.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final DatabaseService _databaseService = DatabaseService();
  
  bool _isLoading = true;
  bool _isWatchlistLoading = true;
  bool _isNewsLoading = true;
  
  List<Stock> _watchlist = [];
  List<Stock> _topGainers = [];
  List<Stock> _topLosers = [];
  List<NewsArticle> _news = [];
  
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    await Future.wait([
      _loadWatchlist(),
      _loadMarketMovers(),
      _loadNews(),
    ]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadWatchlist() async {
    try {
      setState(() {
        _isWatchlistLoading = true;
      });
      
      // Get watchlist from Firestore
      final watchlist = await _databaseService.getWatchlist();
      
      // Update watchlist with latest data
      final updatedWatchlist = <Stock>[];
      
      for (final stock in watchlist) {
        try {
          final updatedStock = await _apiService.getStockQuote(stock.symbol);
          updatedWatchlist.add(updatedStock);
          
          // Update stock in Firestore
          await _databaseService.updateStockPrice(
            stock.symbol,
            updatedStock.price,
            updatedStock.change,
            updatedStock.changePercent,
            updatedStock.lastUpdated,
          );
        } catch (e) {
          // If we can't get updated data, use the stored data
          updatedWatchlist.add(stock);
        }
      }
      
      setState(() {
        _watchlist = updatedWatchlist;
        _isWatchlistLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load watchlist: $e';
        _isWatchlistLoading = false;
      });
    }
  }

  Future<void> _loadMarketMovers() async {
    try {
      // Check if we're using demo API key
      final apiKey = _apiService.getApiKey();
      
      if (apiKey == 'demo' || apiKey == '342567CHG66NUVWB') {
        // Use sample data for demo mode
        setState(() {
          _topGainers = [
            Stock(
              symbol: 'AAPL',
              name: 'Apple Inc.',
              price: 175.34,
              change: 2.56,
              changePercent: 1.48,
              volume: 65432100,
              lastUpdated: DateTime.now(),
            ),
            Stock(
              symbol: 'MSFT',
              name: 'Microsoft Corporation',
              price: 338.11,
              change: 3.45,
              changePercent: 1.03,
              volume: 23456700,
              lastUpdated: DateTime.now(),
            ),
            Stock(
              symbol: 'GOOGL',
              name: 'Alphabet Inc.',
              price: 137.56,
              change: 1.23,
              changePercent: 0.90,
              volume: 15678900,
              lastUpdated: DateTime.now(),
            ),
            Stock(
              symbol: 'AMZN',
              name: 'Amazon.com Inc.',
              price: 178.23,
              change: 2.12,
              changePercent: 1.20,
              volume: 34567800,
              lastUpdated: DateTime.now(),
            ),
          ];
          
          _topLosers = [
            Stock(
              symbol: 'TSLA',
              name: 'Tesla Inc.',
              price: 172.82,
              change: -3.45,
              changePercent: -1.96,
              volume: 87654300,
              lastUpdated: DateTime.now(),
            ),
            Stock(
              symbol: 'META',
              name: 'Meta Platforms Inc.',
              price: 485.39,
              change: -2.34,
              changePercent: -0.48,
              volume: 43215600,
              lastUpdated: DateTime.now(),
            ),
            Stock(
              symbol: 'NFLX',
              name: 'Netflix Inc.',
              price: 602.78,
              change: -5.67,
              changePercent: -0.93,
              volume: 12345600,
              lastUpdated: DateTime.now(),
            ),
            Stock(
              symbol: 'NVDA',
              name: 'NVIDIA Corporation',
              price: 925.66,
              change: -12.34,
              changePercent: -1.32,
              volume: 54321000,
              lastUpdated: DateTime.now(),
            ),
          ];
        });
        return;
      }
      
      // For real API key, fetch actual data
      final gainers = await Future.wait([
        _apiService.getStockQuote('AAPL'),
        _apiService.getStockQuote('MSFT'),
        _apiService.getStockQuote('GOOGL'),
        _apiService.getStockQuote('AMZN'),
      ]);
      
      final losers = await Future.wait([
        _apiService.getStockQuote('TSLA'),
        _apiService.getStockQuote('META'),
        _apiService.getStockQuote('NFLX'),
        _apiService.getStockQuote('NVDA'),
      ]);
      
      setState(() {
        _topGainers = gainers;
        _topLosers = losers;
      });
    } catch (e) {
      // Use sample data as fallback
      setState(() {
        _errorMessage = 'Failed to load market movers: $e';
        
        // Fallback data
        _topGainers = [
          Stock(
            symbol: 'AAPL',
            name: 'Apple Inc.',
            price: 175.34,
            change: 2.56,
            changePercent: 1.48,
            volume: 65432100,
            lastUpdated: DateTime.now(),
          ),
          Stock(
            symbol: 'MSFT',
            name: 'Microsoft Corporation',
            price: 338.11,
            change: 3.45,
            changePercent: 1.03,
            volume: 23456700,
            lastUpdated: DateTime.now(),
          ),
        ];
        
        _topLosers = [
          Stock(
            symbol: 'TSLA',
            name: 'Tesla Inc.',
            price: 172.82,
            change: -3.45,
            changePercent: -1.96,
            volume: 87654300,
            lastUpdated: DateTime.now(),
          ),
          Stock(
            symbol: 'META',
            name: 'Meta Platforms Inc.',
            price: 485.39,
            change: -2.34,
            changePercent: -0.48,
            volume: 43215600,
            lastUpdated: DateTime.now(),
          ),
        ];
      });
    }
  }

  Future<void> _loadNews() async {
    try {
      setState(() {
        _isNewsLoading = true;
      });
      
      // Check if we're using demo API key
      final apiKey = _apiService.getApiKey();
      
      if (apiKey == 'demo' || apiKey == '342567CHG66NUVWB') {
        // Use sample data for demo mode
        setState(() {
          _news = [
            NewsArticle(
              title: 'Apple Announces New iPhone Model',
              source: 'Tech News',
              url: 'https://example.com/apple-news',
              publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
              summary: 'Apple has announced its latest iPhone model with improved features and performance.',
              image: 'https://via.placeholder.com/300x200?text=Apple+News',
            ),
            NewsArticle(
              title: 'Microsoft Reports Strong Quarterly Earnings',
              source: 'Business Insider',
              url: 'https://example.com/microsoft-earnings',
              publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
              summary: 'Microsoft exceeded analyst expectations with its latest quarterly earnings report.',
              image: 'https://via.placeholder.com/300x200?text=Microsoft+News',
            ),
            NewsArticle(
              title: 'Tesla Expands Production Capacity',
              source: 'Auto News',
              url: 'https://example.com/tesla-expansion',
              publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
              summary: 'Tesla is expanding its production capacity to meet growing demand for electric vehicles.',
              image: 'https://via.placeholder.com/300x200?text=Tesla+News',
            ),
          ];
          _isNewsLoading = false;
        });
        return;
      }
      
      final newsResponse = await _apiService.getMarketNews(limit: 10);
      
      setState(() {
        _news = newsResponse.articles;
        _isNewsLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load news: $e';
        _isNewsLoading = false;
        
        // Fallback data
        _news = [
          NewsArticle(
            title: 'Market Update: Stocks Rise on Economic Data',
            source: 'Financial Times',
            url: 'https://example.com/market-update',
            publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
            summary: 'Stocks rose today following positive economic data and central bank announcements.',
            image: 'https://via.placeholder.com/300x200?text=Market+News',
          ),
          NewsArticle(
            title: 'Tech Sector Leads Market Gains',
            source: 'Wall Street Journal',
            url: 'https://example.com/tech-gains',
            publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
            summary: 'Technology stocks led market gains today as investors responded to positive earnings reports.',
            image: 'https://via.placeholder.com/300x200?text=Tech+News',
          ),
        ];
      });
    }
  }

  void _navigateToStockDetails(String symbol) {
    Navigator.pushNamed(
      context,
      '/stock_details',
      arguments: {'symbol': symbol},
    );
  }

  void _navigateToNewsDetails(NewsArticle news) {
    Navigator.pushNamed(
      context,
      '/news_details',
      arguments: {'news': news},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpinKitWave(
                color: theme.colorScheme.primary,
                size: 50.0,
              ),
              const SizedBox(height: 24),
              Text(
                'Loading market data...',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onBackground,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('StockWise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _errorMessage.isNotEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Market Overview Card
                  MarketOverviewCard(
                    gainers: _topGainers,
                    losers: _topLosers,
                  ),
                  const SizedBox(height: 24),
                  
                  // Watchlist Section
                  _buildSectionHeader('Your Watchlist', Icons.star),
                  const SizedBox(height: 8),
                  _isWatchlistLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _watchlist.isEmpty
                          ? _buildEmptyState(
                              'No stocks in watchlist',
                              'Add stocks to your watchlist to track them here',
                              Icons.star_border,
                              () {
                                Navigator.pushNamed(context, '/search');
                              },
                              'Add Stocks',
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _watchlist.length,
                              separatorBuilder: (context, index) => const Divider(),
                              itemBuilder: (context, index) {
                                final stock = _watchlist[index];
                                return StockListItem(
                                  stock: stock,
                                  onTap: () => _navigateToStockDetails(stock.symbol),
                                  isFavorite: true,
                                  onFavoriteToggle: () async {
                                    await _databaseService.removeFromWatchlist(stock.symbol);
                                    _loadWatchlist();
                                  },
                                );
                              },
                            ),
                  const SizedBox(height: 24),
                  
                  // Market News Section
                  _buildSectionHeader('Market News', Icons.newspaper),
                  const SizedBox(height: 8),
                  _isNewsLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _news.isEmpty
                          ? _buildEmptyState(
                              'No news available',
                              'Check back later for market news',
                              Icons.newspaper,
                              _loadNews,
                              'Refresh',
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _news.length,
                              itemBuilder: (context, index) {
                                final article = _news[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: NewsCard(
                                    article: article,
                                    onTap: () => _navigateToNewsDetails(article),
                                  ),
                                );
                              },
                            ),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onAction,
    String actionText,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAction,
            child: Text(actionText),
          ),
        ],
      ),
    );
  }
}
