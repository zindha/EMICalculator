import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w600,
          ),
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
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _HistoryListTile(
                entry: entry,
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
            style: GoogleFonts.inter(color: theme.colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 16),
          Text(
            'Calculation History',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your saved calculations will appear here.\nStart by calculating your first EMI.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryListTile extends StatelessWidget {
  const _HistoryListTile({
    required this.entry,
    required this.onToggleFavorite,
    required this.onDelete,
  });

  final CalculationHistoryEntry entry;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    );
    final calculation = entry.calculation;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            entry.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
            color: entry.isFavorite ? AppColors.warning : theme.colorScheme.onSurfaceVariant,
          ),
          onPressed: onToggleFavorite,
        ),
        title: Text(
          entry.title ?? 'Loan Calculation',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${formatter.format(calculation.loanAmount)} · ${calculation.interestRate.toStringAsFixed(1)}% · ${calculation.tenureMonths} months',
          style: GoogleFonts.inter(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
