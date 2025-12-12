import 'package:flutter/material.dart';

/// Application Color Palette - Complete design system
/// Cohesive color palette with primary, secondary, semantic, and neutral colors
class AppColors {
  // ============ PRIMARY PALETTE ============
  /// Main brand color - Blue
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryVeryLight = Color(0xFFE3F2FD);

  /// Secondary color - Teal/Cyan
  static const Color secondary = Color(0xFF009688);
  static const Color secondaryLight = Color(0xFF4DB6AC);
  static const Color secondaryDark = Color(0xFF00695C);

  // ============ SEMANTIC COLORS ============
  /// Success - Green
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successVeryLight = Color(0xFFC8E6C9);

  /// Error - Red
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorVeryLight = Color(0xFFFFCDD2);

  /// Warning - Orange/Amber
  static const Color warning = Color(0xFFFB8C00);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningVeryLight = Color(0xFFFFE0B2);

  /// Info - Light Blue
  static const Color info = Color(0xFF0288D1);
  static const Color infoLight = Color(0xFF4FC3F7);
  static const Color infoVeryLight = Color(0xFFB3E5FC);

  // ============ NEUTRAL PALETTE ============
  /// Background colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color backgroundDarkSecondary = Color(0xFF1E1E1E);

  /// Surface colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceDarkSecondary = Color(0xFF2C2C2C);

  /// Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Dark mode text
  static const Color textDarkPrimary = Color(0xFFFAFAFA);
  static const Color textDarkSecondary = Color(0xFFBDBDBD);
  static const Color textDarkTertiary = Color(0xFF757575);

  // ============ UTILITY COLORS ============
  static const Color divider = Color(0xFFEEEEEE);
  static const Color dividerDark = Color(0xFF424242);
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF616161);
  static const Color shadow = Color(0xFF000000);

  // ============ SPECIAL COLORS ============
  /// Status colors
  static const Color statusConfirmed = success;
  static const Color statusPending = warning;
  static const Color statusCancelled = error;

  /// Hotel/Room colors
  static const Color hotelAvailable = success;
  static const Color hotelOccupied = error;
  static const Color hotelMaintenance = warning;

  /// Room occupied
  static const Color roomAvailable = success;
  static const Color roomOccupied = error;
}

/// Application Text Styles
/// Centralized typography for consistency
class AppTextStyles {
  // ============ HEADINGS ============
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: 0,
  );

  static const TextStyle headline4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.4,
    letterSpacing: 0.15,
  );

  // ============ SUBTITLES ============
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.57,
    letterSpacing: 0.1,
  );

  // ============ BODY TEXT ============
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0.5,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.43,
    letterSpacing: 0.25,
  );

  // ============ CAPTIONS & LABELS ============
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.33,
    letterSpacing: 0.4,
  );

  static const TextStyle captionSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0.5,
  );

  // ============ BUTTONS ============
  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0.5,
  );
}

/// Application Spacing/Padding Constants
class AppSpacing {
  // ============ SMALL ============
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;

  // ============ MEDIUM ============
  static const double lg = 16.0;
  static const double xl = 20.0;

  // ============ LARGE ============
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // ============ SCREEN PADDING ============
  static const double screenPaddingHorizontal = 16.0;
  static const double screenPaddingVertical = 16.0;
  static const double screenPadding = 16.0;

  // ============ CARD PADDING ============
  static const double cardPadding = 16.0;
  static const double cardPaddingSmall = 12.0;

  // ============ BUTTON PADDING ============
  static const double buttonPaddingHorizontal = 24.0;
  static const double buttonPaddingVertical = 12.0;
}

/// Border Radius Constants
class AppBorderRadius {
  // ============ SMALL ============
  static const Radius small = Radius.circular(4.0);
  static const Radius md = Radius.circular(8.0);

  // ============ MEDIUM ============
  static const Radius lg = Radius.circular(12.0);
  static const Radius xl = Radius.circular(16.0);

  // ============ LARGE ============
  static const Radius xxl = Radius.circular(24.0);

