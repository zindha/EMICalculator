import 'package:flutter/foundation.dart';
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
/// the result whenever any input changes. Also supports in-session undo,
/// redo and reset operations.
@Riverpod(keepAlive: true)
class CalculatorInputNotifier extends _$CalculatorInputNotifier {
  final List<EmiCalculation> _history = [];
  int _historyIndex = -1;

  @override
  EmiCalculation build() {
    const initial = EmiCalculation(
      loanAmount: 500000,
      interestRate: 10.5,
      tenureMonths: 60,
    );
    // Seed the undo history with the initial state so the first edit is
    // undo-able and the user can return to the starting values.
    _history.add(initial);
    _historyIndex = 0;
    return initial;
  }

  /// Pushes a new calculation state onto the undo history.
  ///
  /// This is called by every mutator so that undo/redo work transparently
  /// during the current editing session.
  void _pushState(EmiCalculation value) {
    // Remove any redo states if the user edits after undoing.
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _history.add(value);
    _historyIndex = _history.length - 1;
  }

  /// Whether an undo operation is currently available.
  bool get canUndo => _historyIndex > 0;

  /// Whether a redo operation is currently available.
  bool get canRedo => _historyIndex < _history.length - 1;

  /// Reverts the most recent input change.
  void undo() {
    if (!canUndo) return;
    _historyIndex--;
    state = _history[_historyIndex];
  }

  /// Restores the most recently undone input change.
  void redo() {
    if (!canRedo) return;
    _historyIndex++;
    state = _history[_historyIndex];
  }

  /// Resets all inputs back to their initial defaults.
  void reset() {
    const defaultState = EmiCalculation(
      loanAmount: 500000,
      interestRate: 10.5,
      tenureMonths: 60,
    );
    state = defaultState;
    _pushState(defaultState);
  }

  /// Updates the loan amount to [value].
  void setLoanAmount(double value) {
    final next = state.copyWith(loanAmount: value);
    state = next;
    _pushState(next);
  }

  /// Updates the interest rate to [value].
  void setInterestRate(double value) {
    final next = state.copyWith(interestRate: value);
    state = next;
    _pushState(next);
  }

  /// Updates the tenure in months to [value].
  void setTenureMonths(int value) {
    final next = state.copyWith(tenureMonths: value);
    state = next;
    _pushState(next);
  }

  /// Updates the processing fee percentage to [value].
  void setProcessingFee(double value) {
    final next = state.copyWith(processingFee: value);
    state = next;
    _pushState(next);
  }

  /// Updates the insurance amount to [value].
  void setInsurance(double value) {
    final next = state.copyWith(insurance: value);
    state = next;
    _pushState(next);
  }

  /// Updates the down payment amount to [value].
  void setDownPayment(double value) {
    final next = state.copyWith(downPayment: value);
    state = next;
    _pushState(next);
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
      debugPrint('EMI calculation error: $e');
      return null;
    }
  }
}
