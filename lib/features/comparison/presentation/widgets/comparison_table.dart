import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../shared/widgets/modern_glass_card.dart';
import '../../../../../shared/widgets/number_formatter.dart';
import '../../domain/models/comparison_result.dart';
import '../../domain/models/loan_offer.dart';

/// A horizontally scrollable comparison table that lists each loan offer as
/// a column and highlights the winning values for each metric.
class ComparisonTable extends StatelessWidget with NumberFormatter {
  /// Creates a [ComparisonTable].
  const ComparisonTable({
    super.key,
    required this.result,
    required this.offers,
  });

  /// The analyzed comparison result.
  final ComparisonResult result;

  /// The loan offers in display order.
  final List<LoanOffer> offers;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label column
          _buildLabelColumn(context),
          // Offer columns
          ...offers.map((offer) => _buildOfferColumn(context, offer)),
        ],
      ),
    );
  }

  Widget _buildLabelColumn(BuildContext context) {
    final labels = [
      'Loan Name',
      'EMI',
      'Total Interest',
      'Total Payment',
      'Tenure',
      'Health Score',
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: labels.map((label) {
          return Container(
            width: 140,
            height: 48,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOfferColumn(BuildContext context, LoanOffer offer) {
    final theme = Theme.of(context);
    final metrics = result.offers[offer.id];

    if (metrics == null) {
      return const SizedBox.shrink();
    }

    final isBestOverall = result.bestOverallOfferId == offer.id;
    final cells = [
      _CellData(value: offer.name, isHeader: true),
      _CellData(value: formatInrDecimal(metrics.emi)),
      _CellData(value: formatInrDecimal(metrics.totalInterest)),
      _CellData(value: formatInrDecimal(metrics.totalPayment)),
      _CellData(value: formatDuration(metrics.tenureMonths)),
      _CellData(value: '${metrics.healthScore}'),
    ];

    return ModernGlassCard(
      width: 160,
      margin: const EdgeInsets.only(right: 12, bottom: 8),
      tintColor: isBestOverall ? theme.colorScheme.primary : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: cells.asMap().entries.map((entry) {
          final rowIndex = entry.key;
          final cell = entry.value;
          final isHighlighted = _isHighlighted(offer.id, rowIndex);

          return Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isHighlighted
                  ? const Color(0xFF2ECC71).withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              cell.value,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: cell.isHeader ? 14 : 13,
                fontWeight: cell.isHeader || isHighlighted
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: isHighlighted
                    ? const Color(0xFF2ECC71)
                    : theme.colorScheme.onSurface,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _isHighlighted(String offerId, int rowIndex) {
    switch (rowIndex) {
      case 1:
        return result.lowestEmiOfferId == offerId;
      case 2:
        return result.lowestInterestOfferId == offerId;
      case 3:
        return result.lowestTotalPaymentOfferId == offerId;
      case 4:
        return result.shortestTenureOfferId == offerId;
      case 5:
        return result.bestOverallOfferId == offerId;
      default:
        return false;
    }
  }
}

class _CellData {
  const _CellData({required this.value, this.isHeader = false});

  final String value;
  final bool isHeader;
}
