import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:pushup_ledger/app.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/domain/notification_planner.dart';
import 'package:pushup_ledger/services/permission_service.dart';
import 'package:pushup_ledger/state/ledger_controller.dart';
import 'package:pushup_ledger/ui/home/today_screen.dart';

import '../helpers/fake_clock.dart';
import '../helpers/fake_repositories.dart';

class FakePermissions implements PermissionService {
  final Set<AppPermission> granted = {};
  final List<AppPermission> requested = [];

  @override
  Future<bool> isGranted(AppPermission permission) async =>
      granted.contains(permission);

  @override
  Future<bool> request(AppPermission permission) async {
    requested.add(permission);
    granted.add(permission);
    return true;
  }
}

class FakeScheduler implements NotificationScheduler {
  int rescheduleCount = 0;
  int testCount = 0;

  @override
  Future<void> reschedule(List<PlannedNotification> plan) async {
    rescheduleCount++;
  }

  @override
  Future<void> showTest() async => testCount++;
}

void main() {
  late FakeSettingsRepository settings;
  late FakePermissions permissions;
  late FakeScheduler scheduler;
  late LedgerController controller;

  Future<void> pumpApp(WidgetTester tester, {required bool onboarded}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final clock = FakeClock(DateTime(2026, 11, 25, 7));
    settings = FakeSettingsRepository(onboarded ? DateTime(2026, 11, 25) : null)
      ..isOnboardingDone = onboarded;
    permissions = FakePermissions();
    scheduler = FakeScheduler();
    controller = LedgerController(
      logs: FakeLogRepository(clock),
      settings: settings,
      clock: clock,
      scheduler: scheduler,
    );
    await controller.load();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<PermissionService>.value(value: permissions),
          Provider<NotificationScheduler>.value(value: scheduler),
          ChangeNotifierProvider.value(value: controller),
        ],
        child: const PushupLedgerApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> holdToSign(WidgetTester tester) async {
    final gesture = await tester.startGesture(
      tester.getCenter(find.text(AppCopy.holdToSign).first),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await gesture.up();
    await tester.pumpAndSettle();
  }

  testWidgets('onboarding saves the start date and opens the app', (
    tester,
  ) async {
    await pumpApp(tester, onboarded: false);

    await holdToSign(tester);
    await tester.tap(find.text(AppCopy.startTomorrow));
    await tester.pumpAndSettle();
    for (var i = 0; i < AppPermission.values.length; i++) {
      await tester.tap(find.text(AppCopy.allow));
      await tester.pumpAndSettle();
    }

    expect(settings.start, DateTime(2026, 11, 26));
    expect(settings.isOnboardingDone, isTrue);
    expect(permissions.requested, AppPermission.values);
    expect(find.byType(TodayScreen), findsOneWidget);
  });

  testWidgets('a denied permission does not block onboarding', (tester) async {
    await pumpApp(tester, onboarded: false);

    await holdToSign(tester);
    await tester.tap(find.text(AppCopy.startToday));
    await tester.pumpAndSettle();
    for (var i = 0; i < AppPermission.values.length; i++) {
      await tester.tap(find.text(AppCopy.notNow));
      await tester.pumpAndSettle();
    }

    expect(settings.start, DateTime(2026, 11, 25));
    expect(find.byType(TodayScreen), findsOneWidget);
  });

  testWidgets('settings fixes a permission and sends a test', (tester) async {
    await pumpApp(tester, onboarded: true);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text(AppCopy.permissionNeeded), findsNWidgets(3));

    await tester.tap(find.text(AppCopy.fix).first);
    await tester.pumpAndSettle();
    expect(find.text(AppCopy.permissionNeeded), findsNWidgets(2));

    await tester.tap(find.text(AppCopy.sendTestNotification));
    await tester.pump();
    expect(scheduler.testCount, 1);
  });

  testWidgets('logging reschedules reminders', (tester) async {
    await pumpApp(tester, onboarded: true);
    await controller.notificationsSynced;
    final before = scheduler.rescheduleCount;

    await controller.logSet(20);
    await controller.notificationsSynced;

    expect(scheduler.rescheduleCount, before + 1);
  });
}
