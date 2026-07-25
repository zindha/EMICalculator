import 'package:flutter/material.dart';

import '../../../../../shared/widgets/modern_card.dart';
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

    return ModernCard(
      tintColor: theme.colorScheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Smart Insights',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: theme.colorScheme.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.insights.map((insight) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 7, right: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      insight,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13, height: 1.5, color: theme.colorScheme.onSurface),
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
