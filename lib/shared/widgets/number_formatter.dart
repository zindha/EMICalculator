import 'package:intl/intl.dart';

/// Mixin providing locale-aware number formatting methods.
///
/// Uses Indian numbering system (lakhs, crores) by default, with support
/// for international formatting and customization.
mixin NumberFormatter {
  // ──────────────────────────────────────────────
  // Currency Formatting
  // ──────────────────────────────────────────────

  /// Formats [amount] as Indian Rupees with comma separators.
  ///
  /// Example: ₹ 12,34,567
  String formatInr(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Formats [amount] as Indian Rupees with 2 decimal places.
  ///
  /// Example: ₹ 12,34,567.89
  String formatInrDecimal(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Formats [amount] in USD with comma separators.
  ///
  /// Example: $ 1,234,567
  String formatUsd(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$ ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // ──────────────────────────────────────────────
  // Number Formatting
  // ──────────────────────────────────────────────

  /// Formats [value] as a compact number with abbreviation.
  ///
  /// Examples:
  /// - 1,000 → 1K
  /// - 10,00,000 → 10L (lakh)
  /// - 1,00,00,000 → 1Cr (crore)
  String formatCompact(double value) {
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(1)} Cr';
    } else if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)} L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)} K';
    }
    return value.toStringAsFixed(0);
  }

  /// Formats [value] as a percentage string.
  ///
  /// Example: 10.5%
  String formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  /// Formats an integer [value] with Indian comma separators.
  ///
  /// Example: 12,34,567
  String formatIndianNumber(int value) {
    final formatter = NumberFormat('#,##,###', 'en_IN');
    return formatter.format(value);
  }

  /// Formats a double [value] with Indian comma separators and [decimalPlaces].
  ///
  /// Example: 12,34,567.89
  String formatIndianDecimal(double value, {int decimalPlaces = 2}) {
    final formatter = NumberFormat(
      '#,##,###.${'0' * decimalPlaces}',
      'en_IN',
    );
    return formatter.format(value);
  }

  // ──────────────────────────────────────────────
  // Duration Formatting
  // ──────────────────────────────────────────────

  /// Formats a duration in [months] as a human-readable string.
  ///
  /// Examples:
  /// - 6 → "6 months"
  /// - 24 → "2 years"
  /// - 30 → "2 years 6 months"
  String formatDuration(int months) {
    if (months < 12) {
      return '$months months';
    }
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    if (remainingMonths == 0) {
      return '$years ${years == 1 ? 'year' : 'years'}';
    }
    return '$years ${years == 1 ? 'year' : 'years'} $remainingMonths months';
  }
}
