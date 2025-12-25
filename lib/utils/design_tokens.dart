// ignore_for_file: dangling_library_doc_comments
/// Design Tokens Documentation
/// 
/// This file documents all design tokens used throughout the application.
/// These tokens ensure consistency and make it easy to maintain and update
/// the design system across the entire app.
///
/// USAGE:
/// ```dart
/// import 'package:gestion_hotel/utils/app_theme.dart';
/// import 'package:gestion_hotel/utils/constants.dart';
///
/// // Colors
/// Container(color: AppColors.primary)
///
/// // Spacing
/// Padding(padding: const EdgeInsets.all(AppSpacing.lg))
///
/// // Text Styles
/// Text('Hello', style: AppTextStyles.headline1)
///
/// // Border Radius
/// ClipRRect(borderRadius: AppBorderRadius.allLg)
///
/// // Shadows
/// BoxShadow(shadows: AppShadows.standard)
///
/// // Animations
/// Duration(AppDurations.standard)
///
/// // Responsive
/// ResponsiveHelper.isMobile(context)
/// ```

// ============ COLOR PALETTE ============
// 
// PRIMARY: #2196F3 (Blue)
// - primary: Main brand color
// - primaryLight: Lighter variant (#64B5F6)
// - primaryDark: Darker variant (#1565C0)
// - primaryVeryLight: Very light background (#E3F2FD)
//
// SECONDARY: #009688 (Teal)
// - secondary: Secondary brand color
// - secondaryLight: Lighter variant (#4DB6AC)
// - secondaryDark: Darker variant (#00695C)
//
// SEMANTIC:
// - success: Green (#4CAF50) - Confirmations, positives
// - error: Red (#E53935) - Errors, negatives, cancellations
// - warning: Orange (#FB8C00) - Warnings, pending states
// - info: Blue (#0288D1) - Information, neutral
//
// NEUTRAL:
// - background: Light background (#FAFAFA)
// - surface: White/Card backgrounds (#FFFFFF)
// - textPrimary: Dark text (#212121)
// - textSecondary: Medium text (#757575)
// - textTertiary: Light text (#BDBDBD)
//
// DARK MODE:
// - backgroundDark: Very dark (#121212)
// - surfaceDark: Dark card (#1E1E1E)
// - textDarkPrimary: Light text (#FAFAFA)
// - textDarkSecondary: Medium light text (#BDBDBD)

// ============ SPACING SYSTEM ============
//
// 4px Base Unit System:
// - xs: 4px - Tight spacing
// - sm: 8px - Small spacing
// - md: 12px - Medium-small spacing
// - lg: 16px - Standard spacing (MOST USED)
// - xl: 20px - Large spacing
// - xxl: 24px - Extra large spacing
// - xxxl: 32px - Extra extra large spacing
//
// USE CASES:
// - Padding: AppSpacing.lg (16px)
// - Margin: AppSpacing.md to AppSpacing.xl
// - Card padding: AppSpacing.lg (16px)
// - Button padding: 24px horizontal, 12px vertical

// ============ TYPOGRAPHY ============
//
// FONT SIZES:
// - displayLarge: 57px - Large titles
// - displayMedium: 45px - Medium titles
// - displaySmall: 36px - Small titles
// - headline1-5: 32px to 18px - Main headings
// - subtitle1-2: 16px to 14px - Subtitles
// - body1-2: 16px to 14px - Body text
// - caption: 12px - Captions
// - label: 12px - Labels and buttons
//
// FONT WEIGHTS:
// - Bold: 700 (Headlines)
// - SemiBold: 600 (Subtitles, labels)
// - Regular: 400 (Body text)
//
// LINE HEIGHT:
// - Tight: 1.2 (Headlines)
// - Normal: 1.4 (Standard text)
// - Relaxed: 1.6 (Large text)

// ============ BORDER RADIUS ============
//
// SIZES:
// - small: 4px - Subtle corners
// - md: 8px - Standard input fields
// - lg: 12px - Cards, buttons
// - xl: 16px - Dialogs, modals
// - xxl: 24px - Large modals, sheets
// - huge: 28px - Bottom sheets
// - circular: 999px - Avatars, badges
//
// USE CASES:
// - Buttons: 12px (lg)
// - Cards: 12px (lg)
// - Text fields: 12px (lg)
// - Dialogs: 16px (xl)
// - Bottom sheets: 24px (xxl)
// - Avatars: 999px (circular)

// ============ SHADOWS & ELEVATION ============
//
// TYPES:
// - subtle: 4px blur, 0px offset - Minimal elevation
// - standard: 8px blur, 2px offset - Standard cards
// - medium: 12px blur, 4px offset - Floating elements
// - high: 16px blur, 8px offset - Modals
// - maximum: 24px blur, 12px offset - FAB, overlays
//
// MATERIAL ELEVATION:
// - 1: Standard cards, app bar
// - 2: Raised buttons
// - 6: FAB
// - 8: Dialogs, bottom sheets
// - 12+: Modal overlays

