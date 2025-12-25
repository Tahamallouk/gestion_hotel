import 'package:flutter/material.dart';

/// Application Color Palette - Complete design system
/// Material Design 3 compliant with accessibility in mind
class AppColors {
  // ============ PRIMARY PALETTE ============
  static const Color primary = Color(0xFF0F6CBD);
  static const Color primaryLight = Color(0xFF3E8EDB);
  static const Color primaryLighter = Color(0xFF73B1EC);
  static const Color primaryDark = Color(0xFF0A4E8A);
  static const Color primaryDarker = Color(0xFF073A67);
  static const Color primaryVeryLight = Color(0xFFE8F1FC);

  // ============ SECONDARY PALETTE ============
  static const Color secondary = Color(0xFF4F46E5); // Indigo accent
  static const Color secondaryLight = Color(0xFF7C73F5);
  static const Color secondaryDark = Color(0xFF3C34B4);
  static const Color secondaryVeryLight = Color(0xFFE8E7FF);

  // ============ ACCENT PALETTE ============
  static const Color accent = Color(0xFFF59E0B); // Amber highlight
  static const Color accentLight = Color(0xFFFCCB6B);
  static const Color accentDark = Color(0xFFD97706);

  // ============ SEMANTIC COLORS ============
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successLighter = Color(0xFFC8E6C9);
  static const Color successVeryLight = Color(0xFFF1F8E9);

  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorLighter = Color(0xFFFFCDD2);
  static const Color errorDarker = Color(0xFFB71C1C);
  static const Color errorVeryLight = Color(0xFFFFEBEE);

  static const Color warning = Color(0xFFFB8C00);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningLighter = Color(0xFFFFE0B2);
  static const Color warningVeryLight = Color(0xFFFFF3E0);

  static const Color info = Color(0xFF0288D1);
  static const Color infoLight = Color(0xFF4FC3F7);
  static const Color infoLighter = Color(0xFFB3E5FC);
  static const Color infoVeryLight = Color(0xFFE0F2F1);

  // ============ NEUTRAL PALETTE ============
  static const Color background = Color(0xFFF7F9FC);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color backgroundDarkSecondary = Color(0xFF1E1E1E);
  static const Color backgroundDarkTertiary = Color(0xFF2C2C2C);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceDarkSecondary = Color(0xFF2C2C2C);
  static const Color surfaceDarkTertiary = Color(0xFF3F3F3F);

  static const Color overlay = Color(0xFF000000);
  static const Color overlayDark = Color(0xFFFFFFFF);

  // ============ TEXT COLORS ============
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textDisabled = Color(0xFFCCCCCC);

  static const Color textDarkPrimary = Color(0xFFFAFAFA);
  static const Color textDarkSecondary = Color(0xFFBDBDBD);
  static const Color textDarkTertiary = Color(0xFF757575);
  static const Color textDarkDisabled = Color(0xFF424242);

  // ============ UTILITY COLORS ============
  static const Color divider = Color(0xFFE2E8F0);
  static const Color dividerDark = Color(0xFF424242);
  static const Color dividerDarker = Color(0xFF616161);
  static const Color border = Color(0xFFD8E0EC);
  static const Color borderDark = Color(0xFF616161);
  static const Color borderDarker = Color(0xFF757575);
  static const Color shadow = Color(0xFF000000);
  static const Color shadowDark = Color(0xFF1A1A1A);

  static const Color highlight = Color(0xFFFFF9C4);
  static const Color highlightDark = Color(0xFF4A4A00);

  // ============ STATUS COLORS ============
  static const Color statusConfirmed = success;
  static const Color statusPending = warning;
  static const Color statusCancelled = error;
  static const Color statusArchived = Color(0xFF9E9E9E);

  static const Color hotelAvailable = success;
  static const Color hotelOccupied = error;
  static const Color hotelMaintenance = warning;
  static const Color hotelUnknown = Color(0xFF9E9E9E);

  static const Color roomAvailable = success;
  static const Color roomOccupied = error;
  static const Color roomBlocked = warning;
  // ============ ADDITIONAL SEMANTIC COLORS ============
  static const Color danger = error;
  static const Color onPrimary = textOnPrimary;
  static const Color outline = border;
}

