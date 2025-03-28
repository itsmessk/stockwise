import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../models/user_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../services/preferences_service.dart';
import '../services/database_service.dart';
import '../utils/weather_utils.dart';
import '../utils/date_utils.dart';
import '../constants/theme_constants.dart';
import '../widgets/weather_card.dart';
import '../widgets/forecast_card.dart';
import '../widgets/hourly_forecast_list.dart';
import '../widgets/weather_details_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  final PreferencesService _preferencesService = PreferencesService();
  final DatabaseService _databaseService = DatabaseService();
  
  Weather? _currentWeather;
  WeatherForecast? _forecast;
  String _currentLocation = '';
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';
  UserPreferences _preferences = UserPreferences();
  bool _isFavorite = false;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });
    
    try {
      // Load user preferences
      _preferences = await _preferencesService.getUserPreferences();
      
      // Get last location from preferences
      String? lastLocation = await _preferencesService.getLastLocation();
      
      // Try to get current location if no last location
      if (lastLocation == null || lastLocation.isEmpty) {
        try {
          final position = await _locationService.getCurrentLocation();
          _currentLocation = '${position.latitude},${position.longitude}';
        } catch (e) {
          print('Error getting current location: $e');
          // Use default location if can't get current location
          _currentLocation = 'London';
        }
      } else {
        _currentLocation = lastLocation;
      }
      
      // Save current location to preferences
      await _preferencesService.saveLastLocation(_currentLocation);
      
      // Get current weather
      _currentWeather = await _weatherService.getCurrentWeather(_currentLocation);
      
      // Get forecast
      _forecast = await _weatherService.getForecast(
        _currentLocation, 
        _preferences.forecastDays,
      );
      
      // Check if location is in favorites
      try {
        final favorites = await _databaseService.getFavoriteLocations();
        _isFavorite = favorites.contains(_currentWeather!.location);
      } catch (e) {
        print('Error checking favorites: $e');
      }
      
      // Save to history in Firestore
      try {
        await _databaseService.saveWeatherToHistory(_currentWeather!);
      } catch (e) {
        print('Error saving to history: $e');
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = 'Error loading weather data. Please try again.';
      });
    }
  }
  
  Future<void> _toggleFavorite() async {
    if (_currentWeather == null) return;
    
    try {
      if (_isFavorite) {
        await _databaseService.removeFavoriteLocation(_currentWeather!.location);
      } else {
        await _databaseService.addFavoriteLocation(_currentWeather!.location);
      }
      
      setState(() {
        _isFavorite = !_isFavorite;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite 
            ? '${_currentWeather!.location} added to favorites' 
            : '${_currentWeather!.location} removed from favorites'
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error toggling favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating favorites. Please try again.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading 
        ? const LoadingIndicator(message: 'Loading weather data...')
        : _isError
          ? ErrorMessage(
              message: _errorMessage,
              onRetry: _loadData,
            )
          : _buildWeatherContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
  
  Widget _buildWeatherContent() {
    if (_currentWeather == null || _forecast == null) {
      return const Center(
        child: Text('No weather data available'),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WeatherCard(
                    weather: _currentWeather!,
                    preferences: _preferences,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hourly Forecast',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  HourlyForecastList(
                    hourlyForecast: _forecast!.hourlyForecast,
                    preferences: _preferences,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_preferences.forecastDays}-Day Forecast',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ..._forecast!.dailyForecast.map((forecast) => 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ForecastCard(
                        forecast: forecast,
                        preferences: _preferences,
                      ),
                    ),
                  ).toList(),
                  const SizedBox(height: 16),
                  Text(
                    'Weather Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  WeatherDetailsCard(
                    weather: _currentWeather!,
                    preferences: _preferences,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Weather Advice',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            WeatherUtils.getWeatherDescription(
                              _currentWeather!.condition, 
                              _currentWeather!.temperature,
                            ),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            WeatherUtils.getClothingRecommendation(
                              _currentWeather!.condition, 
                              _currentWeather!.temperature,
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            WeatherUtils.getActivityRecommendation(
                              _currentWeather!.condition, 
                              _currentWeather!.temperature,
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _currentWeather?.location ?? 'Weather',
          style: const TextStyle(color: Colors.white),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _currentWeather?.isDay ?? true
                ? ThemeConstants.dayGradient
                : ThemeConstants.nightGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      actions: [
        if (_currentWeather != null)
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: _toggleFavorite,
            tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
          ),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/search'),
          tooltip: 'Search location',
        ),
      ],
    );
  }
}
