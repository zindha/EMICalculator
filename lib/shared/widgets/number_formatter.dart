import 'package:intl/intl.dart';

/// Mixin providing locale-aware number formatting methods.
///
/// Uses the active app currency by default.  The active currency can be set
/// globally through [configureCurrency] so every UI layer that mixes in
/// [NumberFormatter] formats amounts consistently.
mixin NumberFormatter {
  // ──────────────────────────────────────────────
  // Global Currency Configuration
  // ──────────────────────────────────────────────

  static String _currencySymbol = '₹';
  static String _currencyLocale = 'en_IN';

  /// The currently configured currency symbol used for formatting.
  static String get currencySymbol => _currencySymbol;

  /// Creates a [NumberFormat] instance using the globally configured currency
  /// symbol and locale.
  ///
  /// This is the preferred way to obtain a currency formatter from domain-layer
  /// services and static utility code that cannot mix in [NumberFormatter].
  static NumberFormat createCurrencyFormatter({int decimalDigits = 0}) {
    return NumberFormat.currency(
      locale: _currencyLocale,
      symbol: '$_currencySymbol ',
      decimalDigits: decimalDigits,
    );
  }

  /// Configures the formatting currency used by all [NumberFormatter] users.
  static void configureCurrency(String symbol, String locale) {
    _currencySymbol = symbol;
    _currencyLocale = locale;
  }

  // ──────────────────────────────────────────────
  // Currency Formatting
  // ──────────────────────────────────────────────

  /// Formats [amount] in the active currency with comma separators.
  ///
  /// Example: ₹ 12,34,567
  String formatInr(double amount) => formatCurrency(amount);

  /// Alias for [formatInr] with a clearer name.
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: _currencyLocale,
      symbol: '$_currencySymbol ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Formats [amount] in the active currency with 2 decimal places.
  ///
  /// Example: ₹ 12,34,567.89
  String formatInrDecimal(double amount) => formatCurrencyDecimal(amount);

  /// Alias for [formatInrDecimal] with a clearer name.
  String formatCurrencyDecimal(double amount) {
    final formatter = NumberFormat.currency(
      locale: _currencyLocale,
      symbol: '$_currencySymbol ',
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
