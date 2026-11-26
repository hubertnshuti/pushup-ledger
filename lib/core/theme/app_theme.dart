import 'package:material_ui/material_ui.dart';
import 'package:pushup_ledger/core/theme/app_colors.dart';
import 'package:pushup_ledger/core/theme/app_spacing.dart';
import 'package:pushup_ledger/core/theme/app_typography.dart';

/// Builds the app theme, replacing every default Material color.
ThemeData buildAppTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.orange,
    onPrimary: AppColors.ink,
    primaryContainer: AppColors.orangeTint,
    onPrimaryContainer: AppColors.ink,
    secondary: AppColors.ink,
    onSecondary: AppColors.cream,
    secondaryContainer: AppColors.hairline,
    onSecondaryContainer: AppColors.ink,
    tertiary: AppColors.ink,
    onTertiary: AppColors.cream,
    tertiaryContainer: AppColors.hairline,
    onTertiaryContainer: AppColors.ink,
    error: AppColors.orange,
    onError: AppColors.ink,
    errorContainer: AppColors.orangeTint,
    onErrorContainer: AppColors.ink,
    surface: AppColors.cream,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.inkMuted,
    surfaceDim: AppColors.cream,
    surfaceBright: AppColors.surface,
    surfaceContainerLowest: AppColors.surface,
    surfaceContainerLow: AppColors.surface,
    surfaceContainer: AppColors.surface,
    surfaceContainerHigh: AppColors.surface,
    surfaceContainerHighest: AppColors.surface,
    outline: AppColors.hairline,
    outlineVariant: AppColors.hairline,
    shadow: AppColors.inkOverlay,
    scrim: AppColors.ink,
    inverseSurface: AppColors.ink,
    onInverseSurface: AppColors.creamOnInk,
    inversePrimary: AppColors.orange,
    surfaceTint: AppColors.transparent,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: AppTypography.body.fontFamily,
    scaffoldBackgroundColor: AppColors.cream,
    splashColor: AppColors.inkOverlay,
    highlightColor: AppColors.inkOverlay,
    hoverColor: AppColors.inkOverlay,
    focusColor: AppColors.inkOverlay,
    textTheme: _textTheme,
    iconTheme: const IconThemeData(color: AppColors.ink, size: AppSizes.icon),
    dividerTheme: const DividerThemeData(
      color: AppColors.hairline,
      thickness: AppSizes.border,
      space: AppSizes.border,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.cream,
      foregroundColor: AppColors.ink,
      surfaceTintColor: AppColors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTypography.title.copyWith(color: AppColors.ink),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      surfaceTintColor: AppColors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: const BorderSide(
          color: AppColors.hairline,
          width: AppSizes.border,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.pressed)
              ? AppColors.orangePressed
              : AppColors.orange,
        ),
        foregroundColor: const WidgetStatePropertyAll(AppColors.ink),
        overlayColor: const WidgetStatePropertyAll(AppColors.inkOverlay),
        elevation: const WidgetStatePropertyAll(0),
        minimumSize: const WidgetStatePropertyAll(
          Size.fromHeight(AppSizes.primaryButton),
        ),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
        textStyle: const WidgetStatePropertyAll(AppTypography.bodyStrong),
      ),
    ),
    textButtonTheme: const TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(AppColors.ink),
        overlayColor: WidgetStatePropertyAll(AppColors.inkOverlay),
        minimumSize: WidgetStatePropertyAll(
          Size(AppSizes.minTouchTarget, AppSizes.minTouchTarget),
        ),
        shape: WidgetStatePropertyAll(StadiumBorder()),
        textStyle: WidgetStatePropertyAll(AppTypography.bodyStrong),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      modalBackgroundColor: AppColors.surface,
      surfaceTintColor: AppColors.transparent,
      shadowColor: AppColors.inkOverlay,
      elevation: AppSizes.sheetElevation,
      modalElevation: AppSizes.sheetElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.sheet),
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.cream,
      selectedItemColor: AppColors.ink,
      unselectedItemColor: AppColors.inkFaint,
      selectedLabelStyle: AppTypography.caption,
      unselectedLabelStyle: AppTypography.caption,
      elevation: 0,
    ),
  );
}

const TextTheme _textTheme = TextTheme(
  displayLarge: AppTypography.numeralXL,
  displayMedium: AppTypography.numeralL,
  displaySmall: AppTypography.display,
  headlineMedium: AppTypography.title,
  titleLarge: AppTypography.title,
  titleMedium: AppTypography.heading,
  bodyLarge: AppTypography.body,
  bodyMedium: AppTypography.body,
  bodySmall: AppTypography.caption,
  labelLarge: AppTypography.bodyStrong,
  labelMedium: AppTypography.label,
  labelSmall: AppTypography.label,
);
