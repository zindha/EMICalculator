import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:emi_calculator/features/what_if/presentation/providers/what_if_provider.dart';

void main() {
  group('WhatIfResultProvider', () {
    test('computes baseline and current results correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = container.read(whatIfResultProvider);

      expect(result.baseline.emi, greaterThan(0));
      expect(result.current.emi, greaterThan(0));
      expect(result.baseline.totalInterest, greaterThan(0));
      expect(result.current.totalInterest, greaterThan(0));
    });

    test('diff reflects an increased loan amount correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(whatIfInputNotifierProvider.notifier);
      notifier.setLoanAmount(1000000);

      final result = container.read(whatIfResultProvider);

      expect(result.diff.emiDiff, greaterThan(0));
      expect(result.diff.interestDiff, greaterThan(0));
      expect(result.diff.totalPaymentDiff, greaterThan(0));
      expect(result.diff.extraCost, greaterThan(0));
      expect(result.diff.savings, equals(0));
    });

    test('reset restores current input to baseline', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(whatIfInputNotifierProvider.notifier).setLoanAmount(1000000);
      container.read(whatIfInputNotifierProvider.notifier).reset();

      final state = container.read(whatIfInputNotifierProvider);
      expect(state.current.loanAmount, equals(state.baseline.loanAmount));
    });

    test('diff reflects savings when total payment decreases', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(whatIfInputNotifierProvider.notifier).setTenureMonths(36);

      final result = container.read(whatIfResultProvider);

      expect(result.diff.savings, greaterThan(0));
      expect(result.diff.extraCost, equals(0));
      expect(result.diff.totalPaymentDiff, lessThan(0));
    });
  });
}
