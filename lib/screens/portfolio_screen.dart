import 'package:flutter/material.dart';
import 'package:stockwise/models/stock.dart';
import 'package:stockwise/services/api_service.dart';
import 'package:stockwise/services/database_service.dart';
import 'package:stockwise/widgets/stock_card.dart';
import 'package:stockwise/screens/stock_details_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final ApiService _apiService = ApiService();
  final DatabaseService _databaseService = DatabaseService();
  
  List<Stock> _watchlistStocks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get watchlist symbols from database
      final watchlistData = await _databaseService.getWatchlist();
      final symbols = watchlistData.map((item) => item['symbol'] as String).toList();
      
      if (symbols.isEmpty) {
        setState(() {
          _watchlistStocks = [];
          _isLoading = false;
        });
        return;
      }
      
      // Fetch latest stock data for watchlist symbols
      final stocks = await _apiService.fetchLiveStockPrices(symbols);
      
      setState(() {
        _watchlistStocks = stocks;
        _isLoading = false;
      });
      
      // Save stock data to local database for offline access
      for (var stock in stocks) {
        await _databaseService.saveStockData(stock);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
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

  Future<void> _removeFromWatchlist(Stock stock) async {
    try {
      await _databaseService.removeFromWatchlist(stock.symbol);
      
      setState(() {
        _watchlistStocks.removeWhere((item) => item.symbol == stock.symbol);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${stock.symbol} removed from watchlist'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () async {
              await _databaseService.addToWatchlist(stock.symbol, stock.name);
              _loadWatchlist();
            },
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Failed to remove from watchlist: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Watchlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWatchlist,
          ),
        ],
      ),
      body: _buildWatchlist(),
    );
  }

  Widget _buildWatchlist() {
    if (_isLoading) {
      return const Center(
        child: SpinKitWave(
          color: Colors.blue,
          size: 50.0,
        ),
      );
    }

    if (_watchlistStocks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_border,
              size: 80,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your watchlist is empty',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add stocks to your watchlist to track them here',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to search screen
                Navigator.pushNamed(context, '/search');
              },
              icon: const Icon(Icons.search),
              label: const Text('Search Stocks'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWatchlist,
      child: ListView.builder(
        itemCount: _watchlistStocks.length,
        itemBuilder: (context, index) {
          final stock = _watchlistStocks[index];
          
          return Dismissible(
            key: Key(stock.symbol),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _removeFromWatchlist(stock);
            },
            child: StockCard(
              stock: stock,
              isInWatchlist: true,
              onWatchlistToggle: (add) {
                if (!add) {
                  _removeFromWatchlist(stock);
                }
              },
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StockDetailsScreen(symbol: stock.symbol),
                  ),
                ).then((_) {
                  // Refresh watchlist when returning from details
                  _loadWatchlist();
                });
              },
            ),
          );
        },
      ),
    );
  }
}
