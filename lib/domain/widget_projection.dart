import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/core/dates.dart';
import 'package:pushup_ledger/domain/ledger.dart';
import 'package:pushup_ledger/domain/models/log_entry.dart';
import 'package:pushup_ledger/domain/notification_planner.dart';

/// Sends the home-screen widget its text.
abstract interface class HomeWidgetPublisher {
  /// Replaces the stored lines, keyed by `yyyy-MM-dd`.
  Future<void> publish(Map<String, String> linesByDate);
}

/// Builds one widget line per day, assuming no more reps are logged.
///
/// Projecting ahead keeps the widget correct after midnight even if the app
/// is not opened.
Map<String, String> widgetLinesFor({
  required DateTime startDate,
  required List<LogEntry> entries,
  required DateTime now,
}) {
  final start = dateOnly(startDate);
  final today = dateOnly(now);
  return {
    for (var offset = 0; offset < notificationHorizonDays; offset++)
      formatIsoDate(addDays(today, offset)): _lineFor(
        addDays(today, offset),
        start,
        entries,
      ),
  };
}

String _lineFor(DateTime day, DateTime start, List<LogEntry> entries) {
  if (day.isBefore(start)) {
    return AppCopy.startsOn(start);
  }
  final snapshot = computeLedger(startDate: start, entries: entries, now: day);
  return AppCopy.widgetLine(
    snapshot.days.last.remainingReps,
    snapshot.totalOwed,
  );
}
