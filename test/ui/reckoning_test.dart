import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:pushup_ledger/app.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/domain/models/log_entry.dart';
import 'package:pushup_ledger/state/ledger_controller.dart';
import 'package:pushup_ledger/ui/reckoning/reckoning_screen.dart';

import '../helpers/fake_clock.dart';
import '../helpers/fake_repositories.dart';

void main() {
  late FakeSettingsRepository settings;
  late LedgerController controller;

  Future<void> pumpMissedDay(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final clock = FakeClock(DateTime(2026, 11, 25, 8));
    final logs = FakeLogRepository(clock)
      ..stored.add(
        LogEntry(id: 1, createdAt: DateTime(2026, 11, 24, 7), count: 20),
      );
    settings = FakeSettingsRepository(DateTime(2026, 11, 24));
    controller = LedgerController(logs: logs, settings: settings, clock: clock);
    await controller.load();
    await controller.openReckoningIfDue(isColdStart: true);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const PushupLedgerApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the verdict and the debt', (tester) async {
    await pumpMissedDay(tester);

    expect(find.byType(ReckoningScreen), findsOneWidget);
    expect(find.text(AppCopy.verdict(20, 30)), findsOneWidget);
    expect(find.text(AppCopy.owes(30)), findsOneWidget);
  });

  testWidgets('a short press does not dismiss', (tester) async {
    await pumpMissedDay(tester);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text(AppCopy.holdToPay).first),
    );
    await tester.pump(const Duration(milliseconds: 1400));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.byType(ReckoningScreen), findsOneWidget);
    expect(settings.lastVerdict, isNull);
  });

  testWidgets('a full hold dismisses and records the verdict', (tester) async {
    await pumpMissedDay(tester);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text(AppCopy.holdToPay).first),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.byType(ReckoningScreen), findsNothing);
    expect(find.text(AppCopy.labelDebt), findsOneWidget);
    expect(settings.lastVerdict, DateTime(2026, 11, 24));
  });

  testWidgets('the back button cannot dismiss', (tester) async {
    await pumpMissedDay(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(ReckoningScreen), findsOneWidget);
  });
}