// ============ ANIMATIONS & TRANSITIONS ============
//
// DURATIONS:
// - quick: 150ms - Micro interactions
// - standard: 300ms - Most animations
// - slow: 500ms - Careful transitions
// - verySlow: 800ms - Important transitions
// - extended: 1200ms - Long animations
//
// CURVES:
// - easeInOut: Default, natural motion
// - easeOut: Entering, appearing
// - easeIn: Exiting, disappearing
// - elasticOut: Bouncy animations

// ============ ICON SIZES ============
//
// - xs: 16px - Embedded in text
// - sm: 20px - Secondary icons
// - md: 24px - Standard icons (DEFAULT)
// - lg: 32px - Prominent icons
// - xl: 40px - Large icons
// - xxl: 48px - Hero icons
// - xxxl: 56px - Extra large icons

// ============ RESPONSIVE BREAKPOINTS ============
//
// - MOBILE: < 600px
//   - 1 column layouts
//   - Compact spacing
//   - Stacked navigation
//
// - TABLET: 600px - 1024px
//   - 2 column layouts
//   - Medium spacing
//   - Horizontal navigation
//
// - DESKTOP: 1024px - 1600px
//   - 3 column layouts
//   - Generous spacing
//   - Full navigation
//
// - LARGE DESKTOP: > 1600px
//   - 4+ column layouts
//   - Extra spacing
//   - Enhanced features

// ============ STATUS COLORS ============
//
// RESERVATION STATUS:
// - Confirmed: Green (#4CAF50) ✓
// - Pending: Orange (#FB8C00) ⏳
// - Cancelled: Red (#E53935) ✗
// - Archived: Grey (#9E9E9E) 🗂️
//
// ROOM STATUS:
// - Available: Green (#4CAF50) ✓
// - Occupied: Red (#E53935) ✗
// - Blocked: Orange (#FB8C00) 🚫
// - Cleaning: Blue (#0288D1) 🧹

// ============ USAGE EXAMPLES ============
//
// SPACING:
// Padding(
//   padding: const EdgeInsets.all(AppSpacing.lg),
//   child: child,
// )
//
// TEXT:
// Text(
//   'Title',
//   style: AppTextStyles.headline3.copyWith(
//     color: AppColors.primary,
//   ),
// )
//
// CARDS:
// Card(
//   shape: RoundedRectangleBorder(
//     borderRadius: AppBorderRadius.allLg,
//   ),
//   elevation: 2,
//   child: Padding(
//     padding: const EdgeInsets.all(AppSpacing.lg),
//     child: child,
//   ),
// )
//
// BUTTONS:
// ElevatedButton(
//   onPressed: () {},
//   child: const Text('Button'),
// )
// // Automatically styled via ButtonThemeData in app_theme.dart
//
// RESPONSIVE:
// if (ResponsiveHelper.isMobile(context)) {
//   // Show mobile layout
// } else {
//   // Show desktop layout
// }
//
// ANIMATIONS:
// AnimationController(
//   duration: AppDurations.standard,
//   vsync: this,
// )

// ============ ACCESSIBILITY ============
//
// CONTRAST:
// - All text meets WCAG AA standards
// - Primary on white: 4.5:1 ratio
// - Secondary on white: 4.5:1 ratio
// - Dark mode adjusted for readability
//
// SPACING:
// - Minimum touch target: 48x48 dp
// - Minimum spacing between targets: 8dp
//
// TYPOGRAPHY:
// - Minimum body text: 12px
// - Line height: minimum 1.2
// - Letter spacing: appropriate for readability

// ============ DARK MODE SUPPORT ============
//
// COLORS:
// - Surface colors shift from white to dark grey
// - Text colors invert appropriately
// - Shadows and overlays adjust opacity
// - All semantic colors have dark variants
//
// THEMES:
// - lightTheme(): Full light mode configuration
// - darkTheme(): Full dark mode configuration
// - Automatic switching via MediaQuery.of(context).platformBrightness
//
// TESTING:
// - Test both themes for all components
// - Verify contrast ratios in both modes
// - Check transparency values

// ============ FUTURE ENHANCEMENTS ============
//
// PLANNED:
// - [ ] Theming via ThemeExtension for plugins
// - [ ] Custom color schemes
// - [ ] Animated theme transitions
// - [ ] High contrast mode
// - [ ] Premium branding variants
// - [ ] Glassmorphism effects
// - [ ] Custom cursor styles
// - [ ] Enhanced animations for web

// This documentation is maintained with code changes
// and serves as a reference for all design decisions.
