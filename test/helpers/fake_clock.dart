import 'package:pushup_ledger/core/clock.dart';

/// A clock whose time is set by the test.
class FakeClock implements Clock {
  FakeClock(this.current);

  DateTime current;

  @override
  DateTime now() => current;
}
