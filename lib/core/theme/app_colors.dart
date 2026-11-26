import 'dart:ui';

/// Every color used by the app.
abstract final class AppColors {
  static const Color cream = Color(0xFFF3EEE3);
  static const Color ink = Color(0xFF111111);
  static const Color orange = Color(0xFFD9541E);

  static const Color surface = Color(0xFFFBF8F2);
  static const Color hairline = Color(0xFFDDD5C4);
  static const Color inkMuted = Color(0xFF5C574F);
  static const Color inkFaint = Color(0xFF8A8377);
  static const Color orangeText = Color(0xFFB8441A);
  static const Color orangePressed = Color(0xFFB8441A);
  static const Color orangeTint = Color(0xFFEFD7C5);
  static const Color creamOnInk = Color(0xFFF3EEE3);
  static const Color mutedOnInk = Color(0xFFA39C90);

  /// Ink at 8 %, for ripples and the bottom sheet shadow.
  static const Color inkOverlay = Color(0x14111111);

  /// Cream at 15 %, for dividers on ink screens.
  static const Color hairlineOnInk = Color(0x26F3EEE3);

  static const Color gridEmpty = Color(0xFFE6DFD1);
  static const Color gridLow = Color(0xFFEAB89E);
  static const Color gridMid = Color(0xFFE3926D);

  static const Color transparent = Color(0x00000000);
}
