import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/models/prepayment_strategy.dart';
import '../providers/prepayment_provider.dart';

/// Segmented toggle that lets the user choose between reducing EMI or
/// reducing tenure.
class PrepaymentStrategyToggle extends ConsumerWidget {
  /// Creates a [PrepaymentStrategyToggle].
  const PrepaymentStrategyToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final input = ref.watch(prepaymentInputNotifierProvider);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: PrepaymentStrategy.values.map((strategy) {
          final isSelected = input.strategy == strategy;
          return Expanded(
            child: InkWell(
              onTap: () => ref
                  .read(prepaymentInputNotifierProvider.notifier)
                  .setStrategy(strategy),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      strategy.label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      strategy.description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: isSelected
                            ? theme.colorScheme.onPrimary.withValues(alpha: 0.8)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
