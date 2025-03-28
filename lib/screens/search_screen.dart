import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../services/preferences_service.dart';
import '../widgets/loading_indicator.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final WeatherService _weatherService = WeatherService();
  final PreferencesService _preferencesService = PreferencesService();
  final TextEditingController _searchController = TextEditingController();
  
  List<String> _searchResults = [];
  bool _isLoading = false;
  bool _isError = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _loadRecentLocation();
  }
  
  Future<void> _loadRecentLocation() async {
    try {
      final lastLocation = await _preferencesService.getLastLocation();
      if (lastLocation != null && lastLocation.isNotEmpty) {
        _searchController.text = lastLocation;
        await _searchLocation();
      }
    } catch (e) {
      print('Error loading recent location: $e');
    }
  }
  
  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _isError = false;
    });
    
    try {
      final results = await _weatherService.searchLocation(query);
      
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print('Error searching location: $e');
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = 'Error searching location. Please try again.';
      });
    }
  }
  
  Future<void> _selectLocation(String location) async {
    try {
      await _preferencesService.saveLastLocation(location);
      
      if (mounted) {
        Navigator.pop(context, location);
      }
    } catch (e) {
      print('Error saving location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving location. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Location'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a city',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchResults = [];
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
              onChanged: (value) {
                if (value.length > 2) {
                  _searchLocation();
                }
              },
              onSubmitted: (value) {
                _searchLocation();
              },
              textInputAction: TextInputAction.search,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const LoadingIndicator(message: 'Searching locations...')
                : _isError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage,
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _searchLocation,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      )
                    : _searchResults.isEmpty
                        ? Center(
                            child: Text(
                              _searchController.text.isEmpty
                                  ? 'Search for a city to see weather'
                                  : 'No results found',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          )
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final location = _searchResults[index];
                              return ListTile(
                                title: Text(location),
                                leading: const Icon(Icons.location_on),
                                onTap: () => _selectLocation(location),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
