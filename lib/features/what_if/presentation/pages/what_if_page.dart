import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/modern_glass_card.dart';
import '../../../../shared/widgets/number_formatter.dart';
import '../../../../shared/widgets/synced_slider_input.dart';
import '../../domain/models/what_if_result.dart';
import '../providers/what_if_provider.dart';
import '../widgets/what_if_pie_chart.dart';

/// A real-time What-If Simulator that lets users compare a baseline loan
/// scenario with a modified one.
///
/// Sliders update EMI, interest, and total payment instantly. Differences
/// are shown as savings or extra cost.
class WhatIfPage extends ConsumerStatefulWidget {
  /// Creates the [WhatIfPage].
  const WhatIfPage({super.key});

  @override
  ConsumerState<WhatIfPage> createState() => _WhatIfPageState();
}

class _WhatIfPageState extends ConsumerState<WhatIfPage>
    with NumberFormatter {
  final GlobalKey _captureKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final inputState = ref.watch(whatIfInputNotifierProvider);
    final result = ref.watch(whatIfResultProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'What If Simulator',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset to baseline',
            onPressed: () => ref
                .read(whatIfInputNotifierProvider.notifier)
                .reset(),
          ),
          IconButton(
            icon: const Icon(Icons.flag_rounded),
            tooltip: 'Set as baseline',
            onPressed: () {
              ref
                  .read(whatIfInputNotifierProvider.notifier)
                  .setBaseline(inputState.current);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Baseline updated')),
              );
            },
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, 'Baseline Scenario'),
              const SizedBox(height: 12),
              _buildScenarioCard(context, result.baseline, result.current),
              const SizedBox(height: 24),

              _buildSectionTitle(context, 'New Scenario'),
              const SizedBox(height: 12),
              _buildScenarioCard(context, result.current, result.baseline),
              const SizedBox(height: 24),

              _buildSectionTitle(context, 'Difference'),
              const SizedBox(height: 12),
              _buildDiffCard(context, result),
              const SizedBox(height: 24),

              _buildSectionTitle(context, 'Adjust Scenario'),
              const SizedBox(height: 12),
              _buildSliders(context, inputState),
              const SizedBox(height: 24),

              _buildSectionTitle(context, 'Breakdown'),
              const SizedBox(height: 12),
              ModernGlassCard(
                child: SizedBox(
                  height: 220,
                  child: WhatIfPieChart(result: result),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildScenarioCard(
    BuildContext context,
    WhatIfScenarioResult target,
    WhatIfScenarioResult other,
  ) {
    final theme = Theme.of(context);

    return ModernGlassCard(
      tintColor: theme.colorScheme.primary,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMetricRow(
            context,
            'EMI',
            target.emi,
            target.emi - other.emi,
          ),
          _buildMetricRow(
            context,
            'Total Interest',
            target.totalInterest,
            target.totalInterest - other.totalInterest,
          ),
          _buildMetricRow(
            context,
            'Total Payment',
            target.totalPayment,
            target.totalPayment - other.totalPayment,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context,
    String label,
    double value,
    double diff,
  ) {
    final theme = Theme.of(context);
    final isPositive = diff > 0;
    final diffColor = isPositive ? const Color(0xFFE74C3C) : const Color(0xFF2ECC71);
    final diffText = diff > 0
        ?        '+${formatInr(diff)}'
        : diff < 0
            ? '-${formatInr(diff.abs())}'
            : '—';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatInr(value),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                diffText,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: diffColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiffCard(BuildContext context, WhatIfComparisonResult result) {
    final theme = Theme.of(context);
    final hasDiff = result.diff.totalPaymentDiff.abs() > 0.01;
    final isSaving = result.diff.savings > 0;
    final amount = isSaving ? result.diff.savings : result.diff.extraCost;
    final color = !hasDiff
        ? theme.colorScheme.onSurfaceVariant
        : (isSaving ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C));
    final label = !hasDiff ? 'No Difference' : (isSaving ? 'Total Savings' : 'Extra Cost');

    return ModernGlassCard(
      tintColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatInr(amount),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            !hasDiff
                ? 'Both scenarios cost the same.'
                : isSaving
                    ? 'The new scenario is cheaper overall.'
                    : 'The new scenario is more expensive overall.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliders(BuildContext context, WhatIfInputState inputState) {
    final input = inputState.current;
    final notifier = ref.read(whatIfInputNotifierProvider.notifier);

    return Column(
      children: [
        SyncedSliderInput(
          label: 'Loan Amount',
          value: input.loanAmount,
          min: AppConstants.minLoanAmount,
          max: AppConstants.maxLoanAmount,
          step: AppConstants.loanAmountStep,
          prefixSymbol: '₹ ',
          onChanged: notifier.setLoanAmount,
          helperText: 'Principal loan amount',
          semanticLabel: 'Loan amount slider',
        ),
        const SizedBox(height: 16),
        SyncedSliderInput(
          label: 'Interest Rate',
          value: input.interestRate,
          min: AppConstants.minInterestRate,
          max: AppConstants.maxInterestRate,
          step: AppConstants.interestRateStep,
          decimalPlaces: 1,
          prefixSymbol: '',
          suffixText: '%',
          onChanged: notifier.setInterestRate,
          helperText: 'Annual interest rate',
          semanticLabel: 'Interest rate slider',
        ),
        const SizedBox(height: 16),
        SyncedSliderInput(
          label: 'Tenure',
          value: input.tenureMonths.toDouble(),
          min: AppConstants.minTenureMonths.toDouble(),
          max: AppConstants.maxTenureMonths.toDouble(),
          step: AppConstants.tenureStepMonths.toDouble(),
          decimalPlaces: 0,
          prefixSymbol: '',
          suffixText: 'months',
          onChanged: (value) => notifier.setTenureMonths(value.toInt()),
          helperText: 'Loan duration in months',
          semanticLabel: 'Tenure slider',
        ),
      ],
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
                  'Export What-If',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
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
      final filePath = '${directory.path}/what_if_simulation.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'What If Simulation',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image export failed: \$e')),
        );
      }
    }
  }

}
