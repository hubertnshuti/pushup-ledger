import 'package:flutter/services.dart';
import 'package:pushup_ledger/domain/widget_projection.dart';

/// Passes widget text to the native Android side.
class DeviceHomeWidgetPublisher implements HomeWidgetPublisher {
  const DeviceHomeWidgetPublisher();

  static const MethodChannel _channel = MethodChannel(
    'pushup_ledger/home_widget',
  );

  @override
  Future<void> publish(Map<String, String> linesByDate) =>
      _channel.invokeMethod<void>('publish', {'lines': linesByDate});
}
