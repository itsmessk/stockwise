import 'package:flutter/material.dart';
import 'package:stockwise/models/stock.dart';
import 'package:stockwise/models/company_profile.dart';
import 'package:stockwise/models/historical_data.dart';
import 'package:stockwise/models/news.dart';
import 'package:stockwise/services/api_service.dart';
import 'package:stockwise/services/database_service.dart';
import 'package:stockwise/widgets/news_card.dart';
import 'package:fl_chart/fl_chart.dart';
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

class _StockDetailsScreenState extends State<StockDetailsScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final DatabaseService _databaseService = DatabaseService();
  
  late TabController _tabController;
  
  bool _isLoading = true;
  bool _isFavorite = false;
  String _errorMessage = '';
  
  Stock? _stock;
  CompanyProfile? _companyProfile;
  HistoricalDataList? _historicalData;
  List<NewsArticle> _news = [];
  
  String _selectedTimeRange = '1D'; // 1D, 1W, 1M, 3M, 1Y, 5Y
  
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
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Check if stock is in favorites
      _isFavorite = await _databaseService.isInWatchlist(widget.symbol);
      
      // Load stock data in parallel
      await Future.wait([
        _loadStockQuote(),
        _loadCompanyProfile(),
        _loadHistoricalData(),
        _loadStockNews(),
      ]);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load stock data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStockQuote() async {
    try {
      final stock = await _apiService.getStockQuote(widget.symbol);
      setState(() {
        _stock = stock;
      });
    } catch (e) {
      throw Exception('Failed to load stock quote: $e');
    }
  }

  Future<void> _loadCompanyProfile() async {
    try {
      final profile = await _apiService.getCompanyProfile(widget.symbol);
      setState(() {
        _companyProfile = profile;
      });
    } catch (e) {
      // Company profile is optional, so we don't throw an exception
      print('Failed to load company profile: $e');
    }
  }

  Future<void> _loadHistoricalData() async {
    try {
      final isDaily = _selectedTimeRange != '1D';
      final historicalData = await _apiService.getHistoricalData(
        widget.symbol,
        isDaily: isDaily,
      );
      setState(() {
        _historicalData = historicalData;
      });
    } catch (e) {
      throw Exception('Failed to load historical data: $e');
    }
  }

  Future<void> _loadStockNews() async {
    try {
      final newsResponse = await _apiService.getMarketNews(
        tickers: widget.symbol,
        limit: 5,
      );
      setState(() {
        _news = newsResponse.articles;
      });
    } catch (e) {
      // News is optional, so we don't throw an exception
      print('Failed to load news: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      if (_stock == null) return;
      
      setState(() {
        _isFavorite = !_isFavorite;
      });
      
      if (_isFavorite) {
        await _databaseService.addToWatchlist(_stock!);
      } else {
        await _databaseService.removeFromWatchlist(widget.symbol);
      }
    } catch (e) {
      // Revert the state if there's an error
      setState(() {
        _isFavorite = !_isFavorite;
        _errorMessage = 'Failed to update favorites: $e';
      });
    }
  }

  void _changeTimeRange(String range) {
    if (_selectedTimeRange == range) return;
    
    setState(() {
      _selectedTimeRange = range;
    });
    
    _loadHistoricalData();
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
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol),
        actions: [
          if (!_isLoading && _stock != null)
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.star : Icons.star_border,
                color: _isFavorite ? Colors.amber : null,
              ),
              onPressed: _toggleFavorite,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
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
                    'Loading stock data...',
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
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _stock == null
                  ? Center(
                      child: Text(
                        'No data available for ${widget.symbol}',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stock price header
                            _buildStockHeader(),
                            
                            // Price chart
                            _buildPriceChart(),
                            
                            // Tab bar
                            TabBar(
                              controller: _tabController,
                              tabs: const [
                                Tab(text: 'Overview'),
                                Tab(text: 'Details'),
                                Tab(text: 'News'),
                              ],
                            ),
                            
                            // Tab content
                            SizedBox(
                              height: 500, // Fixed height for tab content
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  // Overview tab
                                  _buildOverviewTab(),
                                  
                                  // Details tab
                                  _buildDetailsTab(),
                                  
                                  // News tab
                                  _buildNewsTab(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildStockHeader() {
    final theme = Theme.of(context);
    final isPositive = _stock!.change >= 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company name
          Text(
            _stock!.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          
          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${_stock!.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 16,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${isPositive ? '+' : ''}${_stock!.change.toStringAsFixed(2)} (${_stock!.changePercent.toStringAsFixed(2)}%)',
                    style: TextStyle(
                      fontSize: 16,
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          
          // Last updated
          Text(
            'Last updated: ${_stock!.lastUpdated}',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceChart() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      height: 300,
      child: Column(
        children: [
          // Time range selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeRangeButton('1D'),
              _buildTimeRangeButton('1W'),
              _buildTimeRangeButton('1M'),
              _buildTimeRangeButton('3M'),
              _buildTimeRangeButton('1Y'),
              _buildTimeRangeButton('5Y'),
            ],
          ),
          const SizedBox(height: 16),
          
          // Chart
          Expanded(
            child: _historicalData == null || _historicalData!.timeSeriesData.isEmpty
                ? Center(
                    child: Text(
                      'No historical data available',
                      style: TextStyle(
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= _historicalData!.timeSeriesData.length || value.toInt() < 0) {
                                return const SizedBox.shrink();
                              }
                              
                              // Only show a few dates
                              if (value.toInt() % (_historicalData!.timeSeriesData.length ~/ 5) != 0) {
                                return const SizedBox.shrink();
                              }
                              
                              final date = _historicalData!.timeSeriesData[value.toInt()].date;
                              return Text(
                                DateFormat.MMMd().format(DateTime.parse(date)),
                                style: TextStyle(
                                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            _historicalData!.timeSeriesData.length,
                            (index) => FlSpot(
                              index.toDouble(),
                              _historicalData!.timeSeriesData[index].close,
                            ),
                          ),
                          isCurved: true,
                          color: theme.colorScheme.primary,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: theme.colorScheme.primary.withOpacity(0.1),
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

  Widget _buildTimeRangeButton(String range) {
    final theme = Theme.of(context);
    final isSelected = _selectedTimeRange == range;
    
    return InkWell(
      onTap: () => _changeTimeRange(range),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.5),
          ),
        ),
        child: Text(
          range,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onBackground,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company description
          if (_companyProfile != null && _companyProfile!.description.isNotEmpty) ...[
            Text(
              'About ${_stock!.name}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _companyProfile!.description,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onBackground.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Key statistics
          Text(
            'Key Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          _buildKeyStatisticsGrid(),
        ],
      ),
    );
  }

  Widget _buildKeyStatisticsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      children: [
        _buildStatItem('Open', '\$${_stock!.open.toStringAsFixed(2)}'),
        _buildStatItem('Previous Close', '\$${_stock!.previousClose.toStringAsFixed(2)}'),
        _buildStatItem('High', '\$${_stock!.high.toStringAsFixed(2)}'),
        _buildStatItem('Low', '\$${_stock!.low.toStringAsFixed(2)}'),
        _buildStatItem('Volume', NumberFormat.compact().format(_stock!.volume)),
        if (_companyProfile != null) ...[
          _buildStatItem('Market Cap', _companyProfile!.marketCap),
          _buildStatItem('P/E Ratio', _companyProfile!.peRatio),
          _buildStatItem('Dividend Yield', _companyProfile!.dividendYield),
          _buildStatItem('52-Week High', _companyProfile!.weekHigh52),
          _buildStatItem('52-Week Low', _companyProfile!.weekLow52),
        ],
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_companyProfile != null) ...[
            // Company information
            Text(
              'Company Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoItem('Sector', _companyProfile!.sector),
            _buildInfoItem('Industry', _companyProfile!.industry),
            _buildInfoItem('Exchange', _companyProfile!.exchange),
            _buildInfoItem('Currency', _companyProfile!.currency),
            _buildInfoItem('Country', _companyProfile!.country),
            _buildInfoItem('Address', _companyProfile!.address),
            _buildInfoItem('Website', _companyProfile!.website),
            
            const SizedBox(height: 24),
            
            // Financial information
            Text(
              'Financial Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoItem('Earnings Per Share (EPS)', _companyProfile!.eps),
            _buildInfoItem('Revenue', _companyProfile!.revenue),
            _buildInfoItem('Gross Profit', _companyProfile!.grossProfit),
            _buildInfoItem('EBITDA', _companyProfile!.ebitda),
            _buildInfoItem('Profit Margin', _companyProfile!.profitMargin),
            _buildInfoItem('Beta', _companyProfile!.beta),
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: theme.colorScheme.onBackground.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No detailed information available',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
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

  Widget _buildInfoItem(String label, String value) {
    final theme = Theme.of(context);
    
    if (value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsTab() {
    final theme = Theme.of(context);
    
    return _news.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.newspaper,
                  size: 48,
                  color: theme.colorScheme.onBackground.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No news available',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
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
          );
  }
}
