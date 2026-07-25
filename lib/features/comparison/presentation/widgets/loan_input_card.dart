import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../shared/widgets/modern_glass_card.dart';
import '../../../../../shared/widgets/synced_slider_input.dart';
import '../../../calculator/domain/models/emi_calculation.dart';
import '../../domain/models/loan_offer.dart';
import '../providers/comparison_provider.dart';

/// Card that allows the user to edit the inputs of a single [LoanOffer]
/// within a comparison session.
class LoanInputCard extends ConsumerStatefulWidget {
  /// Creates a [LoanInputCard].
  const LoanInputCard({
    super.key,
    required this.index,
    required this.offer,
    this.onRemove,
  });

  /// Index of this offer in the active session.
  final int index;

  /// The loan offer being edited.
  final LoanOffer offer;

  /// Optional callback invoked when the remove button is pressed.
  final VoidCallback? onRemove;

  @override
  ConsumerState<LoanInputCard> createState() => _LoanInputCardState();
}

class _LoanInputCardState extends ConsumerState<LoanInputCard> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.offer.name);
  }

  @override
  void didUpdateWidget(covariant LoanInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep the controller in sync if the offer name changes externally.
    if (oldWidget.offer.name != widget.offer.name &&
        _nameController.text != widget.offer.name) {
      _nameController.text = widget.offer.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final calculation = widget.offer.calculation;

    return ModernGlassCard(
      width: 320,
      margin: const EdgeInsets.only(right: 12, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with name field and remove button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Loan Name',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintStyle: GoogleFonts.spaceGrotesk(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  onChanged: (value) {
                    ref
                        .read(activeComparisonNotifierProvider.notifier)
                        .updateOfferName(widget.index, value);
                  },
                ),
              ),
              if (widget.onRemove != null)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: theme.colorScheme.error,
                  ),
                  tooltip: 'Remove loan',
                  onPressed: widget.onRemove,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Loan Amount
          SyncedSliderInput(
            label: 'Loan Amount',
            value: calculation.loanAmount,
            min: AppConstants.minLoanAmount,
            max: AppConstants.maxLoanAmount,
            step: AppConstants.loanAmountStep,
            prefixSymbol: '₹ ',
            onChanged: (value) => _updateCalculation(calculation, loanAmount: value),
            helperText: 'Principal loan amount',
            semanticLabel: 'Loan amount',
          ),
          const SizedBox(height: 12),

          // Interest Rate
          SyncedSliderInput(
            label: 'Interest Rate',
            value: calculation.interestRate,
            min: AppConstants.minInterestRate,
            max: AppConstants.maxInterestRate,
            step: AppConstants.interestRateStep,
            decimalPlaces: 1,
            prefixSymbol: '',
            suffixText: '%',
            onChanged: (value) => _updateCalculation(calculation, interestRate: value),
            helperText: 'Annual interest rate',
            semanticLabel: 'Interest rate',
          ),
          const SizedBox(height: 12),

          // Tenure
          SyncedSliderInput(
            label: 'Tenure',
            value: calculation.tenureMonths.toDouble(),
            min: AppConstants.minTenureMonths.toDouble(),
            max: AppConstants.maxTenureMonths.toDouble(),
            step: AppConstants.tenureStepMonths.toDouble(),
            decimalPlaces: 0,
            prefixSymbol: '',
            suffixText: 'months',
            onChanged: (value) => _updateCalculation(
              calculation,
              tenureMonths: value.toInt(),
            ),
            helperText: 'Loan duration in months',
            semanticLabel: 'Tenure',
          ),
          const SizedBox(height: 12),

          // Processing Fee
          SyncedSliderInput(
            label: 'Processing Fee',
            value: calculation.processingFee,
            min: 0,
            max: 5,
            step: 0.1,
            decimalPlaces: 1,
            prefixSymbol: '',
            suffixText: '%',
            onChanged: (value) => _updateCalculation(calculation, processingFee: value),
            helperText: '% of loan amount',
            semanticLabel: 'Processing fee',
          ),
          const SizedBox(height: 12),

          // Insurance
          SyncedSliderInput(
            label: 'Insurance',
            value: calculation.insurance,
            min: 0,
            max: calculation.loanAmount,
            step: 10000,
            prefixSymbol: '₹ ',
            onChanged: (value) => _updateCalculation(calculation, insurance: value),
            helperText: 'Optional insurance amount',
            semanticLabel: 'Insurance amount',
          ),
          const SizedBox(height: 12),

          // Down Payment
          SyncedSliderInput(
            label: 'Down Payment',
            value: calculation.downPayment,
            min: 0,
            max: calculation.loanAmount,
            step: 10000,
            prefixSymbol: '₹ ',
            onChanged: (value) => _updateCalculation(calculation, downPayment: value),
            helperText: 'Upfront payment',
            semanticLabel: 'Down payment',
          ),
        ],
      ),
    );
  }

  void _updateCalculation(
    EmiCalculation current, {
    double? loanAmount,
    double? interestRate,
    int? tenureMonths,
    double? processingFee,
    double? insurance,
    double? downPayment,
  }) {
    final updated = current.copyWith(
      loanAmount: loanAmount ?? current.loanAmount,
      interestRate: interestRate ?? current.interestRate,
      tenureMonths: tenureMonths ?? current.tenureMonths,
      processingFee: processingFee ?? current.processingFee,
      insurance: insurance ?? current.insurance,
      downPayment: downPayment ?? current.downPayment,
    );
    ref.read(activeComparisonNotifierProvider.notifier).updateOfferCalculation(
      widget.index,
      updated,
    );
  }
}
