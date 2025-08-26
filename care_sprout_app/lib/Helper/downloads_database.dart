import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DownloadsDatabase {
  static final DownloadsDatabase instance = DownloadsDatabase._init();
  static Database? _database;

  DownloadsDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('downloads.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 7,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE lessons RENAME COLUMN title TO name;');
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE lessons ADD COLUMN createdAt INTEGER;');
      await db
          .execute('UPDATE lessons SET createdAt = ? WHERE createdAt IS NULL', [
        DateTime.now().millisecondsSinceEpoch,
      ]);
    }
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE posts ADD COLUMN name TEXT;');
    }
    if (oldVersion < 7) {
      await db.execute('ALTER TABLE posts ADD COLUMN createdAt INTEGER;');
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE downloads (
        id $idType,
        name $textType,
        url $textType,
        localPath $textType
        )
      ''');

    await db.execute('''
      CREATE TABLE lessons (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color TEXT,
        createdBy TEXT,
        createdAt $integerType
      )
    ''');

    await db.execute('''
      CREATE TABLE posts (
        id TEXT PRIMARY KEY,
        lessonId TEXT NOT NULL,
        name TEXT NOT NULL,
        text TEXT NOT NULL,
        attachments TEXT NOT NULL,
        createdAt $integerType
      )
    ''');
  }

  Future<void> cacheLessons(List<Map<String, dynamic>> lessons) async {
    final db = await instance.database;
    final batch = db.batch();
    await db.delete('lessons');
    for (var lesson in lessons) {
      batch.insert('lessons', lesson,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  Future<void> cachePosts(
      String lessonId, List<Map<String, dynamic>> posts) async {
    final db = await instance.database;
    final batch = db.batch();
    await db.delete('posts', where: 'lessonId = ?', whereArgs: [lessonId]);
    for (var post in posts) {
      batch.insert('posts', post, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> getLessons() async {
    final db = await instance.database;
    return await db.query('lessons');
  }

  Future<List<Map<String, dynamic>>> getPostsForLesson(String lessonId) async {
    final db = await instance.database;
    return await db.query('posts',
        where: 'lessonId = ?',
        whereArgs: [lessonId],
        orderBy: 'createdAt DESC');
  }

  Future<int> insertDownload(Map<String, dynamic> download) async {
    final db = await instance.database;
    return await db.insert('downloads', download,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getDownloadByUrl(String url) async {
    final db = await instance.database;
    final results = await db.query(
      'downloads',
      where: 'url = ?',
      whereArgs: [url],
    );
    if (results.isNotEmpty) {
      return results.first;
    } else {
      return null;
    }
  }
}
