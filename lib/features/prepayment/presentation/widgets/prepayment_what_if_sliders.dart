import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/synced_slider_input.dart';
import '../providers/prepayment_provider.dart';

/// What-if sliders that let the user tweak the base loan parameters and see
/// the prepayment result update in real time.
class PrepaymentWhatIfSliders extends ConsumerWidget {
  /// Creates a [PrepaymentWhatIfSliders].
  const PrepaymentWhatIfSliders({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final input = ref.watch(prepaymentInputNotifierProvider);
    final notifier = ref.read(prepaymentInputNotifierProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SyncedSliderInput(
          label: 'Loan Amount',
          value: input.baseCalculation.loanAmount,
          min: AppConstants.minLoanAmount,
          max: AppConstants.maxLoanAmount,
          step: AppConstants.loanAmountStep,
          onChanged: notifier.setLoanAmount,
          helperText: 'Principal loan amount',
          semanticLabel: 'Loan amount slider',
        ),
        const SizedBox(height: 16),
        SyncedSliderInput(
          label: 'Interest Rate',
          value: input.baseCalculation.interestRate,
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
          value: input.baseCalculation.tenureMonths.toDouble(),
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
}
