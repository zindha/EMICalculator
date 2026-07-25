import 'package:freezed_annotation/freezed_annotation.dart';

part 'amortization_month.freezed.dart';
part 'amortization_month.g.dart';

/// Represents a single month's entry in a loan amortization schedule.
///
/// Each month shows the opening balance, the principal and interest portions
/// of the EMI, and the closing balance after the payment.
@freezed
class AmortizationMonth with _$AmortizationMonth {
  /// Creates an [AmortizationMonth] entry.
  ///
  /// [monthNumber]: The sequential month number (1-based).
  /// [openingBalance]: The loan balance at the start of the month.
  /// [emiAmount]: The total EMI paid this month.
  /// [principalPaid]: The portion of EMI that goes toward principal reduction.
  /// [interestPaid]: The portion of EMI that goes toward interest.
  /// [closingBalance]: The loan balance after this month's payment.
  /// [totalPaidSoFar]: The cumulative amount paid up to this month.
  const factory AmortizationMonth({
    required int monthNumber,
    required double openingBalance,
    required double emiAmount,
    required double principalPaid,
    required double interestPaid,
    required double closingBalance,
    required double totalPaidSoFar,
  }) = _AmortizationMonth;

  /// Creates an [AmortizationMonth] from a JSON map.
  factory AmortizationMonth.fromJson(Map<String, dynamic> json) =>
      _$AmortizationMonthFromJson(json);
}
