import 'package:flutter_test/flutter_test.dart';
import 'package:pushup_ledger/core/clock.dart';
import 'package:pushup_ledger/core/dates.dart';

import '../helpers/fake_clock.dart';

void main() {
  test('dateOnly removes the time of day', () {
    expect(dateOnly(DateTime(2026, 11, 24, 18, 30)), DateTime(2026, 11, 24));
  });

  test('addDays crosses month and year boundaries', () {
    expect(addDays(DateTime(2026, 12, 31), 1), DateTime(2027));
  });

  test('mondayOf and sundayOf find the week edges', () {
    final wednesday = DateTime(2026, 11, 25, 12);
    expect(mondayOf(wednesday), DateTime(2026, 11, 23));
    expect(sundayOf(wednesday), DateTime(2026, 11, 29));
  });

  test('Monday and Sunday belong to the same week', () {
    expect(mondayOf(DateTime(2026, 11, 23)), DateTime(2026, 11, 23));
    expect(mondayOf(DateTime(2026, 11, 29)), DateTime(2026, 11, 23));
  });

  test('endOfDay returns 23:59:59', () {
    expect(
      endOfDay(DateTime(2026, 11, 29, 8)),
      DateTime(2026, 11, 29, 23, 59, 59),
    );
  });

  test('ISO dates round-trip with zero padding', () {
    final date = DateTime(2027, 1, 5);
    expect(formatIsoDate(date), '2027-01-05');
    expect(parseIsoDate('2027-01-05'), date);
  });

  test('parseIsoDate rejects malformed and impossible dates', () {
    expect(parseIsoDate('2027-1-5'), isNull);
    expect(parseIsoDate('2027-02-30'), isNull);
    expect(parseIsoDate('not a date'), isNull);
  });

  test('isoWeekNumber handles ordinary weeks and year boundaries', () {
    expect(isoWeekNumber(DateTime(2026, 11, 24)), 48);
    expect(isoWeekNumber(DateTime(2026)), 1);
    expect(isoWeekNumber(DateTime(2027)), 53);
    expect(isoWeekNumber(DateTime(2024, 12, 30)), 1);
  });

  test('a fake clock can stand in for the real clock', () {
    final Clock clock = FakeClock(DateTime(2026, 11, 23, 7));
    expect(clock.now(), DateTime(2026, 11, 23, 7));
  });
}
