import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:pushup_ledger/app.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/state/ledger_controller.dart';

import '../helpers/fake_clock.dart';
import '../helpers/fake_repositories.dart';

void main() {
  late FakeClock clock;
  late FakeLogRepository logs;
  late LedgerController controller;

  Future<void> pumpApp(WidgetTester tester, {DateTime? startDate}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    controller = LedgerController(
      logs: logs,
      settings: FakeSettingsRepository(startDate),
      clock: clock,
    );
    await controller.load();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const PushupLedgerApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> logThroughSheet(WidgetTester tester, int quickCount) async {
    await tester.tap(find.text(AppCopy.logPushups));
    await tester.pumpAndSettle();
    await tester.tap(find.text('$quickCount').last);
    await tester.pump();
    await tester.tap(find.text(AppCopy.logCount(quickCount)));
    await tester.pumpAndSettle();
    expect(find.text(AppCopy.confirmSet(quickCount)), findsOneWidget);
    await tester.tap(find.text(AppCopy.confirm));
    await tester.pumpAndSettle();
  }

  setUp(() {
    clock = FakeClock(DateTime(2026, 11, 25, 7));
    logs = FakeLogRepository(clock);
  });

  testWidgets('nothing is saved until the set is confirmed', (tester) async {
    await pumpApp(tester, startDate: DateTime(2026, 11, 25));
    await tester.tap(find.text(AppCopy.logPushups));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppCopy.logCount(10)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppCopy.back));
    await tester.pumpAndSettle();

    expect(logs.stored, isEmpty);
  });

  testWidgets('a confirmed set updates today', (tester) async {
    await pumpApp(tester, startDate: DateTime(2026, 11, 25));
    await logThroughSheet(tester, 20);

    expect(logs.stored.single.count, 20);
    expect(find.text(AppCopy.left(30)), findsOneWidget);
  });

  testWidgets('undo is offered only inside its window', (tester) async {
    await pumpApp(tester, startDate: DateTime(2026, 11, 25));
    await logThroughSheet(tester, 20);
    expect(find.text(AppCopy.undo), findsOneWidget);

    clock.current = clock.current.add(const Duration(minutes: 2, seconds: 1));
    controller.refresh();
    await tester.pumpAndSettle();

    expect(find.text(AppCopy.undo), findsNothing);
  });

  testWidgets('open debt shows the debt card', (tester) async {
    await pumpApp(tester, startDate: DateTime(2026, 11, 24));

    expect(find.text(AppCopy.labelDebt), findsOneWidget);
    expect(find.text('50'), findsOneWidget);
  });

  testWidgets('carried debt shows the severe card', (tester) async {
    await pumpApp(tester, startDate: DateTime(2026, 11, 16));

    expect(find.text(AppCopy.labelCarriedDebt), findsOneWidget);
    expect(find.text(AppCopy.debtOverdue), findsOneWidget);
  });

  testWidgets('a future start date blocks logging', (tester) async {
    await pumpApp(tester, startDate: DateTime(2026, 11, 26));

    expect(find.text(AppCopy.startsOn(DateTime(2026, 11, 26))), findsOneWidget);
    expect(find.text(AppCopy.logPushups), findsNothing);
  });
}