/// Application Text Styles - Material Design 3 compliant
class AppTextStyles {
  // ============ DISPLAY ============
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.bold,
    height: 1.12,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.bold,
    height: 1.16,
    letterSpacing: -0.5,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    height: 1.22,
    letterSpacing: 0,
  );

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

  static const TextStyle headline5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    height: 1.45,
    letterSpacing: 0.1,
  );

  // ============ SUBTITLES ============
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.57,
    letterSpacing: 0.1,
  );

  static const TextStyle subtitleSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.67,
    letterSpacing: 0.4,
  );

  // ============ BODY TEXT ============
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.5,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
  );

  static const TextStyle body3 = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.38,
    letterSpacing: 0.2,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
  );

  // ============ CAPTIONS & LABELS ============
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: 0.4,
  );

  static const TextStyle captionSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.27,
    letterSpacing: 0.5,
  );

  static const TextStyle captionTiny = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: 0.5,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.33,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.27,
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

  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.1,
  );

  // ============ SPECIAL ============
  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.25,
    decoration: TextDecoration.underline,
  );

  static const TextStyle error = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: 0.4,
    color: AppColors.error,
  );
}

/// Application Spacing - 4px base unit system
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;
  static const double huge2 = 48.0;

  static const double screenPaddingHorizontal = 16.0;
  static const double screenPaddingVertical = 16.0;
  static const double screenPadding = 16.0;

  static const double cardPaddingHorizontal = 16.0;
  static const double cardPaddingVertical = 16.0;
  static const double cardPadding = 16.0;
  static const double cardPaddingSmall = 12.0;

  static const double buttonPaddingHorizontal = 24.0;
  static const double buttonPaddingVertical = 12.0;
  static const double buttonPaddingSmall = 8.0;

  static const double dialogPadding = 24.0;

  static const double listItemPaddingVertical = 12.0;
  static const double listItemPaddingHorizontal = 16.0;
}

/// Border Radius Constants
class AppBorderRadius {
  static const Radius small = Radius.circular(4.0);
  static const BorderRadius allSmall = BorderRadius.all(Radius.circular(4.0));

  static const Radius md = Radius.circular(8.0);
  static const BorderRadius allMd = BorderRadius.all(Radius.circular(8.0));

  static const Radius lg = Radius.circular(12.0);
  static const BorderRadius allLg = BorderRadius.all(Radius.circular(12.0));

  static const Radius xl = Radius.circular(16.0);
  static const BorderRadius allXl = BorderRadius.all(Radius.circular(16.0));

  static const Radius xxl = Radius.circular(24.0);
  static const BorderRadius allXxl = BorderRadius.all(Radius.circular(24.0));

  static const Radius huge = Radius.circular(28.0);
  static const BorderRadius allHuge = BorderRadius.all(Radius.circular(28.0));

  static const Radius circular = Radius.circular(999.0);
  static const BorderRadius allCircular = BorderRadius.all(Radius.circular(999.0));

  // Legacy names
  static const BorderRadius all4 = BorderRadius.all(Radius.circular(4.0));
  static const BorderRadius all8 = BorderRadius.all(Radius.circular(8.0));
  static const BorderRadius all12 = BorderRadius.all(Radius.circular(12.0));
  static const BorderRadius all16 = BorderRadius.all(Radius.circular(16.0));
  static const BorderRadius all24 = BorderRadius.all(Radius.circular(24.0));
}

