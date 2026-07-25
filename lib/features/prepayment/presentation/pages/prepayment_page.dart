import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../shared/widgets/modern_glass_card.dart';
import '../../data/repositories/prepayment_repository.dart';
import '../../domain/models/prepayment_frequency.dart';
import '../../domain/models/prepayment_rule.dart';
import '../providers/prepayment_provider.dart';
import '../widgets/prepayment_pie_chart.dart';
import '../widgets/prepayment_strategy_toggle.dart';
import '../widgets/prepayment_summary_card.dart';
import '../widgets/prepayment_timeline_chart.dart';
import '../widgets/prepayment_what_if_sliders.dart';

/// The main Loan Prepayment Planner screen.
///
/// Allows users to simulate prepayments and see their effect on EMI,
/// tenure, and total interest.
class PrepaymentPage extends ConsumerStatefulWidget {
  /// Creates the [PrepaymentPage].
  const PrepaymentPage({super.key});

  @override
  ConsumerState<PrepaymentPage> createState() => _PrepaymentPageState();
}

class _PrepaymentPageState extends ConsumerState<PrepaymentPage> {
  final GlobalKey _captureKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final input = ref.watch(prepaymentInputNotifierProvider);
    final result = ref.watch(prepaymentResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Prepayment Planner',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            tooltip: 'Save plan',
            onPressed: () => _showSaveDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.folder_open_rounded),
            tooltip: 'Saved plans',
            onPressed: () => _showSavedPlans(context),
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
            // ── Strategy Toggle ─────────────────────
            _buildSectionTitle(context, 'Strategy'),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: PrepaymentStrategyToggle(),
            ),
            const SizedBox(height: 32),

            // ── What-if Sliders ────────────────────
            _buildSectionTitle(context, 'What-If Scenarios'),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const PrepaymentWhatIfSliders(),
            ),
            const SizedBox(height: 32),

            // ── Prepayment Rules ───────────────────
            _buildSectionTitle(context, 'Prepayment Rules'),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildRulesList(context),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.icon(
                onPressed: () => _addDefaultRule(),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Prepayment'),
              ),
            ),
            const SizedBox(height: 32),

            // ── Summary ────────────────────────────
            _buildSectionTitle(context, 'Savings Summary'),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PrepaymentSummaryCard(result: result),
            ),
            const SizedBox(height: 32),

            // ── Payment Breakdown ───────────────────
            _buildSectionTitle(context, 'Payment Breakdown'),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ModernGlassCard(
                child: SizedBox(
                  height: 220,
                  child: PrepaymentPieChart(result: result),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Timeline Chart ──────────────────────
            _buildSectionTitle(context, 'Balance Timeline'),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ModernGlassCard(
                child: SizedBox(
                  height: 240,
                  child: PrepaymentTimelineChart(result: result),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Smart Insights ─────────────────────
            _buildSectionTitle(context, 'Smart Insights'),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ModernGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: result.insights.map((insight) {
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
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
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
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Export Plan',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf_rounded),
                  title: const Text('Export PDF'),
                  onTap: () {
                    Navigator.pop(context);
                    _exportPdf();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.table_chart_rounded),
                  title: const Text('Export CSV'),
                  onTap: () {
                    Navigator.pop(context);
                    _exportCsv();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.image_rounded),
                  title: const Text('Export Image'),
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
    final input = ref.read(prepaymentInputNotifierProvider);
    final result = ref.read(prepaymentResultProvider);
    final exportService = ref.read(prepaymentExportServiceProvider);
    final csv = exportService.generateCsv(input: input, result: result);
    await exportService.shareCsv(csv);
  }

  Future<void> _exportPdf() async {
    try {
      final input = ref.read(prepaymentInputNotifierProvider);
      final result = ref.read(prepaymentResultProvider);
      final exportService = ref.read(prepaymentExportServiceProvider);
      final filePath = await exportService.generatePdf(
        title: 'Prepayment Plan',
        input: input,
        result: result,
      );
      await exportService.sharePdf(filePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF export failed: \$e')),
        );
      }
    }
  }

  Future<void> _exportImage() async {
    try {
      final boundary = _captureKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();

      if (bytes == null) return;

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/prepayment_plan.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([XFile(filePath)], subject: 'Prepayment Plan');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image export failed: \$e')),
        );
      }
    }
  }

  void _showSavedPlans(BuildContext context) {
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
            final asyncPlans = ref.watch(savedPrepaymentPlansNotifierProvider);

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
                        'Saved Plans',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: asyncPlans.when(
                          data: (plans) {
                            if (plans.isEmpty) {
                              return Center(
                                child: Text(
                                  'No saved plans yet',
                                  style: GoogleFonts.inter(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              );
                            }
                            return ListView.builder(
                              controller: scrollController,
                              itemCount: plans.length,
                              itemBuilder: (context, index) {
                                final plan = plans[index];
                                return _SavedPlanListTile(
                                  plan: plan,
                                  onLoad: () {
                                    ref
                                        .read(prepaymentInputNotifierProvider
                                            .notifier)
                                        .setInput(plan.input);
                                    Navigator.pop(context);
                                  },
                                  onDelete: () async {
                                    await ref
                                        .read(savedPrepaymentPlansNotifierProvider
                                            .notifier)
                                        .delete(plan.id);
                                  },
                                  onToggleFavorite: () async {
                                    await ref
                                        .read(savedPrepaymentPlansNotifierProvider
                                            .notifier)
                                        .toggleFavorite(plan.id);
                                  },
                                );
                              },
                            );
                          },
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (error, _) => Center(
                            child: Text('Error: \$error'),
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildRulesList(BuildContext context) {
    final input = ref.watch(prepaymentInputNotifierProvider);

    if (input.rules.isEmpty) {
      return ModernGlassCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No prepayment rules yet. Add one to see savings.',
              style: GoogleFonts.inter(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: input.rules.asMap().entries.map((entry) {
        final index = entry.key;
        final rule = entry.value;
        return ListTile(
          title: Text(
            rule.name ?? rule.frequency.label,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '₹${rule.amount.toStringAsFixed(0)} starting month ${rule.startMonth}',
            style: GoogleFonts.inter(fontSize: 12),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => ref
                .read(prepaymentInputNotifierProvider.notifier)
                .removeRule(index),
          ),
        );
      }).toList(),
    );
  }

  void _addDefaultRule() {
    final notifier = ref.read(prepaymentInputNotifierProvider.notifier);
    notifier.addRule(
      PrepaymentRule(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: 5000,
        frequency: PrepaymentFrequency.monthly,
        startMonth: 1,
        name: 'Monthly Extra EMI',
      ),
    );
  }

  Future<void> _showSaveDialog(BuildContext context) async {
    final controller = TextEditingController(text: 'My Prepayment Plan');
    final title = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Plan'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Plan title'),
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

    if (title != null && title.isNotEmpty) {
      await ref.read(savedPrepaymentPlansNotifierProvider.notifier).saveCurrent(title);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan saved')),
        );
      }
    }
  }
}

class _SavedPlanListTile extends StatelessWidget {
  const _SavedPlanListTile({
    required this.plan,
    required this.onLoad,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  final SavedPrepaymentPlan plan;
  final VoidCallback onLoad;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: IconButton(
        icon: Icon(
          plan.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
          color: plan.isFavorite ? const Color(0xFFF39C12) : null,
        ),
        onPressed: onToggleFavorite,
      ),
      title: Text(
        plan.title,
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${plan.input.strategy.label} • ${DateFormat.yMMMd().format(plan.createdAt)}',
        style: GoogleFonts.inter(fontSize: 12),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline_rounded),
        tooltip: 'Delete',
        onPressed: onDelete,
      ),
      onTap: onLoad,
    );
  }
}
