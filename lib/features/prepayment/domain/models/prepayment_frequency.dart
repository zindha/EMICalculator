/// Represents how often a prepayment recurs.
enum PrepaymentFrequency {
  /// A single one-time prepayment.
  oneTime,

  /// Extra payment every month.
  monthly,

  /// Extra payment every quarter.
  quarterly,

  /// Extra payment every six months.
  halfYearly,

  /// Extra payment once per year.
  yearly,

  /// Custom schedule defined by explicit months.
  custom,
}

/// Extension to get human-readable labels for [PrepaymentFrequency].
extension PrepaymentFrequencyLabel on PrepaymentFrequency {
  /// Returns a user-facing label for this frequency.
  String get label {
    switch (this) {
      case PrepaymentFrequency.oneTime:
        return 'One-time';
      case PrepaymentFrequency.monthly:
        return 'Monthly';
      case PrepaymentFrequency.quarterly:
        return 'Quarterly';
      case PrepaymentFrequency.halfYearly:
        return 'Half-yearly';
      case PrepaymentFrequency.yearly:
        return 'Yearly';
      case PrepaymentFrequency.custom:
        return 'Custom';
    }
  }
}
