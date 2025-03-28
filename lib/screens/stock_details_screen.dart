import 'package:flutter/material.dart';
import 'package:stockwise/models/stock.dart';
import 'package:stockwise/models/company_profile.dart';
import 'package:stockwise/models/historical_data.dart';
import 'package:stockwise/services/api_service.dart';
import 'package:stockwise/services/database_service.dart';
import 'package:stockwise/utils/stock_utils.dart';
import 'package:stockwise/widgets/stock_chart.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class StockDetailsScreen extends StatefulWidget {
  final String symbol;

  const StockDetailsScreen({
    Key? key,
    required this.symbol,
  }) : super(key: key);

  @override
  State<StockDetailsScreen> createState() => _StockDetailsScreenState();
}

class _StockDetailsScreenState extends State<StockDetailsScreen> {
  final ApiService _apiService = ApiService();
  final DatabaseService _databaseService = DatabaseService();

  Stock? _stock;
  CompanyProfile? _companyProfile;
  List<HistoricalData> _historicalData = [];
  bool _isInWatchlist = false;
  
  bool _isLoadingStock = true;
  bool _isLoadingProfile = true;
  bool _isLoadingHistoricalData = true;
  
  String _selectedTimeRange = '1M'; // Default to 1 month

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _loadStock();
    _loadCompanyProfile();
    _loadHistoricalData();
    _checkWatchlistStatus();
  }

  Future<void> _loadStock() async {
    setState(() {
      _isLoadingStock = true;
    });

    try {
      final stocks = await _apiService.fetchLiveStockPrices([widget.symbol]);
      
      if (stocks.isNotEmpty) {
        setState(() {
          _stock = stocks.first;
          _isLoadingStock = false;
        });
        
        // Save to local database
        await _databaseService.saveStockData(_stock!);
      } else {
        setState(() {
          _isLoadingStock = false;
        });
        _showErrorSnackBar('Stock data not found');
      }
    } catch (e) {
      setState(() {
        _isLoadingStock = false;
      });
      _showErrorSnackBar('Failed to load stock data: $e');
    }
  }

  Future<void> _loadCompanyProfile() async {
    setState(() {
      _isLoadingProfile = true;
    });

    try {
      final profile = await _apiService.fetchCompanyProfile(widget.symbol);
      
      setState(() {
        _companyProfile = profile;
        _isLoadingProfile = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProfile = false;
      });
      _showErrorSnackBar('Failed to load company profile: $e');
    }
  }

  Future<void> _loadHistoricalData() async {
    setState(() {
      _isLoadingHistoricalData = true;
    });

    try {
      final dateFrom = _getDateFromForRange();
      final data = await _apiService.fetchHistoricalData(
        widget.symbol,
        DateFormat('yyyy-MM-dd').format(dateFrom),
      );
      
      setState(() {
        _historicalData = data;
        _isLoadingHistoricalData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingHistoricalData = false;
      });
      _showErrorSnackBar('Failed to load historical data: $e');
    }
  }

  Future<void> _checkWatchlistStatus() async {
    try {
      final isInWatchlist = await _databaseService.isInWatchlist(widget.symbol);
      
      setState(() {
        _isInWatchlist = isInWatchlist;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to check watchlist status: $e');
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

  DateTime _getDateFromForRange() {
    final now = DateTime.now();
    
    switch (_selectedTimeRange) {
      case '1D':
        return now.subtract(const Duration(days: 1));
      case '1W':
        return now.subtract(const Duration(days: 7));
      case '1M':
        return now.subtract(const Duration(days: 30));
      case '3M':
        return now.subtract(const Duration(days: 90));
      case '6M':
        return now.subtract(const Duration(days: 180));
      case '1Y':
        return now.subtract(const Duration(days: 365));
      case '5Y':
        return now.subtract(const Duration(days: 365 * 5));
      default:
        return now.subtract(const Duration(days: 30));
    }
  }

  Future<void> _toggleWatchlist() async {
    try {
      if (_stock == null) return;
      
      if (_isInWatchlist) {
        await _databaseService.removeFromWatchlist(widget.symbol);
        setState(() {
          _isInWatchlist = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.symbol} removed from watchlist'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        await _databaseService.addToWatchlist(widget.symbol, _stock!.name);
        setState(() {
          _isInWatchlist = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.symbol} added to watchlist'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update watchlist: $e');
    }
  }

  void _onTimeRangeChanged(String range) {
    setState(() {
      _selectedTimeRange = range;
    });
    _loadHistoricalData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol),
        actions: [
          IconButton(
            icon: Icon(
              _isInWatchlist ? Icons.star : Icons.star_border,
              color: _isInWatchlist ? Colors.amber : null,
            ),
            onPressed: _toggleWatchlist,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStockHeader(),
            _buildChart(),
            _buildCompanyProfile(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStockHeader() {
    if (_isLoadingStock) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SpinKitWave(
            color: Colors.blue,
            size: 30.0,
          ),
        ),
      );
    }

    if (_stock == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Stock data not available'),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _stock!.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_stock!.exchange}: ${_stock!.symbol}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    StockUtils.formatPrice(_stock!.price, _stock!.currency),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        StockUtils.getPriceChangeIcon(_stock!.change),
                        color: StockUtils.getPriceChangeColor(_stock!.change),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_stock!.change.toStringAsFixed(2)} (${StockUtils.formatPercentageChange(_stock!.percentChange)})',
                        style: TextStyle(
                          color: StockUtils.getPriceChangeColor(_stock!.change),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('Volume', StockUtils.formatLargeNumber(_stock!.volume)),
              _buildInfoItem('Currency', _stock!.currency),
              _buildInfoItem('Last Updated', _formatLastUpdated(_stock!.lastUpdated)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    if (_isLoadingHistoricalData) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SpinKitWave(
            color: Colors.blue,
            size: 30.0,
          ),
        ),
      );
    }

    if (_historicalData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Historical data not available'),
        ),
      );
    }

    return StockChart(
      data: _historicalData,
      timeRange: _selectedTimeRange,
      onTimeRangeChanged: _onTimeRangeChanged,
    );
  }

  Widget _buildCompanyProfile() {
    if (_isLoadingProfile) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SpinKitWave(
            color: Colors.blue,
            size: 30.0,
          ),
        ),
      );
    }

    if (_companyProfile == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Company profile not available'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Company Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_companyProfile!.logoUrl.isNotEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Image.network(
                          _companyProfile!.logoUrl,
                          height: 60,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox(
                              height: 60,
                              child: Icon(
                                Icons.business,
                                size: 60,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  _buildProfileItem('Industry', _companyProfile!.industry),
                  _buildProfileItem('Sector', _companyProfile!.sector),
                  _buildProfileItem('CEO', _companyProfile!.ceo),
                  _buildProfileItem('Employees', _companyProfile!.employees.toString()),
                  _buildProfileItem('Website', _companyProfile!.website),
                  _buildProfileItem('Market Cap', StockUtils.formatLargeNumber(_companyProfile!.marketCap)),
                  _buildProfileItem('Address', _getFullAddress()),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _companyProfile!.description,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _getFullAddress() {
    if (_companyProfile == null) return '';
    
    final parts = [
      _companyProfile!.address,
      _companyProfile!.city,
      _companyProfile!.state,
      _companyProfile!.zip,
      _companyProfile!.country,
    ].where((part) => part.isNotEmpty).toList();
    
    return parts.join(', ');
  }

  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
