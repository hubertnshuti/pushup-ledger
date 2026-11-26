/// A source of the current time that tests can replace.
abstract interface class Clock {
  DateTime now();
}

/// The real device clock.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
