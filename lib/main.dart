import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:pushup_ledger/app.dart';
import 'package:pushup_ledger/core/clock.dart';
import 'package:pushup_ledger/data/app_database.dart';
import 'package:pushup_ledger/data/log_repository.dart';
import 'package:pushup_ledger/data/settings_repository.dart';
import 'package:pushup_ledger/domain/backup.dart';
import 'package:pushup_ledger/domain/notification_planner.dart';
import 'package:pushup_ledger/services/backup_service.dart';
import 'package:pushup_ledger/services/home_widget_service.dart';
import 'package:pushup_ledger/services/notification_service.dart';
import 'package:pushup_ledger/services/permission_service.dart';
import 'package:pushup_ledger/state/ledger_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const clock = SystemClock();
  final database = await AppDatabase.open();
  final notifications = DeviceNotificationService();
  await notifications.initialize();

  final controller = LedgerController(
    logs: LogRepository(database, clock),
    settings: SettingsRepository(database),
    clock: clock,
    scheduler: notifications,
    widgetPublisher: const DeviceHomeWidgetPublisher(),
  );
  await controller.load();
  await controller.openReckoningIfDue(isColdStart: true);

  runApp(
    MultiProvider(
      providers: [
        Provider<PermissionService>.value(
          value: const DevicePermissionService(),
        ),
        Provider<NotificationScheduler>.value(value: notifications),
        Provider<BackupSaver>.value(value: const DeviceBackupSaver()),
        ChangeNotifierProvider.value(value: controller),
      ],
      child: const PushupLedgerApp(),
    ),
  );
}
