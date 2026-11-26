import 'package:pushup_ledger/domain/models/day_record.dart';
import 'package:pushup_ledger/domain/models/debt.dart';
import 'package:pushup_ledger/domain/models/week_summary.dart';

/// Everything computed from the raw log at one moment.
class LedgerSnapshot {
  LedgerSnapshot({
    required List<DayRecord> days,
    required List<Debt> debts,
    required List<WeekSummary> weeks,
    required this.currentStreak,
    required this.bestStreak,
  }) : days = List.unmodifiable(days),
       debts = List.unmodifiable(debts),
       weeks = List.unmodifiable(weeks);

  final List<DayRecord> days;
  final List<Debt> debts;
  final List<WeekSummary> weeks;
  final int currentStreak;
  final int bestStreak;

  /// All reps still owed, whether or not their deadline has passed.
  int get totalOwed => debts.fold(0, (total, debt) => total + debt.remaining);

  /// Reps still owed after missing their deadline.
  int get carriedOwed => debts
      .where((debt) => debt.isCarried)
      .fold(0, (total, debt) => total + debt.remaining);

  /// Reps still owed that can be paid before their deadline.
  int get openOwed => totalOwed - carriedOwed;

  /// Every rep logged since the start date.
  int get allTimeReps => days.fold(0, (total, day) => total + day.totalReps);

  int get completedDays => days.where((day) => day.isComplete).length;

  int get trackedDays => days.length;

  /// The debt created by [date], if that day was missed.
  Debt? debtFrom(DateTime date) =>
      debts.where((debt) => debt.originDate == date).firstOrNull;
}
