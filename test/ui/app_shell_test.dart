import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:pushup_ledger/app.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/core/theme/app_colors.dart';
import 'package:pushup_ledger/state/ledger_controller.dart';
import 'package:pushup_ledger/ui/history/history_screen.dart';
import 'package:pushup_ledger/ui/home/today_screen.dart';

import '../helpers/fake_clock.dart';
import '../helpers/fake_repositories.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    final clock = FakeClock(DateTime(2026, 11, 25, 7));
    final controller = LedgerController(
      logs: FakeLogRepository(clock),
      settings: FakeSettingsRepository(DateTime(2026, 11, 25)),
      clock: clock,
    );
    await controller.load();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const PushupLedgerApp(),
      ),
    );
  }

  testWidgets('bottom navigation switches between screens', (tester) async {
    await pumpApp(tester);

    expect(find.byType(TodayScreen), findsOneWidget);
    expect(find.byType(HistoryScreen), findsNothing);

    await tester.tap(find.byIcon(Icons.grid_view_outlined));
    await tester.pump();

    expect(find.byType(HistoryScreen), findsOneWidget);
    expect(find.text(AppCopy.navHistory), findsWidgets);
  });

  testWidgets('theme uses brand colors', (tester) async {
    await pumpApp(tester);
    final theme = Theme.of(tester.element(find.byType(TodayScreen)));

    expect(theme.colorScheme.primary, AppColors.orange);
    expect(theme.scaffoldBackgroundColor, AppColors.cream);
    expect(theme.colorScheme.surfaceTint, AppColors.transparent);
  });
}
