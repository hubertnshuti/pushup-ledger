import 'package:flutter_test/flutter_test.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/domain/models/log_entry.dart';
import 'package:pushup_ledger/domain/notification_planner.dart';
import 'package:pushup_ledger/domain/widget_projection.dart';

void main() {
  final now = DateTime(2026, 11, 25, 12);

  test('today shows real progress and tomorrow projects the debt', () {
    final lines = widgetLinesFor(
      startDate: DateTime(2026, 11, 25),
      entries: [
        LogEntry(id: 1, createdAt: DateTime(2026, 11, 25, 7), count: 20),
      ],
      now: now,
    );

    expect(lines['2026-11-25'], '30 left today');
    expect(lines['2026-11-26'], '50 left today · You owe 30');
  });

  test('a complete day says done', () {
    final lines = widgetLinesFor(
      startDate: DateTime(2026, 11, 25),
      entries: [
        LogEntry(id: 1, createdAt: DateTime(2026, 11, 25, 7), count: 50),
      ],
      now: now,
    );

    expect(lines['2026-11-25'], 'Done today');
  });

  test('days before the start date announce it', () {
    final start = DateTime(2026, 11, 26);
    final lines = widgetLinesFor(startDate: start, entries: const [], now: now);

    expect(lines['2026-11-25'], AppCopy.startsOn(start));
    expect(lines['2026-11-26'], '50 left today');
  });

  test('covers the full horizon across a month boundary', () {
    final lines = widgetLinesFor(
      startDate: DateTime(2026, 11, 25),
      entries: const [],
      now: now,
    );

    expect(lines, hasLength(notificationHorizonDays));
    expect(lines.keys.last, '2026-12-08');
  });
}
