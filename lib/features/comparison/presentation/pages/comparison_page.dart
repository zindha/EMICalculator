import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';


import '../../../../shared/widgets/modern_card.dart';
import '../../../../shared/widgets/image_export_service.dart';
import '../../../../shared/widgets/number_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/comparison_result.dart';
import '../../domain/models/comparison_session.dart';
import '../providers/comparison_provider.dart';
import '../widgets/comparison_charts.dart';
import '../widgets/comparison_table.dart';
import '../widgets/loan_input_card.dart';
import '../widgets/smart_insights_card.dart';

/// The main Loan Comparison screen.
///
/// Allows users to add, edit, and compare multiple loan offers side-by-side,
/// view charts and smart insights, and export/share the comparison.
class ComparisonPage extends ConsumerStatefulWidget {
  /// Creates the [ComparisonPage].
  const ComparisonPage({super.key});

  @override
  ConsumerState<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends ConsumerState<ComparisonPage>
    with NumberFormatter {
  final GlobalKey _captureKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeComparisonNotifierProvider);
    final result = ref.watch(comparisonResultProvider);
    final insights = ref.watch(comparisonInsightsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Compare Loans',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            tooltip: 'Save comparison',
            onPressed: _saveComparison,
          ),
          IconButton(
            icon: const Icon(Icons.folder_open_rounded),
            tooltip: 'Saved comparisons',
            onPressed: () => _showSavedComparisons(context),
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Export / Share',
            onPressed: () => _showExportOptions(context),
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _captureKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Input Section ─────────────────────
              _buildSectionTitle(context, 'Loan Offers'),
              const SizedBox(height: 12),
              SizedBox(
                height: (MediaQuery.of(context).size.height * 0.72)
                    .clamp(520.0, 680.0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: session.offers.length,
                  itemBuilder: (context, index) {
                    final offer = session.offers[index];
                    return LoanInputCard(
                      index: index,
                      offer: offer,
                      onRemove: session.offers.length > 2
                          ? () => ref
                              .read(activeComparisonNotifierProvider.notifier)
                              .removeOffer(index)
                          : null,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton.icon(
                  onPressed: () => ref
                      .read(activeComparisonNotifierProvider.notifier)
                      .addOffer(),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Another Loan'),
                ),
              ),
              const SizedBox(height: 32),

              // ── Comparison Summary ────────────────
              _buildSectionTitle(context, 'Comparison Highlights'),
              const SizedBox(height: 12),
              _buildHighlights(context, result),
              const SizedBox(height: 32),

              // ── Comparison Table ─────────────────
              _buildSectionTitle(context, 'Comparison Table'),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ComparisonTable(result: result, offers: session.offers),
              ),
              const SizedBox(height: 32),

              // ── Charts ────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ComparisonCharts(result: result, offers: session.offers),
              ),
              const SizedBox(height: 32),

              // ── Smart Insights ────────────────────
              _buildSectionTitle(context, 'Smart Insights'),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SmartInsightsCard(insights: insights),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildHighlights(BuildContext context, ComparisonResult result) {
    final theme = Theme.of(context);
    final highlightMap = <String, String?>{
      'Lowest EMI': result.lowestEmiOfferId,
      'Lowest Interest': result.lowestInterestOfferId,
      'Shortest Tenure': result.shortestTenureOfferId,
      'Lowest Total Payment': result.lowestTotalPaymentOfferId,
      'Best Overall Value': result.bestOverallOfferId,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: highlightMap.entries.map((entry) {
          final metrics = result.offers[entry.value ?? ''];
          final label = entry.key;
          final value = metrics?.offer.name ?? '—';            return ModernCard(
            width: 170,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(16),
            tintColor: theme.colorScheme.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 11, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: theme.colorScheme.onSurface),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _saveComparison() async {
    await ref.read(activeComparisonNotifierProvider.notifier).saveActive();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comparison saved')),
      );
    }
    await ref.read(savedComparisonsNotifierProvider.notifier).refresh();
  }

  void _showSavedComparisons(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final asyncSessions = ref.watch(savedComparisonsNotifierProvider);

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Saved Comparisons',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: asyncSessions.when(
                          data: (sessions) {
                            if (sessions.isEmpty) {
                              return Center(
                                child: Text(
                                  'No saved comparisons yet',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                ),
                              );
                            }
                            return ListView.builder(
                              controller: scrollController,
                              itemCount: sessions.length,
                              itemBuilder: (context, index) {
                                final session = sessions[index];
                                return _SavedComparisonListTile(
                                  session: session,
                                  onLoad: () {
                                    ref
                                        .read(activeComparisonNotifierProvider
                                            .notifier)
                                        .setSession(session);
                                    Navigator.pop(context);
                                  },
                                  onDelete: () async {
                                    await ref
                                        .read(savedComparisonsNotifierProvider
                                            .notifier)
                                        .delete(session.id);
                                  },
                                  onToggleFavorite: () async {
                                    await ref
                                        .read(savedComparisonsNotifierProvider
                                            .notifier)
                                        .toggleFavorite(session.id);
                                  },
                                  onDuplicate: () async {
                                    await ref
                                        .read(savedComparisonsNotifierProvider
                                            .notifier)
                                        .duplicate(session.id);
                                  },
                                  onRename: () async {
                                    final newTitle = await _showRenameDialog(
                                      context,
                                      session.title,
                                    );
                                    if (newTitle != null &&
                                        newTitle.isNotEmpty) {
                                      await ref
                                          .read(savedComparisonsNotifierProvider
                                              .notifier)
                                          .rename(session.id, newTitle);
                                    }
                                  },
                                );
                              },
                            );
                          },
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (error, _) => Center(
                            child: Text('Error: $error'),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<String?> _showRenameDialog(
    BuildContext context,
    String currentTitle,
  ) async {
    final controller = TextEditingController(text: currentTitle);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Comparison'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Comparison title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Export Comparison',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.3),
                ),
                const SizedBox(height: 20),
                _ExportOptionTile(
                  icon: Icons.picture_as_pdf_rounded,
                  label: 'Export PDF',
                  description: 'Professional document with summary',
                  onTap: () {
                    Navigator.pop(context);
                    _exportPdf();
                  },
                ),
                _ExportOptionTile(
                  icon: Icons.table_chart_rounded,
                  label: 'Export CSV',
                  description: 'Open in spreadsheet apps',
                  onTap: () {
                    Navigator.pop(context);
                    _exportCsv();
                  },
                ),
                _ExportOptionTile(
                  icon: Icons.image_rounded,
                  label: 'Export Image',
                  description: 'Share as a screenshot',
                  onTap: () {
                    Navigator.pop(context);
                    _exportImage();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportCsv() async {
    final session = ref.read(activeComparisonNotifierProvider);
    final result = ref.read(comparisonResultProvider);
    final exportService = ref.read(comparisonExportServiceProvider);
    final csv = exportService.generateCsv(session: session, result: result);
    await exportService.shareCsv(csv);
  }

  Future<void> _exportPdf() async {
    try {
      final session = ref.read(activeComparisonNotifierProvider);
      final result = ref.read(comparisonResultProvider);
      final exportService = ref.read(comparisonExportServiceProvider);
      final filePath = await exportService.generatePdf(
        session: session,
        result: result,
      );
      await exportService.sharePdf(filePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF export failed: $e')),
        );
      }
    }
  }

  Future<void> _exportImage() async {
    try {
      final title = ref.read(activeComparisonNotifierProvider).title;
      await ImageExportService.captureAndShare(
        captureKey: _captureKey,
        fileName: 'loan_comparison',
        shareSubject: title,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image export failed: $e')),
        );
      }
    }
  }
}

class _ExportOptionTile extends StatelessWidget {
  const _ExportOptionTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer
                .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        title: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _SavedComparisonListTile extends StatelessWidget {
  const _SavedComparisonListTile({
    required this.session,
    required this.onLoad,
    required this.onDelete,
    required this.onToggleFavorite,
    required this.onDuplicate,
    required this.onRename,
  });

  final ComparisonSession session;
  final VoidCallback onLoad;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDuplicate;
  final VoidCallback onRename;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconButton(
        icon: Icon(
          session.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
          color: session.isFavorite ? AppColors.warning : null,
        ),
        onPressed: onToggleFavorite,
      ),
      title: Text(
        session.title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${session.offers.length} loans • ${DateFormat.yMMMd().format(session.createdAt)}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Rename',
            onPressed: onRename,
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Duplicate',
            onPressed: onDuplicate,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete',
            onPressed: onDelete,
          ),
        ],
      ),
      onTap: onLoad,
    );
  }
}
