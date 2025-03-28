import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/weather_service.dart';
import '../services/preferences_service.dart';
import '../models/weather_model.dart';
import '../widgets/favorite_location_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final WeatherService _weatherService = WeatherService();
  final PreferencesService _preferencesService = PreferencesService();
  
  List<String> _favoriteLocations = [];
  Map<String, Weather> _weatherData = {};
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }
  
  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });
    
    try {
      // Get favorite locations from Firestore
      _favoriteLocations = await _databaseService.getFavoriteLocations();
      
      // Get weather data for each location
      _weatherData = {};
      for (var location in _favoriteLocations) {
        try {
          final weather = await _weatherService.getCurrentWeather(location);
          _weatherData[location] = weather;
        } catch (e) {
          print('Error getting weather for $location: $e');
        }
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading favorites: $e');
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = 'Error loading favorites. Please try again.';
      });
    }
  }
  
  Future<void> _removeFromFavorites(String location) async {
    try {
      await _databaseService.removeFavoriteLocation(location);
      
      setState(() {
        _favoriteLocations.remove(location);
        _weatherData.remove(location);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$location removed from favorites'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              try {
                await _databaseService.addFavoriteLocation(location);
                await _loadFavorites();
              } catch (e) {
                print('Error undoing remove favorite: $e');
              }
            },
          ),
        ),
      );
    } catch (e) {
      print('Error removing from favorites: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error removing from favorites. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  Future<void> _selectLocation(String location) async {
    try {
      await _preferencesService.saveLastLocation(location);
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      print('Error saving location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error selecting location. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Locations'),
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading favorite locations...')
          : _isError
              ? ErrorMessage(
                  message: _errorMessage,
                  onRetry: _loadFavorites,
                )
              : _buildFavoritesContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/search'),
        tooltip: 'Add location',
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildFavoritesContent() {
    if (_favoriteLocations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No favorite locations yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add locations to your favorites to see them here',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/search'),
              icon: const Icon(Icons.add),
              label: const Text('Add Location'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _favoriteLocations.length,
        itemBuilder: (context, index) {
          final location = _favoriteLocations[index];
          final weather = _weatherData[location];
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: FavoriteLocationCard(
              location: location,
              weather: weather,
              onTap: () => _selectLocation(location),
              onRemove: () => _removeFromFavorites(location),
            ),
          );
        },
      ),
    );
  }
}
