import '../models/comparison_result.dart';
import '../models/loan_offer.dart';

/// Pure Dart service that generates human-readable insights from a
/// [ComparisonResult].
///
/// Insights compare offers across EMI, total interest, tenure, and total
/// payment, and include actionable "what-if" recommendations.
class SmartInsightsService {
  /// Creates a [SmartInsightsService].
  const SmartInsightsService();

  /// Generates a list of insights for the given [result].
  ///
  /// [formatCurrency] is a callback that converts a numeric amount into a
  /// user-facing currency string (e.g., "₹ 2.3 Lakhs").
  List<String> generateInsights(
    ComparisonResult result, {
    required String Function(double) formatCurrency,
  }) {
    final insights = <String>[];
    final entries = result.offers.values.toList();

    if (entries.length < 2) {
      insights.add('Add at least two loans to generate comparison insights.');
      return insights;
    }

    // ── Highlight winners ───────────────────────
    if (result.lowestEmiOfferId != null) {
      final winner = result.offers[result.lowestEmiOfferId]!;
      insights.add(
        '${winner.offer.name} has the lowest EMI at ${formatCurrency(winner.emi)} per month.',
      );
    }

    if (result.lowestInterestOfferId != null) {
      final winner = result.offers[result.lowestInterestOfferId]!;
      insights.add(
        '${winner.offer.name} costs the least in interest (${formatCurrency(winner.totalInterest)} total).',
      );
    }

    if (result.lowestTotalPaymentOfferId != null) {
      final winner = result.offers[result.lowestTotalPaymentOfferId]!;
      insights.add(
        '${winner.offer.name} has the lowest total payment at ${formatCurrency(winner.totalPayment)}.',
      );
    }

    if (result.bestOverallOfferId != null) {
      final winner = result.offers[result.bestOverallOfferId]!;
      insights.add(
        '${winner.offer.name} is the best overall value based on cost and loan health.',
      );
    }

    // ── Pairwise savings ──────────────────────
    final sortedByPayment = entries
      ..sort((a, b) => a.totalPayment.compareTo(b.totalPayment));
    if (sortedByPayment.length >= 2) {
      final best = sortedByPayment.first;
      final second = sortedByPayment[1];
      final savings = second.totalPayment - best.totalPayment;
      if (savings > 0) {
        insights.add(
          '${best.offer.name} saves ${formatCurrency(savings)} compared to ${second.offer.name}.',
        );
      }
    }

    // ── Lowest EMI vs lowest interest trade-off ─
    if (result.lowestEmiOfferId != null &&
        result.lowestInterestOfferId != null &&
        result.lowestEmiOfferId != result.lowestInterestOfferId) {
      final lowEmi = result.offers[result.lowestEmiOfferId]!;
      final lowInterest = result.offers[result.lowestInterestOfferId]!;
      final extraInterest = lowEmi.totalInterest - lowInterest.totalInterest;
      insights.add(
        '${lowEmi.offer.name} has the lowest EMI but costs ${formatCurrency(extraInterest.abs())} more in long-term interest than ${lowInterest.offer.name}.',
      );
    }

    // ── What-if recommendation ────────────────
    insights.addAll(_generateWhatIfInsights(result, formatCurrency));

    return insights;
  }

  /// Generates actionable "what-if" recommendations.
  List<String> _generateWhatIfInsights(
    ComparisonResult result,
    String Function(double) formatCurrency,
  ) {
    final insights = <String>[];
    final entries = result.offers.values.toList();

    // Suggest increasing down payment for the best-overall candidate if it
    // doesn't already have one.
    if (result.bestOverallOfferId != null) {
      final best = result.offers[result.bestOverallOfferId]!;
      final downPayment = best.offer.calculation.downPayment;
      final loanAmount = best.offer.calculation.loanAmount;

      if (downPayment == 0 && loanAmount > 0) {
        final suggested = loanAmount * 0.1;
        insights.add(
          'If you increase the down payment by ${formatCurrency(suggested)} on ${best.offer.name}, your EMI and total interest will drop further.',
        );
      }
    }

    // Suggest the shortest-tenure option if it is not the best overall.
    if (result.shortestTenureOfferId != null &&
        result.shortestTenureOfferId != result.bestOverallOfferId) {
      final shortest = result.offers[result.shortestTenureOfferId]!;
      insights.add(
        '${shortest.offer.name} has the shortest tenure, which means you become debt-free sooner.',
      );
    }

    return insights;
  }
}
