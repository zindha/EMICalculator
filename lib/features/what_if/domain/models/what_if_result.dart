import '../../../calculator/domain/models/emi_calculation.dart';

/// Result of a single What-If scenario.
class WhatIfScenarioResult {
  /// Creates a [WhatIfScenarioResult].
  const WhatIfScenarioResult({
    required this.emi,
    required this.totalInterest,
    required this.totalPayment,
    required this.effectiveLoanAmount,
  });

  /// Monthly EMI amount.
  final double emi;

  /// Total interest payable.
  final double totalInterest;

  /// Total payment (principal + interest).
  final double totalPayment;

  /// Effective loan amount.
  final double effectiveLoanAmount;
}

/// Computed diff between the current scenario and the baseline.
class WhatIfDiff {
  /// Creates a [WhatIfDiff].
  const WhatIfDiff({
    required this.emiDiff,
    required this.interestDiff,
    required this.totalPaymentDiff,
    required this.savings,
    required this.extraCost,
  });

  /// Change in monthly EMI.
  final double emiDiff;

  /// Change in total interest.
  final double interestDiff;

  /// Change in total payment.
  final double totalPaymentDiff;

  /// Alias for a positive total payment saving.
  final double savings;

  /// Alias for a positive total payment increase.
  final double extraCost;
}

/// Holds the baseline (captured) and current (editable) inputs for the
/// What-If Simulator.
class WhatIfInputState {
  /// Creates a [WhatIfInputState].
  const WhatIfInputState({
    required this.baseline,
    required this.current,
  });

  /// The original / baseline loan inputs.
  final EmiCalculation baseline;

  /// The modified / what-if loan inputs.
  final EmiCalculation current;

  /// Creates a copy with the given fields replaced.
  WhatIfInputState copyWith({
    EmiCalculation? baseline,
    EmiCalculation? current,
  }) {
    return WhatIfInputState(
      baseline: baseline ?? this.baseline,
      current: current ?? this.current,
    );
  }
}

/// Aggregated result for the What-If simulator UI.
class WhatIfComparisonResult {
  /// Creates a [WhatIfComparisonResult].
  const WhatIfComparisonResult({
    required this.baseline,
    required this.current,
    required this.diff,
  });

  /// Baseline scenario result.
  final WhatIfScenarioResult baseline;

  /// Current scenario result.
  final WhatIfScenarioResult current;

  /// Diff between current and baseline.
  final WhatIfDiff diff;
}
