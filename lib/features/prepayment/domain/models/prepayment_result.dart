import '../../../calculator/domain/models/amortization_month.dart';

/// Result of a prepayment simulation.
///
/// Holds the original loan metrics, the updated amortization schedule after
/// applying prepayments, and the computed savings.
class PrepaymentResult {
  /// Creates a [PrepaymentResult].
  const PrepaymentResult({
    required this.originalEmi,
    required this.originalTenureMonths,
    required this.originalTotalInterest,
    required this.originalTotalPayment,
    required this.updatedSchedule,
    required this.updatedEmi,
    required this.updatedTenureMonths,
    required this.updatedTotalInterest,
    required this.updatedTotalPayment,
    required this.totalExtraPayments,
    required this.interestSaved,
    required this.moneySaved,
    required this.monthsSaved,
    required this.completionDate,
    required this.insights,
  });

  /// Original monthly EMI.
  final double originalEmi;

  /// Original tenure in months.
  final int originalTenureMonths;

  /// Total interest payable on the original loan.
  final double originalTotalInterest;

  /// Total payment for the original loan.
  final double originalTotalPayment;

  /// Amortization schedule after prepayments are applied.
  final List<AmortizationMonth> updatedSchedule;

  /// Updated monthly EMI (same as original for reduce-tenure, lower for
  /// reduce-EMI).
  final double updatedEmi;

  /// Updated tenure in months.
  final int updatedTenureMonths;

  /// Total interest payable after prepayments.
  final double updatedTotalInterest;

  /// Total payment after prepayments.
  final double updatedTotalPayment;

  /// Sum of all extra prepayments made.
  final double totalExtraPayments;

  /// Total interest saved due to prepayments.
  final double interestSaved;

  /// Total money saved (interest saved).
  final double moneySaved;

  /// Number of months by which the loan is shortened.
  final int monthsSaved;

  /// Projected completion date.
  final DateTime completionDate;

  /// Human-readable insights.
  final List<String> insights;
}
