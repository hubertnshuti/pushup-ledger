import 'package:flutter_test/flutter_test.dart';
import 'package:pushup_ledger/domain/ledger.dart';
import 'package:pushup_ledger/domain/models/log_entry.dart';
import 'package:pushup_ledger/domain/week_strip.dart';

void main() {
  test('maps each day to its strip state', () {
    final now = DateTime(2026, 11, 25, 12);
    final snapshot = computeLedger(
      startDate: DateTime(2026, 11, 23),
      entries: [
        LogEntry(id: 1, createdAt: DateTime(2026, 11, 23, 7), count: 50),
        LogEntry(id: 2, createdAt: DateTime(2026, 11, 24, 7), count: 20),
        LogEntry(id: 3, createdAt: DateTime(2026, 11, 25, 7), count: 10),
      ],
      now: now,
    );

    final strip = weekStripFor(snapshot.days, now);

    expect(strip.map((day) => day.state), [
      WeekDayState.complete,
      WeekDayState.missed,
      WeekDayState.partial,
      WeekDayState.upcoming,
      WeekDayState.upcoming,
      WeekDayState.upcoming,
      WeekDayState.upcoming,
    ]);
  });

  test('days before the start date look upcoming', () {
    final now = DateTime(2026, 11, 25, 12);
    final snapshot = computeLedger(startDate: now, entries: const [], now: now);
    expect(weekStripFor(snapshot.days, now).first.state, WeekDayState.upcoming);
  });
}
