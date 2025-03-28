import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stockwise/services/auth_service.dart';
import 'package:stockwise/services/database_service.dart';
import 'package:stockwise/services/theme_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  
  bool _isLoading = false;
  String _errorMessage = '';
  
  bool _isDarkMode = false;
  String _defaultCurrency = 'USD';
  
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
      
      final prefs = await _databaseService.getUserPreferences();
      
      setState(() {
        _isDarkMode = prefs['darkMode'] ?? false;
        _defaultCurrency = prefs['defaultCurrency'] ?? 'USD';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserPreferences() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      await _databaseService.saveUserPreferences(
        darkMode: _isDarkMode,
        defaultCurrency: _defaultCurrency,
      );
      
      // Update theme
      final themeService = Provider.of<ThemeService>(context, listen: false);
      await themeService.setThemeMode(_isDarkMode ? ThemeMode.dark : ThemeMode.light);
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferences saved'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save preferences: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      await _authService.signOut();
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign out: $e';
        _isLoading = false;
      });
    }
  }

  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _authService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitWave(
                    color: theme.colorScheme.primary,
                    size: 50.0,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Loading profile...',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error message
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.error.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  
                  // User profile card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Profile picture
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            backgroundImage: user?.photoURL != null
                                ? NetworkImage(user!.photoURL!)
                                : null,
                            child: user?.photoURL == null
                                ? Icon(
                                    Icons.person,
                                    size: 40,
                                    color: theme.colorScheme.primary,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          
                          // User name
                          Text(
                            user?.displayName ?? 'User',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // User email
                          Text(
                            user?.email ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onBackground.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Edit profile button
                          OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Implement edit profile functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Edit profile functionality coming soon'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Profile'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Settings section
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Advanced settings
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: const Text('Advanced Settings'),
                      subtitle: Text(
                        'API keys, preferences, and more',
                        style: TextStyle(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                      leading: Icon(
                        Icons.settings,
                        color: theme.colorScheme.primary,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Theme setting
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      title: const Text('Dark Mode'),
                      subtitle: Text(
                        'Switch between light and dark themes',
                        style: TextStyle(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                      secondary: Icon(
                        _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: _isDarkMode
                            ? Colors.amber
                            : theme.colorScheme.primary,
                      ),
                      value: _isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          _isDarkMode = value;
                        });
                        _saveUserPreferences();
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Currency setting
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: const Text('Default Currency'),
                      subtitle: Text(
                        'Set your preferred currency',
                        style: TextStyle(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                      leading: const Icon(Icons.attach_money),
                      trailing: DropdownButton<String>(
                        value: _defaultCurrency,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _defaultCurrency = value;
                            });
                            _saveUserPreferences();
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'USD',
                            child: Text('USD (\$)'),
                          ),
                          DropdownMenuItem(
                            value: 'EUR',
                            child: Text('EUR (€)'),
                          ),
                          DropdownMenuItem(
                            value: 'GBP',
                            child: Text('GBP (£)'),
                          ),
                          DropdownMenuItem(
                            value: 'JPY',
                            child: Text('JPY (¥)'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Account section
                  Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Change password
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: const Text('Change Password'),
                      subtitle: Text(
                        'Update your account password',
                        style: TextStyle(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                      leading: const Icon(Icons.lock),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Implement change password functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Change password functionality coming soon'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Sign out
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: const Text('Sign Out'),
                      subtitle: Text(
                        'Sign out of your account',
                        style: TextStyle(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                      leading: const Icon(Icons.logout),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showSignOutConfirmation,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // About section
                  Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // App info
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: const Text('About StockWise'),
                      subtitle: Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                      leading: const Icon(Icons.info),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'StockWise',
                          applicationVersion: '1.0.0',
                          applicationIcon: Icon(
                            Icons.show_chart,
                            color: theme.colorScheme.primary,
                            size: 48,
                          ),
                          applicationLegalese: ' 2025 StockWise',
                          children: [
                            const SizedBox(height: 16),
                            const Text(
                              'StockWise is your personal stock market companion. Track your favorite stocks, get real-time market data, and stay informed with the latest financial news.',
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
