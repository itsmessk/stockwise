import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stockwise/models/stock.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;
  
  // Check if user is logged in
  bool get isUserLoggedIn => _auth.currentUser != null;

  // Reference to user's watchlist collection
  CollectionReference<Map<String, dynamic>> get _watchlistCollection {
    if (!isUserLoggedIn) {
      throw Exception('User not logged in');
    }
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('watchlist');
  }

  // Add a stock to watchlist
  Future<void> addToWatchlist(Stock stock) async {
    if (!isUserLoggedIn) {
      throw Exception('User not logged in');
    }

    try {
      await _watchlistCollection.doc(stock.symbol).set({
        'symbol': stock.symbol,
        'name': stock.name,
        'price': stock.price,
        'change': stock.change,
        'changePercent': stock.changePercent,
        'addedAt': FieldValue.serverTimestamp(),
        'lastUpdated': stock.lastUpdated,
      });
    } catch (e) {
      throw Exception('Failed to add stock to watchlist: $e');
    }
  }

  // Remove a stock from watchlist
  Future<void> removeFromWatchlist(String symbol) async {
    if (!isUserLoggedIn) {
      throw Exception('User not logged in');
    }

    try {
      await _watchlistCollection.doc(symbol).delete();
    } catch (e) {
      throw Exception('Failed to remove stock from watchlist: $e');
    }
  }

  // Check if a stock is in the watchlist
  Future<bool> isInWatchlist(String symbol) async {
    if (!isUserLoggedIn) {
      return false;
    }

    try {
      final doc = await _watchlistCollection.doc(symbol).get();
      return doc.exists;
    } catch (e) {
      print('Error checking watchlist: $e');
      return false;
    }
  }

  // Get all stocks in watchlist
  Stream<List<Stock>> getWatchlistStream() {
    if (!isUserLoggedIn) {
      return Stream.value([]);
    }

    return _watchlistCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Stock(
          symbol: data['symbol'] ?? '',
          name: data['name'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          change: (data['change'] ?? 0).toDouble(),
          changePercent: (data['changePercent'] ?? 0).toDouble(),
          high: 0,
          low: 0,
          open: 0,
          previousClose: 0,
          volume: 0,
          lastUpdated: data['lastUpdated'] ?? '',
        );
      }).toList();
    });
  }

  // Get all stocks in watchlist as a future
  Future<List<Stock>> getWatchlist() async {
    if (!isUserLoggedIn) {
      return [];
    }

    try {
      final snapshot = await _watchlistCollection.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Stock(
          symbol: data['symbol'] ?? '',
          name: data['name'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          change: (data['change'] ?? 0).toDouble(),
          changePercent: (data['changePercent'] ?? 0).toDouble(),
          high: 0,
          low: 0,
          open: 0,
          previousClose: 0,
          volume: 0,
          lastUpdated: data['lastUpdated'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error getting watchlist: $e');
      return [];
    }
  }

  // Update stock price in watchlist
  Future<void> updateStockPrice(String symbol, double price, double change, double changePercent, String lastUpdated) async {
    if (!isUserLoggedIn) {
      return;
    }

    try {
      await _watchlistCollection.doc(symbol).update({
        'price': price,
        'change': change,
        'changePercent': changePercent,
        'lastUpdated': lastUpdated,
      });
    } catch (e) {
      print('Error updating stock price: $e');
    }
  }

  // Get user search history
  Future<List<String>> getSearchHistory() async {
    if (!isUserLoggedIn) {
      return [];
    }

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('preferences')
          .doc('searchHistory')
          .get();

      if (!doc.exists) {
        return [];
      }

      final data = doc.data();
      if (data == null || !data.containsKey('history')) {
        return [];
      }

      return List<String>.from(data['history']);
    } catch (e) {
      print('Error getting search history: $e');
      return [];
    }
  }

  // Add to search history
  Future<void> addToSearchHistory(String query) async {
    if (!isUserLoggedIn || query.trim().isEmpty) {
      return;
    }

    try {
      final history = await getSearchHistory();
      
      // Remove if already exists to avoid duplicates
      history.remove(query);
      
      // Add to the beginning
      history.insert(0, query);
      
      // Limit to 10 items
      if (history.length > 10) {
        history.removeLast();
      }

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('preferences')
          .doc('searchHistory')
          .set({
        'history': history,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding to search history: $e');
    }
  }

  // Clear search history
  Future<void> clearSearchHistory() async {
    if (!isUserLoggedIn) {
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('preferences')
          .doc('searchHistory')
          .set({
        'history': [],
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  // Save user preferences
  Future<void> saveUserPreferences({
    required bool darkMode,
    required String defaultCurrency,
  }) async {
    if (!isUserLoggedIn) {
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('preferences')
          .doc('settings')
          .set({
        'darkMode': darkMode,
        'defaultCurrency': defaultCurrency,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving user preferences: $e');
    }
  }

  // Get user preferences
  Future<Map<String, dynamic>> getUserPreferences() async {
    if (!isUserLoggedIn) {
      return {
        'darkMode': false,
        'defaultCurrency': 'USD',
      };
    }

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('preferences')
          .doc('settings')
          .get();

      if (!doc.exists) {
        return {
          'darkMode': false,
          'defaultCurrency': 'USD',
        };
      }

      final data = doc.data();
      return {
        'darkMode': data?['darkMode'] ?? false,
        'defaultCurrency': data?['defaultCurrency'] ?? 'USD',
      };
    } catch (e) {
      print('Error getting user preferences: $e');
      return {
        'darkMode': false,
        'defaultCurrency': 'USD',
      };
    }
  }
}
