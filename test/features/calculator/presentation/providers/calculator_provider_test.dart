import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:emi_calculator/features/calculator/presentation/providers/calculator_provider.dart';

void main() {
  group('CalculatorInputNotifier', () {
    ProviderContainer createContainer() {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      return container;
    }

    test('initial state is the default calculation', () {
      final container = createContainer();
      final state = container.read(calculatorInputNotifierProvider);
      expect(state.loanAmount, 500000);
      expect(state.interestRate, 10.5);
      expect(state.tenureMonths, 60);
    });

    test('setLoanAmount pushes state and enables undo', () {
      final container = createContainer();
      final notifier = container.read(calculatorInputNotifierProvider.notifier);

      expect(notifier.canUndo, isFalse);
      expect(notifier.canRedo, isFalse);

      notifier.setLoanAmount(1000000);

      expect(container.read(calculatorInputNotifierProvider).loanAmount, 1000000);
      expect(notifier.canUndo, isTrue);
      expect(notifier.canRedo, isFalse);
    });

    test('undo reverts the last change', () {
      final container = createContainer();
      final notifier = container.read(calculatorInputNotifierProvider.notifier);
      notifier.setLoanAmount(1000000);

      notifier.undo();

      expect(container.read(calculatorInputNotifierProvider).loanAmount, 500000);
    });

    test('redo restores an undone change', () {
      final container = createContainer();
      final notifier = container.read(calculatorInputNotifierProvider.notifier);
      notifier.setLoanAmount(1000000);
      notifier.undo();

      expect(notifier.canRedo, isTrue);

      notifier.redo();

      expect(container.read(calculatorInputNotifierProvider).loanAmount, 1000000);
    });

    test('reset returns to default state and enables undo', () {
      final container = createContainer();
      final notifier = container.read(calculatorInputNotifierProvider.notifier);
      notifier.setLoanAmount(1000000);

      notifier.reset();

      final state = container.read(calculatorInputNotifierProvider);
      expect(state.loanAmount, 500000);
      expect(state.interestRate, 10.5);
      expect(state.tenureMonths, 60);
      expect(notifier.canUndo, isTrue);
    });

    test('editing after undo clears redo history', () {
      final container = createContainer();
      final notifier = container.read(calculatorInputNotifierProvider.notifier);
      notifier.setLoanAmount(1000000);
      notifier.setInterestRate(12);
      notifier.undo();
      notifier.undo();

      expect(notifier.canRedo, isTrue);

      notifier.setTenureMonths(120);

      expect(notifier.canRedo, isFalse);
      expect(container.read(calculatorInputNotifierProvider).tenureMonths, 120);
    });

    test('undo at history start is a no-op', () {
      final container = createContainer();
      final notifier = container.read(calculatorInputNotifierProvider.notifier);

      notifier.undo();
      notifier.undo();

      expect(container.read(calculatorInputNotifierProvider).loanAmount, 500000);
      expect(notifier.canUndo, isFalse);
    });

    test('redo at history end is a no-op', () {
      final container = createContainer();
      final notifier = container.read(calculatorInputNotifierProvider.notifier);
      notifier.setLoanAmount(1000000);

      notifier.redo();

      expect(container.read(calculatorInputNotifierProvider).loanAmount, 1000000);
      expect(notifier.canRedo, isFalse);
    });
  });
}
