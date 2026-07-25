import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/modern_card.dart';
import '../providers/calculator_provider.dart';

/// A premium hero card that displays the computed monthly EMI in large,
/// bold typography with a smooth animated count-up/down effect.
///
/// Uses [TweenAnimationBuilder] to animate the EMI value when inputs change.
/// Also shows total interest, total payment, and loan health score.
class HeroCard extends ConsumerWidget {
  /// Creates a [HeroCard].
  const HeroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final result = ref.watch(emiResultNotifierProvider);

    return ModernCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      tintColor: theme.colorScheme.primary,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Label ──────────────────────────────
          Text(
            'Monthly EMI',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),

          // ── EMI Value (Animated with TweenAnimationBuilder) ──
          if (result != null)
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: result.emi),
              duration: Duration(
                milliseconds:
                    MediaQuery.of(context).disableAnimations ? 0 : 500,
              ),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                final formatter = NumberFormat.currency(
                  locale: 'en_IN',
                  symbol: '₹ ',
                  decimalDigits: 0,
                );

                return FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatter.format(value),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 40, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface, height: 1.1, letterSpacing: -1.5),
                  ),
                );
              },
            )
          else
            Text(
              '₹ 0',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 40, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                height: 1.1,
                letterSpacing: -1.5,
              ),
            ),

          const SizedBox(height: 6),

          // ── Per Month Label ────────────────────
          Text(
            'per month',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.w400, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),

          // ── Divider ────────────────────────────
          Container(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 20),

          // ── Principal / Interest / Total / Score ─
          if (result != null)
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildStatItem(
                      context,
                      label: 'Principal',
                      value: _formatInr(result.effectiveLoanAmount),
                      color: theme.colorScheme.primary,
                    ),
                    _buildStatItem(
                      context,
                      label: 'Interest',
                      value: _formatInr(result.totalInterest),
                      color: AppColors.danger,
                    ),
                    _buildStatItem(
                      context,
                      label: 'Total',
                      value: _formatInr(result.totalPayment),
                      color: theme.colorScheme.onSurface,
                    ),
                    _buildStatItem(
                      context,
                      label: 'Health',
                      value: '${result.healthScore}',
                      color: _healthScoreColor(result.healthScore),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  /// Builds a single statistic item card.
  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTypography.monetaryStyle(context).copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: color),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Returns the appropriate color for a given health score.
  Color _healthScoreColor(int score) {
    if (score >= 80) return AppColors.positive;
    if (score >= 50) return AppColors.warning;
    return AppColors.danger;
  }

  /// Formats a double as Indian rupees.
  String _formatInr(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