  // ============ BORDER RADIUS OBJECTS ============
  static const BorderRadius all4 = BorderRadius.all(Radius.circular(4.0));
  static const BorderRadius all8 = BorderRadius.all(Radius.circular(8.0));
  static const BorderRadius all12 = BorderRadius.all(Radius.circular(12.0));
  static const BorderRadius all16 = BorderRadius.all(Radius.circular(16.0));
  static const BorderRadius all24 = BorderRadius.all(Radius.circular(24.0));
}

/// Light Theme Configuration
ThemeData lightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.textOnPrimary,
      error: AppColors.error,
      onError: AppColors.textOnPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
    ),

    // ============ SCAFFOLD ============
    scaffoldBackgroundColor: AppColors.background,

    // ============ APP BAR ============
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headline4.copyWith(
        color: AppColors.textPrimary,
      ),
      toolbarHeight: 56,
    ),

    // ============ CARD ============
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 1,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.all12,
      ),
    ),

    // ============ ELEVATED BUTTON ============
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHorizontal,
          vertical: AppSpacing.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.all12,
        ),
        textStyle: AppTextStyles.buttonText,
      ),
    ),

    // ============ TEXT BUTTON ============
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHorizontal,
          vertical: AppSpacing.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.all12,
        ),
        textStyle: AppTextStyles.buttonText,
      ),
    ),

    // ============ OUTLINED BUTTON ============
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHorizontal,
          vertical: AppSpacing.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.all12,
        ),
        textStyle: AppTextStyles.buttonText,
      ),
    ),

    // ============ INPUT DECORATION ============
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: AppBorderRadius.all12,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.all12,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.all12,
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.all12,
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.all12,
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
      hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textTertiary),
      errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
    ),

    // ============ CHIP ============
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.background,
      selectedColor: AppColors.primary,
      labelStyle: AppTextStyles.label,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.all12,
      ),
    ),

    // ============ DIALOG ============
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.all16,
      ),
      backgroundColor: AppColors.surface,
      titleTextStyle: AppTextStyles.headline3.copyWith(
        color: AppColors.textPrimary,
      ),
    ),

    // ============ SNACKBAR ============
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppTextStyles.body2.copyWith(
        color: AppColors.textOnPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.all12,
      ),
    ),

    // ============ BOTTOM SHEET ============
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
    ),

    // ============ FLOATING ACTION BUTTON ============
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.all16,
      ),
    ),

    // ============ TEXT THEME ============
    textTheme: TextTheme(
      displayLarge: AppTextStyles.headline1.copyWith(color: AppColors.textPrimary),
      displayMedium: AppTextStyles.headline2.copyWith(color: AppColors.textPrimary),
      displaySmall: AppTextStyles.headline3.copyWith(color: AppColors.textPrimary),
      headlineSmall: AppTextStyles.headline4.copyWith(color: AppColors.textPrimary),
      titleLarge: AppTextStyles.subtitle1.copyWith(color: AppColors.textPrimary),
      titleMedium: AppTextStyles.subtitle2.copyWith(color: AppColors.textPrimary),
      titleSmall: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
      bodyLarge: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
      bodyMedium: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
      bodySmall: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
      labelLarge: AppTextStyles.buttonText.copyWith(color: AppColors.primary),
      labelMedium: AppTextStyles.label.copyWith(color: AppColors.primary),
      labelSmall: AppTextStyles.captionSmall.copyWith(color: AppColors.textTertiary),
    ),

    // ============ ICON THEME ============
    iconTheme: const IconThemeData(
      color: AppColors.textPrimary,
      size: 24,
    ),

    // ============ DIVIDER ============
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 16,
    ),
  );
}

