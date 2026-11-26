import 'dart:convert';

import 'package:pushup_ledger/core/dates.dart';
import 'package:pushup_ledger/domain/models/log_entry.dart';

/// Identifies a file as a backup from this app.
const String backupFormat = 'pushup_ledger_backup';

/// Version of the backup file structure.
const int backupVersion = 1;

/// Saves a text file somewhere the user chooses.
abstract interface class BackupSaver {
  /// Returns true if saved, or false if the user cancelled.
  Future<bool> save({required String fileName, required String content});
}

/// Suggested file name for a backup made at [now].
String backupFileName(DateTime now) =>
    'pushup_ledger_backup_${formatIsoDate(now)}.json';

/// Encodes the stored facts. Everything else can be recomputed from them.
String encodeBackup({
  required DateTime startDate,
  required List<LogEntry> entries,
  required DateTime exportedAt,
}) {
  return jsonEncode({
    'format': backupFormat,
    'version': backupVersion,
    'exportedAt': exportedAt.millisecondsSinceEpoch,
    'startDate': formatIsoDate(startDate),
    'entries': [
      for (final entry in entries)
        {
          'id': entry.id,
          'createdAt': entry.createdAt.millisecondsSinceEpoch,
          'count': entry.count,
        },
    ],
  });
}
