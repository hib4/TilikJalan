import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme extends InheritedWidget {
  const AppTheme({
    required this.textTheme,
    required this.colorTheme,
    required super.child,
    super.key,
  });

  final AppTextStyles textTheme;
  final AppColors colorTheme;

  // Static method to access the theme from context
  static AppTheme? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppTheme>();

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}

/// Extension on BuildContext for easy theme access
extension ThemeExtension on BuildContext {
  AppTheme get themes {
    final theme = AppTheme.of(this);
    assert(theme != null, 'No AppTheme found in context');
    return theme!;
  }

  AppColors get colors {
    final theme = AppTheme.of(this);
    assert(theme != null, 'No AppTheme found in context');
    return theme!.colorTheme;
  }

  AppTextStyles get textTheme {
    final theme = AppTheme.of(this);
    assert(theme != null, 'No AppTheme found in context');
    return theme!.textTheme;
  }
}

///////////////////////////
///                     ///
///      COLORS         ///
///                     ///
///////////////////////////
class AppColors {
  const AppColors({
    required this.primary,
    required this.secondary,
    required this.support,
    required this.darkAccent,
    required this.neutral,
    required this.grey,
  });

  factory AppColors.colors() {
    // Primary
    final primary = {
      50: const Color(0xFFE6F2FF), // primary-50
      100: const Color(0xFFB0D6FF), // primary-100
      200: const Color(0xFF8AC2FF), // primary-200
      300: const Color(0xFF54A6FF), // primary-300
      400: const Color(0xFF3395FF), // primary-400
      500: const Color(0xFF007AFF), // primary-500
      600: const Color(0xFF006FE8), // primary-600
      700: const Color(0xFF0057B5), // primary-700
      800: const Color(0xFF00438C), // primary-800
      900: const Color(0xFF00336B), // primary-900
    };

    // Secondary
    final secondary = {
      50: const Color(0xFFFFF4E6), // secondary-50
      100: const Color(0xFFFFDEB0), // secondary-100
      200: const Color(0xFFFFCE8A), // secondary-200
      300: const Color(0xFFFFB854), // secondary-300
      400: const Color(0xFFFFAA33), // secondary-400
      500: const Color(0xFFFF9500), // secondary-500
      600: const Color(0xFFE88800), // secondary-600
      700: const Color(0xFFB56A00), // secondary-700
      800: const Color(0xFF8C5200), // secondary-800
      900: const Color(0xFF6B3F00), // secondary-900
    };

    // Support
    final support = {
      50: const Color(0xFFEBF9EE), // support-50
      100: const Color(0xFFC0EECC), // support-100
      200: const Color(0xFFA2E5B3), // support-200
      300: const Color(0xFF77D990), // support-300
      400: const Color(0xFF5DD27A), // support-400
      500: const Color(0xFF34C759), // support-500
      600: const Color(0xFF2FB551), // support-600
      700: const Color(0xFF258D3F), // support-700
      800: const Color(0xFF1D6D31), // support-800
      900: const Color(0xFF165425), // support-900
    };

    // Dark Accent
    final darkAccent = {
      50: const Color(0xFFE6EEFA), // darkAccent-50
      100: const Color(0xFFB0C9EF), // darkAccent-100
      200: const Color(0xFF8AAFE8), // darkAccent-200
      300: const Color(0xFF548ADD), // darkAccent-300
      400: const Color(0xFF3374D6), // darkAccent-400
      500: const Color(0xFF0051CC), // darkAccent-500
      600: const Color(0xFF004ABA), // darkAccent-600
      700: const Color(0xFF003A91), // darkAccent-700
      800: const Color(0xFF002D70), // darkAccent-800
      900: const Color(0xFF002256), // darkAccent-900
    };

    // Neutral
    final neutral = {
      50: const Color(0xFFFEFEFE), // neutral-50
      100: const Color(0xFFFBFBFD), // neutral-100
      200: const Color(0xFFF9F9FB), // neutral-200
      300: const Color(0xFFF6F6FA), // neutral-300
      400: const Color(0xFFF5F5F9), // neutral-400
      500: const Color(0xFFF2F2F7), // neutral-500
      600: const Color(0xFFDCDCE1), // neutral-600
      700: const Color(0xFFACACAF), // neutral-700
      800: const Color(0xFF858588), // neutral-800
      900: const Color(0xFF666668), // neutral-900
    };

    // Grey
    final grey = {
      50: const Color(0xFFF4F4F4), // grey-50
      100: const Color(0xFFDCDCDE), // grey-100
      200: const Color(0xFFCBCBCD), // grey-200
      300: const Color(0xFFB3B3B7), // grey-300
      400: const Color(0xFFA5A5A9), // grey-400
      500: const Color(0xFF8E8E93), // grey-500
      600: const Color(0xFF818186), // grey-600
      700: const Color(0xFF656568), // grey-700
      800: const Color(0xFF4E4E51), // grey-800
      900: const Color(0xFF3C3C3E), // grey-900
    };

    return AppColors(
      primary: primary,
      secondary: secondary,
      support: support,
      darkAccent: darkAccent,
      neutral: neutral,
      grey: grey,
    );
  }

