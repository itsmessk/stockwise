import 'package:flutter/material.dart';
import 'package:stockwise/models/stock.dart';
import 'package:stockwise/models/news.dart';
import 'package:stockwise/models/forex.dart';
import 'package:stockwise/services/api_service.dart';
import 'package:stockwise/services/database_service.dart';
import 'package:stockwise/utils/stock_utils.dart';
import 'package:stockwise/widgets/stock_card.dart';
import 'package:stockwise/widgets/news_card.dart';
import 'package:stockwise/widgets/forex_card.dart';
import 'package:stockwise/screens/stock_details_screen.dart';
import 'package:stockwise/screens/news_details_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final DatabaseService _databaseService = DatabaseService();
  
  late TabController _tabController;
  
  List<Stock> _topStocks = [];
  List<News> _latestNews = [];
  List<Forex> _forexRates = [];
  List<String> _watchlist = [];
  
  bool _isLoadingStocks = true;
  bool _isLoadingNews = true;
  bool _isLoadingForex = true;
  bool _isLoadingWatchlist = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _loadTopStocks();
    _loadLatestNews();
    _loadForexRates();
    _loadWatchlist();
  }

  Future<void> _loadTopStocks() async {
    setState(() {
      _isLoadingStocks = true;
    });

    try {
      final stocks = await _apiService.fetchLiveStockPrices(StockUtils.getPopularStocks());
      
      setState(() {
        _topStocks = stocks;
        _isLoadingStocks = false;
      });
      
      // Save stock data to local database for offline access
      for (var stock in stocks) {
        await _databaseService.saveStockData(stock);
      }
    } catch (e) {
      setState(() {
        _isLoadingStocks = false;
      });
      _showErrorSnackBar('Failed to load stocks: $e');
    }
  }

  Future<void> _loadLatestNews() async {
    setState(() {
      _isLoadingNews = true;
    });

    try {
      final news = await _apiService.fetchMarketNews(limit: 15);
      
      setState(() {
        _latestNews = news;
        _isLoadingNews = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingNews = false;
      });
      _showErrorSnackBar('Failed to load news: $e');
    }
  }

  Future<void> _loadForexRates() async {
    setState(() {
      _isLoadingForex = true;
    });

    try {
      final forex = await _apiService.fetchForexRates();
      
      setState(() {
        _forexRates = forex;
        _isLoadingForex = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingForex = false;
      });
      _showErrorSnackBar('Failed to load forex rates: $e');
    }
  }

  Future<void> _loadWatchlist() async {
    setState(() {
      _isLoadingWatchlist = true;
    });

    try {
      final watchlistData = await _databaseService.getWatchlist();
      final symbols = watchlistData.map((item) => item['symbol'] as String).toList();
      
      setState(() {
        _watchlist = symbols;
        _isLoadingWatchlist = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingWatchlist = false;
      });
      _showErrorSnackBar('Failed to load watchlist: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _toggleWatchlist(Stock stock, bool add) async {
    try {
      if (add) {
        await _databaseService.addToWatchlist(stock.symbol, stock.name);
        setState(() {
          _watchlist.add(stock.symbol);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${stock.symbol} added to watchlist'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        await _databaseService.removeFromWatchlist(stock.symbol);
        setState(() {
          _watchlist.remove(stock.symbol);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${stock.symbol} removed from watchlist'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update watchlist: $e');
    }
  }

  Future<void> _openNewsUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await launcher.canLaunchUrl(uri)) {
        await launcher.launchUrl(uri, mode: launcher.LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not open news article');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.show_chart, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'StockWise',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
          ],
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Stocks'),
            Tab(text: 'News'),
            Tab(text: 'Forex'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh data',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
            tooltip: 'Search stocks',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.background,
              theme.colorScheme.background.withOpacity(0.95),
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildStocksTab(),
            _buildNewsTab(),
            _buildForexTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildStocksTab() {
    if (_isLoadingStocks) {
      return Center(
        child: SpinKitWave(
          color: Theme.of(context).colorScheme.primary,
          size: 50.0,
        ),
      );
    }

    if (_topStocks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'No stocks available',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTopStocks,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTopStocks,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: _topStocks.length + 1, // +1 for header
        itemBuilder: (context, index) {
          if (index == 0) {
            // Header
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Stocks',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  Text(
                    'Updated: ${StockUtils.formatDateTime(DateTime.now())}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }
          
          final stockIndex = index - 1;
          final stock = _topStocks[stockIndex];
          final isInWatchlist = _watchlist.contains(stock.symbol);
          
          return StockCard(
            stock: stock,
            isInWatchlist: isInWatchlist,
            onWatchlistToggle: (add) => _toggleWatchlist(stock, add),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/stock_details',
                arguments: {'symbol': stock.symbol},
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNewsTab() {
    if (_isLoadingNews) {
      return Center(
        child: SpinKitWave(
          color: Theme.of(context).colorScheme.primary,
          size: 50.0,
        ),
      );
    }

    if (_latestNews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.newspaper,
              size: 48,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No news available',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadLatestNews,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLatestNews,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: _latestNews.length + 1, // +1 for header
        itemBuilder: (context, index) {
          if (index == 0) {
            // Header
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Latest News',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  Text(
                    'Updated: ${StockUtils.formatDateTime(DateTime.now())}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }
          
          final newsIndex = index - 1;
          final news = _latestNews[newsIndex];
          
          return NewsCard(
            news: news,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/news_details',
                arguments: {'news': news},
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildForexTab() {
    if (_isLoadingForex) {
      return Center(
        child: SpinKitWave(
          color: Theme.of(context).colorScheme.primary,
          size: 50.0,
        ),
      );
    }

    if (_forexRates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.currency_exchange,
              size: 48,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No forex rates available',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadForexRates,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadForexRates,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: _forexRates.length + 1, // +1 for header
        itemBuilder: (context, index) {
          if (index == 0) {
            // Header
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Forex Rates',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  Text(
                    'Updated: ${StockUtils.formatDateTime(DateTime.now())}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }
          
          final forexIndex = index - 1;
          final forex = _forexRates[forexIndex];
          
          return ForexCard(
            forex: forex,
            onTap: () {
              // Show detailed forex view if needed
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${forex.baseCurrency}/${forex.quoteCurrency} rate: ${forex.exchangeRate}'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
