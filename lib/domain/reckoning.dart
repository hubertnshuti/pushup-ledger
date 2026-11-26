import 'package:pushup_ledger/core/constants.dart';
import 'package:pushup_ledger/core/dates.dart';
import 'package:pushup_ledger/domain/models/debt.dart';
import 'package:pushup_ledger/domain/models/ledger_snapshot.dart';

/// Why the app must block the user, from most to least severe.
enum ReckoningKind { carriedDebt, openDebt, dayClosing }

/// What the blocking screen must show.
class Reckoning {
  Reckoning({
    required this.kind,
    required this.amount,
    required List<Debt> debts,
    this.failedWeekStart,
  }) : debts = List.unmodifiable(debts);

  final ReckoningKind kind;

  /// Reps owed, or reps left today for a closing day.
  final int amount;

  /// Unpaid debts, oldest first.
  final List<Debt> debts;

  /// The Monday of the oldest failed week with debt still unpaid.
  final DateTime? failedWeekStart;
}

/// The result of the most recent missed day.
class Verdict {
  const Verdict({
    required this.date,
    required this.quotaReps,
    required this.addedDebt,
  });

  final DateTime date;
  final int quotaReps;
  final int addedDebt;
}

/// Picks the most severe blocking condition, or null if none applies.
Reckoning? reckoningFor(LedgerSnapshot snapshot, DateTime now) {
  final unpaid = snapshot.debts.where((debt) => !debt.isPaid).toList();
  if (snapshot.carriedOwed > 0) {
    final oldestCarried = unpaid.firstWhere((debt) => debt.isCarried);
    return Reckoning(
      kind: ReckoningKind.carriedDebt,
      amount: snapshot.totalOwed,
      debts: unpaid,
      failedWeekStart: mondayOf(oldestCarried.originDate),
    );
  }
  if (snapshot.openOwed > 0) {
    return Reckoning(
      kind: ReckoningKind.openDebt,
      amount: snapshot.totalOwed,
      debts: unpaid,
    );
  }

  final latest = snapshot.days.lastOrNull;
  final isToday = latest != null && latest.date == dateOnly(now);
  if (isToday && now.hour >= eveningEndHour && !latest.isComplete) {
    return Reckoning(
      kind: ReckoningKind.dayClosing,
      amount: latest.remainingReps,
      debts: const [],
    );
  }
  return null;
}

/// Yesterday's verdict, unless it was already acknowledged.
Verdict? verdictFor(
  LedgerSnapshot snapshot,
  DateTime now, {
  required DateTime? lastVerdictDate,
}) {
  final yesterday = addDays(now, -1);
  if (lastVerdictDate != null && !lastVerdictDate.isBefore(yesterday)) {
    return null;
  }
  final record = snapshot.days
      .where((day) => day.date == yesterday)
      .firstOrNull;
  if (record == null || record.isComplete) {
    return null;
  }
  return Verdict(
    date: record.date,
    quotaReps: record.quotaReps,
    addedDebt: record.remainingReps,
  );
}

/// Whether enough time has passed to block a resumed app again.
///
/// A clock set before the last showing counts as due, so changing the device
/// time cannot suppress the screen.
bool isReckoningDueOnResume(DateTime? lastShownAt, DateTime now) {
  if (lastShownAt == null) {
    return true;
  }
  final elapsed = now.difference(lastShownAt);
  return elapsed.isNegative || elapsed >= reckoningResumeGap;
}
