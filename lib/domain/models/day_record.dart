import 'package:pushup_ledger/core/constants.dart';

/// How the reps logged on one calendar day were applied.
class DayRecord {
  const DayRecord({
    required this.date,
    required this.quotaReps,
    required this.extraReps,
    required this.debtPaidReps,
    required this.isPast,
  });

  final DateTime date;

  /// Reps that counted for this day itself, from 0 to the daily target.
  final int quotaReps;

  /// Reps beyond the quota and open debt. These are never banked.
  final int extraReps;

  /// Reps from this day that paid off earlier days.
  final int debtPaidReps;

  final bool isPast;

  bool get isComplete => quotaReps == dailyTarget;

  int get remainingReps => dailyTarget - quotaReps;

  int get totalReps => quotaReps + extraReps + debtPaidReps;

  @override
  bool operator ==(Object other) =>
      other is DayRecord &&
      other.date == date &&
      other.quotaReps == quotaReps &&
      other.extraReps == extraReps &&
      other.debtPaidReps == debtPaidReps &&
      other.isPast == isPast;

  @override
  int get hashCode =>
      Object.hash(date, quotaReps, extraReps, debtPaidReps, isPast);
}
