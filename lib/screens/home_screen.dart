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
      // For demonstration, we'll use some predefined symbols
      // In a real app, you would get these from an API endpoint
      final gainers = await Future.wait([
        _apiService.getStockQuote('AAPL'),
        _apiService.getStockQuote('MSFT'),
        _apiService.getStockQuote('GOOGL'),
        _apiService.getStockQuote('AMZN'),
      ]);
      
      final losers = await Future.wait([
        _apiService.getStockQuote('TSLA'),
        _apiService.getStockQuote('FB'),
        _apiService.getStockQuote('NFLX'),
        _apiService.getStockQuote('NVDA'),
      ]);
      
      setState(() {
        _topGainers = gainers;
        _topLosers = losers;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load market movers: $e';
      });
    }
  }

  Future<void> _loadNews() async {
    try {
      setState(() {
        _isNewsLoading = true;
      });
      
      final newsResponse = await _apiService.getMarketNews(limit: 10);
      
      setState(() {
        _news = newsResponse.articles;
        _isNewsLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load news: $e';
        _isNewsLoading = false;
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
