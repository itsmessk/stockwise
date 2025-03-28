import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockWise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StockWise'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.show_chart,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to StockWise',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your personal stock market companion',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                // Will implement search functionality later
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Search functionality coming soon!'),
                  ),
                );
              },
              child: const Text('Search Stocks'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Will implement API key setup later
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please set your API key in the .env file'),
                  ),
                );
              },
              child: const Text('Set API Key'),
            ),
          ],
        ),
      ),
    );
  }
}
