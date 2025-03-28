import 'package:flutter/material.dart';
import 'package:stockwise/services/api_service.dart';
import 'package:stockwise/services/database_service.dart';
import 'package:stockwise/models/stock.dart';
import 'package:stockwise/widgets/stock_list_item.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fl_chart/fl_chart.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final ApiService _apiService = ApiService();
  final DatabaseService _databaseService = DatabaseService();
  
  bool _isLoading = true;
  List<Stock> _watchlist = [];
  String _errorMessage = '';
  
  // Portfolio statistics
  double _totalValue = 0;
  double _totalGain = 0;
  double _totalGainPercent = 0;
  
  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
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
      
      // Calculate portfolio statistics
      _calculatePortfolioStats(updatedWatchlist);
      
      setState(() {
        _watchlist = updatedWatchlist;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load watchlist: $e';
        _isLoading = false;
      });
    }
  }

  void _calculatePortfolioStats(List<Stock> stocks) {
    double totalValue = 0;
    double totalGain = 0;
    
    for (final stock in stocks) {
      // In a real app, you would multiply by the number of shares owned
      // For now, we'll just sum up the prices
      totalValue += stock.price;
      totalGain += stock.change;
    }
    
    double totalGainPercent = 0;
    if (totalValue > 0) {
      totalGainPercent = (totalGain / totalValue) * 100;
    }
    
    setState(() {
      _totalValue = totalValue;
      _totalGain = totalGain;
      _totalGainPercent = totalGainPercent;
    });
  }

  void _navigateToStockDetails(String symbol) {
    Navigator.pushNamed(
      context,
      '/stock_details',
      arguments: {'symbol': symbol},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWatchlist,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitWave(
                    color: theme.colorScheme.primary,
                    size: 50.0,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Loading portfolio...',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
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
                        onPressed: _loadWatchlist,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadWatchlist,
                  child: _watchlist.isEmpty
                      ? _buildEmptyState(context)
                      : SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Portfolio summary card
                              _buildPortfolioSummary(context),
                              
                              // Portfolio allocation chart
                              _buildPortfolioAllocation(context),
                              
                              // Watchlist
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Your Watchlist',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onBackground,
                                  ),
                                ),
                              ),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            ],
                          ),
                        ),
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Your portfolio is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Add stocks to your watchlist to track them here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
            icon: const Icon(Icons.search),
            label: const Text('Search Stocks'),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSummary(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = _totalGain >= 0;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Value',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${_totalValue.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Today's gain/loss
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Change',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${isPositive ? '+' : ''}\$${_totalGain.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Percentage change
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Percent Change',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isPositive ? '+' : ''}${_totalGainPercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioAllocation(BuildContext context) {
    final theme = Theme.of(context);
    
    // Skip if no stocks
    if (_watchlist.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Create data for pie chart
    final List<PieChartSectionData> sections = [];
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ];
    
    for (int i = 0; i < _watchlist.length; i++) {
      final stock = _watchlist[i];
      final color = colors[i % colors.length];
      
      // In a real app, you would calculate the percentage based on the value of each position
      // For now, we'll just use equal weights
      final value = 100 / _watchlist.length;
      
      sections.add(
        PieChartSectionData(
          color: color,
          value: value,
          title: stock.symbol,
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Allocation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: List.generate(
              _watchlist.length,
              (index) {
                final stock = _watchlist[index];
                final color = colors[index % colors.length];
                
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      stock.symbol,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
