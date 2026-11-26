import 'package:flutter_test/flutter_test.dart';
import 'package:pushup_ledger/domain/ledger.dart';
import 'package:pushup_ledger/domain/models/ledger_snapshot.dart';
import 'package:pushup_ledger/domain/models/log_entry.dart';
import 'package:pushup_ledger/domain/reckoning.dart';

LogEntry entry(int id, int month, int day, int count) =>
    LogEntry(id: id, createdAt: DateTime(2026, month, day, 7), count: count);

LedgerSnapshot snapshot(
  DateTime start,
  DateTime now, [
  List<LogEntry> entries = const [],
]) => computeLedger(startDate: start, entries: entries, now: now);

void main() {
  group('reckoningFor', () {
    test('nothing owed before 21:00 needs no screen', () {
      final now = DateTime(2026, 11, 25, 20, 59);
      expect(reckoningFor(snapshot(DateTime(2026, 11, 25), now), now), isNull);
    });

    test('an incomplete day blocks from 21:00', () {
      final now = DateTime(2026, 11, 25, 21);
      final result = reckoningFor(
        snapshot(DateTime(2026, 11, 25), now, [entry(1, 11, 25, 20)]),
        now,
      );
      expect(result?.kind, ReckoningKind.dayClosing);
      expect(result?.amount, 30);
    });

    test('a complete day does not block at night', () {
      final now = DateTime(2026, 11, 25, 22);
      final result = reckoningFor(
        snapshot(DateTime(2026, 11, 25), now, [entry(1, 11, 25, 50)]),
        now,
      );
      expect(result, isNull);
    });

    test('open debt outranks a closing day', () {
      final now = DateTime(2026, 11, 25, 22);
      final result = reckoningFor(snapshot(DateTime(2026, 11, 24), now), now);
      expect(result?.kind, ReckoningKind.openDebt);
      expect(result?.amount, 50);
    });

    test('carried debt outranks open debt', () {
      final now = DateTime(2026, 12, 2, 10);
      final result = reckoningFor(snapshot(DateTime(2026, 11, 29), now), now);
      expect(result?.kind, ReckoningKind.carriedDebt);
      expect(result?.amount, 150);
      expect(result?.failedWeekStart, DateTime(2026, 11, 23));
    });
  });

  group('verdictFor', () {
    final now = DateTime(2026, 11, 25, 8);
    final missed = snapshot(DateTime(2026, 11, 24), now, [
      entry(1, 11, 24, 20),
    ]);

    test('reports yesterday once', () {
      final verdict = verdictFor(missed, now, lastVerdictDate: null);
      expect(verdict?.quotaReps, 20);
      expect(verdict?.addedDebt, 30);
      expect(
        verdictFor(missed, now, lastVerdictDate: DateTime(2026, 11, 24)),
        isNull,
      );
    });

    test('a completed yesterday has no verdict', () {
      final done = snapshot(DateTime(2026, 11, 24), now, [
        entry(1, 11, 24, 50),
      ]);
      expect(verdictFor(done, now, lastVerdictDate: null), isNull);
    });
  });

  group('isReckoningDueOnResume', () {
    final shown = DateTime(2026, 11, 25, 8);

    test('waits 15 minutes', () {
      expect(
        isReckoningDueOnResume(shown, DateTime(2026, 11, 25, 8, 14, 59)),
        isFalse,
      );
      expect(
        isReckoningDueOnResume(shown, DateTime(2026, 11, 25, 8, 15)),
        isTrue,
      );
    });

    test('a clock moved backward counts as due', () {
      expect(isReckoningDueOnResume(shown, DateTime(2026, 11, 25, 7)), isTrue);
    });
  });
}
