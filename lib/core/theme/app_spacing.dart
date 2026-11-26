/// The 4-point spacing scale.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  static const double screenHorizontal = xl;
  static const double cardGap = lg;
}

/// Corner radii.
abstract final class AppRadii {
  static const double card = 16;
  static const double sheet = 24;
  static const double gridCell = 3;
}

/// Fixed component dimensions.
abstract final class AppSizes {
  static const double primaryButton = 56;
  static const double secondaryButton = 48;
  static const double minTouchTarget = 48;
  static const double icon = 24;
  static const double border = 1;
  static const double sheetElevation = 8;
  static const double weekCircle = 36;
  static const double progressBar = 8;
  static const double dot = 2;
  static const double ringStroke = 1.5;
  static const double gridCell = 14;
  static const double gridGap = 3;
}

/// Animation durations.
abstract final class AppMotion {
  static const Duration standard = Duration(milliseconds: 200);
  static const Duration sheet = Duration(milliseconds: 280);
  static const Duration entrance = Duration(milliseconds: 300);
  static const Duration holdToConfirm = Duration(milliseconds: 1500);
  static const double entranceStartScale = 0.98;
}
