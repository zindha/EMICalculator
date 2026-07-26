import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/modern_card.dart';
import '../../../../shared/widgets/synced_slider_input.dart';
import '../providers/calculator_provider.dart';
import '../widgets/calculator_actions.dart';
import '../widgets/hero_card.dart';
import '../widgets/result_charts.dart';
import '../widgets/tenure_toggle.dart';

import 'package:emi_calculator/core/services/notification_service.dart';

/// The main EMI Calculator screen.
///
/// Contains:
/// - Top section: [HeroCard] displaying the computed EMI with animated counter.
/// - Middle section: [SyncedSliderInput] widgets for loan amount, rate, tenure,
///   and optional expandable fields for processing fee and down payment.
/// - Bottom section: [ResultCharts] showing pie and line charts.
class CalculatorPage extends ConsumerStatefulWidget {
  /// Creates the [CalculatorPage].
  const CalculatorPage({super.key});

  @override
  ConsumerState<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends ConsumerState<CalculatorPage> {
  bool _tenureInYears = false;
  final GlobalKey _captureKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final input = ref.watch(calculatorInputNotifierProvider);
    final result = ref.watch(emiResultNotifierProvider);
    // Watch currency so the page rebuilds when the selected currency changes.
    ref.watch(currencyNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'EMI Calculator',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          // ── Undo / Redo / Reset ────────────────
          _UndoRedoButton(
            icon: Icons.undo_rounded,
            tooltip: 'Undo',
            onPressed: () => ref.read(calculatorInputNotifierProvider.notifier).undo(),
            enabled: ref.read(calculatorInputNotifierProvider.notifier).canUndo,
          ),
          _UndoRedoButton(
            icon: Icons.redo_rounded,
            tooltip: 'Redo',
            onPressed: () => ref.read(calculatorInputNotifierProvider.notifier).redo(),
            enabled: ref.read(calculatorInputNotifierProvider.notifier).canRedo,
          ),
          IconButton(
            icon: const Icon(Icons.replay_rounded),
            tooltip: 'Reset',
            onPressed: () {
              ref.read(calculatorInputNotifierProvider.notifier).reset();
              NotificationService.show('Calculator reset');
            },
          ),
          if (result != null) ...[
            IconButton(
              icon: const Icon(Icons.save_rounded),
              tooltip: 'Save Calculation',
              onPressed: () => saveCalculationToHistory(context, ref, input),
            ),
            IconButton(
              icon: const Icon(Icons.download_rounded),
              tooltip: 'View Amortization Schedule',
              onPressed: () {
                context.push(
                  AppRoutes.amortizationSchedule,
                  extra: {
                    'months': result.amortizationSchedule,
                    'loanAmount': result.effectiveLoanAmount,
                    'totalInterest': result.totalInterest,
                    'totalPayment': result.totalPayment,
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: 'Share / Export',
              onPressed: () => showCalculatorExportOptions(
                context: context,
                ref: ref,
                input: input,
                result: result,
                captureKey: _captureKey,
              ),
            ),
          ],
        ],
      ),
      body: RepaintBoundary(
        key: _captureKey,
        child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Card ─────────────────────────
            const HeroCard(),
            const SizedBox(height: 24),

            // ── Input Section ─────────────────────
            _buildSectionTitle(context, 'Loan Details'),
            const SizedBox(height: 20),

            // Loan Amount Slider
            SyncedSliderInput(
              label: 'Loan Amount',
              value: input.loanAmount,
              min: AppConstants.minLoanAmount,
              max: AppConstants.maxLoanAmount,
              step: AppConstants.loanAmountStep,
              onChanged: (value) {
                ref.read(calculatorInputNotifierProvider.notifier)
                    .setLoanAmount(value);
              },
              helperText: 'Min – Max loan amount',
              semanticLabel: 'Loan amount slider',
            ),
            const SizedBox(height: 16),

            // Interest Rate Slider
            SyncedSliderInput(
              label: 'Interest Rate',
              value: input.interestRate,
              min: AppConstants.minInterestRate,
              max: AppConstants.maxInterestRate,
              step: AppConstants.interestRateStep,
              decimalPlaces: 1,
              prefixSymbol: '',
              suffixText: '%',
              onChanged: (value) {
                ref.read(calculatorInputNotifierProvider.notifier)
                    .setInterestRate(value);
              },
              helperText: '0% – 50% per annum',
              semanticLabel: 'Interest rate slider',
            ),
            const SizedBox(height: 16),

            // Tenure Slider with months/years toggle
            _buildSectionTitle(context, 'Tenure'),
            const SizedBox(height: 12),
            TenureToggle(
              inYears: _tenureInYears,
              onChanged: (value) => setState(() => _tenureInYears = value),
            ),
            const SizedBox(height: 12),
            SyncedSliderInput(
              label: _tenureInYears ? 'Tenure (Years)' : 'Tenure (Months)',
              value: _tenureInYears
                  ? (input.tenureMonths / 12).floorToDouble()
                  : input.tenureMonths.toDouble(),
              min: 1,
              max: _tenureInYears ? 30 : 360,
              step: 1,
              decimalPlaces: 0,
              prefixSymbol: '',
              suffixText: _tenureInYears ? 'years' : 'months',
              onChanged: (value) {
                final months = _tenureInYears ? (value * 12).toInt() : value.toInt();
                ref.read(calculatorInputNotifierProvider.notifier)
                    .setTenureMonths(months);
              },
              helperText: '1 month – 30 years',
              semanticLabel: 'Loan tenure slider',
            ),
            const SizedBox(height: 8),

            // ── Expandable Advanced Fields ────────
            _AdvancedFields(),
            const SizedBox(height: 24),

            // ── Charts Section ────────────────────
            if (result != null) ...[
              _buildSectionTitle(context, 'Charts & Analysis'),
              const SizedBox(height: 20),
              ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Loan Health Score Bar
                    _buildHealthScoreBar(context, result),
                    const SizedBox(height: 20),
                    const ResultCharts(),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Empty state when no result yet.
            if (result == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
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
                          Icons.trending_up_rounded,
                          size: 32,
                          color: theme.colorScheme.primary.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Move the sliders to see\nyour EMI breakdown',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w400, color: theme.colorScheme.onSurfaceVariant, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }

  /// Builds a section title widget.
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  /// Builds the loan health score indicator bar.
  Widget _buildHealthScoreBar(
    BuildContext context,
    dynamic result,
  ) {
    final theme = Theme.of(context);
    final score = result.healthScore as int;

    Color scoreColor;
    String scoreLabel;
    if (score >= 80) {
      scoreColor = AppColors.healthExcellent;
      scoreLabel = 'Excellent';
    } else if (score >= 50) {
      scoreColor = AppColors.healthFair;
      scoreLabel = 'Fair';
    } else {
      scoreColor = AppColors.healthRisky;
      scoreLabel = 'Risky';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Loan Health Score',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant),
            ),
            Row(
              children: [
                Text(
                  '$score',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: scoreColor),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    scoreLabel,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: scoreColor),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.5),
            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

/// Small icon button used for undo/redo actions.
///
/// Unlike a plain [IconButton], this widget fades out when disabled and
/// always occupies the same 48dp touch target.
class _UndoRedoButton extends StatelessWidget {
  const _UndoRedoButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.enabled,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      icon: Icon(icon),
      tooltip: enabled ? tooltip : '$tooltip (unavailable)',
      color: theme.colorScheme.onSurface.withValues(
        alpha: enabled ? 1.0 : 0.38,
      ),
      onPressed: enabled ? onPressed : null,
    );
  }
}

/// Expandable section for advanced loan fields (processing fee, insurance,
/// down payment).
class _AdvancedFields extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AdvancedFields> createState() => _AdvancedFieldsState();
}

class _AdvancedFieldsState extends ConsumerState<_AdvancedFields> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final input = ref.watch(calculatorInputNotifierProvider);

    return Column(
      children: [          InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _expanded ? 'Hide Advanced Fields' : 'Show Advanced Fields',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.primary),
                ),
              ],
            ),
          ),
        ),          AnimatedCrossFade(
          duration: Duration(
            milliseconds:
                MediaQuery.of(context).disableAnimations ? 0 : 300,
          ),
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: [
                SyncedSliderInput(
                  label: 'Processing Fee',
                  value: input.processingFee,
                  min: 0,
                  max: 5,
                  step: 0.1,
                  decimalPlaces: 1,
                  prefixSymbol: '',
                  suffixText: '%',
                  onChanged: (value) {
                    ref.read(calculatorInputNotifierProvider.notifier)
                        .setProcessingFee(value);
                  },
                  helperText: '0% – 5% of loan amount',
                  semanticLabel: 'Processing fee slider',
                ),
                const SizedBox(height: 16),
                SyncedSliderInput(
                  label: 'Down Payment',
                  value: input.downPayment,
                  min: 0,
                  max: input.loanAmount,
                  step: 10000,
                  onChanged: (value) {
                    ref.read(calculatorInputNotifierProvider.notifier)
                        .setDownPayment(value);
                  },
                  helperText: 'Reduce loan amount by paying upfront',
                  semanticLabel: 'Down payment slider',
                ),
              ],
            ),
          ),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,

        ),
      ],
    );
  }
}
