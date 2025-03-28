import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:stockwise/models/stock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user is logged in
  bool get isUserLoggedIn => _auth.currentUser != null;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'stockwise.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create stock history table for offline access
    await db.execute('''
      CREATE TABLE stock_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT,
        price REAL,
        change REAL,
        percent_change REAL,
        volume INTEGER,
        currency TEXT,
        exchange TEXT,
        last_updated TIMESTAMP,
        UNIQUE(symbol, last_updated)
      )
    ''');
  }

  // Firestore Watchlist Operations
  Future<void> addToWatchlist(String symbol, String name) async {
    try {
      if (!isUserLoggedIn) {
        // If user is not logged in, store in local database
        await _addToLocalWatchlist(symbol, name);
        return;
      }

      // Add to Firestore
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('watchlist')
          .doc(symbol)
          .set({
        'symbol': symbol,
        'name': name,
        'added_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding to watchlist: $e');
      // Fallback to local storage if Firestore fails
      await _addToLocalWatchlist(symbol, name);
    }
  }

  Future<void> removeFromWatchlist(String symbol) async {
    try {
      if (!isUserLoggedIn) {
        // If user is not logged in, remove from local database
        await _removeFromLocalWatchlist(symbol);
        return;
      }

      // Remove from Firestore
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('watchlist')
          .doc(symbol)
          .delete();
    } catch (e) {
      print('Error removing from watchlist: $e');
      // Fallback to local storage if Firestore fails
      await _removeFromLocalWatchlist(symbol);
    }
  }

  Future<bool> isInWatchlist(String symbol) async {
    try {
      if (!isUserLoggedIn) {
        // If user is not logged in, check local database
        return await _isInLocalWatchlist(symbol);
      }

      // Check Firestore
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('watchlist')
          .doc(symbol)
          .get();
          
      return doc.exists;
    } catch (e) {
      print('Error checking watchlist: $e');
      // Fallback to local storage if Firestore fails
      return await _isInLocalWatchlist(symbol);
    }
  }

  Future<List<Map<String, dynamic>>> getWatchlist() async {
    try {
      if (!isUserLoggedIn) {
        // If user is not logged in, get from local database
        return await _getLocalWatchlist();
      }

      // Get from Firestore
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('watchlist')
          .orderBy('added_at', descending: true)
          .get();
          
      return snapshot.docs.map((doc) => {
        'symbol': doc.data()['symbol'] as String,
        'name': doc.data()['name'] as String,
        'added_at': doc.data()['added_at'] ?? Timestamp.now(),
      }).toList();
    } catch (e) {
      print('Error getting watchlist: $e');
      // Fallback to local storage if Firestore fails
      return await _getLocalWatchlist();
    }
  }

  // Sync local watchlist with Firestore when user logs in
  Future<void> syncWatchlistToFirestore() async {
    if (!isUserLoggedIn) return;

    try {
      // Get local watchlist
      final localWatchlist = await _getLocalWatchlist();
      
      // Add each item to Firestore
      for (var item in localWatchlist) {
        await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('watchlist')
            .doc(item['symbol'] as String)
            .set({
          'symbol': item['symbol'],
          'name': item['name'],
          'added_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error syncing watchlist to Firestore: $e');
    }
  }

  // New method to sync local watchlist to Firestore
  Future<void> syncWatchlistToFirestore() async {
    if (!isUserLoggedIn) return;
    
    try {
      final localWatchlist = await _getLocalWatchlist();
      
      // Skip if local watchlist is empty
      if (localWatchlist.isEmpty) return;
      
      // Get batch for efficient writes
      final batch = _firestore.batch();
      final userWatchlistRef = _firestore.collection('users').doc(currentUserId).collection('watchlist');
      
      // Add each local watchlist item to Firestore
      for (var item in localWatchlist) {
        final symbol = item['symbol'] as String;
        final name = item['name'] as String;
        
        // Check if already exists in Firestore
        final docSnapshot = await userWatchlistRef.doc(symbol).get();
        if (!docSnapshot.exists) {
          batch.set(userWatchlistRef.doc(symbol), {
            'symbol': symbol,
            'name': name,
            'added_at': FieldValue.serverTimestamp(),
            'synced_from_local': true,
          });
        }
      }
      
      // Commit the batch
      await batch.commit();
      
      print('Successfully synced local watchlist to Firestore');
    } catch (e) {
      print('Error syncing watchlist to Firestore: $e');
    }
  }

  // Local SQLite Watchlist Operations (fallback)
  Future<int> _addToLocalWatchlist(String symbol, String name) async {
    final db = await database;
    
    // Create watchlist table if it doesn't exist
    await db.execute('''
      CREATE TABLE IF NOT EXISTS watchlist(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT UNIQUE,
        name TEXT,
        added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    return await db.insert(
      'watchlist',
      {'symbol': symbol, 'name': name},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> _removeFromLocalWatchlist(String symbol) async {
    final db = await database;
    return await db.delete(
      'watchlist',
      where: 'symbol = ?',
      whereArgs: [symbol],
    );
  }

  Future<bool> _isInLocalWatchlist(String symbol) async {
    final db = await database;
    
    try {
      // Check if watchlist table exists
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='watchlist'"
      );
      
      if (tables.isEmpty) {
        return false;
      }
      
      final result = await db.query(
        'watchlist',
        where: 'symbol = ?',
        whereArgs: [symbol],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking local watchlist: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> _getLocalWatchlist() async {
    final db = await database;
    
    try {
      // Check if watchlist table exists
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='watchlist'"
      );
      
      if (tables.isEmpty) {
        return [];
      }
      
      return await db.query('watchlist', orderBy: 'added_at DESC');
    } catch (e) {
      print('Error getting local watchlist: $e');
      return [];
    }
  }

  // Stock history operations
  Future<int> saveStockData(Stock stock) async {
    final db = await database;
    return await db.insert(
      'stock_history',
      {
        'symbol': stock.symbol,
        'price': stock.price,
        'change': stock.change,
        'percent_change': stock.percentChange,
        'volume': stock.volume,
        'currency': stock.currency,
        'exchange': stock.exchange,
        'last_updated': stock.lastUpdated.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Stock>> getStockHistory(String symbol, {int limit = 30}) async {
    final db = await database;
    final result = await db.query(
      'stock_history',
      where: 'symbol = ?',
      whereArgs: [symbol],
      orderBy: 'last_updated DESC',
      limit: limit,
    );

    return result.map((data) => Stock(
      symbol: data['symbol'] as String,
      name: '', // Name is not stored in history
      price: data['price'] as double,
      change: data['change'] as double,
      percentChange: data['percent_change'] as double,
      volume: data['volume'] as int,
      currency: data['currency'] as String,
      exchange: data['exchange'] as String,
      lastUpdated: DateTime.parse(data['last_updated'] as String),
    )).toList();
  }

  // Clear all data
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('stock_history');
    
    try {
      await db.delete('watchlist');
    } catch (e) {
      print('Error clearing watchlist: $e');
    }
  }
}
