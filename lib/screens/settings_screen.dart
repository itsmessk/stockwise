import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/preferences_service.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../widgets/loading_indicator.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PreferencesService _preferencesService = PreferencesService();
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  
  UserPreferences _preferences = UserPreferences();
  bool _isLoading = true;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load preferences from SharedPreferences
      _preferences = await _preferencesService.getUserPreferences();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading preferences: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading preferences. Using defaults.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  Future<void> _savePreferences() async {
    setState(() {
      _isSaving = true;
    });
    
    try {
      // Save to SharedPreferences
      await _preferencesService.saveUserPreferences(_preferences);
      
      // Save to Firestore if user is logged in
      try {
        await _databaseService.updateUserPreferences(_preferences);
      } catch (e) {
        print('Error saving to Firestore: $e');
      }
      
      setState(() {
        _isSaving = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error saving preferences: $e');
      setState(() {
        _isSaving = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving settings. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('Error signing out: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error signing out. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  Future<void> _clearWeatherHistory() async {
    try {
      await _databaseService.clearWeatherHistory();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weather history cleared'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error clearing weather history: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error clearing weather history. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading settings...')
          : _buildSettingsContent(),
    );
  }
  
  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Display Settings'),
          _buildDarkModeSwitch(),
          const Divider(),
          
          _buildSectionTitle('Units'),
          _buildTemperatureUnitSelector(),
          const SizedBox(height: 16),
          _buildWindSpeedUnitSelector(),
          const Divider(),
          
          _buildSectionTitle('Forecast Settings'),
          _buildForecastDaysSelector(),
          const Divider(),
          
          _buildSectionTitle('Notifications'),
          _buildNotificationsSwitch(),
          const Divider(),
          
          _buildSectionTitle('Account'),
          _buildAccountActions(),
          const Divider(),
          
          _buildSectionTitle('Data'),
          _buildDataActions(),
          const SizedBox(height: 32),
          
          _buildSaveButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
  
  Widget _buildDarkModeSwitch() {
    return SwitchListTile(
      title: const Text('Dark Mode'),
      subtitle: const Text('Use dark theme'),
      value: _preferences.darkMode,
      onChanged: (value) {
        setState(() {
          _preferences = _preferences.copyWith(darkMode: value);
        });
      },
    );
  }
  
  Widget _buildTemperatureUnitSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Temperature Unit'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Celsius (°C)'),
                value: 'celsius',
                groupValue: _preferences.temperatureUnit,
                onChanged: (value) {
                  setState(() {
                    _preferences = _preferences.copyWith(temperatureUnit: value);
                  });
                },
                dense: true,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Fahrenheit (°F)'),
                value: 'fahrenheit',
                groupValue: _preferences.temperatureUnit,
                onChanged: (value) {
                  setState(() {
                    _preferences = _preferences.copyWith(temperatureUnit: value);
                  });
                },
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildWindSpeedUnitSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Wind Speed Unit'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('km/h'),
                value: 'kph',
                groupValue: _preferences.windSpeedUnit,
                onChanged: (value) {
                  setState(() {
                    _preferences = _preferences.copyWith(windSpeedUnit: value);
                  });
                },
                dense: true,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('mph'),
                value: 'mph',
                groupValue: _preferences.windSpeedUnit,
                onChanged: (value) {
                  setState(() {
                    _preferences = _preferences.copyWith(windSpeedUnit: value);
                  });
                },
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildForecastDaysSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Forecast Days'),
        const SizedBox(height: 8),
        Slider(
          value: _preferences.forecastDays.toDouble(),
          min: 1,
          max: 7,
          divisions: 6,
          label: _preferences.forecastDays.toString(),
          onChanged: (value) {
            setState(() {
              _preferences = _preferences.copyWith(forecastDays: value.toInt());
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('1 day'),
            Text('${_preferences.forecastDays} days'),
            const Text('7 days'),
          ],
        ),
      ],
    );
  }
  
  Widget _buildNotificationsSwitch() {
    return SwitchListTile(
      title: const Text('Weather Alerts'),
      subtitle: const Text('Receive notifications about severe weather'),
      value: _preferences.notificationsEnabled,
      onChanged: (value) {
        setState(() {
          _preferences = _preferences.copyWith(notificationsEnabled: value);
        });
      },
    );
  }
  
  Widget _buildAccountActions() {
    return Column(
      children: [
        ListTile(
          title: const Text('Sign Out'),
          leading: const Icon(Icons.logout),
          onTap: _signOut,
        ),
      ],
    );
  }
  
  Widget _buildDataActions() {
    return Column(
      children: [
        ListTile(
          title: const Text('Clear Weather History'),
          subtitle: const Text('Delete all saved weather history'),
          leading: const Icon(Icons.delete),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Clear Weather History'),
                content: const Text('Are you sure you want to clear your weather history? This action cannot be undone.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _clearWeatherHistory();
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _savePreferences,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save Settings'),
        ),
      ),
    );
  }
}
