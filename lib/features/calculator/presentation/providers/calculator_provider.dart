import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/engines/emi_calculator_service.dart';
import '../../domain/models/emi_calculation.dart';

part 'calculator_provider.g.dart';

/// Riverpod provider that always exposes the current [EmiCalculation] state.
///
/// This is a simple provider (value provider) that returns the default
/// calculation. The actual input state is managed by the [calculatorInputProvider]
/// notifier below.
@Riverpod(keepAlive: true)
EmiCalculatorService emiCalculatorService(EmiCalculatorServiceRef ref) {
  return const EmiCalculatorService();
}

/// Notifier that manages the user's current loan input state.
///
/// Provides mutation methods for each input field and auto-recalculates
/// the result whenever any input changes.
@Riverpod(keepAlive: true)
class CalculatorInputNotifier extends _$CalculatorInputNotifier {
  @override
  EmiCalculation build() {
    return const EmiCalculation(
      loanAmount: 500000,
      interestRate: 10.5,
      tenureMonths: 60,
    );
  }

  /// Updates the loan amount to [value].
  void setLoanAmount(double value) {
    state = state.copyWith(loanAmount: value);
  }

  /// Updates the interest rate to [value].
  void setInterestRate(double value) {
    state = state.copyWith(interestRate: value);
  }

  /// Updates the tenure in months to [value].
  void setTenureMonths(int value) {
    state = state.copyWith(tenureMonths: value);
  }

  /// Updates the processing fee percentage to [value].
  void setProcessingFee(double value) {
    state = state.copyWith(processingFee: value);
  }

  /// Updates the insurance amount to [value].
  void setInsurance(double value) {
    state = state.copyWith(insurance: value);
  }

  /// Updates the down payment amount to [value].
  void setDownPayment(double value) {
    state = state.copyWith(downPayment: value);
  }
}

/// Result holder for a complete EMI calculation.
class EmiCalculationResult {
  /// Creates an [EmiCalculationResult].
  const EmiCalculationResult({
    required this.emi,
    required this.totalInterest,
    required this.totalPayment,
    required this.effectiveLoanAmount,
    required this.monthlyRate,
    required this.amortizationSchedule,
    required this.healthScore,
    this.stressLevel,
    this.stressRatio,
  });

  /// The computed monthly EMI amount.
  final double emi;

  /// Total interest payable over the full tenure.
  final double totalInterest;

  /// Total payment (principal + interest).
  final double totalPayment;

  /// Effective loan amount after fees, insurance, and down payment.
  final double effectiveLoanAmount;

  /// Monthly interest rate (as a decimal).
  final double monthlyRate;

  /// The full amortization schedule.
  final List<dynamic> amortizationSchedule;

  /// Loan health score (0–100).
  final int healthScore;

  /// EMI stress level, if monthly income was provided.
  final dynamic stressLevel;

  /// EMI-to-income ratio (0.0–1.0), if monthly income was provided.
  final double? stressRatio;
}

/// Riverpod provider that computes the full [EmiCalculationResult] based on
/// the current [EmiCalculation] input state.
///
/// This is a derived provider that automatically recalculates whenever the
/// input changes.
@Riverpod(keepAlive: true)
class EmiResultNotifier extends _$EmiResultNotifier {
  @override
  EmiCalculationResult? build() {
    // Watch the input so recalculations happen automatically.
    final input = ref.watch(calculatorInputNotifierProvider);
    final service = ref.watch(emiCalculatorServiceProvider);

    if (input.loanAmount <= 0 || input.tenureMonths <= 0) return null;

    try {
      final emi = service.calculateEmi(input);
      final totalInterest = service.calculateTotalInterest(input);
      final totalPayment = service.calculateTotalPayment(input);
      final effectiveLoanAmount =
          service.calculateEffectiveLoanAmount(input);
      final monthlyRate = input.interestRate / 12 / 100;
      final schedule = service.generateAmortizationSchedule(input);
      final healthScore = service.calculateLoanHealthScore(input);

      return EmiCalculationResult(
        emi: emi,
        totalInterest: totalInterest,
        totalPayment: totalPayment,
        effectiveLoanAmount: effectiveLoanAmount,
        monthlyRate: monthlyRate,
        amortizationSchedule: schedule,
        healthScore: healthScore,
      );
    } catch (e) {
      return null;
    }
  }
}