  // Each color group is a map of shade to Color
  final Map<int, Color> primary;
  final Map<int, Color> secondary;
  final Map<int, Color> support;
  final Map<int, Color> darkAccent;
  final Map<int, Color> neutral;
  final Map<int, Color> grey;

  static AppColors of(BuildContext context) {
    final inheritedWidget = context
        .dependOnInheritedWidgetOfExactType<AppTheme>();
    assert(inheritedWidget != null, 'No AppTheme found in context');
    return inheritedWidget!.colorTheme;
  }
}

///////////////////////////
///     Text Style      ///
///////////////////////////
class AppTextStyles {
  AppTextStyles({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
    required this.caption,
  });

  factory AppTextStyles.textStyles() {
    return AppTextStyles(
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: Colors.black,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: Colors.black,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: Colors.black,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: Colors.black,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: Colors.black,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: Colors.black,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: Colors.black,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: Colors.black,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: Colors.black,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: Colors.black,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: Colors.black,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: Colors.black,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: Colors.black,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: Colors.black,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: Colors.black,
      ),
      caption: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: Colors.black,
      ),
    );
  }

  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle displaySmall;
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;
  final TextStyle caption;
}

/// The theme data for this application.
/// Use this theme data for requiring style, such as AppBar, ElevatedButton, etc.
class AppThemeData {
  const AppThemeData({
    required this.themeData,
  });

  factory AppThemeData.themeData() {
    final appColors = AppColors.colors();
    final appTextStyles = AppTextStyles.textStyles();

    final primaryColor = appColors.primary[500] ?? const Color(0xFF007AFF);
    final primaryColorMap = <int, Color>{
      50: primaryColor,
      100: primaryColor,
      200: primaryColor,
      300: primaryColor,
      400: primaryColor,
      500: primaryColor,
      600: primaryColor,
      700: primaryColor,
      800: primaryColor,
      900: primaryColor,
    };

    final primaryMaterialColor = MaterialColor(
      primaryColor.toARGB32(),
      primaryColorMap,
    );

    final themeData = ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      primarySwatch: primaryMaterialColor,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: appColors.primary.values.first,
        secondary: appColors.secondary.values.first,
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
      tabBarTheme: const TabBarThemeData(
        indicatorColor: Colors.black,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.white,
      ),
      // actionIconTheme: ActionIconThemeData(
      //   backButtonIconBuilder: (context) => Assets.icons.arrowLeft.svg(),
      // ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: appColors.neutral[100],
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        actionsIconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      primaryTextTheme: GoogleFonts.interTextTheme(),
      textTheme: TextTheme(
        displayLarge: appTextStyles.displayLarge,
        displayMedium: appTextStyles.displayMedium,
        displaySmall: appTextStyles.displaySmall,
        headlineLarge: appTextStyles.headlineLarge,
        headlineMedium: appTextStyles.headlineMedium,
        headlineSmall: appTextStyles.headlineSmall,
        titleLarge: appTextStyles.titleLarge,
        titleMedium: appTextStyles.titleMedium,
        titleSmall: appTextStyles.titleSmall,
        bodyLarge: appTextStyles.bodyLarge,
        bodyMedium: appTextStyles.bodyMedium,
        bodySmall: appTextStyles.bodySmall,
        labelLarge: appTextStyles.labelLarge,
        labelMedium: appTextStyles.labelMedium,
        labelSmall: appTextStyles.labelSmall,
      ),
    );

    return AppThemeData(
      themeData: themeData,
    );
  }

  final ThemeData? themeData;
}

void statusBarDarkStyle() {
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayDarkStyle);
}

SystemUiOverlayStyle get systemUiOverlayDarkStyle {
  return const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );
}

class NoOverScrollEffectBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
