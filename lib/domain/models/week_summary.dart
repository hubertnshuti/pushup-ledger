import 'package:pushup_ledger/domain/models/week_status.dart';

/// Totals and verdict for one week.
class WeekSummary {
  const WeekSummary({
    required this.weekStart,
    required this.status,
    required this.totalReps,
    required this.completedDays,
    required this.trackedDays,
  });

  /// The Monday that begins this week.
  final DateTime weekStart;
  final WeekStatus status;
  final int totalReps;
  final int completedDays;

  /// Days in this week on or after the start date and not in the future.
  final int trackedDays;

  @override
  bool operator ==(Object other) =>
      other is WeekSummary &&
      other.weekStart == weekStart &&
      other.status == status &&
      other.totalReps == totalReps &&
      other.completedDays == completedDays &&
      other.trackedDays == trackedDays;

  @override
  int get hashCode =>
      Object.hash(weekStart, status, totalReps, completedDays, trackedDays);
}
