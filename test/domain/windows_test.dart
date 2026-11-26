import 'package:flutter_test/flutter_test.dart';
import 'package:pushup_ledger/domain/models/window_status.dart';
import 'package:pushup_ledger/domain/windows.dart';

void main() {
  WindowPhase phaseAt(int hour, int minute) => windowStatusAt(
    DateTime(2026, 11, 24, hour, minute),
    isDayComplete: false,
  ).phase;

  test('each boundary lands in the correct phase', () {
    expect(phaseAt(0, 0), WindowPhase.beforeMorning);
    expect(phaseAt(4, 59), WindowPhase.beforeMorning);
    expect(phaseAt(5, 0), WindowPhase.morningOpen);
    expect(phaseAt(8, 59), WindowPhase.morningOpen);
    expect(phaseAt(9, 0), WindowPhase.betweenWindows);
    expect(phaseAt(15, 59), WindowPhase.betweenWindows);
    expect(phaseAt(16, 0), WindowPhase.eveningOpen);
    expect(phaseAt(20, 59), WindowPhase.eveningOpen);
    expect(phaseAt(21, 0), WindowPhase.dayClosing);
    expect(phaseAt(23, 59), WindowPhase.dayClosing);
  });

  test('a complete day overrides every time', () {
    for (final hour in [0, 6, 12, 18, 23]) {
      expect(
        windowStatusAt(DateTime(2026, 11, 24, hour), isDayComplete: true).phase,
        WindowPhase.dayComplete,
      );
    }
  });

  test('open windows report the time left', () {
    expect(
      windowStatusAt(
        DateTime(2026, 11, 24, 8, 30),
        isDayComplete: false,
      ).timeLeft,
      const Duration(minutes: 30),
    );
    expect(
      windowStatusAt(
        DateTime(2026, 11, 24, 19, 48),
        isDayComplete: false,
      ).timeLeft,
      const Duration(hours: 1, minutes: 12),
    );
  });

  test('day closing reports the time until midnight', () {
    expect(
      windowStatusAt(
        DateTime(2026, 11, 24, 23, 30),
        isDayComplete: false,
      ).timeLeft,
      const Duration(minutes: 30),
    );
  });
}
