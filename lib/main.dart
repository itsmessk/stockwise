import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:stockwise/firebase_options.dart';
import 'package:stockwise/screens/home_screen.dart';
import 'package:stockwise/screens/search_screen.dart';
import 'package:stockwise/screens/portfolio_screen.dart';
import 'package:stockwise/screens/profile_screen.dart';
import 'package:stockwise/screens/login_screen.dart';
import 'package:stockwise/screens/register_screen.dart';
import 'package:stockwise/screens/splash_screen.dart';
import 'package:stockwise/screens/stock_details_screen.dart';
import 'package:stockwise/screens/news_details_screen.dart';
import 'package:stockwise/services/auth_service.dart';
import 'package:stockwise/services/theme_service.dart';
import 'package:stockwise/services/preferences_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeService _themeService = ThemeService();
  final PreferencesService _preferencesService = PreferencesService();
  final AuthService _authService = AuthService();
  
  bool _isDarkMode = false;
  bool _isLoading = true;
  bool _isInitialLaunch = true;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _checkInitialLaunch();
  }

  Future<void> _loadThemePreference() async {
    try {
      final preferences = await _preferencesService.getUserPreferences();
      setState(() {
        _isDarkMode = preferences.darkMode;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkInitialLaunch() async {
    try {
      final preferences = await _preferencesService.getUserPreferences();
      setState(() {
        _isInitialLaunch = preferences.isFirstLaunch;
      });
      
      if (_isInitialLaunch) {
        // Update first launch preference
        await _preferencesService.updateFirstLaunch(false);
      }
    } catch (e) {
      // Default to true if there's an error
      setState(() {
        _isInitialLaunch = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return StreamProvider<User?>.value(
      value: _authService.authStateChanges,
      initialData: null,
      child: MaterialApp(
        title: 'StockWise',
        debugShowCheckedModeBanner: false,
        theme: _themeService.getLightTheme(),
        darkTheme: _themeService.getDarkTheme(),
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'), // English
          Locale('es', 'ES'), // Spanish
          Locale('fr', 'FR'), // French
          Locale('de', 'DE'), // German
          Locale('ja', 'JP'), // Japanese
          Locale('zh', 'CN'), // Chinese
        ],
        initialRoute: _isInitialLaunch ? '/splash' : '/',
        routes: {
          '/': (context) => AuthWrapper(),
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/search': (context) => const SearchScreen(),
          '/portfolio': (context) => const PortfolioScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
        // Use onGenerateRoute for screens that require parameters
        onGenerateRoute: (settings) {
          if (settings.name == '/stock_details') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => StockDetailsScreen(
                symbol: args['symbol'],
              ),
            );
          } else if (settings.name == '/news_details') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => NewsDetailsScreen(
                news: args['news'],
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    
    // Return login if not authenticated, otherwise return main app
    if (user == null) {
      return const LoginScreen();
    }
    
    return const MainScreen();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const PortfolioScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
