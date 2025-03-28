import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stockwise/constants/api_constants.dart';
import 'package:stockwise/models/stock.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late final String _apiKey;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _apiKey = dotenv.env['ALPHA_VANTAGE_API_KEY'] ?? 'demo';
  }

  // Get the API key for checking in other parts of the app
  String getApiKey() {
    return _apiKey;
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

  // Get top gainers and losers
  Future<Map<String, List<Stock>>> getTopGainersLosers() async {
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

      // Check if data is empty
      if (!jsonData.containsKey('topGainers') || jsonData['topGainers'] == null) {
        return {'gainers': [], 'losers': []};
      }

      final List<dynamic> gainers = jsonData['topGainers'];
      final List<dynamic> losers = jsonData['topLosers'];

      return {
        'gainers': gainers.map((gainer) => Stock.fromJson(gainer)).toList(),
        'losers': losers.map((loser) => Stock.fromJson(loser)).toList(),
      };
    } else {
      throw Exception('Failed to load top gainers/losers data: ${response.statusCode}');
    }
  }
}
