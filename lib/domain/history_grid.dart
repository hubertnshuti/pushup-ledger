import 'package:pushup_ledger/core/dates.dart';
import 'package:pushup_ledger/domain/models/day_record.dart';

/// Quota reps at which a day moves to the stronger partial color.
const int _midLevelFrom = 25;

/// How strongly a day is filled in the contribution grid.
enum GridLevel { none, empty, low, mid, full }

/// One day in the contribution grid.
class GridCell {
  const GridCell({
    required this.date,
    required this.level,
    required this.hasMissedDot,
    required this.isToday,
    required this.day,
  });

  final DateTime date;
  final GridLevel level;

  /// Whether the day is over and its quota was not reached.
  final bool hasMissedDot;
  final bool isToday;

  /// The day's record, or null if it is in the future or before the start.
  final DayRecord? day;
}

/// Builds Monday-to-Sunday columns from the first tracked week to this week.
List<List<GridCell>> gridWeeksFor(List<DayRecord> days, DateTime now) {
  if (days.isEmpty) {
    return const [];
  }
  final byDate = {for (final day in days) day.date: day};
  final today = dateOnly(now);
  final currentWeek = mondayOf(today);
  final weeks = <List<GridCell>>[];
  for (
    var monday = mondayOf(days.first.date);
    !monday.isAfter(currentWeek);
    monday = addDays(monday, DateTime.daysPerWeek)
  ) {
    weeks.add([
      for (var offset = 0; offset < DateTime.daysPerWeek; offset++)
        _cell(addDays(monday, offset), byDate, today),
    ]);
  }
  return weeks;
}

GridCell _cell(DateTime date, Map<DateTime, DayRecord> byDate, DateTime today) {
  final day = byDate[date];
  return GridCell(
    date: date,
    level: _level(day),
    hasMissedDot: day != null && day.isPast && !day.isComplete,
    isToday: date == today,
    day: day,
  );
}

GridLevel _level(DayRecord? day) {
  if (day == null) {
    return GridLevel.none;
  }
  if (day.isComplete) {
    return GridLevel.full;
  }
  if (day.quotaReps == 0) {
    return GridLevel.empty;
  }
  return day.quotaReps < _midLevelFrom ? GridLevel.low : GridLevel.mid;
}
