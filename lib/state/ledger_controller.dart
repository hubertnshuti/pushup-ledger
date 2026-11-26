import 'package:flutter/foundation.dart';
import 'package:pushup_ledger/core/clock.dart';
import 'package:pushup_ledger/core/dates.dart';
import 'package:pushup_ledger/data/log_repository.dart';
import 'package:pushup_ledger/data/settings_repository.dart';
import 'package:pushup_ledger/domain/backup.dart';
import 'package:pushup_ledger/domain/history_grid.dart';
import 'package:pushup_ledger/domain/ledger.dart';
import 'package:pushup_ledger/domain/models/day_record.dart';
import 'package:pushup_ledger/domain/models/ledger_snapshot.dart';
import 'package:pushup_ledger/domain/models/log_entry.dart';
import 'package:pushup_ledger/domain/models/window_status.dart';
import 'package:pushup_ledger/domain/notification_planner.dart';
import 'package:pushup_ledger/domain/reckoning.dart';
import 'package:pushup_ledger/domain/week_strip.dart';
import 'package:pushup_ledger/domain/widget_projection.dart';
import 'package:pushup_ledger/domain/windows.dart';

/// Loads stored facts, runs the ledger, and tells the UI when results change.
class LedgerController extends ChangeNotifier {
  LedgerController({
    required this._logs,
    required this._settings,
    required this._clock,
    this._scheduler,
    this._widgetPublisher,
  });

  final LogRepository _logs;
  final SettingsRepository _settings;
  final Clock _clock;
  final NotificationScheduler? _scheduler;
  final HomeWidgetPublisher? _widgetPublisher;

  bool _isOnboardingDone = false;
  Future<void> _notificationSync = Future.value();

  bool get isOnboardingDone => _isOnboardingDone;

  /// Completes when every queued reminder update has finished.
  Future<void> get notificationsSynced => _notificationSync;

  List<LogEntry> _entries = const [];
  DateTime? _startDate;
  LedgerSnapshot? _snapshot;
  bool _isReckoningOpen = false;
  Verdict? _verdict;

  List<LogEntry> get entries => _entries;
  DateTime? get startDate => _startDate;

  /// The computed ledger, or null until a start date has been chosen.
  LedgerSnapshot? get snapshot => _snapshot;

  /// Today's record, or null before the start date.
  DayRecord? get today {
    final todayDate = dateOnly(_clock.now());
    final last = _snapshot?.days.lastOrNull;
    return last?.date == todayDate ? last : null;
  }

  /// Today's entries, newest first.
  List<LogEntry> get todayEntries {
    final todayDate = dateOnly(_clock.now());
    return _entries
        .where((entry) => dateOnly(entry.createdAt) == todayDate)
        .toList()
        .reversed
        .toList(growable: false);
  }

  WindowStatus get windowStatus =>
      windowStatusAt(_clock.now(), isDayComplete: today?.isComplete ?? false);

  List<WeekDay> get weekStrip =>
      weekStripFor(_snapshot?.days ?? const [], _clock.now());

  List<List<GridCell>> get gridWeeks =>
      gridWeeksFor(_snapshot?.days ?? const [], _clock.now());

  /// Time until this week's Sunday deadline.
  Duration get timeUntilWeekCloses {
    final now = _clock.now();
    return endOfDay(sundayOf(now)).difference(now);
  }

  /// Time until today ends.
  Duration get timeUntilMidnight {
    final now = _clock.now();
    return addDays(now, 1).difference(now);
  }

  /// The blocking screen to show now, or null.
  Reckoning? get activeReckoning {
    final snapshot = _snapshot;
    if (!_isReckoningOpen || snapshot == null) {
      return null;
    }
    return reckoningFor(snapshot, _clock.now());
  }

  /// The missed-day verdict to show on the blocking screen, or null.
  Verdict? get activeVerdict => _verdict;

  bool canUndoEntry(LogEntry entry) => canUndo(entry, _clock.now());

