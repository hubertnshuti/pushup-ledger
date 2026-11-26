import 'package:material_ui/material_ui.dart';

/// Every text style used by the app.
abstract final class AppTypography {
  static const String _sans = 'Inter';
  static const String _serif = 'InstrumentSerif';
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];
  static const double _tightSpacing = -0.5;

  static const TextStyle numeralXL = TextStyle(
    fontFamily: _sans,
    fontSize: 88,
    height: 88 / 88,
    fontWeight: FontWeight.w600,
    letterSpacing: _tightSpacing,
    fontFeatures: _tabular,
  );

  static const TextStyle numeralL = TextStyle(
    fontFamily: _sans,
    fontSize: 56,
    height: 60 / 56,
    fontWeight: FontWeight.w600,
    letterSpacing: _tightSpacing,
    fontFeatures: _tabular,
  );

  static const TextStyle display = TextStyle(
    fontFamily: _serif,
    fontSize: 36,
    height: 40 / 36,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
  );

  static const TextStyle title = TextStyle(
    fontFamily: _sans,
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: _tightSpacing,
    fontFeatures: _tabular,
  );

  static const TextStyle heading = TextStyle(
    fontFamily: _sans,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
    fontFeatures: _tabular,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _sans,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    fontFeatures: _tabular,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: _sans,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
    fontFeatures: _tabular,
  );

  /// Section label. Its text must be written in uppercase.
  static const TextStyle label = TextStyle(
    fontFamily: _sans,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    fontFeatures: _tabular,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _sans,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    fontFeatures: _tabular,
  );
}
