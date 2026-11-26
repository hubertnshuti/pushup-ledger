import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/core/dates.dart';
import 'package:pushup_ledger/domain/ledger.dart';
import 'package:pushup_ledger/domain/models/ledger_snapshot.dart';
import 'package:pushup_ledger/domain/models/log_entry.dart';
import 'package:pushup_ledger/domain/models/week_status.dart';

/// Days ahead that reminders are scheduled.
const int notificationHorizonDays = 14;

/// The Android channel a reminder is delivered through.
enum ReminderChannel { windows, warnings }

/// One reminder to deliver at an exact time.
class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.at,
    required this.channel,
    required this.body,
  });

  final int id;
  final DateTime at;
  final ReminderChannel channel;
  final String body;
}

/// Delivers planned reminders on the device.
abstract interface class NotificationScheduler {
  /// Replaces every scheduled reminder with [plan].
  Future<void> reschedule(List<PlannedNotification> plan);

  /// Shows one reminder immediately.
  Future<void> showTest();
}

/// Plans reminders, assuming no more reps are logged.
List<PlannedNotification> planNotifications({
  required DateTime startDate,
  required List<LogEntry> entries,
  required DateTime now,
}) {
  final start = dateOnly(startDate);
  final today = dateOnly(now);
  final slots = <_Slot>[];

  for (var offset = 0; offset < notificationHorizonDays; offset++) {
    final day = addDays(today, offset);
    if (day.isBefore(start)) {
      continue;
    }
    final snapshot = computeLedger(
      startDate: start,
      entries: entries,
      now: day == today ? now : day,
    );
    slots.addAll(_slotsFor(day, snapshot));
  }

  final upcoming = slots.where((slot) => slot.at.isAfter(now)).toList()
    ..sort((a, b) => a.at.compareTo(b.at));
  return [
    for (final (index, slot) in upcoming.indexed)
      PlannedNotification(
        id: index,
        at: slot.at,
        channel: slot.channel,
        body: slot.body,
      ),
  ];
}

List<_Slot> _slotsFor(DateTime day, LedgerSnapshot snapshot) {
  DateTime at(int hour, [int minute = 0]) =>
      DateTime(day.year, day.month, day.day, hour, minute);

  final record = snapshot.days.last;
  final left = record.remainingReps;
  final owed = snapshot.totalOwed;
  final open = snapshot.openOwed;
  const windows = ReminderChannel.windows;
  const warnings = ReminderChannel.warnings;

  return [
    if (!record.isComplete) ...[
      _Slot(at(5), windows, AppCopy.notifyMorningOpen(left, owed)),
      _Slot(at(8, 30), windows, AppCopy.notifyMorningClosing(left)),
      _Slot(at(9), windows, AppCopy.notifyMorningEnded(left)),
      _Slot(at(16), windows, AppCopy.notifyEveningOpen(left)),
      _Slot(at(20), windows, AppCopy.notifyEveningHour(left)),
      _Slot(at(21), warnings, AppCopy.notifyEveningEnded(left)),
      _Slot(at(22, 30), warnings, AppCopy.notifyDayCloses(left)),
      _Slot(at(23, 30), warnings, AppCopy.notifyLastCall(left)),
    ],
    if (open > 0) _Slot(at(12), warnings, AppCopy.notifyDebtDue(open)),
    if (day.weekday == DateTime.sunday && open > 0)
      for (final hour in const [18, 21, 23])
        _Slot(
          at(hour),
          warnings,
          AppCopy.notifyWeekCloses(endOfDay(day).difference(at(hour)), open),
        ),
    if (day.weekday == DateTime.monday && _lastWeekFailed(day, snapshot))
      _Slot(at(6), warnings, AppCopy.notifyCarried),
  ];
}

bool _lastWeekFailed(DateTime monday, LedgerSnapshot snapshot) {
  final lastWeek = addDays(monday, -DateTime.daysPerWeek);
  return snapshot.weeks.any(
    (week) => week.weekStart == lastWeek && week.status == WeekStatus.failed,
  );
}

class _Slot {
  const _Slot(this.at, this.channel, this.body);

  final DateTime at;
  final ReminderChannel channel;
  final String body;
}
