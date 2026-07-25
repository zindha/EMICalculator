import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography definitions using Google Fonts.
///
/// Font stack:
/// - **Space Grotesk**: Display numbers, headlines (hero EMI values)
/// - **Inter**: Body text, labels, subheadings
/// - **JetBrains Mono**: Monetary values (tabular figures for alignment)
class AppTypography {
  const AppTypography._();

  // ──────────────────────────────────────────────
  // Display / Hero Numbers
  // ──────────────────────────────────────────────

  /// Hero text style for displaying large monetary values (e.g., EMI amount).
  static TextStyle heroTextStyle(BuildContext context) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      );

  /// Large display text style for section headers.
  static TextStyle displayLarge(BuildContext context) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      );

  // ──────────────────────────────────────────────
  // Headlines
  // ──────────────────────────────────────────────

  /// H1 headline (32px, Space Grotesk SemiBold).
  static TextStyle headline1(BuildContext context) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      );

  /// H2 headline (28px, Space Grotesk SemiBold).
  static TextStyle headline2(BuildContext context) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      );

  /// H3 headline (24px, Space Grotesk SemiBold).
  static TextStyle headline3(BuildContext context) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      );

  // ──────────────────────────────────────────────
  // Subheadings
  // ──────────────────────────────────────────────

  /// H4 subheading (20px, Inter Medium).
  static TextStyle headline4(BuildContext context) => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
      );

  /// H5 subheading (18px, Inter Medium).
  static TextStyle headline5(BuildContext context) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
      );

  // ──────────────────────────────────────────────
  // Body
  // ──────────────────────────────────────────────

  /// Body large (16px, Inter Regular).
  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface,
      );

  /// Body medium (14px, Inter Regular).
  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface,
      );

  /// Body small (12px, Inter Regular, 80% opacity).
  static TextStyle bodySmall(BuildContext context) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
      );

  // ──────────────────────────────────────────────
  // Monetary Values
  // ──────────────────────────────────────────────

  /// Monetary value text (JetBrains Mono, tabular figures for alignment).
  static TextStyle monetaryStyle(BuildContext context) =>
      GoogleFonts.jetBrainsMono(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
      );

  /// Large monetary value text (JetBrains Mono, 24px).
  static TextStyle monetaryLarge(BuildContext context) =>
      GoogleFonts.jetBrainsMono(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
      );

  // ──────────────────────────────────────────────
  // Caption / Small
  // ──────────────────────────────────────────────

  /// Caption text (10px, Inter Regular).
  static TextStyle caption(BuildContext context) => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      );

  /// Label text (14px, Inter Medium, for form labels).
  static TextStyle label(BuildContext context) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
      );
}
