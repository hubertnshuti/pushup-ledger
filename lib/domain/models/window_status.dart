/// Where the current time sits in the daily routine.
enum WindowPhase {
  dayComplete,
  beforeMorning,
  morningOpen,
  betweenWindows,
  eveningOpen,
  dayClosing,
}

/// The current phase and, when something is closing, the time left.
class WindowStatus {
  const WindowStatus(this.phase, {this.timeLeft});

  final WindowPhase phase;
  final Duration? timeLeft;

  @override
  bool operator ==(Object other) =>
      other is WindowStatus &&
      other.phase == phase &&
      other.timeLeft == timeLeft;

  @override
  int get hashCode => Object.hash(phase, timeLeft);
}
