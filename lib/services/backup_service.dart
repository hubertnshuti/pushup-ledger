import 'package:flutter/services.dart';
import 'package:pushup_ledger/domain/backup.dart';

/// Saves backups through Android's system file picker.
class DeviceBackupSaver implements BackupSaver {
  const DeviceBackupSaver();

  static const MethodChannel _channel = MethodChannel('pushup_ledger/backup');

  @override
  Future<bool> save({required String fileName, required String content}) async {
    final saved = await _channel.invokeMethod<bool>('save', {
      'fileName': fileName,
      'content': content,
    });
    return saved ?? false;
  }
}