  /// Opens the blocking screen if a condition applies and it is due.
  Future<void> openReckoningIfDue({required bool isColdStart}) async {
    final snapshot = _snapshot;
    if (_isReckoningOpen || snapshot == null) {
      return;
    }
    final now = _clock.now();
    if (reckoningFor(snapshot, now) == null) {
      return;
    }
    final verdict = verdictFor(
      snapshot,
      now,
      lastVerdictDate: await _settings.lastVerdictDate(),
    );
    final lastShownAt = await _settings.lastReckoningShownAt();
    if (isColdStart ||
        verdict != null ||
        isReckoningDueOnResume(lastShownAt, now)) {
      await _settings.setLastReckoningShownAt(now);
      _verdict = verdict;
      _isReckoningOpen = true;
      notifyListeners();
    }
  }

  /// Closes the blocking screen and records any verdict as acknowledged.
  Future<void> dismissReckoning() async {
    final verdict = _verdict;
    if (verdict != null) {
      await _settings.setLastVerdictDate(verdict.date);
    }
    _verdict = null;
    _isReckoningOpen = false;
    notifyListeners();
  }

  /// Reads everything from storage and recomputes.
  Future<void> load() async {
    _entries = await _logs.all();
    _startDate = await _settings.startDate();
    _isOnboardingDone = await _settings.onboardingDone();
    refresh();
    _queueNotificationSync();
  }

  /// Saves the contract's start date. It cannot be changed afterwards.
  Future<void> finishOnboarding({required bool startTomorrow}) async {
    if (_isOnboardingDone) {
      return;
    }
    final today = dateOnly(_clock.now());
    await _settings.setStartDate(startTomorrow ? addDays(today, 1) : today);
    await _settings.setOnboardingDone(done: true);
    await load();
  }

  /// Brings data and reminders up to date when the app returns.
  Future<void> handleResume() async {
    await load();
    await openReckoningIfDue(isColdStart: false);
  }

  /// Runs reminder and widget updates one at a time so they cannot overlap.
  void _queueNotificationSync() {
    final startDate = _startDate;
    if (startDate == null || !_isOnboardingDone) {
      return;
    }
    final entries = _entries;
    _notificationSync = _notificationSync.then((_) async {
      final now = _clock.now();
      try {
        await _scheduler?.reschedule(
          planNotifications(startDate: startDate, entries: entries, now: now),
        );
      } on Exception {
        // A saved set must not fail because of a reminder. The next load retries.
      }
      try {
        await _widgetPublisher?.publish(
          widgetLinesFor(startDate: startDate, entries: entries, now: now),
        );
      } on Exception {
        // The widget is optional and is updated again on the next load.
      }
    });
  }

  /// Writes the stored facts to [saver]. Returns false if nothing was saved.
  Future<bool> exportBackup(BackupSaver saver) async {
    final startDate = _startDate;
    if (startDate == null) {
      return false;
    }
    final now = _clock.now();
    return saver.save(
      fileName: backupFileName(now),
      content: encodeBackup(
        startDate: startDate,
        entries: _entries,
        exportedAt: now,
      ),
    );
  }

  /// Recomputes from loaded data, for when time has passed.
  void refresh() {
    final startDate = _startDate;
    _snapshot = startDate == null
        ? null
        : computeLedger(
            startDate: startDate,
            entries: _entries,
            now: _clock.now(),
          );
    final snapshot = _snapshot;
    if (snapshot == null || reckoningFor(snapshot, _clock.now()) == null) {
      _isReckoningOpen = false;
      _verdict = null;
    }
    notifyListeners();
  }

  /// Saves a confirmed set.
  Future<void> logSet(int count) async {
    await _logs.add(count);
    await load();
  }

  /// Deletes an entry if still allowed, returning whether it was deleted.
  Future<bool> undo(int id) async {
    final deleted = await _logs.undo(id);
    await load();
    return deleted;
  }
}
