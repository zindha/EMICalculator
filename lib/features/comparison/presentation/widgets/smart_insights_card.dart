import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../shared/widgets/modern_glass_card.dart';
import '../providers/comparison_provider.dart';

/// Card that displays the human-readable insights generated for a comparison.
class SmartInsightsCard extends StatelessWidget {
  /// Creates a [SmartInsightsCard].
  const SmartInsightsCard({
    super.key,
    required this.insights,
  });

  /// The generated comparison insights.
  final ComparisonInsights insights;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ModernGlassCard(
      tintColor: theme.colorScheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_rounded,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Smart Insights',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.insights.map((insight) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      insight,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.5,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
