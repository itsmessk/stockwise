import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.weatherapi.com/v1';
  late final String _apiKey;

  WeatherService() {
    _apiKey = dotenv.env['WEATHER_API_KEY'] ?? 'demo_api_key';
  }

  Future<Weather> getCurrentWeather(String location) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/current.json?key=$_apiKey&q=$location&aqi=no'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Weather.fromJson(data);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather data: $e');
    }
  }

  Future<WeatherForecast> getForecast(String location, int days) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/forecast.json?key=$_apiKey&q=$location&days=$days&aqi=no&alerts=yes'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherForecast.fromJson(data);
      } else {
        throw Exception('Failed to load forecast data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching forecast data: $e');
    }
  }

  Future<List<String>> searchLocation(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/search.json?key=$_apiKey&q=$query'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((location) => '${location['name']}, ${location['country']}').toList();
      } else {
        throw Exception('Failed to search locations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching locations: $e');
    }
  }
}
