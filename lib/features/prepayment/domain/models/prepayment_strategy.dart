/// Represents how a prepayment should affect the loan terms.
enum PrepaymentStrategy {
  /// Keep the tenure the same and reduce the monthly EMI.
  reduceEmi,

  /// Keep the EMI the same and shorten the loan duration.
  reduceTenure,
}

/// Extension to get human-readable labels for [PrepaymentStrategy].
extension PrepaymentStrategyLabel on PrepaymentStrategy {
  /// Returns a user-facing label for this strategy.
  String get label {
    switch (this) {
      case PrepaymentStrategy.reduceEmi:
        return 'Reduce EMI';
      case PrepaymentStrategy.reduceTenure:
        return 'Reduce Tenure';
    }
  }

  /// Returns a short description of the strategy.
  String get description {
    switch (this) {
      case PrepaymentStrategy.reduceEmi:
        return 'Keep tenure same, lower monthly EMI';
      case PrepaymentStrategy.reduceTenure:
        return 'Keep EMI same, pay off loan faster';
    }
  }
}
