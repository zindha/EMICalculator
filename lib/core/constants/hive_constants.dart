/// Hive storage constants for box names, field keys, and type adapter IDs.
///
/// Centralizes all Hive-related string and integer constants to prevent
/// typos and ensure consistency across data-layer implementations.
class HiveConstants {
  const HiveConstants._();

  // ──────────────────────────────────────────────
  // Box Names
  // ──────────────────────────────────────────────

  /// Box for persisting user theme and appearance preferences.
  static const String themeBox = 'themeBox';

  /// Box for persisting loan calculation history.
  static const String loanHistoryBox = 'loanHistoryBox';

  /// Box for persisting saved loan offers for comparison.
  static const String savedOffersBox = 'savedOffersBox';

  /// Box for persisting saved loan comparison sessions.
  static const String comparisonBox = 'comparisonBox';

  /// Box for persisting saved prepayment plans.
  static const String prepaymentBox = 'prepaymentBox';

  // ──────────────────────────────────────────────
  // Theme Box Keys
  // ──────────────────────────────────────────────

  /// Key for the stored [ThemeMode] index (0=light, 1=dark, 2=amoled).
  static const String themeModeKey = 'themeMode';

  /// Key for the stored accent seed color as an integer (ARGB).
  static const String accentColorKey = 'accentColor';

  // ──────────────────────────────────────────────
  // Type Adapter IDs
  // ──────────────────────────────────────────────

  /// Type adapter ID for [EmiCalculation].
  static const int emiCalculationAdapterId = 1;

  /// Type adapter ID for [ComparisonSession].
  static const int comparisonSessionAdapterId = 2;
}
