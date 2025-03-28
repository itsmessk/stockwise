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
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/data/quote?symbols=${symbols.join(',')}&api_token=${ApiConstants.apiKey}')
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((item) => Stock.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load stock prices: ${response.statusCode}');
    }
  }

  // Fetch historical stock data
  Future<List<HistoricalData>> fetchHistoricalData(String symbol, String dateFrom) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/data/eod?symbols=$symbol&date_from=$dateFrom&api_token=${ApiConstants.apiKey}')
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((item) => HistoricalData.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load historical data: ${response.statusCode}');
    }
  }

  // Fetch company profile
  Future<CompanyProfile> fetchCompanyProfile(String symbol) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/entity/profile?symbols=$symbol&api_token=${ApiConstants.apiKey}')
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      if (data.isNotEmpty) {
        return CompanyProfile.fromJson(data[0]);
      } else {
        throw Exception('No company profile found for $symbol');
      }
    } else {
      throw Exception('Failed to load company profile: ${response.statusCode}');
    }
  }

  // Fetch market news
  Future<List<News>> fetchMarketNews() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/news/all?api_token=${ApiConstants.apiKey}')
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((item) => News.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load market news: ${response.statusCode}');
    }
  }

  // Fetch forex rates
  Future<List<Forex>> fetchForexRates() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/data/forex/latest?api_token=${ApiConstants.apiKey}')
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((item) => Forex.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load forex rates: ${response.statusCode}');
    }
  }
}
