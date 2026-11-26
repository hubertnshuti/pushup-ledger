import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:pushup_ledger/core/copy.dart';
import 'package:pushup_ledger/core/theme/app_colors.dart';
import 'package:pushup_ledger/core/theme/app_spacing.dart';
import 'package:pushup_ledger/core/theme/app_typography.dart';
import 'package:pushup_ledger/domain/backup.dart';
import 'package:pushup_ledger/domain/notification_planner.dart';
import 'package:pushup_ledger/services/permission_service.dart';
import 'package:pushup_ledger/state/ledger_controller.dart';

/// Permission status, a test notification, and app information.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  Map<AppPermission, bool> _granted = const {};
  String? _backupMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadStatuses();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadStatuses();
    }
  }

  Future<void> _loadStatuses() async {
    final service = context.read<PermissionService>();
    final granted = <AppPermission, bool>{
      for (final permission in AppPermission.values)
        permission: await service.isGranted(permission),
    };
    if (mounted) {
      setState(() => _granted = granted);
    }
  }

  Future<void> _fix(AppPermission permission) async {
    await context.read<PermissionService>().request(permission);
    await _loadStatuses();
  }

  Future<void> _exportBackup() async {
    final controller = context.read<LedgerController>();
    final saver = context.read<BackupSaver>();
    String message;
    try {
      final saved = await controller.exportBackup(saver);
      message = saved ? AppCopy.backupSaved : AppCopy.backupCancelled;
    } on Exception {
      message = AppCopy.backupFailed;
    }
    if (mounted) {
      setState(() => _backupMessage = message);
    }
  }

  String _title(AppPermission permission) => switch (permission) {
    AppPermission.notifications => AppCopy.permissionNotificationsTitle,
    AppPermission.exactAlarms => AppCopy.permissionAlarmsTitle,
    AppPermission.batteryOptimization => AppCopy.permissionBatteryTitle,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppCopy.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.lg,
          ),
          children: [
            Text(
              AppCopy.labelPermissions,
              style: AppTypography.label.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final permission in AppPermission.values)
              _PermissionRow(
                title: _title(permission),
                isGranted: _granted[permission] ?? false,
                onFix: () => _fix(permission),
              ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: () => context.read<NotificationScheduler>().showTest(),
              child: const Text(AppCopy.sendTestNotification),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              AppCopy.labelBackup,
              style: AppTypography.label.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _exportBackup,
                child: const Text(AppCopy.exportBackup),
              ),
            ),
            if (_backupMessage case final message?)
              Text(
                message,
                style: AppTypography.caption.copyWith(
                  color: AppColors.inkMuted,
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              AppCopy.labelAbout,
              style: AppTypography.label.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(AppCopy.aboutBody, style: AppTypography.body),
          ],
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.title,
    required this.isGranted,
    required this.onFix,
  });

  final String title;
  final bool isGranted;
  final VoidCallback onFix;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyStrong),
                Text(
                  isGranted
                      ? AppCopy.permissionAllowed
                      : AppCopy.permissionNeeded,
                  style: AppTypography.caption.copyWith(
                    color: isGranted
                        ? AppColors.inkMuted
                        : AppColors.orangeText,
                  ),
                ),
              ],
            ),
          ),
          if (!isGranted)
            TextButton(onPressed: onFix, child: const Text(AppCopy.fix)),
        ],
      ),
    );
  }
}
