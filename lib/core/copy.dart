import 'package:intl/intl.dart';
import 'package:pushup_ledger/core/constants.dart';

/// All user-facing text.
abstract final class AppCopy {
  static const String appName = 'Pushup Ledger';
  static const String navToday = 'Today';
  static const String navHistory = 'History';

  static const String labelToday = 'TODAY';
  static const String labelDebt = 'DEBT';
  static const String labelCarriedDebt = 'CARRIED DEBT';
  static const String labelWeek = 'THIS WEEK';
  static const String labelEntries = 'ENTRIES';
  static const List<String> weekdayLetters = [
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
    'S',
  ];

  static const String logPushups = 'Log push-ups';
  static const String logTitle = 'Log a set';
  static const String confirm = 'Confirm';
  static const String back = 'Back';
  static const String undo = 'Undo';
  static const String decreaseCount = 'One less';
  static const String increaseCount = 'One more';
  static const String noEntries = 'Nothing logged today.';
  static const String noStartDate = 'No start date chosen yet.';
  static const String dayDone = 'Done for today';
  static const String pushUpsOwed = 'push-ups owed';
  static const String debtOverdue = 'Overdue. Pay it back.';

  static const String betweenWindows = 'Morning window ended';
  static const String dayComplete = 'Today is complete';

  static String get beforeMorning =>
      'Morning window opens at ${morningStartHour.toString().padLeft(2, '0')}:00';

  static String outOfTarget() => '/ $dailyTarget';
  static String left(int reps) => '$reps left';
  static String logCount(int reps) => 'Log $reps';
  static String streak(int current, int best) => 'Streak $current · Best $best';
  static String reps(int count) => count == 1 ? '1 push-up' : '$count push-ups';
  static String confirmSet(int count) => 'Confirm: ${reps(count)} done now.';
  static String startsOn(DateTime date) =>
      'Your ledger starts ${DateFormat('EEE d MMM', 'en_US').format(date)}.';
  static String entryTime(DateTime time) =>
      DateFormat('HH:mm', 'en_US').format(time);
  static String morningCloses(Duration left) =>
      'Morning window · closes in ${timeLeft(left)}';
  static String eveningCloses(Duration left) =>
      'Evening window · closes in ${timeLeft(left)}';
  static String dayClosing(int reps) =>
      'Evening window ended · $reps still due before midnight';
  static String debtDue(Duration left) =>
      'Due Sunday 23:59 · ${timeLeft(left)} left';

  static const String labelTotals = 'TOTALS';
  static const String labelDays = 'DAYS';
  static const String labelWeeks = 'WEEKS';
  static const String gridLess = 'Less';
  static const String gridMore = 'More';
  static const String allTimePushups = 'All-time push-ups';
  static const String weekClean = 'Clean';
  static const String weekRecovered = 'Recovered';
  static const String weekFailed = 'Failed';
  static const String weekInProgress = 'In progress';
  static const String detailCounted = 'Counted for the day';
  static const String detailExtra = 'Extra';
  static const String detailDebtPaid = 'Debt paid this day';

  static String daysCompleted(int completed, int tracked) =>
      '$completed of $tracked days completed';
  static String quotaOfTarget(int reps) => '$reps / $dailyTarget';
  static String stillOwed(int reps) => '$reps still owed';
  static String dayTitle(DateTime date) =>
      DateFormat('EEE d MMM', 'en_US').format(date);
  static String paidBack(int reps, DateTime date) =>
      '$reps paid back on ${dayTitle(date)}';
  static String weekRange(DateTime monday, DateTime sunday) {
    final format = DateFormat('d MMM', 'en_US');
    return '${format.format(monday)} – ${format.format(sunday)}';
  }

  static const String labelOutstandingDebt = 'OUTSTANDING DEBT';
  static const String labelDayClosing = 'DAY CLOSING';
  static const String pushUpsUnit = 'push-ups';
  static const String promisedFifty = 'You promised fifty.';
  static const String debtCarriedOver = 'Debt carried over.';
  static const String holdToPay = 'I will pay it';

