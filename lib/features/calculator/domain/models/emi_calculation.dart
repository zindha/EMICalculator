import 'package:freezed_annotation/freezed_annotation.dart';

part 'emi_calculation.freezed.dart';
part 'emi_calculation.g.dart';

/// Immutable data class representing the inputs and computed results of an
/// EMI (Equated Monthly Installment) calculation.
///
/// Contains all input parameters required to compute a loan's EMI, total
/// interest, total payment, and amortization schedule.
///
/// All monetary values are in the same currency unit (default: INR).
@freezed
class EmiCalculation with _$EmiCalculation {
  /// Creates an [EmiCalculation] with the given input parameters.
  ///
  /// [loanAmount]: The principal loan amount in rupees (required, > 0).
  /// [interestRate]: The annual interest rate in percentage (e.g., 10.5 for 10.5%).
  /// [tenureMonths]: The loan tenure in months (e.g., 60 for 5 years).
  /// [processingFee]: The processing fee as a percentage of loan amount (optional, default 0).
  /// [insurance]: The insurance amount in rupees (optional, default 0).
  /// [downPayment]: The down payment amount in rupees (optional, default 0).
  const factory EmiCalculation({
    required double loanAmount,
    required double interestRate,
    required int tenureMonths,
    @Default(0.0) double processingFee,
    @Default(0.0) double insurance,
    @Default(0.0) double downPayment,
  }) = _EmiCalculation;

  /// Creates an [EmiCalculation] from a JSON map.
  factory EmiCalculation.fromJson(Map<String, dynamic> json) =>
      _$EmiCalculationFromJson(json);
}
