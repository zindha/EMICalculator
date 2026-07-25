import 'loan_offer.dart';

/// Immutable result of analyzing a list of [LoanOffer] entries.
///
/// Holds the computed financial metrics for each offer, identifies the winners
/// across key dimensions, and carries the dynamically generated insights.
class ComparisonResult {
  /// Creates a [ComparisonResult].
  const ComparisonResult({
    required this.offers,
    this.lowestEmiOfferId,
    this.lowestInterestOfferId,
    this.shortestTenureOfferId,
    this.lowestTotalPaymentOfferId,
    this.bestOverallOfferId,
    this.insights = const [],
  });

  /// Map of offer id to its computed metrics.
  final Map<String, LoanOfferMetrics> offers;

  /// Id of the offer with the lowest monthly EMI.
  final String? lowestEmiOfferId;

  /// Id of the offer with the lowest total interest.
  final String? lowestInterestOfferId;

  /// Id of the offer with the shortest tenure.
  final String? shortestTenureOfferId;

  /// Id of the offer with the lowest total payment.
  final String? lowestTotalPaymentOfferId;

  /// Id of the offer selected as the best overall value.
  final String? bestOverallOfferId;

  /// Human-readable insights generated for this comparison.
  final List<String> insights;

  /// Returns the metric for a specific [offerId], or null if not found.
  LoanOfferMetrics? metricsFor(String offerId) => offers[offerId];

  /// Returns true if the given [offerId] won any highlight category.
  bool isHighlighted(String offerId) {
    return lowestEmiOfferId == offerId ||
        lowestInterestOfferId == offerId ||
        shortestTenureOfferId == offerId ||
        lowestTotalPaymentOfferId == offerId ||
        bestOverallOfferId == offerId;
  }

  /// Returns a set of highlight labels for the given [offerId].
  Set<String> highlightLabelsFor(String offerId) {
    final labels = <String>{};
    if (lowestEmiOfferId == offerId) labels.add('Lowest EMI');
    if (lowestInterestOfferId == offerId) labels.add('Lowest Interest');
    if (shortestTenureOfferId == offerId) labels.add('Shortest Tenure');
    if (lowestTotalPaymentOfferId == offerId) labels.add('Lowest Total Payment');
    if (bestOverallOfferId == offerId) labels.add('Best Overall Value');
    return labels;
  }
}

/// Computed financial metrics for a single [LoanOffer].
class LoanOfferMetrics {
  /// Creates a [LoanOfferMetrics].
  const LoanOfferMetrics({
    required this.offer,
    required this.emi,
    required this.totalInterest,
    required this.totalPayment,
    required this.effectiveLoanAmount,
    required this.tenureMonths,
    required this.healthScore,
  });

  /// The source offer.
  final LoanOffer offer;

  /// Monthly EMI amount.
  final double emi;

  /// Total interest payable over the full tenure.
  final double totalInterest;

  /// Total payment (principal + interest + fees + insurance).
  final double totalPayment;

  /// Effective loan amount after fees, insurance, and down payment.
  final double effectiveLoanAmount;

  /// Loan tenure in months.
  final int tenureMonths;

  /// Loan health score for this offer (0–100).
  final int healthScore;
}
