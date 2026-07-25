import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../calculator/domain/engines/emi_calculator_service.dart';
import '../../../calculator/domain/models/emi_calculation.dart';
import '../../domain/models/what_if_result.dart';

/// Provider for the [EmiCalculatorService] used by the what-if simulator.
final whatIfCalculatorServiceProvider = Provider<EmiCalculatorService>((ref) {
  return const EmiCalculatorService();
});

/// Notifier that manages baseline and current loan inputs for the What-If
/// Simulator.
class WhatIfInputNotifier extends StateNotifier<WhatIfInputState> {
  /// Creates a [WhatIfInputNotifier].
  WhatIfInputNotifier() : super(_defaultState());

  static WhatIfInputState _defaultState() {
    const defaultInput = EmiCalculation(
      loanAmount: 500000,
      interestRate: 10.5,
      tenureMonths: 60,
    );

    return const WhatIfInputState(
      baseline: defaultInput,
      current: defaultInput,
    );
  }

  /// Resets the current input to match the baseline.
  void reset() {
    state = state.copyWith(current: state.baseline);
  }

  /// Captures the current input as the new baseline.
  void setBaseline(EmiCalculation baseline) {
    state = state.copyWith(baseline: baseline, current: baseline);
  }

  /// Updates the current loan amount.
  void setLoanAmount(double value) {
    state = state.copyWith(
      current: state.current.copyWith(loanAmount: value),
    );
  }

  /// Updates the current interest rate.
  void setInterestRate(double value) {
    state = state.copyWith(
      current: state.current.copyWith(interestRate: value),
    );
  }

  /// Updates the current tenure in months.
  void setTenureMonths(int value) {
    state = state.copyWith(
      current: state.current.copyWith(tenureMonths: value),
    );
  }
}

/// Provider that exposes the what-if input state.
final whatIfInputNotifierProvider =
    StateNotifierProvider<WhatIfInputNotifier, WhatIfInputState>(
  (ref) => WhatIfInputNotifier(),
);

/// Provider that computes both scenario results and the diff.
final whatIfResultProvider = Provider<WhatIfComparisonResult>((ref) {
  final inputState = ref.watch(whatIfInputNotifierProvider);
  final service = ref.watch(whatIfCalculatorServiceProvider);

  return _compute(inputState, service);
});

WhatIfComparisonResult _compute(
  WhatIfInputState inputState,
  EmiCalculatorService service,
) {
  final baselineResult = _resultFor(inputState.baseline, service);
  final currentResult = _resultFor(inputState.current, service);

  final emiDiff = currentResult.emi - baselineResult.emi;
  final interestDiff =
      currentResult.totalInterest - baselineResult.totalInterest;
  final totalPaymentDiff =
      currentResult.totalPayment - baselineResult.totalPayment;

  return WhatIfComparisonResult(
    baseline: baselineResult,
    current: currentResult,
    diff: WhatIfDiff(
      emiDiff: emiDiff,
      interestDiff: interestDiff,
      totalPaymentDiff: totalPaymentDiff,
      savings: totalPaymentDiff < 0 ? -totalPaymentDiff : 0,
      extraCost: totalPaymentDiff > 0 ? totalPaymentDiff : 0,
    ),
  );
}

WhatIfScenarioResult _resultFor(
  EmiCalculation input,
  EmiCalculatorService service,
) {
  final emi = service.calculateEmi(input);
  final totalInterest = service.calculateTotalInterest(input);
  final totalPayment = service.calculateTotalPayment(input);
  final effectiveLoanAmount = service.calculateEffectiveLoanAmount(input);

  return WhatIfScenarioResult(
    emi: emi,
    totalInterest: totalInterest,
    totalPayment: totalPayment,
    effectiveLoanAmount: effectiveLoanAmount,
  );
}
