import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'custom_theme_extension.dart';

/// Builds [ThemeData] instances for all three theme modes:
/// Light, Dark, and AMOLED (pure black).
///
/// Each theme uses Material 3 with customizable accent seed colors.
class AppTheme {
  const AppTheme._();

  /// Builds the light theme with the given [accentSeedColor].
  ///
  /// Uses a warm white surface background ([AppColors.surfaceWarm]) and
  /// the brand color palette for semantic indicators.
  static ThemeData buildLightTheme(Color accentSeedColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentSeedColor,
      brightness: Brightness.light,
      surface: AppColors.surfaceWarm,
    );

    return _baseTheme(colorScheme, brightness: Brightness.light).copyWith(
      extensions: const [AppColorsExtension.light],
      scaffoldBackgroundColor: AppColors.surfaceWarm,
    );
  }

  /// Builds the dark theme with the given [accentSeedColor].
  ///
  /// Uses a deep navy background ([AppColors.darkBackground]) and
  /// lighter surface colors for elevated elements.
  static ThemeData buildDarkTheme(Color accentSeedColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentSeedColor,
      brightness: Brightness.dark,
      surface: AppColors.darkSurface,
    );

    return _baseTheme(colorScheme, brightness: Brightness.dark).copyWith(
      extensions: const [AppColorsExtension.dark],
      scaffoldBackgroundColor: AppColors.darkBackground,
    );
  }

  /// Builds the AMOLED (pure black) theme.
  ///
  /// Uses pure black backgrounds ([AppColors.amoledBackground]) for maximum
  /// contrast on AMOLED displays, saving battery and providing deep blacks.
  static ThemeData buildAmoledTheme(Color accentSeedColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentSeedColor,
      brightness: Brightness.dark,
      surface: AppColors.amoledSurface,
    );

    return _baseTheme(colorScheme, brightness: Brightness.dark).copyWith(
      extensions: const [AppColorsExtension.dark],
      scaffoldBackgroundColor: AppColors.amoledBackground,
      cardColor: AppColors.amoledSurface,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.amoledBackground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.amoledBackground,
      ),
    );
  }

  /// Shared base theme configuration for all modes.
  static ThemeData _baseTheme(ColorScheme colorScheme,
      {required Brightness brightness}) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // ── Typography ──────────────────────────
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 48,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          fontSize: 36,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ── Cards ───────────────────────────────
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ── Input Fields ────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // ── Sliders ─────────────────────────────
      sliderTheme: SliderThemeData(
        overlayShape: SliderComponentShape.noOverlay,
        activeTrackColor: colorScheme.primary,
        thumbColor: colorScheme.primary,
        trackHeight: 6,
        trackShape: const RoundedRectSliderTrackShape(),
      ),

      // ── Navigation Bar ──────────────────────
      navigationBarTheme: NavigationBarThemeData(
        elevation: 3,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // ── Bottom Sheet ────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        modalElevation: 8,
      ),

      // ── Snackbar ────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
