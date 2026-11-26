import 'package:pushup_ledger/core/constants.dart';
import 'package:pushup_ledger/core/dates.dart';
import 'package:pushup_ledger/domain/models/window_status.dart';

/// Derives the window status from the time and today's progress.
WindowStatus windowStatusAt(DateTime now, {required bool isDayComplete}) {
  if (isDayComplete) {
    return const WindowStatus(WindowPhase.dayComplete);
  }

  final hour = now.hour;
  if (hour < morningStartHour) {
    return const WindowStatus(WindowPhase.beforeMorning);
  }
  if (hour < morningEndHour) {
    return WindowStatus(
      WindowPhase.morningOpen,
      timeLeft: _atHour(now, morningEndHour).difference(now),
    );
  }
  if (hour < eveningStartHour) {
    return const WindowStatus(WindowPhase.betweenWindows);
  }
  if (hour < eveningEndHour) {
    return WindowStatus(
      WindowPhase.eveningOpen,
      timeLeft: _atHour(now, eveningEndHour).difference(now),
    );
  }
  return WindowStatus(
    WindowPhase.dayClosing,
    timeLeft: addDays(now, 1).difference(now),
  );
}

DateTime _atHour(DateTime day, int hour) =>
    DateTime(day.year, day.month, day.day, hour);
