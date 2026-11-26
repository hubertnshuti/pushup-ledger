import 'package:permission_handler/permission_handler.dart';

/// The device permissions reminders depend on.
enum AppPermission { notifications, exactAlarms, batteryOptimization }

/// Checks and requests device permissions.
abstract interface class PermissionService {
  Future<bool> isGranted(AppPermission permission);

  /// Asks for [permission] and returns whether it is now granted.
  Future<bool> request(AppPermission permission);
}

/// Uses the real Android permission system.
class DevicePermissionService implements PermissionService {
  const DevicePermissionService();

  Permission _platform(AppPermission permission) => switch (permission) {
    AppPermission.notifications => Permission.notification,
    AppPermission.exactAlarms => Permission.scheduleExactAlarm,
    AppPermission.batteryOptimization => Permission.ignoreBatteryOptimizations,
  };

  @override
  Future<bool> isGranted(AppPermission permission) =>
      _platform(permission).isGranted;

  @override
  Future<bool> request(AppPermission permission) async {
    final platform = _platform(permission);
    if (await platform.isPermanentlyDenied) {
      await openAppSettings();
      return platform.isGranted;
    }
    final status = await platform.request();
    return status.isGranted;
  }
}
