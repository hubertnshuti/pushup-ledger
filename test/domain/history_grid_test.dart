import 'package:flutter_test/flutter_test.dart';
import 'package:pushup_ledger/domain/history_grid.dart';
import 'package:pushup_ledger/domain/ledger.dart';
import 'package:pushup_ledger/domain/models/log_entry.dart';

LogEntry entry(int id, int day, int count) =>
    LogEntry(id: id, createdAt: DateTime(2026, 11, day, 7), count: count);

void main() {
  test('no tracked days produce no weeks', () {
    expect(gridWeeksFor(const [], DateTime(2026, 11, 25)), isEmpty);
  });

  test('levels follow quota reps and past misses get a dot', () {
    final now = DateTime(2026, 11, 28, 12);
    final snapshot = computeLedger(
      startDate: DateTime(2026, 11, 23),
      entries: [
        entry(1, 24, 24),
        entry(2, 25, 25),
        entry(3, 26, 49),
        entry(4, 27, 50),
      ],
      now: now,
    );

    final week = gridWeeksFor(snapshot.days, now).single;

    expect(week.map((cell) => cell.level), [
      GridLevel.empty,
      GridLevel.low,
      GridLevel.mid,
      GridLevel.mid,
      GridLevel.full,
      GridLevel.empty,
      GridLevel.none,
    ]);
    expect(week.map((cell) => cell.hasMissedDot), [
      true,
      true,
      true,
      true,
      false,
      false,
      false,
    ]);
    expect(week[5].isToday, isTrue);
  });

  test('a repaid day keeps its original level and dot', () {
    final now = DateTime(2026, 11, 25, 20);
    final snapshot = computeLedger(
      startDate: DateTime(2026, 11, 24),
      entries: [entry(1, 24, 20), entry(2, 25, 80)],
      now: now,
    );

    final tuesday = gridWeeksFor(snapshot.days, now).single[1];

    expect(snapshot.totalOwed, 0);
    expect(tuesday.level, GridLevel.low);
    expect(tuesday.hasMissedDot, isTrue);
  });

  test('weeks run from the first tracked week through this week', () {
    final now = DateTime(2026, 12, 2, 12);
    final snapshot = computeLedger(
      startDate: DateTime(2026, 11, 25),
      entries: const [],
      now: now,
    );

    final weeks = gridWeeksFor(snapshot.days, now);

    expect(weeks, hasLength(2));
    expect(weeks.first.first.date, DateTime(2026, 11, 23));
    expect(weeks.first.first.level, GridLevel.none);
    expect(weeks.last.last.date, DateTime(2026, 12, 6));
  });
}
