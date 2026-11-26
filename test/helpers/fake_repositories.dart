import 'package:pushup_ledger/core/clock.dart';
import 'package:pushup_ledger/data/log_repository.dart';
import 'package:pushup_ledger/data/settings_repository.dart';
import 'package:pushup_ledger/domain/ledger.dart';
import 'package:pushup_ledger/domain/models/log_entry.dart';

/// Keeps log entries in memory.
class FakeLogRepository implements LogRepository {
  FakeLogRepository(this.clock);

  final Clock clock;
  final List<LogEntry> stored = [];
  int _nextId = 1;

  @override
  Future<LogEntry> add(int count) async {
    final entry = LogEntry(id: _nextId++, createdAt: clock.now(), count: count);
    stored.add(entry);
    return entry;
  }

  @override
  Future<List<LogEntry>> all() async => List.of(stored);

  @override
  Future<bool> undo(int id) async {
    final matches = stored.where((entry) => entry.id == id);
    if (matches.isEmpty || !canUndo(matches.first, clock.now())) {
      return false;
    }
    stored.remove(matches.first);
    return true;
  }
}

/// Keeps settings in memory.
class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository(this.start);

  DateTime? start;
  bool isOnboardingDone = true;
  DateTime? lastShownAt;
  DateTime? lastVerdict;

  @override
  Future<DateTime?> startDate() async => start;

  @override
  Future<void> setStartDate(DateTime date) async => start = date;

  @override
  Future<bool> onboardingDone() async => isOnboardingDone;

  @override
  Future<void> setOnboardingDone({required bool done}) async =>
      isOnboardingDone = done;

  @override
  Future<DateTime?> lastReckoningShownAt() async => lastShownAt;

  @override
  Future<void> setLastReckoningShownAt(DateTime time) async =>
      lastShownAt = time;

  @override
  Future<DateTime?> lastVerdictDate() async => lastVerdict;

  @override
  Future<void> setLastVerdictDate(DateTime date) async => lastVerdict = date;

  @override
  Object? noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}
