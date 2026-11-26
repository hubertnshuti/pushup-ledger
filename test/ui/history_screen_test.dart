import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:pushup_ledger/app.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/domain/models/log_entry.dart';
import 'package:pushup_ledger/state/ledger_controller.dart';

import '../helpers/fake_clock.dart';
import '../helpers/fake_repositories.dart';

void main() {
  testWidgets('a repaid day shows its original score and repayment', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final clock = FakeClock(DateTime(2026, 11, 25, 20));
    final logs = FakeLogRepository(clock)
      ..stored.addAll([
        LogEntry(id: 1, createdAt: DateTime(2026, 11, 24, 7), count: 20),
        LogEntry(id: 2, createdAt: DateTime(2026, 11, 25, 7), count: 80),
      ]);
    final controller = LedgerController(
      logs: logs,
      settings: FakeSettingsRepository(DateTime(2026, 11, 24)),
      clock: clock,
    );
    await controller.load();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const PushupLedgerApp(),
      ),
    );

    await tester.tap(find.byIcon(Icons.grid_view_outlined));
    await tester.pumpAndSettle();

    expect(find.text('100'), findsOneWidget);
    expect(find.text(AppCopy.daysCompleted(1, 2)), findsOneWidget);
    expect(find.text(AppCopy.weekInProgress), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('grid-2026-11-24')));
    await tester.pumpAndSettle();

    expect(find.text(AppCopy.quotaOfTarget(20)), findsOneWidget);
    expect(
      find.text(AppCopy.paidBack(30, DateTime(2026, 11, 25))),
      findsOneWidget,
    );
  });
}
