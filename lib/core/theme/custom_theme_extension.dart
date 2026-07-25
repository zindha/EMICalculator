import 'package:flutter/material.dart';

/// Custom [ThemeExtension] providing brand-specific and semantic colors
/// that are not covered by the Material 3 [ColorScheme].
///
/// Usage:
/// ```dart
/// final appColors = Theme.of(context).extension<AppColorsExtension>()!;
/// final healthColor = appColors.loanHealthExcellent;
/// ```
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  /// Creates an [AppColorsExtension] with all semantic color properties.
  const AppColorsExtension({
    required this.loanHealthExcellent,
    required this.loanHealthFair,
    required this.loanHealthRisky,
    required this.stressLow,
    required this.stressModerate,
    required this.stressHigh,
    required this.stressCritical,
    required this.savingsGreen,
    required this.costRed,
    required this.glassmorphism,
    required this.glassBorder,
  });

  /// Color for excellent loan health score (80–100).
  final Color loanHealthExcellent;

  /// Color for fair loan health score (50–79).
  final Color loanHealthFair;

  /// Color for risky loan health score (0–49).
  final Color loanHealthRisky;

  /// Color for low EMI stress (≤20% of income).
  final Color stressLow;

  /// Color for moderate EMI stress (20–35% of income).
  final Color stressModerate;

  /// Color for high EMI stress (35–50% of income).
  final Color stressHigh;

  /// Color for critical EMI stress (>50% of income).
  final Color stressCritical;

  /// Color for positive savings indicators.
  final Color savingsGreen;

  /// Color for negative cost indicators.
  final Color costRed;

  /// Semi-transparent background for glassmorphism cards.
  final Color glassmorphism;

  /// Border color for glassmorphism cards.
  final Color glassBorder;

  @override
  AppColorsExtension copyWith({
    Color? loanHealthExcellent,
    Color? loanHealthFair,
    Color? loanHealthRisky,
    Color? stressLow,
    Color? stressModerate,
    Color? stressHigh,
    Color? stressCritical,
    Color? savingsGreen,
    Color? costRed,
    Color? glassmorphism,
    Color? glassBorder,
  }) {
    return AppColorsExtension(
      loanHealthExcellent: loanHealthExcellent ?? this.loanHealthExcellent,
      loanHealthFair: loanHealthFair ?? this.loanHealthFair,
      loanHealthRisky: loanHealthRisky ?? this.loanHealthRisky,
      stressLow: stressLow ?? this.stressLow,
      stressModerate: stressModerate ?? this.stressModerate,
      stressHigh: stressHigh ?? this.stressHigh,
      stressCritical: stressCritical ?? this.stressCritical,
      savingsGreen: savingsGreen ?? this.savingsGreen,
      costRed: costRed ?? this.costRed,
      glassmorphism: glassmorphism ?? this.glassmorphism,
      glassBorder: glassBorder ?? this.glassBorder,
    );
  }

  @override
  AppColorsExtension lerp(
    ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      loanHealthExcellent:
          Color.lerp(loanHealthExcellent, other.loanHealthExcellent, t)!,
      loanHealthFair: Color.lerp(loanHealthFair, other.loanHealthFair, t)!,
      loanHealthRisky:
          Color.lerp(loanHealthRisky, other.loanHealthRisky, t)!,
      stressLow: Color.lerp(stressLow, other.stressLow, t)!,
      stressModerate:
          Color.lerp(stressModerate, other.stressModerate, t)!,
      stressHigh: Color.lerp(stressHigh, other.stressHigh, t)!,
      stressCritical:
          Color.lerp(stressCritical, other.stressCritical, t)!,
      savingsGreen: Color.lerp(savingsGreen, other.savingsGreen, t)!,
      costRed: Color.lerp(costRed, other.costRed, t)!,
      glassmorphism:
          Color.lerp(glassmorphism, other.glassmorphism, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
    );
  }

  /// Light-mode instance of the custom theme extension.
  static const light = AppColorsExtension(
    loanHealthExcellent: Color(0xFF2ECC71),
    loanHealthFair: Color(0xFFF39C12),
    loanHealthRisky: Color(0xFFE74C3C),
    stressLow: Color(0xFF2ECC71),
    stressModerate: Color(0xFFF39C12),
    stressHigh: Color(0xFFE67E22),
    stressCritical: Color(0xFFE74C3C),
    savingsGreen: Color(0xFF2ECC71),
    costRed: Color(0xFFE74C3C),
    glassmorphism: Color(0xB3FFFFFF),
    glassBorder: Color(0x4DFFFFFF),
  );

  /// Dark-mode instance of the custom theme extension.
  static const dark = AppColorsExtension(
    loanHealthExcellent: Color(0xFF2ECC71),
    loanHealthFair: Color(0xFFF39C12),
    loanHealthRisky: Color(0xFFE74C3C),
    stressLow: Color(0xFF2ECC71),
    stressModerate: Color(0xFFF39C12),
    stressHigh: Color(0xFFE67E22),
    stressCritical: Color(0xFFE74C3C),
    savingsGreen: Color(0xFF2ECC71),
    costRed: Color(0xFFE74C3C),
    glassmorphism: Color(0x0DFFFFFF),
    glassBorder: Color(0x1AFFFFFF),
  );
}
