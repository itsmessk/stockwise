import 'package:flutter/material.dart';
import 'package:stockwise/services/api_service.dart';
import 'package:stockwise/services/database_service.dart';
import 'package:stockwise/models/stock.dart';
import 'package:stockwise/widgets/stock_list_item.dart';
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
  
  bool _isLoading = false;
  bool _isHistoryLoading = true;
  List<Stock> _searchResults = [];
  List<String> _searchHistory = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    try {
      setState(() {
        _isHistoryLoading = true;
      });
      
      final history = await _databaseService.getSearchHistory();
      
      setState(() {
        _searchHistory = history;
        _isHistoryLoading = false;
      });
    } catch (e) {
      setState(() {
        _isHistoryLoading = false;
      });
    }
  }

  Future<void> _searchStocks(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Check if we're using demo API key
      final apiKey = _apiService.getApiKey();
      
      if (apiKey == 'demo' || apiKey == '342567CHG66NUVWB') {
        // Use sample data for demo mode
        await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
        
        setState(() {
          _searchResults = [
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
          _isLoading = false;
        });
        
        // Save search to history
        try {
          await _databaseService.addSearchQuery(query);
          await _loadSearchHistory();
        } catch (e) {
          print('Error saving search history: $e');
        }
        
        return;
      }
      
      final results = await _apiService.searchStocks(query);
      
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
      
      // Save search to history
      try {
        await _databaseService.addSearchQuery(query);
        await _loadSearchHistory();
      } catch (e) {
        setState(() {
          _errorMessage = 'Error saving search history: $e';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error searching stocks: $e';
        _isLoading = false;
        
        // Provide fallback data
        _searchResults = [
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
      });
    }
  }

  Future<void> _checkFavoriteStatus() async {
    if (_searchResults.isEmpty) return;
    
    final updatedResults = <Stock>[];
    
    for (final stock in _searchResults) {
      final isInWatchlist = await _databaseService.isInWatchlist(stock.symbol);
      
      // Create a new stock with the same properties
      final updatedStock = Stock(
        symbol: stock.symbol,
        name: stock.name,
        price: stock.price,
        change: stock.change,
        changePercent: stock.changePercent,
        high: stock.high,
        low: stock.low,
        open: stock.open,
        previousClose: stock.previousClose,
        volume: stock.volume,
        lastUpdated: stock.lastUpdated,
      );
      
      updatedResults.add(updatedStock);
    }
    
    setState(() {
      _searchResults = updatedResults;
    });
  }

  void _navigateToStockDetails(String symbol) {
    Navigator.pushNamed(
      context,
      '/stock_details',
      arguments: {'symbol': symbol},
    );
  }

  Future<void> _toggleFavorite(Stock stock) async {
    final isInWatchlist = await _databaseService.isInWatchlist(stock.symbol);
    
    if (isInWatchlist) {
      await _databaseService.removeFromWatchlist(stock.symbol);
    } else {
      await _databaseService.addToWatchlist(stock);
    }
    
    // Refresh the favorite status
    await _checkFavoriteStatus();
  }

  void _clearSearchHistory() async {
    await _databaseService.clearSearchHistory();
    await _loadSearchHistory();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Stocks'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by company name or symbol',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: _searchStocks,
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          
          // Loading indicator
          if (_isLoading)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitWave(
                      color: theme.colorScheme.primary,
                      size: 40.0,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Searching...',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
              ),
            )
          // Error message
          else if (_errorMessage.isNotEmpty)
            Expanded(
              child: Center(
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
                      onPressed: () => _searchStocks(_searchController.text),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          // Search results
          else if (_searchResults.isNotEmpty)
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _searchResults.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final stock = _searchResults[index];
                  return StockListItem(
                    stock: stock,
                    onTap: () => _navigateToStockDetails(stock.symbol),
                    isFavorite: false, // We'll update this with actual data
                    onFavoriteToggle: () => _toggleFavorite(stock),
                  );
                },
              ),
            )
          // Search history
          else
            Expanded(
              child: _isHistoryLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recent Searches',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                              if (_searchHistory.isNotEmpty)
                                TextButton(
                                  onPressed: _clearSearchHistory,
                                  child: const Text('Clear All'),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _searchHistory.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search,
                                        size: 48,
                                        color: theme.colorScheme.onBackground.withOpacity(0.3),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No recent searches',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _searchHistory.length,
                                  itemBuilder: (context, index) {
                                    final query = _searchHistory[index];
                                    return ListTile(
                                      leading: const Icon(Icons.history),
                                      title: Text(query),
                                      onTap: () {
                                        _searchController.text = query;
                                        _searchStocks(query);
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}
