import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Opens the on-device database and keeps its schema up to date.
class AppDatabase {
  const AppDatabase._();

  static const String fileName = 'pushup_ledger.db';

  /// Schema steps in order. Index 0 builds version 1, index 1 upgrades to
  /// version 2, and so on. Released steps must never be edited.
  static const List<List<String>> migrations = [
    [
      '''
      CREATE TABLE log_entries (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at INTEGER NOT NULL,
        count      INTEGER NOT NULL CHECK (count BETWEEN 1 AND 200)
      )
      ''',
      '''
      CREATE TABLE settings (
        key   TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
      ''',
    ],
  ];

  static int get schemaVersion => migrations.length;

  static Future<Database> open() async {
    final directory = await getDatabasesPath();
    return openDatabase(
      join(directory, fileName),
      version: schemaVersion,
      onCreate: (db, version) => _migrate(db, from: 0, to: version),
      onUpgrade: (db, from, to) => _migrate(db, from: from, to: to),
    );
  }

  static Future<void> _migrate(
    Database db, {
    required int from,
    required int to,
  }) async {
    for (final step in migrations.sublist(from, to)) {
      for (final statement in step) {
        await db.execute(statement);
      }
    }
  }
}
