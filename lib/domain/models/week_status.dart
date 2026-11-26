/// The verdict for one Monday-to-Sunday week.
enum WeekStatus {
  /// The week has not ended.
  inProgress,

  /// Every tracked day was completed on the day.
  clean,

  /// Some days were missed, but their debt was paid by Sunday night.
  recovered,

  /// Some debt from this week missed the Sunday deadline.
  failed,
}
