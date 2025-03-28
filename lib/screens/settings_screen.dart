import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockwise/services/theme_service.dart';
import 'package:stockwise/services/preferences_service.dart';
import 'package:stockwise/constants/theme_constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:stockwise/services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PreferencesService _preferencesService = PreferencesService();
  final ApiService _apiService = ApiService();
  
  bool _isLoading = true;
  bool _isDarkMode = false;
  String _defaultCurrency = 'USD';
  String _apiKey = '';
  
  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final prefs = await _preferencesService.getUserPreferences();
      
      // Get API key from .env or ApiService
      String apiKey = '';
      try {
        apiKey = _apiService.getApiKey();
      } catch (e) {
        print('Error getting API key: $e');
        apiKey = 'demo';
      }
      
      setState(() {
        _isDarkMode = prefs.darkMode;
        _defaultCurrency = prefs.defaultCurrency;
        _apiKey = apiKey;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading preferences: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleTheme() async {
    try {
      final newValue = !_isDarkMode;
      await _preferencesService.updateDarkMode(newValue);
      
      // Update theme service
      final themeService = Provider.of<ThemeService>(context, listen: false);
      await themeService.setThemeMode(newValue ? ThemeMode.dark : ThemeMode.light);
      
      setState(() {
        _isDarkMode = newValue;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Theme updated to ${newValue ? 'dark' : 'light'} mode')),
      );
    } catch (e) {
      print('Error toggling theme: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update theme: $e')),
      );
    }
  }

  Future<void> _updateCurrency(String currency) async {
    try {
      await _preferencesService.updateCurrency(currency);
      setState(() {
        _defaultCurrency = currency;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Default currency updated to $currency')),
      );
    } catch (e) {
      print('Error updating currency: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update currency: $e')),
      );
    }
  }

  Future<void> _updateApiKey(String apiKey) async {
    try {
      // Save to .env file or a secure storage
      // This is a simplified implementation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API key update functionality is not implemented yet'),
          duration: Duration(seconds: 3),
        ),
      );
      
      setState(() {
        _apiKey = apiKey;
      });
    } catch (e) {
      print('Error updating API key: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update API key: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: SpinKitCircle(
            color: theme.primaryColor,
            size: 50.0,
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme settings
          Card(
            elevation: 2.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16.0),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: Text(_isDarkMode ? 'On' : 'Off'),
                    value: _isDarkMode,
                    onChanged: (value) => _toggleTheme(),
                    secondary: Icon(
                      _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16.0),
          
          // Currency settings
          Card(
            elevation: 2.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Currency',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Default Currency',
                      border: OutlineInputBorder(),
                    ),
                    value: _defaultCurrency,
                    onChanged: (value) {
                      if (value != null) {
                        _updateCurrency(value);
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 'USD', child: Text('USD - US Dollar')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
                      DropdownMenuItem(value: 'GBP', child: Text('GBP - British Pound')),
                      DropdownMenuItem(value: 'JPY', child: Text('JPY - Japanese Yen')),
                      DropdownMenuItem(value: 'CAD', child: Text('CAD - Canadian Dollar')),
                      DropdownMenuItem(value: 'AUD', child: Text('AUD - Australian Dollar')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16.0),
          
          // API settings
          Card(
            elevation: 2.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'API Settings',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    initialValue: _apiKey,
                    decoration: const InputDecoration(
                      labelText: 'Alpha Vantage API Key',
                      hintText: 'Enter your API key',
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (value) {
                      _updateApiKey(value);
                    },
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Get a free API key at alphavantage.co',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16.0),
          
          // About section
          Card(
            elevation: 2.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16.0),
                  ListTile(
                    title: const Text('Version'),
                    subtitle: const Text('1.0.0'),
                    leading: Icon(Icons.info_outline, color: theme.primaryColor),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Terms of Service'),
                    leading: Icon(Icons.description, color: theme.primaryColor),
                    onTap: () {
                      // Navigate to terms of service
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Privacy Policy'),
                    leading: Icon(Icons.privacy_tip, color: theme.primaryColor),
                    onTap: () {
                      // Navigate to privacy policy
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
