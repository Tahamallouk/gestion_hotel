import 'package:flutter/material.dart';
import 'constants.dart';

/// Responsive helper utilities for adaptive layouts
/// Provides utilities for building responsive layouts across different screen sizes
class ResponsiveUtils {
  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if screen is mobile (< 600px)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < ResponsiveBreakpoints.mobile;
  }

  /// Check if screen is tablet (600px - 1024px)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= ResponsiveBreakpoints.mobile &&
        width < ResponsiveBreakpoints.tablet;
  }

  /// Check if screen is desktop (> 1024px)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= ResponsiveBreakpoints.tablet;
  }

  /// Check if screen is large desktop (> 1600px)
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= ResponsiveBreakpoints.largeDesktop;
  }

  /// Get device type
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < ResponsiveBreakpoints.mobile) {
      return DeviceType.mobile;
    } else if (width < ResponsiveBreakpoints.tablet) {
      return DeviceType.tablet;
    } else if (width < ResponsiveBreakpoints.largeDesktop) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }

  /// Get device padding based on screen size
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(12.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(16.0);
    } else {
      return const EdgeInsets.all(24.0);
    }
  }

  /// Get grid columns based on screen size
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else if (isDesktop(context)) {
      return 3;
    } else {
      return 4;
    }
  }

  /// Get responsive font size
  static double responsiveFontSize(
    BuildContext context, {
    required double mobileSize,
    double? tabletSize,
    double? desktopSize,
  }) {
    if (isMobile(context)) {
      return mobileSize;
    } else if (isTablet(context)) {
      return tabletSize ?? mobileSize * 1.1;
    } else {
      return desktopSize ?? mobileSize * 1.2;
    }
  }

  /// Get responsive width
  static double responsiveWidth(
    BuildContext context, {
    required double mobileWidth,
    double? tabletWidth,
    double? desktopWidth,
  }) {
    if (isMobile(context)) {
      return mobileWidth;
    } else if (isTablet(context)) {
      return tabletWidth ?? mobileWidth * 1.1;
    } else {
      return desktopWidth ?? mobileWidth * 1.2;
    }
  }

  /// Get responsive height
  static double responsiveHeight(
    BuildContext context, {
    required double mobileHeight,
    double? tabletHeight,
    double? desktopHeight,
  }) {
    if (isMobile(context)) {
      return mobileHeight;
    } else if (isTablet(context)) {
      return tabletHeight ?? mobileHeight * 1.1;
    } else {
      return desktopHeight ?? mobileHeight * 1.2;
    }
  }

  /// Get safe area padding (respects notches and safe areas)
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get view insets (keyboard height, etc.)
  static EdgeInsets getViewInsets(BuildContext context) {
    return MediaQuery.of(context).viewInsets;
  }

  /// Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  /// Get keyboard height
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  /// Get device pixel ratio
  static double getDevicePixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  /// Get text scale factor
  static double getTextScaleFactor(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    // scale(1.0) returns the effective factor with accessibility applied
    return scaler.scale(1.0);
  }
}

/// Device type enum
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Responsive widget that builds different layouts based on device type
class Responsive extends StatelessWidget {
  final WidgetBuilder mobileBuilder;
  final WidgetBuilder? tabletBuilder;
  final WidgetBuilder? desktopBuilder;
  final WidgetBuilder? largeDesktopBuilder;

  const Responsive({
    super.key,
    required this.mobileBuilder,
    this.tabletBuilder,
    this.desktopBuilder,
    this.largeDesktopBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobileBuilder(context);
      case DeviceType.tablet:
        return tabletBuilder?.call(context) ?? mobileBuilder(context);
      case DeviceType.desktop:
        return desktopBuilder?.call(context) ??
            tabletBuilder?.call(context) ??
            mobileBuilder(context);
      case DeviceType.largeDesktop:
        return largeDesktopBuilder?.call(context) ??
            desktopBuilder?.call(context) ??
            tabletBuilder?.call(context) ??
            mobileBuilder(context);
    }
  }
}

/// Responsive grid view with adaptive columns
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double childAspectRatio;
  final double spacing;
  final EdgeInsets padding;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.childAspectRatio = 1.0,
    this.spacing = 16.0,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveUtils.getGridColumns(context);

    return GridView.count(
      crossAxisCount: columns,
      childAspectRatio: childAspectRatio,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      padding: padding,
      children: children,
    );
  }
}

/// Responsive list view that adapts to screen size
class ResponsiveListView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final ScrollPhysics? physics;

  const ResponsiveListView({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(16.0),
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: padding,
      physics: physics ?? const BouncingScrollPhysics(),
      children: children,
    );
  }
}
