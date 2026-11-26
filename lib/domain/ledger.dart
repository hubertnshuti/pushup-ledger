import 'dart:math';

import 'package:pushup_ledger/core/constants.dart';
import 'package:pushup_ledger/core/dates.dart';
import 'package:pushup_ledger/domain/models/day_record.dart';
import 'package:pushup_ledger/domain/models/debt.dart';
import 'package:pushup_ledger/domain/models/ledger_snapshot.dart';
import 'package:pushup_ledger/domain/models/log_entry.dart';
import 'package:pushup_ledger/domain/models/week_status.dart';
import 'package:pushup_ledger/domain/models/week_summary.dart';

/// Rebuilds every day, debt, week, and streak from the raw log.
LedgerSnapshot computeLedger({
  required DateTime startDate,
  required Iterable<LogEntry> entries,
  required DateTime now,
}) {
  final start = dateOnly(startDate);
  final today = dateOnly(now);
  final entriesByDay = _groupByDay(entries);
  final days = <DayRecord>[];
  final accounts = <_DebtAccount>[];

  for (var day = start; !day.isAfter(today); day = addDays(day, 1)) {
    final record = _applyDay(
      day,
      entriesByDay[day] ?? const <LogEntry>[],
      accounts,
      isPast: day.isBefore(today),
    );
    days.add(record);
    if (record.isPast && !record.isComplete) {
      accounts.add(_DebtAccount(day, record.remainingReps));
    }
  }

  final debts = [for (final account in accounts) account.toDebt(today)];
  final (:current, :best) = _streaks(days, today);
  return LedgerSnapshot(
    days: days,
    debts: debts,
    weeks: _summarizeWeeks(days, debts, today),
    currentStreak: current,
    bestStreak: best,
  );
}

/// Whether [entry] is still inside its undo window.
///
/// A clock set before the entry's time is refused, so changing the device time
/// cannot reopen the window.
bool canUndo(LogEntry entry, DateTime now) {
  final elapsed = now.difference(entry.createdAt);
  return !elapsed.isNegative && elapsed <= undoWindow;
}

Map<DateTime, List<LogEntry>> _groupByDay(Iterable<LogEntry> entries) {
  final sorted = entries.toList()
    ..sort((a, b) {
      final byTime = a.createdAt.compareTo(b.createdAt);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });
  final byDay = <DateTime, List<LogEntry>>{};
  for (final entry in sorted) {
    byDay.putIfAbsent(dateOnly(entry.createdAt), () => []).add(entry);
  }
  return byDay;
}

DayRecord _applyDay(
  DateTime day,
  List<LogEntry> entries,
  List<_DebtAccount> accounts, {
  required bool isPast,
}) {
  var quota = 0;
  var debtPaid = 0;
  var extra = 0;

  for (final entry in entries) {
    final toQuota = min(entry.count, dailyTarget - quota);
    quota += toQuota;
    var reps = entry.count - toQuota;

    for (final account in accounts) {
      if (reps == 0) {
        break;
      }
      final paid = account.pay(day, reps);
      debtPaid += paid;
      reps -= paid;
    }
    extra += reps;
  }

  return DayRecord(
    date: day,
    quotaReps: quota,
    extraReps: extra,
    debtPaidReps: debtPaid,
    isPast: isPast,
  );
}

({int current, int best}) _streaks(List<DayRecord> days, DateTime today) {
  var run = 0;
  var best = 0;
  for (final day in days) {
    if (day.isComplete) {
      run++;
      best = max(best, run);
    } else if (day.date != today) {
      run = 0;
    }
  }
  return (current: run, best: best);
}

List<WeekSummary> _summarizeWeeks(
  List<DayRecord> days,
  List<Debt> debts,
  DateTime today,
) {
  final byWeek = <DateTime, List<DayRecord>>{};
  for (final day in days) {
    byWeek.putIfAbsent(mondayOf(day.date), () => []).add(day);
  }

  final currentWeek = mondayOf(today);
  return [
    for (final MapEntry(key: weekStart, value: weekDays) in byWeek.entries)
      WeekSummary(
        weekStart: weekStart,
        status: _weekStatus(weekStart, weekDays, debts, currentWeek),
        totalReps: weekDays.fold(0, (total, day) => total + day.totalReps),
        completedDays: weekDays.where((day) => day.isComplete).length,
        trackedDays: weekDays.length,
      ),
  ];
}

WeekStatus _weekStatus(
  DateTime weekStart,
  List<DayRecord> days,
  List<Debt> debts,
  DateTime currentWeek,
) {
  if (weekStart == currentWeek) {
    return WeekStatus.inProgress;
  }
  final hasCarriedDebt = debts.any(
    (debt) => debt.isCarried && mondayOf(debt.originDate) == weekStart,
  );
  if (hasCarriedDebt) {
    return WeekStatus.failed;
  }
  return days.every((day) => day.isComplete)
      ? WeekStatus.clean
      : WeekStatus.recovered;
}

/// Mutable bookkeeping used only while the ledger is being computed.
class _DebtAccount {
  _DebtAccount(this.originDate, this.amount);

  final DateTime originDate;
  final int amount;
  final Map<DateTime, int> _paidByDay = {};
  int _paid = 0;

  int pay(DateTime day, int reps) {
    final paid = min(reps, amount - _paid);
    if (paid > 0) {
      _paid += paid;
      _paidByDay[day] = (_paidByDay[day] ?? 0) + paid;
    }
    return paid;
  }

  Debt toDebt(DateTime today) {
    final dueDate = sundayOf(originDate);
    var paidOnTime = 0;
    final payments = <DebtPayment>[];
    for (final MapEntry(key: date, value: paid) in _paidByDay.entries) {
      payments.add(DebtPayment(date: date, amount: paid));
      if (!date.isAfter(dueDate)) {
        paidOnTime += paid;
      }
    }
    return Debt(
      originDate: originDate,
      amount: amount,
      dueBy: endOfDay(dueDate),
      isCarried: today.isAfter(dueDate) && paidOnTime < amount,
      payments: payments,
    );
  }
}
