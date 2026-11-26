import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pushup_ledger/domain/widget_projection.dart';
import 'package:pushup_ledger/state/ledger_controller.dart';

import '../helpers/fake_clock.dart';
import '../helpers/fake_repositories.dart';

class FakeWidgetPublisher implements HomeWidgetPublisher {
  FakeWidgetPublisher({this.shouldFail = false});

  final bool shouldFail;
  Map<String, String> latest = const {};

  @override
  Future<void> publish(Map<String, String> linesByDate) async {
    if (shouldFail) {
      throw PlatformException(code: 'unavailable');
    }
    latest = linesByDate;
  }
}

void main() {
  LedgerController build(
    FakeWidgetPublisher publisher,
    FakeLogRepository logs,
  ) {
    return LedgerController(
      logs: logs,
      settings: FakeSettingsRepository(DateTime(2026, 11, 25)),
      clock: logs.clock,
      widgetPublisher: publisher,
    );
  }

  test('logging a set updates the widget', () async {
    final publisher = FakeWidgetPublisher();
    final logs = FakeLogRepository(FakeClock(DateTime(2026, 11, 25, 7)));
    final controller = build(publisher, logs);

    await controller.load();
    await controller.logSet(20);
    await controller.notificationsSynced;

    expect(publisher.latest['2026-11-25'], '30 left today');
  });

  test('a widget failure does not lose the logged set', () async {
    final publisher = FakeWidgetPublisher(shouldFail: true);
    final logs = FakeLogRepository(FakeClock(DateTime(2026, 11, 25, 7)));
    final controller = build(publisher, logs);

    await controller.load();
    await controller.logSet(20);
    await controller.notificationsSynced;

    expect(logs.stored.single.count, 20);
    expect(controller.today?.quotaReps, 20);
  });
}
