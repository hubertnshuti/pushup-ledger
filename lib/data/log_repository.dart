import 'package:pushup_ledger/core/clock.dart';
import 'package:pushup_ledger/core/constants.dart';
import 'package:pushup_ledger/domain/ledger.dart';
import 'package:pushup_ledger/domain/models/log_entry.dart';
import 'package:sqflite/sqflite.dart';

/// Stores logged sets. Entries can be added or undone, never edited.
class LogRepository {
  const LogRepository(this._db, this._clock);

  static const String _table = 'log_entries';

  final Database _db;
  final Clock _clock;

  /// Saves a set stamped with the current time.
  Future<LogEntry> add(int count) async {
    RangeError.checkValueInInterval(count, minSetCount, maxSetCount, 'count');
    final createdAt = _clock.now();
    final id = await _db.insert(_table, {
      'created_at': createdAt.millisecondsSinceEpoch,
      'count': count,
    });
    return LogEntry(id: id, createdAt: createdAt, count: count);
  }

  /// Returns every entry, oldest first.
  Future<List<LogEntry>> all() async {
    final rows = await _db.query(_table, orderBy: 'created_at ASC, id ASC');
    return rows.map(_fromRow).toList(growable: false);
  }

  /// Deletes an entry if its undo window is still open.
  ///
  /// Returns whether the entry was deleted.
  Future<bool> undo(int id) {
    return _db.transaction<bool>((txn) async {
      final rows = await txn.query(
        _table,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty || !canUndo(_fromRow(rows.first), _clock.now())) {
        return false;
      }
      final deleted = await txn.delete(
        _table,
        where: 'id = ?',
        whereArgs: [id],
      );
      return deleted == 1;
    });
  }

  LogEntry _fromRow(Map<String, Object?> row) {
    return switch (row) {
      {
        'id': final int id,
        'created_at': final int createdAtMs,
        'count': final int count,
      } =>
        LogEntry(
          id: id,
          createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
          count: count,
        ),
      _ => throw StateError('Malformed log entry row: $row'),
    };
  }
}
