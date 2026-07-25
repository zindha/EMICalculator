import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../shared/widgets/modern_glass_card.dart';
import '../../../../shared/widgets/number_formatter.dart';
import '../../domain/models/prepayment_result.dart';

/// Card that displays the key savings from a prepayment simulation.
class PrepaymentSummaryCard extends StatelessWidget with NumberFormatter {
  /// Creates a [PrepaymentSummaryCard].
  const PrepaymentSummaryCard({
    super.key,
    required this.result,
  });

  /// The prepayment simulation result.
  final PrepaymentResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ModernGlassCard(
      tintColor: theme.colorScheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Prepayment Summary',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildRow(
            context,
            'Original EMI',
            formatInrDecimal(result.originalEmi),
          ),
          _buildRow(
            context,
            'Updated EMI',
            formatInrDecimal(result.updatedEmi),
          ),
          _buildRow(
            context,
            'Original Tenure',
            '${result.originalTenureMonths} months',
          ),
          _buildRow(
            context,
            'Updated Tenure',
            '${result.updatedTenureMonths} months',
          ),
          _buildRow(
            context,
            'Interest Saved',
            formatInrDecimal(result.interestSaved),
            valueColor: const Color(0xFF2ECC71),
          ),
          _buildRow(
            context,
            'Money Saved',
            formatInrDecimal(result.moneySaved),
            valueColor: const Color(0xFF2ECC71),
          ),
          _buildRow(
            context,
            'Months Saved',
            '${result.monthsSaved}',
            valueColor: const Color(0xFF2ECC71),
          ),
          _buildRow(
            context,
            'Completion Date',
            '${result.completionDate.day}/${result.completionDate.month}/${result.completionDate.year}',
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Container(
            padding: valueColor != null
                ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
                : null,
            decoration: valueColor != null
                ? BoxDecoration(
                    color: valueColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: Text(
              value,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
