/// Push-ups required every day.
const int dailyTarget = 50;

/// Push-ups required every Monday-to-Sunday week.
const int weeklyTarget = dailyTarget * DateTime.daysPerWeek;

/// Smallest count accepted for one logged set.
const int minSetCount = 1;

/// Largest count accepted for one logged set.
const int maxSetCount = 200;

/// One-tap counts offered when logging a set.
const List<int> quickSetCounts = [10, 20, 30, 50];

/// Count selected when the log sheet opens.
const int defaultSetCount = 10;

/// How often visible countdowns and undo buttons are updated.
const Duration uiRefreshInterval = Duration(seconds: 15);

/// How long a new log entry can still be deleted.
const Duration undoWindow = Duration(minutes: 2);

/// Minimum gap before a resumed app shows the blocking screen again.
const Duration reckoningResumeGap = Duration(minutes: 15);

/// Hour the morning window opens.
const int morningStartHour = 5;

/// Hour the morning window closes.
const int morningEndHour = 9;

/// Hour the evening window opens.
const int eveningStartHour = 16;

/// Hour the evening window closes.
const int eveningEndHour = 21;
