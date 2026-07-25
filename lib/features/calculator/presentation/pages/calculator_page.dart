import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/modern_glass_card.dart';
import '../../../../shared/widgets/synced_slider_input.dart';
import '../providers/calculator_provider.dart';
import '../widgets/hero_card.dart';
import '../widgets/result_charts.dart';

/// The main EMI Calculator screen.
///
/// Contains:
/// - Top section: [HeroCard] displaying the computed EMI with animated counter.
/// - Middle section: [SyncedSliderInput] widgets for loan amount, rate, tenure,
///   and optional expandable fields for processing fee and down payment.
/// - Bottom section: [ResultCharts] showing pie and line charts.
class CalculatorPage extends ConsumerWidget {
  /// Creates the [CalculatorPage].
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final input = ref.watch(calculatorInputNotifierProvider);
    final result = ref.watch(emiResultNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'EMI Calculator',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (result != null)
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
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Card ─────────────────────────
            const HeroCard(),
            const SizedBox(height: 24),

            // ── Input Section ─────────────────────
            _buildSectionTitle(context, 'Loan Details'),
            const SizedBox(height: 16),

            // Loan Amount Slider
            SyncedSliderInput(
              label: 'Loan Amount',
              value: input.loanAmount,
              min: AppConstants.minLoanAmount,
              max: AppConstants.maxLoanAmount,
              step: AppConstants.loanAmountStep,
              prefixSymbol: '₹ ',
              onChanged: (value) {
                ref.read(calculatorInputNotifierProvider.notifier)
                    .setLoanAmount(value);
              },
              helperText: '₹1,000 – ₹10,00,00,000',
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

            // Tenure Slider
            SyncedSliderInput(
              label: 'Tenure',
              value: input.tenureMonths.toDouble(),
              min: AppConstants.minTenureMonths.toDouble(),
              max: AppConstants.maxTenureMonths.toDouble(),
              step: AppConstants.tenureStepMonths.toDouble(),
              decimalPlaces: 0,
              prefixSymbol: '',
              suffixText: 'months',
              onChanged: (value) {
                ref.read(calculatorInputNotifierProvider.notifier)
                    .setTenureMonths(value.toInt());
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
              const SizedBox(height: 16),
              ModernGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Loan Health Score Bar
                    _buildHealthScoreBar(context, result),
                    const SizedBox(height: 16),
                    const ResultCharts(),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Empty state when no result yet.
            if (result == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.calculate_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Adjust the sliders above to\nsee your EMI breakdown',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds a section title widget.
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
      scoreColor = const Color(0xFF2ECC71);
      scoreLabel = 'Excellent';
    } else if (score >= 50) {
      scoreColor = const Color(0xFFF39C12);
      scoreLabel = 'Fair';
    } else {
      scoreColor = const Color(0xFFE74C3C);
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
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Row(
              children: [
                Text(
                  '$score',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: scoreColor,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  scoreLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: scoreColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
            minHeight: 6,
          ),
        ),
      ],
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
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
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
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
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
                  prefixSymbol: '₹ ',
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
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}