/// Dark Theme Configuration
ThemeData darkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.textPrimary,
      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.textPrimary,
      error: AppColors.errorLight,
      onError: AppColors.textPrimary,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textDarkPrimary,
    ),

    // ============ SCAFFOLD ============
    scaffoldBackgroundColor: AppColors.backgroundDark,

    // ============ APP BAR ============
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.textDarkPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headline4.copyWith(
        color: AppColors.textDarkPrimary,
      ),
      toolbarHeight: 56,
    ),

    // ============ CARD ============
    cardTheme: CardThemeData(
      color: AppColors.surfaceDark,
      elevation: 1,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.all12,
      ),
    ),

    // ============ ELEVATED BUTTON ============
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.textPrimary,
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHorizontal,
          vertical: AppSpacing.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.all12,
        ),
        textStyle: AppTextStyles.buttonText,
      ),
    ),

    // ============ TEXT BUTTON ============
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHorizontal,
          vertical: AppSpacing.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.all12,
        ),
        textStyle: AppTextStyles.buttonText,
      ),
    ),

    // ============ OUTLINED BUTTON ============
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        side: const BorderSide(color: AppColors.borderDark),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHorizontal,
          vertical: AppSpacing.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.all12,
        ),
        textStyle: AppTextStyles.buttonText,
      ),
    ),

    // ============ INPUT DECORATION ============
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.backgroundDarkSecondary,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: AppBorderRadius.all12,
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.all12,
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.all12,
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.all12,
        borderSide: const BorderSide(color: AppColors.errorLight),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.all12,
        borderSide: const BorderSide(color: AppColors.errorLight, width: 2),
      ),
      labelStyle: AppTextStyles.body2.copyWith(color: AppColors.textDarkSecondary),
      hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textDarkTertiary),
      errorStyle: AppTextStyles.caption.copyWith(color: AppColors.errorLight),
    ),

    // ============ CHIP ============
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.backgroundDarkSecondary,
      selectedColor: AppColors.primaryLight,
      labelStyle: AppTextStyles.label.copyWith(color: AppColors.textDarkPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.all12,
      ),
    ),

    // ============ DIALOG ============
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.all16,
      ),
      backgroundColor: AppColors.surfaceDark,
      titleTextStyle: AppTextStyles.headline3.copyWith(
        color: AppColors.textDarkPrimary,
      ),
    ),

    // ============ SNACKBAR ============
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceDarkSecondary,
      contentTextStyle: AppTextStyles.body2.copyWith(
        color: AppColors.textDarkPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.all12,
      ),
    ),

    // ============ BOTTOM SHEET ============
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
    ),

    // ============ FLOATING ACTION BUTTON ============
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: AppColors.textPrimary,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.all16,
      ),
    ),

    // ============ TEXT THEME ============
    textTheme: TextTheme(
      displayLarge: AppTextStyles.headline1.copyWith(color: AppColors.textDarkPrimary),
      displayMedium: AppTextStyles.headline2.copyWith(color: AppColors.textDarkPrimary),
      displaySmall: AppTextStyles.headline3.copyWith(color: AppColors.textDarkPrimary),
      headlineSmall: AppTextStyles.headline4.copyWith(color: AppColors.textDarkPrimary),
      titleLarge: AppTextStyles.subtitle1.copyWith(color: AppColors.textDarkPrimary),
      titleMedium: AppTextStyles.subtitle2.copyWith(color: AppColors.textDarkPrimary),
      titleSmall: AppTextStyles.label.copyWith(color: AppColors.textDarkSecondary),
      bodyLarge: AppTextStyles.body1.copyWith(color: AppColors.textDarkPrimary),
      bodyMedium: AppTextStyles.body2.copyWith(color: AppColors.textDarkPrimary),
      bodySmall: AppTextStyles.caption.copyWith(color: AppColors.textDarkSecondary),
      labelLarge: AppTextStyles.buttonText.copyWith(color: AppColors.primaryLight),
      labelMedium: AppTextStyles.label.copyWith(color: AppColors.primaryLight),
      labelSmall: AppTextStyles.captionSmall.copyWith(color: AppColors.textDarkTertiary),
    ),

    // ============ ICON THEME ============
    iconTheme: const IconThemeData(
      color: AppColors.textDarkPrimary,
      size: 24,
    ),

    // ============ DIVIDER ============
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerDark,
      thickness: 1,
      space: 16,
    ),
  );
}
