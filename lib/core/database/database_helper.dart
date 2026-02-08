import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/logger.dart';

/// SQLite database helper for local caching

class DatabaseHelper {
  static const String _databaseName = 'autogram.db';
  static const int _databaseVersion = 1;

  static Database? _database;

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    AppLogger.info('Initializing database at: $path');

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    AppLogger.info('Creating database tables...');

    // Users cache table
    await db.execute('''
      CREATE TABLE cached_users (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Listings cache table
    await db.execute('''
      CREATE TABLE cached_listings (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Categories cache table
    await db.execute('''
      CREATE TABLE cached_categories (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Brands cache table
    await db.execute('''
      CREATE TABLE cached_brands (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Search history table
    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL UNIQUE,
        category TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // Saved listings (offline access)
    await db.execute('''
      CREATE TABLE saved_listings (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        saved_at INTEGER NOT NULL
      )
    ''');

    // Draft listings (offline creation)
    await db.execute('''
      CREATE TABLE draft_listings (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // General cache table for key-value storage
    await db.execute('''
      CREATE TABLE cache (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        expires_at INTEGER NOT NULL
      )
    ''');

    AppLogger.info('Database tables created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.info('Upgrading database from $oldVersion to $newVersion');
    // Handle migrations here
  }

  // Generic cache operations
  Future<void> setCache(String key, String value, Duration duration) async {
    final db = await database;
    final expiresAt =
        DateTime.now().add(duration).millisecondsSinceEpoch;

    await db.insert(
      'cache',
      {
        'key': key,
        'value': value,
        'expires_at': expiresAt,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getCache(String key) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final result = await db.query(
      'cache',
      where: 'key = ? AND expires_at > ?',
      whereArgs: [key, now],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first['value'] as String;
  }

  Future<void> deleteCache(String key) async {
    final db = await database;
    await db.delete('cache', where: 'key = ?', whereArgs: [key]);
  }

  Future<void> clearExpiredCache() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.delete('cache', where: 'expires_at < ?', whereArgs: [now]);
  }

  Future<void> clearAllCache() async {
    final db = await database;
    await db.delete('cache');
    await db.delete('cached_users');
    await db.delete('cached_listings');
    await db.delete('cached_categories');
    await db.delete('cached_brands');
  }

  // Search history operations
  Future<void> addSearchHistory(String query, {String? category}) async {
    final db = await database;
    await db.insert(
      'search_history',
      {
        'query': query,
        'category': category,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<String>> getSearchHistory({int limit = 10}) async {
    final db = await database;
    final result = await db.query(
      'search_history',
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return result.map((row) => row['query'] as String).toList();
  }

  Future<void> clearSearchHistory() async {
    final db = await database;
    await db.delete('search_history');
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