/// Light Theme
ThemeData lightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: AppColors.primaryVeryLight,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      onSecondary: AppColors.textOnPrimary,
      secondaryContainer: AppColors.secondaryVeryLight,
      onSecondaryContainer: AppColors.secondaryDark,
      tertiary: AppColors.accent,
      onTertiary: AppColors.textOnPrimary,
      error: AppColors.error,
      onError: AppColors.textOnPrimary,
      errorContainer: AppColors.errorVeryLight,
      onErrorContainer: AppColors.error,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      outline: AppColors.border,
      outlineVariant: AppColors.divider,
      scrim: AppColors.overlay,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headline4.copyWith(color: AppColors.textPrimary),
      toolbarHeight: 56,
      shadowColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allXl, side: BorderSide(color: AppColors.border)),
      shadowColor: AppColors.shadow.withValues(alpha: 0.06),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 2,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHorizontal,
          vertical: AppSpacing.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allLg),
        textStyle: AppTextStyles.buttonText,
        disabledBackgroundColor: AppColors.textTertiary,
        disabledForegroundColor: AppColors.textDisabled,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHorizontal,
          vertical: AppSpacing.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allLg),
        textStyle: AppTextStyles.buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHorizontal,
          vertical: AppSpacing.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allLg),
        textStyle: AppTextStyles.buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border, width: 1.2),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHorizontal,
          vertical: AppSpacing.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allLg),
        textStyle: AppTextStyles.buttonText,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      border: OutlineInputBorder(
        borderRadius: AppBorderRadius.allLg,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.allLg,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.allLg,
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.allLg,
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.allLg,
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.allLg,
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      labelStyle: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
      hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textTertiary),
      errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
      floatingLabelStyle: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
      prefixIconColor: AppColors.textSecondary,
      suffixIconColor: AppColors.textSecondary,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return AppColors.border;
      }),
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allSmall),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return AppColors.textTertiary;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return AppColors.textTertiary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary.withValues(alpha: 0.5);
        return AppColors.divider;
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.background,
      selectedColor: AppColors.primary,
      labelStyle: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
      secondaryLabelStyle: AppTextStyles.label.copyWith(color: AppColors.textOnPrimary),
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allLg),
      side: const BorderSide(color: AppColors.border),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allXxl),
      backgroundColor: AppColors.surface,
      titleTextStyle: AppTextStyles.headline3.copyWith(color: AppColors.textPrimary),
      contentTextStyle: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
      elevation: 8,
      shadowColor: AppColors.shadow.withValues(alpha: 0.15),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppTextStyles.body2.copyWith(color: AppColors.textOnPrimary),
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allLg),
      elevation: 6,
      behavior: SnackBarBehavior.floating,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      elevation: 8,
      modalElevation: 16,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 6,
      focusElevation: 8,
      hoverElevation: 8,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allXl),
      sizeConstraints: const BoxConstraints(minHeight: 56, minWidth: 56),
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimary),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimary),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary),
      headlineLarge: AppTextStyles.headline1.copyWith(color: AppColors.textPrimary),
      headlineMedium: AppTextStyles.headline2.copyWith(color: AppColors.textPrimary),
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
    iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
    primaryIconTheme: const IconThemeData(color: AppColors.textOnPrimary, size: 24),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 16,
      indent: 0,
      endIndent: 0,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.surface,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textTertiary,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textTertiary,
      indicatorColor: AppColors.primary,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.divider,
    ),
  );
}

/// Dark Theme
ThemeData darkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.textPrimary,
      primaryContainer: AppColors.primaryDarker,
      onPrimaryContainer: AppColors.primaryLighter,
      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.textPrimary,
      secondaryContainer: AppColors.secondaryDark,
      onSecondaryContainer: AppColors.secondaryLight,
      tertiary: AppColors.accentLight,
      onTertiary: AppColors.textPrimary,
      error: AppColors.errorLight,
      onError: AppColors.textPrimary,
      errorContainer: AppColors.errorDarker,
      onErrorContainer: AppColors.errorLight,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textDarkPrimary,
      outline: AppColors.borderDark,
      outlineVariant: AppColors.dividerDark,
      scrim: AppColors.overlay,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.textDarkPrimary,
      elevation: 1,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headline4.copyWith(color: AppColors.textDarkPrimary),
      toolbarHeight: 56,
      shadowColor: AppColors.shadowDark.withValues(alpha: 0.2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceDark,
      elevation: 1,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allXl),
      shadowColor: AppColors.shadowDark.withValues(alpha: 0.15),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.textPrimary,
        elevation: 2,
        shadowColor: AppColors.primaryLight.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHorizontal,
          vertical: AppSpacing.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allLg),
        textStyle: AppTextStyles.buttonText,
        disabledBackgroundColor: AppColors.textDarkTertiary,
        disabledForegroundColor: AppColors.textDarkDisabled,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHorizontal,
          vertical: AppSpacing.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allLg),
        textStyle: AppTextStyles.buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHorizontal,
          vertical: AppSpacing.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allLg),
        textStyle: AppTextStyles.buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        side: const BorderSide(color: AppColors.borderDark, width: 1.5),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHorizontal,
          vertical: AppSpacing.buttonPaddingVertical,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allLg),
        textStyle: AppTextStyles.buttonText,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.backgroundDarkSecondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      border: OutlineInputBorder(
        borderRadius: AppBorderRadius.allLg,
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.allLg,
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.allLg,
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.allLg,
        borderSide: const BorderSide(color: AppColors.errorLight),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.allLg,
        borderSide: const BorderSide(color: AppColors.errorLight, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: AppBorderRadius.allLg,
        borderSide: const BorderSide(color: AppColors.dividerDark),
      ),
      labelStyle: AppTextStyles.body2.copyWith(color: AppColors.textDarkSecondary),
      hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textDarkTertiary),
      errorStyle: AppTextStyles.caption.copyWith(color: AppColors.errorLight),
      floatingLabelStyle: const TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.w600),
      prefixIconColor: AppColors.textDarkSecondary,
      suffixIconColor: AppColors.textDarkSecondary,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primaryLight;
        return AppColors.borderDark;
      }),
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allSmall),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primaryLight;
        return AppColors.textDarkTertiary;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primaryLight;
        return AppColors.textDarkTertiary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primaryLight.withValues(alpha: 0.5);
        return AppColors.dividerDark;
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.backgroundDarkSecondary,
      selectedColor: AppColors.primaryLight,
      labelStyle: AppTextStyles.label.copyWith(color: AppColors.textDarkPrimary),
      secondaryLabelStyle: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allLg),
      side: const BorderSide(color: AppColors.borderDark),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allXxl),
      backgroundColor: AppColors.surfaceDark,
      titleTextStyle: AppTextStyles.headline3.copyWith(color: AppColors.textDarkPrimary),
      contentTextStyle: AppTextStyles.body2.copyWith(color: AppColors.textDarkSecondary),
      elevation: 8,
      shadowColor: AppColors.shadowDark.withValues(alpha: 0.3),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceDarkSecondary,
      contentTextStyle: AppTextStyles.body2.copyWith(color: AppColors.textDarkPrimary),
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allLg),
      elevation: 6,
      behavior: SnackBarBehavior.floating,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      elevation: 8,
      modalElevation: 16,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: AppColors.textPrimary,
      elevation: 6,
      focusElevation: 8,
      hoverElevation: 8,
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.allXl),
      sizeConstraints: const BoxConstraints(minHeight: 56, minWidth: 56),
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.textDarkPrimary),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.textDarkPrimary),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: AppColors.textDarkPrimary),
      headlineLarge: AppTextStyles.headline1.copyWith(color: AppColors.textDarkPrimary),
      headlineMedium: AppTextStyles.headline2.copyWith(color: AppColors.textDarkPrimary),
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
    iconTheme: const IconThemeData(color: AppColors.textDarkPrimary, size: 24),
    primaryIconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerDark,
      thickness: 1,
      space: 16,
      indent: 0,
      endIndent: 0,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.surfaceDark,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.textDarkTertiary,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.primaryLight,
      unselectedLabelColor: AppColors.textDarkTertiary,
      indicatorColor: AppColors.primaryLight,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryLight,
      linearTrackColor: AppColors.dividerDark,
    ),
  );
}

