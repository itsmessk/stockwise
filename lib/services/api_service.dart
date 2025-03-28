import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stockwise/constants/api_constants.dart';
import 'package:stockwise/models/stock.dart';
import 'package:stockwise/models/company_profile.dart';
import 'package:stockwise/models/news.dart';
import 'package:stockwise/models/forex.dart';
import 'package:stockwise/models/historical_data.dart';

class ApiService {
  // Fetch live stock prices
  Future<List<Stock>> fetchLiveStockPrices(List<String> symbols) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/data/quote?symbols=${symbols.join(',')}&api_token=${ApiConstants.apiKey}')
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        // Check if the API returned a successful response
        if (jsonResponse['status'] == 'success' && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((item) => Stock.fromJson(item)).toList();
        } else {
          throw Exception('API returned error: ${jsonResponse['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to load stock prices: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching live stock prices: $e');
      return []; // Return empty list instead of throwing to prevent app crashes
    }
  }

  // Fetch historical stock data
  Future<List<HistoricalData>> fetchHistoricalData(String symbol, {String? dateFrom, String? dateTo}) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'symbols': symbol,
        'api_token': ApiConstants.apiKey,
      };
      
      if (dateFrom != null) {
        queryParams['date_from'] = dateFrom;
      }
      
      if (dateTo != null) {
        queryParams['date_to'] = dateTo;
      }
      
      final Uri uri = Uri.parse('${ApiConstants.baseUrl}/data/eod').replace(queryParameters: queryParams);
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['status'] == 'success' && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((item) => HistoricalData.fromJson(item)).toList();
        } else {
          throw Exception('API returned error: ${jsonResponse['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to load historical data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching historical data: $e');
      return []; // Return empty list instead of throwing
    }
  }

  // Fetch company profile
  Future<CompanyProfile?> fetchCompanyProfile(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/entity/profile?symbols=$symbol&api_token=${ApiConstants.apiKey}')
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['status'] == 'success' && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          if (data.isNotEmpty) {
            return CompanyProfile.fromJson(data[0]);
          } else {
            print('No company profile found for $symbol');
            return null;
          }
        } else {
          throw Exception('API returned error: ${jsonResponse['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to load company profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching company profile: $e');
      return null; // Return null instead of throwing
    }
  }

  // Fetch market news
  Future<List<News>> fetchMarketNews({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/news/all?limit=$limit&api_token=${ApiConstants.apiKey}')
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['status'] == 'success' && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((item) => News.fromJson(item)).toList();
        } else {
          throw Exception('API returned error: ${jsonResponse['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to load market news: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching market news: $e');
      return []; // Return empty list instead of throwing
    }
  }

  // Fetch forex rates
  Future<List<Forex>> fetchForexRates() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/data/forex/latest?api_token=${ApiConstants.apiKey}')
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['status'] == 'success' && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((item) => Forex.fromJson(item)).toList();
        } else {
          throw Exception('API returned error: ${jsonResponse['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to load forex rates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching forex rates: $e');
      return []; // Return empty list instead of throwing
    }
  }
  
  // Search stocks
  Future<List<Stock>> searchStocks(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }
      
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/entity/search?query=$query&api_token=${ApiConstants.apiKey}')
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['status'] == 'success' && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          
          // Convert search results to Stock objects
          return data.map((item) => Stock(
            symbol: item['symbol'] ?? '',
            name: item['name'] ?? '',
            price: 0.0, // Price not available in search results
            change: 0.0,
            percentChange: 0.0,
            volume: 0,
            currency: 'USD',
            exchange: item['exchange'] ?? '',
            lastUpdated: DateTime.now(),
          )).toList();
        } else {
          throw Exception('API returned error: ${jsonResponse['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to search stocks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching stocks: $e');
      return []; // Return empty list instead of throwing
    }
  }
}
