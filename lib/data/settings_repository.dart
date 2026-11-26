import 'package:pushup_ledger/core/dates.dart';
import 'package:sqflite/sqflite.dart';

/// Typed access to the key-value settings table.
class SettingsRepository {
  const SettingsRepository(this._db);

  static const String _table = 'settings';
  static const String _startDate = 'start_date';
  static const String _onboardingDone = 'onboarding_done';
  static const String _lastReckoningShownAt = 'last_reckoning_shown_at';
  static const String _lastVerdictDate = 'last_verdict_date';

  final Database _db;

  Future<DateTime?> startDate() => _readDate(_startDate);

  Future<void> setStartDate(DateTime date) =>
      _write(_startDate, formatIsoDate(date));

  Future<bool> onboardingDone() async => await _read(_onboardingDone) == 'true';

  Future<void> setOnboardingDone({required bool done}) =>
      _write(_onboardingDone, done.toString());

  Future<DateTime?> lastReckoningShownAt() async {
    final stored = await _read(_lastReckoningShownAt);
    final milliseconds = stored == null ? null : int.tryParse(stored);
    return milliseconds == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  Future<void> setLastReckoningShownAt(DateTime time) =>
      _write(_lastReckoningShownAt, time.millisecondsSinceEpoch.toString());

  Future<DateTime?> lastVerdictDate() => _readDate(_lastVerdictDate);

  Future<void> setLastVerdictDate(DateTime date) =>
      _write(_lastVerdictDate, formatIsoDate(date));

  Future<DateTime?> _readDate(String key) async {
    final stored = await _read(key);
    return stored == null ? null : parseIsoDate(stored);
  }

  Future<String?> _read(String key) async {
    final rows = await _db.query(
      _table,
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return switch (rows.firstOrNull) {
      {'value': final String value} => value,
      _ => null,
    };
  }

  Future<void> _write(String key, String value) async {
    await _db.insert(_table, {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
