/// Removes the time of day, leaving local midnight of the same calendar day.
DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// Moves by calendar days, so daylight-saving changes cannot skip a date.
DateTime addDays(DateTime value, int days) =>
    DateTime(value.year, value.month, value.day + days);

/// The Monday of the week containing [value].
DateTime mondayOf(DateTime value) =>
    addDays(value, DateTime.monday - value.weekday);

/// The Sunday of the week containing [value].
DateTime sundayOf(DateTime value) =>
    addDays(mondayOf(value), DateTime.daysPerWeek - 1);

/// The last whole second of the calendar day containing [value].
DateTime endOfDay(DateTime value) =>
    DateTime(value.year, value.month, value.day, 23, 59, 59);

/// The ISO-8601 week number, where a week belongs to the year of its Thursday.
int isoWeekNumber(DateTime value) {
  final thursday = addDays(mondayOf(value), DateTime.thursday - 1);
  final dayOfYear = DateTime.utc(
    thursday.year,
    thursday.month,
    thursday.day,
  ).difference(DateTime.utc(thursday.year)).inDays;
  return dayOfYear ~/ DateTime.daysPerWeek + 1;
}

/// Formats the calendar day of [value] as `yyyy-MM-dd`.
String formatIsoDate(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

/// Parses a `yyyy-MM-dd` string, returning null if it is not a real date.
DateTime? parseIsoDate(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
  if (match == null) {
    return null;
  }
  final [year, month, day] = [
    for (final group in [1, 2, 3]) int.parse(match.group(group) ?? ''),
  ];
  final date = DateTime(year, month, day);
  final isRealDate = date.month == month && date.day == day;
  return isRealDate ? date : null;
}
