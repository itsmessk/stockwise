import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:stockwise/models/stock.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

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
    // Create watchlist table
    await db.execute('''
      CREATE TABLE watchlist(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT UNIQUE,
        name TEXT,
        added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

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

  // Watchlist operations
  Future<int> addToWatchlist(String symbol, String name) async {
    final db = await database;
    return await db.insert(
      'watchlist',
      {'symbol': symbol, 'name': name},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> removeFromWatchlist(String symbol) async {
    final db = await database;
    return await db.delete(
      'watchlist',
      where: 'symbol = ?',
      whereArgs: [symbol],
    );
  }

  Future<bool> isInWatchlist(String symbol) async {
    final db = await database;
    final result = await db.query(
      'watchlist',
      where: 'symbol = ?',
      whereArgs: [symbol],
    );
    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getWatchlist() async {
    final db = await database;
    return await db.query('watchlist', orderBy: 'added_at DESC');
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
    await db.delete('watchlist');
    await db.delete('stock_history');
  }
}
