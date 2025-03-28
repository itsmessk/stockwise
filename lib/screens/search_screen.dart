import 'package:flutter/material.dart';
import 'package:stockwise/models/stock.dart';
import 'package:stockwise/services/api_service.dart';
import 'package:stockwise/services/database_service.dart';
import 'package:stockwise/widgets/stock_card.dart';
import 'package:stockwise/screens/stock_details_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Stock> _searchResults = [];
  List<String> _watchlist = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWatchlist() async {
    try {
      final watchlistData = await _databaseService.getWatchlist();
      setState(() {
        _watchlist = watchlistData.map((item) => item['symbol'] as String).toList();
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load watchlist: $e');
    }
  }

  Future<void> _searchStocks(String query) async {
    if (query.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      // Split the query by commas or spaces to search for multiple symbols
      final symbols = query.split(RegExp(r'[,\s]+')).where((s) => s.isNotEmpty).toList();
      
      if (symbols.isEmpty) {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
        return;
      }
      
      final stocks = await _apiService.fetchLiveStockPrices(symbols);
      
      setState(() {
        _searchResults = stocks;
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
      _showErrorSnackBar('Failed to search stocks: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Stocks'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter stock symbol (e.g., AAPL, MSFT)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: _searchStocks,
              textInputAction: TextInputAction.search,
            ),
          ),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: SpinKitWave(
          color: Colors.blue,
          size: 50.0,
        ),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Search for stock symbols',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Example: AAPL, MSFT, GOOGL',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied,
              size: 80,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try searching for different symbols',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final stock = _searchResults[index];
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
            ).then((_) {
              // Refresh watchlist when returning from details
              _loadWatchlist();
            });
          },
        );
      },
    );
  }
}