  static String weekFailedLabel(int week) => 'WEEK $week · FAILED';
  static String weekFailedRecord(int week) =>
      'Week $week is marked failed. That record does not change.';
  static String verdict(int quota, int added) =>
      'Yesterday: $quota / $dailyTarget. $added added to your debt.';
  static String owes(int reps) => 'owes $reps';
  static String weekClosesIn(Duration left) =>
      'Week closes in ${timeLeft(left)}';
  static String dayClosesIn(Duration left) => 'Day closes in ${timeLeft(left)}';

  static const String channelWindows = 'Window reminders';
  static const String channelWarnings = 'Warnings';
  static const String testNotificationBody =
      'Test notification. Reminders are working.';
  static const String notifyCarried =
      'Debt carried over. Last week is marked failed.';

  static String notifyMorningOpen(int left, int owed) {
    final base = 'Morning window open. $left today.';
    return owed > 0 ? '$base You owe $owed.' : base;
  }

  static String notifyMorningClosing(int left) =>
      'Morning window closes in 30 min. $left left today.';
  static String notifyMorningEnded(int left) =>
      'Morning window ended. $left still due today.';
  static String notifyDebtDue(int owed) => 'You owe $owed. Due Sunday 23:59.';
  static String notifyEveningOpen(int left) =>
      'Evening window open. $left left today.';
  static String notifyEveningHour(int left) =>
      'One hour left in the evening window. $left left.';
  static String notifyEveningEnded(int left) =>
      'Evening window ended. $left not done.';
  static String notifyDayCloses(int left) =>
      'Day closes at midnight. $left will become debt.';
  static String notifyLastCall(int left) => '30 minutes. $left push-ups. Now.';
  static String notifyWeekCloses(Duration left, int owed) {
    final time = left.inHours > 0
        ? '${left.inHours} h'
        : '${left.inMinutes} min';
    return 'Week closes in $time. You owe $owed.';
  }

  static const String contractTitle = 'The contract';
  static const List<String> contractLines = [
    'Fifty push-ups. Every day.',
    'Missed reps become debt.',
    'Debt is due Sunday at 23:59.',
    'No exceptions.',
  ];
  static const String holdToSign = 'Hold to sign';
  static const String startTitle = 'When do you start?';
  static const String startToday = 'Start today';
  static const String startTomorrow = 'Start tomorrow';
  static const String allow = 'Allow';
  static const String notNow = 'Not now';
  static const String permissionNotificationsTitle = 'Notifications';
  static const String permissionNotificationsBody =
      'Reminders are how this app holds you to the rule. Without them, it stays silent.';
  static const String permissionAlarmsTitle = 'Exact alarms';
  static const String permissionAlarmsBody =
      'Warnings must arrive on time. A reminder at 23:30 is useless at 23:50.';
  static const String permissionBatteryTitle = 'Battery optimization';
  static const String permissionBatteryBody =
      'Android can stop background reminders to save power. This exemption prevents that.';
  static const String settingsTitle = 'Settings';
  static const String labelPermissions = 'PERMISSIONS';
  static const String labelAbout = 'ABOUT';
  static const String permissionAllowed = 'Allowed';
  static const String permissionNeeded = 'Needed';
  static const String fix = 'Fix';
  static const String sendTestNotification = 'Send test notification';
  static const String aboutBody =
      'Fifty push-ups every day. All data stays on this phone.';

  static const String labelBackup = 'BACKUP';
  static const String exportBackup = 'Export backup';
  static const String backupSaved = 'Backup saved.';
  static const String backupCancelled = 'Backup not saved.';
  static const String backupFailed = 'Backup failed. Try again.';

  static String widgetLine(int left, int owed) {
    final today = left > 0 ? '$left left today' : 'Done today';
    return owed > 0 ? '$today · You owe $owed' : today;
  }

  /// Formats a countdown such as `2 d 04 h`, `1 h 12 min`, or `9 min`.
  static String timeLeft(Duration value) {
    final hours = value.inHours.remainder(Duration.hoursPerDay);
    final minutes = value.inMinutes.remainder(Duration.minutesPerHour);
    if (value.inDays > 0) {
      return '${value.inDays} d ${hours.toString().padLeft(2, '0')} h';
    }
    if (value.inHours > 0) {
      return '${value.inHours} h $minutes min';
    }
    return value.inMinutes > 0 ? '$minutes min' : 'under 1 min';
  }
}
