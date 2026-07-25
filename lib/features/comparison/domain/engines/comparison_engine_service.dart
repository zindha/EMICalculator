import 'dart:math';

import '../../../calculator/domain/engines/emi_calculator_service.dart';
import '../../../calculator/domain/models/emi_calculation.dart';
import '../models/comparison_result.dart';
import '../models/loan_offer.dart';

/// Pure Dart service that performs side-by-side loan comparison analysis.
///
/// The engine computes the EMI, total interest, total payment, effective loan
/// amount, and loan health score for every offer, then identifies winners in
/// each dimension and calculates an overall best-value recommendation.
class ComparisonEngineService {
  /// Creates a [ComparisonEngineService].
  const ComparisonEngineService();

  static final _calculator = EmiCalculatorService();

  /// Analyzes the given [offers] and returns a fully populated
  /// [ComparisonResult].
  ComparisonResult analyze(List<LoanOffer> offers) {
    final validOffers = offers.where((o) => _isValid(o.calculation)).toList();

    if (validOffers.isEmpty) {
      return const ComparisonResult(offers: {});
    }

    final metrics = <String, LoanOfferMetrics>{};
    for (final offer in validOffers) {
      metrics[offer.id] = _computeMetrics(offer);
    }

    return ComparisonResult(
      offers: metrics,
      lowestEmiOfferId: _findMinBy(metrics, (m) => m.emi),
      lowestInterestOfferId: _findMinBy(metrics, (m) => m.totalInterest),
      shortestTenureOfferId: _findMinBy(metrics, (m) => m.tenureMonths.toDouble()),
      lowestTotalPaymentOfferId: _findMinBy(metrics, (m) => m.totalPayment),
      bestOverallOfferId: _findBestOverall(metrics),
    );
  }

  /// Computes metrics for a single [offer].
  LoanOfferMetrics _computeMetrics(LoanOffer offer) {
    final calculation = offer.calculation;
    final emi = _calculator.calculateEmi(calculation);
    final totalInterest = _calculator.calculateTotalInterest(calculation);
    final totalPayment = _calculator.calculateTotalPayment(calculation);
    final effectiveLoanAmount = _calculator.calculateEffectiveLoanAmount(calculation);
    final healthScore = _calculator.calculateLoanHealthScore(calculation);

    return LoanOfferMetrics(
      offer: offer,
      emi: emi,
      totalInterest: totalInterest,
      totalPayment: totalPayment,
      effectiveLoanAmount: effectiveLoanAmount,
      tenureMonths: calculation.tenureMonths,
      healthScore: healthScore,
    );
  }

  /// Validates that a calculation can be evaluated.
  bool _isValid(EmiCalculation calculation) {
    return calculation.loanAmount > 0 &&
        calculation.interestRate >= 0 &&
        calculation.tenureMonths > 0;
  }

  /// Returns the id of the offer with the minimum value of [selector].
  ///
  /// Ties are resolved by picking the first occurrence.
  String? _findMinBy(
    Map<String, LoanOfferMetrics> metrics,
    double Function(LoanOfferMetrics) selector,
  ) {
    if (metrics.isEmpty) return null;

    String? winnerId;
    double minValue = double.infinity;

    for (final entry in metrics.entries) {
      final value = selector(entry.value);
      if (value < minValue) {
        minValue = value;
        winnerId = entry.key;
      }
    }

    return winnerId;
  }

  /// Determines the best overall value offer using a weighted scoring model.
  ///
  /// The model favors lower total payment, lower EMI, shorter tenure, and a
  /// higher loan health score. Each dimension is normalized to a 0–1 scale
  /// before scoring so offers of different magnitudes can be compared fairly.
  String? _findBestOverall(Map<String, LoanOfferMetrics> metrics) {
    if (metrics.length < 2) return metrics.keys.firstOrNull;

    final values = metrics.values.toList();
    final maxPayment = values.map((m) => m.totalPayment).reduce(max);
    final maxEmi = values.map((m) => m.emi).reduce(max);
    final maxTenure = values.map((m) => m.tenureMonths).reduce(max);

    final minHealth = values.map((m) => m.healthScore).reduce(min);
    final maxHealth = values.map((m) => m.healthScore).reduce(max);

    String? bestId;
    double bestScore = double.infinity;

    for (final entry in metrics.entries) {
      final m = entry.value;
      final paymentScore = maxPayment > 0 ? m.totalPayment / maxPayment : 0;
      final emiScore = maxEmi > 0 ? m.emi / maxEmi : 0;
      final tenureScore = maxTenure > 0 ? m.tenureMonths / maxTenure : 0;

      double healthScore;
      if (maxHealth > minHealth) {
        healthScore = 1 - ((m.healthScore - minHealth) / (maxHealth - minHealth));
      } else {
        healthScore = 0;
      }

      // Weights: total payment is the strongest cost signal, followed by
      // interest burden (EMI), tenure, and health score.
      final score =
          (paymentScore * 0.4) +
          (emiScore * 0.25) +
          (tenureScore * 0.15) +
          (healthScore * 0.2);

      if (score < bestScore) {
        bestScore = score;
        bestId = entry.key;
      }
    }

    return bestId;
  }
}
