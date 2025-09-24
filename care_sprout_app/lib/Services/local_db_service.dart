import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDBService {
  static Database? _database;

  static Future<void> init() async {
    if (_database != null) return;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'caresprout_progress.db');
    _database =
        await openDatabase(path, version: 2, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE progress (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT NOT NULL,
          category TEXT NOT NULL,
          unlockedLevel INTEGER NOT NULL,
          UNIQUE(userId, category)
        )
      ''');

      // Lock animations table
      await db.execute('''
          CREATE TABLE lock_animations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId TEXT NOT NULL,
            category TEXT NOT NULL,
            level INTEGER NOT NULL,
            UNIQUE(userId, category, level)
          )
        ''');
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS lock_animations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId TEXT NOT NULL,
            category TEXT NOT NULL,
            level INTEGER NOT NULL,
            UNIQUE(userId, category, level)
          )
        ''');
      }
    });
  }

  static Future<int> getUnlockedLevel(String userId, String category) async {
    if (_database == null) throw Exception('Database not initialized');
    final rows = await _database!.query(
      'progress',
      columns: ['unlockedLevel'],
      where: 'userId = ? AND category = ?',
      whereArgs: [userId, category],
      limit: 1,
    );
    if (rows.isEmpty) return 1;
    return rows.first['unlockedLevel'] as int;
  }

  static Future<void> setUnlockedLevel(
      String userId, String category, int level) async {
    if (_database == null) throw Exception('Database not initialized');

    final existing = await _database!.query(
      'progress',
      columns: ['unlockedLevel'],
      where: 'userId = ? AND category = ?',
      whereArgs: [userId, category],
      limit: 1,
    );
    final current =
        existing.isNotEmpty ? (existing.first['unlockedLevel'] as int) : 1;
    final next = level > current ? level : current;

    await _database!.insert(
      'progress',
      {'userId': userId, 'category': category, 'unlockedLevel': next},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Lock animation check
  static Future<bool> getLockAnimationPlayed(
      String userId, String category, int level) async {
    if (_database == null) throw Exception('Database not initialized');
    final rows = await _database!.query(
      'lock_animations',
      where: 'userId = ? AND category = ? AND level = ?',
      whereArgs: [userId, category, level],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  // Mark lock animation as played
  static Future<void> setLockAnimationPlayed(
      String userId, String category, int level) async {
    if (_database == null) throw Exception('Database not initialized');
    await _database!.insert(
      'lock_animations',
      {'userId': userId, 'category': category, 'level': level},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  //Reset
  static Future<void> resetAll(String userId) async {
    if (_database == null) throw Exception('Database not initialized');
    await _database!.delete(
      'progress',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // Reset lock animations
  static Future<void> resetLockAnimations(String userId) async {
    if (_database == null) throw Exception('Database not initialized');
    await _database!.delete(
      'lock_animations',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }
}
