import 'package:flutter_test/flutter_test.dart';
import 'package:pushup_ledger/domain/ledger.dart';
import 'package:pushup_ledger/domain/models/debt.dart';
import 'package:pushup_ledger/domain/models/log_entry.dart';
import 'package:pushup_ledger/domain/models/week_status.dart';

final monday = DateTime(2026, 11, 23);
final nextMonday = DateTime(2026, 11, 30, 8);

/// Builds entries from (day offset from [monday], count) pairs.
List<LogEntry> logs(List<(int, int)> sets) => [
  for (final (index, (day, count)) in sets.indexed)
    LogEntry(
      id: index,
      createdAt: DateTime(2026, 11, 23 + day, 7, index),
      count: count,
    ),
];

void main() {
  test('no entries: each past day creates 50 debt', () {
    final result = computeLedger(
      startDate: monday,
      entries: const [],
      now: DateTime(2026, 11, 26, 10),
    );
    expect(result.debts.map((debt) => debt.amount), [50, 50, 50]);
    expect(result.totalOwed, 150);
  });

  test('30 + 20 on the same day: complete, no debt', () {
    final result = computeLedger(
      startDate: monday,
      entries: logs([(0, 30), (0, 20)]),
      now: DateTime(2026, 11, 24, 10),
    );
    expect(result.days.first.isComplete, isTrue);
    expect(result.debts, isEmpty);
  });

  test('70 with no debt: 50 quota + 20 extra, nothing banked', () {
    final result = computeLedger(
      startDate: monday,
      entries: logs([(0, 70)]),
      now: DateTime(2026, 11, 25, 10),
    );
    expect(result.days[0].quotaReps, 50);
    expect(result.days[0].extraReps, 20);
    expect(result.days[1].quotaReps, 0);
    expect(result.totalOwed, 50);
  });

  test('70 with 30 open debt: 50 quota + 20 debt paid', () {
    final result = computeLedger(
      startDate: monday,
      entries: logs([(0, 20), (1, 70)]),
      now: DateTime(2026, 11, 24, 20),
    );
    expect(result.days[1].quotaReps, 50);
    expect(result.days[1].debtPaidReps, 20);
    expect(result.days[1].extraReps, 0);
    expect(result.totalOwed, 10);
  });

  test('debt is paid oldest first', () {
    final result = computeLedger(
      startDate: monday,
      entries: logs([(2, 80)]),
      now: DateTime(2026, 11, 25, 20),
    );
    expect(result.debts[0].remaining, 20);
    expect(result.debts[1].remaining, 50);
  });

  test('debt unpaid at Sunday 23:59: carried, week failed', () {
    final result = computeLedger(
      startDate: monday,
      entries: logs([
        (0, 50),
        (1, 20),
        (2, 50),
        (3, 50),
        (4, 50),
        (5, 50),
        (6, 50),
      ]),
      now: nextMonday,
    );
    expect(result.debts.single.isCarried, isTrue);
    expect(result.carriedOwed, 30);
    expect(result.weeks.first.status, WeekStatus.failed);
  });

  test('debt is not carried during Sunday', () {
    final result = computeLedger(
      startDate: monday,
      entries: logs([(0, 50), (1, 20)]),
      now: DateTime(2026, 11, 29, 23, 59, 59),
    );
    expect(result.debts.first.isCarried, isFalse);
  });

  test('missed Tuesday, paid Wednesday: Tuesday stays 20/50, recovered', () {
    final result = computeLedger(
      startDate: monday,
      entries: logs([
        (0, 50),
        (1, 20),
        (2, 80),
        (3, 50),
        (4, 50),
        (5, 50),
        (6, 50),
      ]),
      now: nextMonday,
    );
    expect(result.days[1].quotaReps, 20);
    expect(result.days[2].debtPaidReps, 30);
    expect(result.debts.single.payments, [
      DebtPayment(date: DateTime(2026, 11, 25), amount: 30),
    ]);
    expect(result.weeks.first.status, WeekStatus.recovered);
  });

  test('Sunday shortfall: immediately carried', () {
    final result = computeLedger(
      startDate: monday,
      entries: logs([
        (0, 50),
        (1, 50),
        (2, 50),
        (3, 50),
        (4, 50),
        (5, 50),
        (6, 40),
      ]),
      now: DateTime(2026, 11, 30, 0, 0, 1),
    );
    expect(result.debts.single.amount, 10);
    expect(result.debts.single.isCarried, isTrue);
    expect(result.weeks.first.status, WeekStatus.failed);
  });

  test('a carried debt paid late leaves the week failed', () {
    final result = computeLedger(
      startDate: monday,
      entries: logs([
        (0, 50),
        (1, 20),
        (2, 50),
        (3, 50),
        (4, 50),
        (5, 50),
        (6, 50),
        (7, 80),
      ]),
      now: DateTime(2026, 11, 30, 20),
    );
    expect(result.debts.single.isPaid, isTrue);
    expect(result.debts.single.isCarried, isTrue);
    expect(result.carriedOwed, 0);
    expect(result.weeks.first.status, WeekStatus.failed);
  });

  test('start date tomorrow: today is ignored', () {
    final result = computeLedger(
      startDate: DateTime(2026, 11, 24),
      entries: logs([(0, 50)]),
      now: DateTime(2026, 11, 23, 20),
    );
    expect(result.days, isEmpty);
    expect(result.debts, isEmpty);
    expect(result.weeks, isEmpty);
  });

  test('a fully completed past week is clean', () {
    final result = computeLedger(
      startDate: monday,
      entries: logs([for (var day = 0; day < 7; day++) (day, 50)]),
      now: nextMonday,
    );
    expect(result.weeks.first.status, WeekStatus.clean);
    expect(result.weeks.first.totalReps, 350);
    expect(result.weeks.last.status, WeekStatus.inProgress);
  });

  test('streak counts through yesterday and includes a complete today', () {
    final waiting = computeLedger(
      startDate: monday,
      entries: logs([(0, 50), (1, 50)]),
      now: DateTime(2026, 11, 25, 8),
    );
    expect(waiting.currentStreak, 2);

    final done = computeLedger(
      startDate: monday,
      entries: logs([(0, 50), (1, 50), (2, 50)]),
      now: DateTime(2026, 11, 25, 8),
    );
    expect(done.currentStreak, 3);
  });

  test('a day paid back later does not count toward a streak', () {
    final result = computeLedger(
      startDate: monday,
      entries: logs([(0, 50), (1, 20), (2, 80), (3, 50)]),
      now: DateTime(2026, 11, 27, 8),
    );
    expect(result.currentStreak, 2);
    expect(result.bestStreak, 2);
  });

  group('undo', () {
    final entry = LogEntry(
      id: 1,
      createdAt: DateTime(2026, 11, 23, 7),
      count: 20,
    );

    test('allowed at 1:59', () {
      expect(canUndo(entry, DateTime(2026, 11, 23, 7, 1, 59)), isTrue);
    });

    test('refused at 2:01', () {
      expect(canUndo(entry, DateTime(2026, 11, 23, 7, 2, 1)), isFalse);
    });

    test('refused when the clock moved backward', () {
      expect(canUndo(entry, DateTime(2026, 11, 23, 6, 59)), isFalse);
    });
  });
}
