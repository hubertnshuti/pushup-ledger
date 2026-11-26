import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/domain/backup.dart';
import 'package:pushup_ledger/services/permission_service.dart';
import 'package:pushup_ledger/state/ledger_controller.dart';
import 'package:pushup_ledger/ui/settings/settings_screen.dart';

import '../helpers/fake_clock.dart';
import '../helpers/fake_repositories.dart';

class FakeSaver implements BackupSaver {
  FakeSaver({this.result = true, this.shouldFail = false});

  final bool result;
  final bool shouldFail;
  String? savedName;

  @override
  Future<bool> save({required String fileName, required String content}) async {
    if (shouldFail) {
      throw PlatformException(code: 'backup_write_failed');
    }
    savedName = fileName;
    return result;
  }
}

class GrantedPermissions implements PermissionService {
  @override
  Future<bool> isGranted(AppPermission permission) async => true;

  @override
  Future<bool> request(AppPermission permission) async => true;
}

void main() {
  Future<void> exportWith(WidgetTester tester, FakeSaver saver) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final clock = FakeClock(DateTime(2026, 11, 25, 7));
    final controller = LedgerController(
      logs: FakeLogRepository(clock),
      settings: FakeSettingsRepository(DateTime(2026, 11, 25)),
      clock: clock,
    );
    await controller.load();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<PermissionService>.value(value: GrantedPermissions()),
          Provider<BackupSaver>.value(value: saver),
          ChangeNotifierProvider.value(value: controller),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppCopy.exportBackup));
    await tester.pumpAndSettle();
  }

  testWidgets('reports a saved backup', (tester) async {
    final saver = FakeSaver();
    await exportWith(tester, saver);

    expect(saver.savedName, 'pushup_ledger_backup_2026-11-25.json');
    expect(find.text(AppCopy.backupSaved), findsOneWidget);
  });

  testWidgets('reports a cancelled backup', (tester) async {
    await exportWith(tester, FakeSaver(result: false));

    expect(find.text(AppCopy.backupCancelled), findsOneWidget);
  });

  testWidgets('reports a failed backup', (tester) async {
    await exportWith(tester, FakeSaver(shouldFail: true));

    expect(find.text(AppCopy.backupFailed), findsOneWidget);
  });
}
