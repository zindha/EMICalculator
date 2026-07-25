import 'package:flutter/material.dart';

/// Centralized color definitions for the EMI Calculator brand palette.
///
/// All UI colors should derive from this class or the Material 3 [ColorScheme].
/// Do NOT hardcode raw color values in widget files.
class AppColors {
  const AppColors._();

  // ──────────────────────────────────────────────
  // Brand Colors
  // ──────────────────────────────────────────────

  /// Primary brand color — Periwinkle (trust, stability).
  static const Color primary = Color(0xFF6C63FF);

  /// Secondary brand color — Coral (urgency, action).
  static const Color secondary = Color(0xFFFF6584);

  /// Tertiary brand color — Mint (savings, success, money).
  static const Color tertiary = Color(0xFF00C9A7);

  // ──────────────────────────────────────────────
  // Semantic Colors
  // ──────────────────────────────────────────────

  /// Positive/savings indicator — Green.
  static const Color positive = Color(0xFF2ECC71);

  /// Warning/moderate indicator — Amber.
  static const Color warning = Color(0xFFF39C12);

  /// Danger/high-risk indicator — Red.
  static const Color danger = Color(0xFFE74C3C);

  /// Informational/neutral indicator — Blue.
  static const Color info = Color(0xFF3498DB);

  // ──────────────────────────────────────────────
  // Surface Colors
  // ──────────────────────────────────────────────

  /// Warm light surface background.
  static const Color surfaceWarm = Color(0xFFFFF8F0);

  /// Cool alternate light surface.
  static const Color surfaceCool = Color(0xFFF0F4FF);

  // ──────────────────────────────────────────────
  // Dark Mode Surface Colors
  // ──────────────────────────────────────────────

  /// Deep navy background for standard dark mode.
  static const Color darkBackground = Color(0xFF1A1A2E);

  /// Slightly lighter dark surface for cards.
  static const Color darkSurface = Color(0xFF16213E);

  /// Pure black background for AMOLED mode.
  static const Color amoledBackground = Color(0xFF000000);

  /// Near-black surface for AMOLED cards.
  static const Color amoledSurface = Color(0xFF0D0D0D);

  // ──────────────────────────────────────────────
  // Loan Health Score Colors
  // ──────────────────────────────────────────────

  /// Excellent health score (80–100).
  static const Color healthExcellent = Color(0xFF2ECC71);

  /// Fair health score (50–79).
  static const Color healthFair = Color(0xFFF39C12);

  /// Risky health score (0–49).
  static const Color healthRisky = Color(0xFFE74C3C);

  // ──────────────────────────────────────────────
  // EMI Stress Meter Colors
  // ──────────────────────────────────────────────

  /// Low stress (≤20% of income).
  static const Color stressLow = Color(0xFF2ECC71);

  /// Moderate stress (20–35% of income).
  static const Color stressModerate = Color(0xFFF39C12);

  /// High stress (35–50% of income).
  static const Color stressHigh = Color(0xFFE67E22);

  /// Critical stress (>50% of income).
  static const Color stressCritical = Color(0xFFE74C3C);

  // ──────────────────────────────────────────────
  // Glassmorphism
  // ──────────────────────────────────────────────

  /// Semi-transparent white overlay for light-mode glassmorphism.
  static const Color glassLight = Color(0x4DFFFFFF); // 30% opacity

  /// Semi-transparent white overlay for dark-mode glassmorphism.
  static const Color glassDark = Color(0x0DFFFFFF); // 5% opacity
}
