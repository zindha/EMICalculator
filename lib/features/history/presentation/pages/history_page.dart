import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/currency_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';

import '../../data/repositories/history_repository.dart';
import '../providers/history_provider.dart';

/// The History screen showing past loan calculations saved locally.
///
/// Displays a list of saved calculations with options to favorite or delete
/// each entry. Empty state is shown when no calculations have been saved.
class HistoryPage extends ConsumerWidget {
  /// Creates the [HistoryPage].
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncEntries = ref.watch(historyNotifierProvider);
    // Watch currency so the page rebuilds when the selected currency changes.
    final currency = ref.watch(currencyNotifierProvider).currency;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Clear all',
            onPressed: () => ref.read(historyNotifierProvider.notifier).clearAll(),
          ),
        ],
      ),
      body: asyncEntries.when(
        data: (entries) {
          if (entries.isEmpty) {
            return _buildEmptyState(context);
          }            return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _HistoryListTile(
                entry: entry,
                currencySymbol: currency.symbol,
                currencyLocale: currency.locale,
                onToggleFavorite: () {
                  ref.read(historyNotifierProvider.notifier).toggleFavorite(entry.id);
                },
                onDelete: () {
                  ref.read(historyNotifierProvider.notifier).delete(entry.id);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Error: $error',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer
                    .withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 32,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Calculation History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Your saved calculations will appear here.\nStart by calculating your first EMI.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14, color: theme.colorScheme.onSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.go(AppRoutes.calculator),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('New Calculation'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryListTile extends StatelessWidget {
  const _HistoryListTile({
    required this.entry,
    required this.currencySymbol,
    required this.currencyLocale,
    required this.onToggleFavorite,
    required this.onDelete,
  });

  final CalculationHistoryEntry entry;
  final String currencySymbol;
  final String currencyLocale;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(
      locale: currencyLocale,
      symbol: '$currencySymbol ',
      decimalDigits: 0,
    );
    final calculation = entry.calculation;

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant
                .withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: IconButton(
            icon: Icon(
              entry.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: entry.isFavorite ? AppColors.warning : theme.colorScheme.onSurfaceVariant,
              size: 22,
            ),
            tooltip: entry.isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: onToggleFavorite,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
          title: Text(
            entry.title ?? 'Loan Calculation',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              '${formatter.format(calculation.loanAmount)} · ${calculation.interestRate.toStringAsFixed(1)}% · ${calculation.tenureMonths} months',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}
