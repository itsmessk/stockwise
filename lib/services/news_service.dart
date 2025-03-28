import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/news_model.dart';

class NewsService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  late final String _apiKey;

  NewsService() {
    _apiKey = dotenv.env['NEWS_API_KEY'] ?? 'demo_api_key';
  }

  Future<NewsResponse> getWeatherNews() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/everything?q=weather&sortBy=publishedAt&language=en&apiKey=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NewsResponse.fromJson(data);
      } else {
        throw Exception('Failed to load news data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news data: $e');
    }
  }

  Future<NewsResponse> getLocationWeatherNews(String location) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/everything?q=$location+weather&sortBy=publishedAt&language=en&apiKey=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NewsResponse.fromJson(data);
      } else {
        throw Exception('Failed to load location news data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching location news data: $e');
    }
  }

  Future<NewsResponse> getWeatherAlerts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/everything?q=weather+alert+warning&sortBy=publishedAt&language=en&apiKey=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NewsResponse.fromJson(data);
      } else {
        throw Exception('Failed to load weather alerts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather alerts: $e');
    }
  }
}
