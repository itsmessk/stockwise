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
import 'package:url_launcher/url_launcher.dart';

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
      final news = await _apiService.fetchMarketNews();
      
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
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update watchlist: $e');
    }
  }

  void _openNewsUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showErrorSnackBar('Could not open news article');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StockWise'),
        bottom: TabBar(
          controller: _tabController,
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
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStocksTab(),
          _buildNewsTab(),
          _buildForexTab(),
        ],
      ),
    );
  }

  Widget _buildStocksTab() {
    if (_isLoadingStocks) {
      return const Center(
        child: SpinKitWave(
          color: Colors.blue,
          size: 50.0,
        ),
      );
    }

    if (_topStocks.isEmpty) {
      return const Center(
        child: Text('No stocks available'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTopStocks,
      child: ListView.builder(
        itemCount: _topStocks.length,
        itemBuilder: (context, index) {
          final stock = _topStocks[index];
          final isInWatchlist = _watchlist.contains(stock.symbol);
          
          return StockCard(
            stock: stock,
            isInWatchlist: isInWatchlist,
            onWatchlistToggle: (add) => _toggleWatchlist(stock, add),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StockDetailsScreen(symbol: stock.symbol),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNewsTab() {
    if (_isLoadingNews) {
      return const Center(
        child: SpinKitWave(
          color: Colors.blue,
          size: 50.0,
        ),
      );
    }

    if (_latestNews.isEmpty) {
      return const Center(
        child: Text('No news available'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLatestNews,
      child: ListView.builder(
        itemCount: _latestNews.length,
        itemBuilder: (context, index) {
          final news = _latestNews[index];
          
          return NewsCard(
            news: news,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsDetailsScreen(news: news),
                ),
              ).then((_) {
                // Refresh if needed
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildForexTab() {
    if (_isLoadingForex) {
      return const Center(
        child: SpinKitWave(
          color: Colors.blue,
          size: 50.0,
        ),
      );
    }

    if (_forexRates.isEmpty) {
      return const Center(
        child: Text('No forex rates available'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadForexRates,
      child: ListView.builder(
        itemCount: _forexRates.length,
        itemBuilder: (context, index) {
          final forex = _forexRates[index];
          
          return ForexCard(
            forex: forex,
            onTap: () {
              // Show detailed forex view if needed
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${forex.baseCurrency}/${forex.quoteCurrency} rate: ${forex.exchangeRate}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
