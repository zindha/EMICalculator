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
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // ── Typography ──────────────────────────
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
        ),
        headlineLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        headlineSmall: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),

      // ── Cards ───────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        color: colorScheme.surfaceContainerLow,
      ),

      // ── Input Fields ────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.5,
          ),
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
        inactiveTrackColor: colorScheme.surfaceContainerHighest,
        thumbColor: colorScheme.primary,
        trackHeight: 4,
        trackShape: const RoundedRectSliderTrackShape(),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),

      // ── Filled Buttons ──────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ── Outlined Buttons ────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ── Navigation Bar ──────────────────────
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: isDark
            ? colorScheme.surface.withValues(alpha: 0.95)
            : colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            );
          }
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          );
        }),
      ),

      // ── AppBar ──────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: isDark ? 0.5 : 1,
        centerTitle: true,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: colorScheme.onSurface,
        ),
      ),

      // ── Bottom Sheet ────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        dragHandleColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        modalElevation: 0,
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // ── Dialog ──────────────────────────────
      dialogTheme: DialogThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: colorScheme.surfaceContainerHigh,
      ),

      // ── Snackbar ────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ── Divider ─────────────────────────────
      dividerTheme: DividerThemeData(
        thickness: 1,
        color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        space: 1,
      ),

      // ── ListTile ────────────────────────────
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // ── IconButton ──────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
