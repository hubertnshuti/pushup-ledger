import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pushup_ledger/domain/backup.dart';
import 'package:pushup_ledger/domain/models/log_entry.dart';

void main() {
  test('names the file after the export date', () {
    expect(
      backupFileName(DateTime(2027, 1, 5, 9)),
      'pushup_ledger_backup_2027-01-05.json',
    );
  });

  test('stores the start date and every raw entry', () {
    final createdAt = DateTime(2026, 11, 25, 7);
    final content = encodeBackup(
      startDate: DateTime(2026, 11, 24),
      entries: [LogEntry(id: 3, createdAt: createdAt, count: 20)],
      exportedAt: DateTime(2026, 11, 25, 8),
    );

    expect(jsonDecode(content), {
      'format': backupFormat,
      'version': backupVersion,
      'exportedAt': DateTime(2026, 11, 25, 8).millisecondsSinceEpoch,
      'startDate': '2026-11-24',
      'entries': [
        {'id': 3, 'createdAt': createdAt.millisecondsSinceEpoch, 'count': 20},
      ],
    });
  });
}
