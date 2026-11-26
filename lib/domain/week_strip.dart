import 'package:pushup_ledger/core/dates.dart';
import 'package:pushup_ledger/domain/models/day_record.dart';

/// How one day appears in the Monday-to-Sunday strip.
enum WeekDayState { complete, partial, missed, upcoming }

/// One position in the week strip.
class WeekDay {
  const WeekDay({
    required this.date,
    required this.state,
    required this.quotaReps,
  });

  final DateTime date;
  final WeekDayState state;
  final int quotaReps;

  @override
  bool operator ==(Object other) =>
      other is WeekDay &&
      other.date == date &&
      other.state == state &&
      other.quotaReps == quotaReps;

  @override
  int get hashCode => Object.hash(date, state, quotaReps);
}

/// Builds the seven days of the week containing [now].
List<WeekDay> weekStripFor(List<DayRecord> days, DateTime now) {
  final byDate = {for (final day in days) day.date: day};
  final monday = mondayOf(now);
  return [
    for (var offset = 0; offset < DateTime.daysPerWeek; offset++)
      _weekDay(addDays(monday, offset), byDate),
  ];
}

WeekDay _weekDay(DateTime date, Map<DateTime, DayRecord> byDate) {
  final record = byDate[date];
  final state = switch (record) {
    null => WeekDayState.upcoming,
    DayRecord(isComplete: true) => WeekDayState.complete,
    DayRecord(isPast: true) => WeekDayState.missed,
    DayRecord(quotaReps: > 0) => WeekDayState.partial,
    DayRecord() => WeekDayState.upcoming,
  };
  return WeekDay(date: date, state: state, quotaReps: record?.quotaReps ?? 0);
}
