import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stockwise/constants/api_constants.dart';
import 'package:stockwise/models/stock.dart';
import 'package:stockwise/models/company_profile.dart';
import 'package:stockwise/models/historical_data.dart';
import 'package:stockwise/models/news.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late final String _apiKey;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _apiKey = dotenv.env['ALPHA_VANTAGE_API_KEY'] ?? '';
  }

  // Get stock quote data
  Future<Stock> getStockQuote(String symbol) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}?${ApiConstants.functionParam}=${ApiConstants.globalQuote}&${ApiConstants.symbolParam}=$symbol&${ApiConstants.apiKeyParam}=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      
      // Check if the response contains an error message
      if (jsonData.containsKey('Error Message')) {
        throw Exception(jsonData['Error Message']);
      }
      
      // Check if the response contains a note (usually rate limit info)
      if (jsonData.containsKey('Note')) {
        throw Exception('API rate limit exceeded. ${jsonData['Note']}');
      }

      // Check if Global Quote is empty
      if (jsonData['Global Quote'] == null || jsonData['Global Quote'].isEmpty) {
        throw Exception('No data found for symbol: $symbol');
      }

      return Stock.fromJson(jsonData);
    } else {
      throw Exception('Failed to load stock data: ${response.statusCode}');
    }
  }

  // Search for stocks
  Future<List<Stock>> searchStocks(String query) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}?${ApiConstants.functionParam}=${ApiConstants.symbolSearch}&${ApiConstants.keywordsParam}=$query&${ApiConstants.apiKeyParam}=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      
      // Check if the response contains an error message
      if (jsonData.containsKey('Error Message')) {
        throw Exception(jsonData['Error Message']);
      }
      
      // Check if the response contains a note (usually rate limit info)
      if (jsonData.containsKey('Note')) {
        throw Exception('API rate limit exceeded. ${jsonData['Note']}');
      }

      // Check if bestMatches is empty
      if (!jsonData.containsKey('bestMatches') || jsonData['bestMatches'] == null) {
        return [];
      }

      final List<dynamic> matches = jsonData['bestMatches'];
      return matches.map((match) => Stock.fromSearchResult(match)).toList();
    } else {
      throw Exception('Failed to search stocks: ${response.statusCode}');
    }
  }

  // Get company profile
  Future<CompanyProfile> getCompanyProfile(String symbol) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}?${ApiConstants.functionParam}=${ApiConstants.companyOverview}&${ApiConstants.symbolParam}=$symbol&${ApiConstants.apiKeyParam}=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      
      // Check if the response contains an error message
      if (jsonData.containsKey('Error Message')) {
        throw Exception(jsonData['Error Message']);
      }
      
      // Check if the response contains a note (usually rate limit info)
      if (jsonData.containsKey('Note')) {
        throw Exception('API rate limit exceeded. ${jsonData['Note']}');
      }

      // Check if the response is empty or doesn't contain Symbol
      if (!jsonData.containsKey('Symbol') || jsonData['Symbol'] == null) {
        throw Exception('No company profile found for symbol: $symbol');
      }

      return CompanyProfile.fromJson(jsonData);
    } else {
      throw Exception('Failed to load company profile: ${response.statusCode}');
    }
  }

  // Get historical data
  Future<HistoricalDataList> getHistoricalData(String symbol, {bool isDaily = true}) async {
    final function = isDaily ? ApiConstants.timeSeriesDaily : ApiConstants.timeSeriesIntraday;
    final interval = isDaily ? '' : '&${ApiConstants.intervalParam}=${ApiConstants.thirtyMinInterval}';
    
    final url = Uri.parse(
      '${ApiConstants.baseUrl}?${ApiConstants.functionParam}=$function$interval&${ApiConstants.symbolParam}=$symbol&${ApiConstants.outputSizeParam}=${ApiConstants.compactOutputSize}&${ApiConstants.apiKeyParam}=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      
      // Check if the response contains an error message
      if (jsonData.containsKey('Error Message')) {
        throw Exception(jsonData['Error Message']);
      }
      
      // Check if the response contains a note (usually rate limit info)
      if (jsonData.containsKey('Note')) {
        throw Exception('API rate limit exceeded. ${jsonData['Note']}');
      }

      // Check if Meta Data is empty
      if (!jsonData.containsKey('Meta Data') || jsonData['Meta Data'] == null) {
        throw Exception('No historical data found for symbol: $symbol');
      }

      return HistoricalDataList.fromJson(jsonData);
    } else {
      throw Exception('Failed to load historical data: ${response.statusCode}');
    }
  }

  // Get market news
  Future<NewsResponse> getMarketNews({String? tickers, int limit = 10}) async {
    final tickerParam = tickers != null ? '&tickers=$tickers' : '';
    
    final url = Uri.parse(
      '${ApiConstants.baseUrl}?${ApiConstants.functionParam}=${ApiConstants.news}$tickerParam&limit=$limit&${ApiConstants.apiKeyParam}=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      
      // Check if the response contains an error message
      if (jsonData.containsKey('Error Message')) {
        throw Exception(jsonData['Error Message']);
      }
      
      // Check if the response contains a note (usually rate limit info)
      if (jsonData.containsKey('Note')) {
        throw Exception('API rate limit exceeded. ${jsonData['Note']}');
      }

      // Check if feed is empty
      if (!jsonData.containsKey('feed') || jsonData['feed'] == null) {
        throw Exception('No news data found');
      }

      return NewsResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to load news data: ${response.statusCode}');
    }
  }

  // Get top gainers and losers
  Future<Map<String, dynamic>> getTopGainersLosers() async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}?${ApiConstants.functionParam}=${ApiConstants.topGainers}&${ApiConstants.apiKeyParam}=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      
      // Check if the response contains an error message
      if (jsonData.containsKey('Error Message')) {
        throw Exception(jsonData['Error Message']);
      }
      
      // Check if the response contains a note (usually rate limit info)
      if (jsonData.containsKey('Note')) {
        throw Exception('API rate limit exceeded. ${jsonData['Note']}');
      }

      return jsonData;
    } else {
      throw Exception('Failed to load top gainers and losers: ${response.statusCode}');
    }
  }

  // Batch get stock quotes for multiple symbols
  Future<List<Stock>> batchGetStockQuotes(List<String> symbols) async {
    List<Stock> stocks = [];
    
    // Alpha Vantage doesn't have a batch endpoint, so we need to make multiple requests
    for (final symbol in symbols) {
      try {
        final stock = await getStockQuote(symbol);
        stocks.add(stock);
        
        // Add a delay to avoid hitting rate limits
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        print('Error fetching data for $symbol: $e');
        // Continue with the next symbol
      }
    }
    
    return stocks;
  }
}
