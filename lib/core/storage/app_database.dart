import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

/// Lightweight local database for assistants, history, and consent logs.
class AppDatabase {
  AppDatabase();

  Database? _database;

  Future<Database> get instance async {
    final Database? existing = _database;
    if (existing != null) {
      return existing;
    }

    final String databasesPath = await getDatabasesPath();
    final String databasePath = path.join(databasesPath, 'clever_typing.db');
    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE assistants(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            promptIntent TEXT NOT NULL,
            promptTemplate TEXT NOT NULL,
            isPremium INTEGER NOT NULL,
            isCustom INTEGER NOT NULL,
            isPinned INTEGER NOT NULL,
            updatedAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE usage_history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            feature TEXT NOT NULL,
            action TEXT NOT NULL,
            inputPreview TEXT,
            outputPreview TEXT,
            wasSuccessful INTEGER NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE consent_logs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            consentType TEXT NOT NULL,
            wasGranted INTEGER NOT NULL,
            metadata TEXT,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }
}
