import 'package:flutter_test/flutter_test.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/domain/models/log_entry.dart';
import 'package:pushup_ledger/domain/notification_planner.dart';

LogEntry entry(int id, DateTime at, int count) =>
    LogEntry(id: id, createdAt: at, count: count);

void main() {
  test('nothing is scheduled in the past', () {
    final now = DateTime(2026, 11, 25, 12);
    final plan = planNotifications(
      startDate: DateTime(2026, 11, 25),
      entries: const [],
      now: now,
    );
    expect(plan.every((item) => item.at.isAfter(now)), isTrue);
    expect(plan.first.at, DateTime(2026, 11, 25, 16));
  });

  test('uses today\'s real remaining reps', () {
    final now = DateTime(2026, 11, 25, 12);
    final plan = planNotifications(
      startDate: DateTime(2026, 11, 25),
      entries: [entry(1, DateTime(2026, 11, 25, 7), 20)],
      now: now,
    );
    expect(plan.first.body, AppCopy.notifyEveningOpen(30));
  });

  test('a complete day gets no reminders for the rest of that day', () {
    final now = DateTime(2026, 11, 25, 12);
    final plan = planNotifications(
      startDate: DateTime(2026, 11, 25),
      entries: [entry(1, DateTime(2026, 11, 25, 7), 50)],
      now: now,
    );
    expect(plan.first.at, DateTime(2026, 11, 26, 5));
  });

  test('projects tomorrow\'s debt from today\'s shortfall', () {
    final now = DateTime(2026, 11, 25, 12);
    final plan = planNotifications(
      startDate: DateTime(2026, 11, 25),
      entries: [entry(1, DateTime(2026, 11, 25, 7), 20)],
      now: now,
    );
    final tomorrowMorning = plan.firstWhere(
      (item) => item.at == DateTime(2026, 11, 26, 5),
    );
    expect(tomorrowMorning.body, AppCopy.notifyMorningOpen(50, 30));
    expect(
      plan.any(
        (item) =>
            item.at == DateTime(2026, 11, 26, 12) &&
            item.channel == ReminderChannel.warnings &&
            item.body == AppCopy.notifyDebtDue(30),
      ),
      isTrue,
    );
  });

  test('Sunday warnings count down to the deadline', () {
    final now = DateTime(2026, 11, 29, 12);
    final plan = planNotifications(
      startDate: DateTime(2026, 11, 28),
      entries: const [],
      now: now,
    );
    final bodies = plan.map((item) => item.body);
    expect(bodies, contains('Week closes in 5 h. You owe 50.'));
    expect(bodies, contains('Week closes in 2 h. You owe 50.'));
    expect(bodies, contains('Week closes in 59 min. You owe 50.'));
  });

  test('Monday warns about carried debt', () {
    final now = DateTime(2026, 11, 29, 12);
    final plan = planNotifications(
      startDate: DateTime(2026, 11, 28),
      entries: const [],
      now: now,
    );
    expect(
      plan.any(
        (item) =>
            item.at == DateTime(2026, 11, 30, 6) &&
            item.body == AppCopy.notifyCarried,
      ),
      isTrue,
    );
  });

  test('no Monday warning when last week itself was clean', () {
    final plan = planNotifications(
      startDate: DateTime(2026, 11, 16),
      entries: [
        for (var day = 23; day <= 29; day++)
          entry(day, DateTime(2026, 11, day, 7), 50),
      ],
      now: DateTime(2026, 11, 29, 12),
    );
    expect(
      plan.any(
        (item) =>
            item.at == DateTime(2026, 11, 30, 6) &&
            item.body == AppCopy.notifyCarried,
      ),
      isFalse,
    );
  });

  test('a future start date plans nothing before it', () {
    final now = DateTime(2026, 11, 25, 12);
    final plan = planNotifications(
      startDate: DateTime(2026, 11, 26),
      entries: const [],
      now: now,
    );
    expect(plan.first.at, DateTime(2026, 11, 26, 5));
  });

  test('stays inside the 14-day horizon with unique ids', () {
    final now = DateTime(2026, 11, 25, 12);
    final plan = planNotifications(
      startDate: DateTime(2026, 11, 25),
      entries: const [],
      now: now,
    );
    expect(plan.last.at.isBefore(DateTime(2026, 12, 9)), isTrue);
    expect(plan.map((item) => item.id).toSet(), hasLength(plan.length));
  });
}
