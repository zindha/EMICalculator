import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/modern_card.dart';
import '../../../../shared/widgets/image_export_service.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('What If Simulator'),
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
              ModernCard(
                child: SizedBox(
                  height: _clampChartHeight(0.28),
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

  double _clampChartHeight(double factor) {
    final height = MediaQuery.of(context).size.height * factor;
    return height.clamp(180.0, 280.0);
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildScenarioCard(
    BuildContext context,
    WhatIfScenarioResult target,
    WhatIfScenarioResult other,
  ) {
    final theme = Theme.of(context);

    return ModernCard(
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
    final diffColor = isPositive ? AppColors.danger : AppColors.positive;
    final diffText = diff > 0
        ? '+${formatInr(diff)}'
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
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatInr(value),
                style: AppTypography.monetaryStyle(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (diff != 0)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: diffColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    diffText,
                    style: AppTypography.monetaryStyle(context).copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: diffColor,
                    ),
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
        : (isSaving ? AppColors.positive : AppColors.danger);
    final label = !hasDiff ? 'No Difference' : (isSaving ? 'Total Savings' : 'Extra Cost');

    return ModernCard(
      tintColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatInr(amount),
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
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
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
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
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Export What-If',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.image_rounded),
                  title: const Text('Export Image'),
                  subtitle: const Text('Share as a screenshot'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
      await ImageExportService.captureAndShare(
        captureKey: _captureKey,
        fileName: 'what_if_simulation',
        shareSubject: 'What If Simulation',
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