/// Application Typography - Material Design 3 text styles
class AppTypography {
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
  );

  // Material 3 compatible properties
  static const TextStyle? displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  );
  
  static const TextStyle? displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  
  static const TextStyle? displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  
  static const TextStyle? displayLg = displayLarge;

  static const TextStyle? headlineLarge = headline1;
  static const TextStyle? headlineMedium = headline2;
  static const TextStyle? headlineSmall = headline3;
  static const TextStyle? headline = headline1;

  static const TextStyle? titleLarge = subtitle1;
  static const TextStyle? titleMedium = subtitle2;
  static const TextStyle? titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );
  static const TextStyle? title = titleLarge;

  static const TextStyle? bodyLarge = body1;
  static const TextStyle? bodyMedium = body2;
  static const TextStyle? bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );
  
  static const TextStyle? bodyMuted = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: Color(0xFF6B7280),
  );

  static const TextStyle? labelLarge = button;
  static const TextStyle? labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
  static const TextStyle? labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
  static const TextStyle? label = labelLarge;

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    letterSpacing: 1.5,
  );
}

/// Application Border Radius values
class AppRadius {
  static const Radius xs = Radius.circular(2);
  static const Radius sm = Radius.circular(4);
  static const Radius md = Radius.circular(6);
  static const Radius lg = Radius.circular(8);
  static const Radius xl = Radius.circular(12);
  static const Radius xxl = Radius.circular(16);
  static const Radius round = Radius.circular(50);
  static const Radius pill = Radius.circular(9999);
  
  // Convert to double for compatibility
  static const double xsValue = 2;
  static const double smValue = 4;
  static const double mdValue = 6;
  static const double lgValue = 8;
  static const double xlValue = 12;
  static const double xxlValue = 16;
  static const double roundValue = 50;
  static const double pillValue = 9999;
}

/// Application Shadows
class AppShadows {
  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
    ),
  ];

  static const List<BoxShadow> standard = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 6),
      blurRadius: 16,
      spreadRadius: -4,
    ),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 20),
      blurRadius: 25,
      spreadRadius: -5,
    ),
  ];
  
  // Additional shadows for compatibility
  static const List<BoxShadow> subtle = xs;
  static const List<BoxShadow> medium = md;
}

/// Application Durations for animations
class AppDurations {
  static const Duration quick = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

/// Responsive Helper class
class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) return 1;
    if (width < 1024) return 2;
    if (width < 1440) return 3;
    return 4;
  }

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) return DeviceType.mobile;
    if (width < 1024) return DeviceType.tablet;
    return DeviceType.desktop;
  }
}

enum DeviceType {
  mobile,
  tablet, 
  desktop,
}
