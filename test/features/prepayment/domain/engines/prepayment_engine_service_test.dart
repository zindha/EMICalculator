import 'package:emi_calculator/features/calculator/domain/models/emi_calculation.dart';
import 'package:emi_calculator/features/prepayment/domain/engines/prepayment_engine_service.dart';
import 'package:emi_calculator/features/prepayment/domain/models/prepayment_frequency.dart';
import 'package:emi_calculator/features/prepayment/domain/models/prepayment_input.dart';
import 'package:emi_calculator/features/prepayment/domain/models/prepayment_rule.dart';
import 'package:emi_calculator/features/prepayment/domain/models/prepayment_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = PrepaymentEngineService();

  group('PrepaymentEngineService', () {
    test('reduce tenure shortens the loan duration', () {
      final input = PrepaymentInput(
        baseCalculation: const EmiCalculation(
          loanAmount: 500000,
          interestRate: 10.5,
          tenureMonths: 60,
        ),
        rules: [
          PrepaymentRule(
            id: '1',
            amount: 5000,
            frequency: PrepaymentFrequency.monthly,
            startMonth: 1,
          ),
        ],
        strategy: PrepaymentStrategy.reduceTenure,
      );

      final result = engine.calculate(input);

      expect(result.updatedTenureMonths, lessThan(result.originalTenureMonths));
      expect(result.interestSaved, greaterThan(0));
      expect(result.moneySaved, greaterThan(0));
      expect(result.monthsSaved, greaterThan(0));
    });

    test('reduce EMI lowers the monthly EMI while keeping tenure', () {
      final input = PrepaymentInput(
        baseCalculation: const EmiCalculation(
          loanAmount: 500000,
          interestRate: 10.5,
          tenureMonths: 60,
        ),
        rules: [
          PrepaymentRule(
            id: '1',
            amount: 5000,
            frequency: PrepaymentFrequency.monthly,
            startMonth: 1,
          ),
        ],
        strategy: PrepaymentStrategy.reduceEmi,
      );

      final result = engine.calculate(input);

      expect(result.updatedTenureMonths, equals(result.originalTenureMonths));
      expect(result.updatedEmi, lessThan(result.originalEmi));
      expect(result.interestSaved, greaterThan(0));
    });

    test('one-time prepayment reduces interest', () {
      final input = PrepaymentInput(
        baseCalculation: const EmiCalculation(
          loanAmount: 500000,
          interestRate: 10.5,
          tenureMonths: 60,
        ),
        rules: [
          PrepaymentRule(
            id: '1',
            amount: 100000,
            frequency: PrepaymentFrequency.oneTime,
            startMonth: 6,
          ),
        ],
        strategy: PrepaymentStrategy.reduceTenure,
      );

      final result = engine.calculate(input);

      expect(result.interestSaved, greaterThan(0));
      expect(result.totalExtraPayments, greaterThan(0));
    });

    test('quarterly prepayment rule applies correctly', () {
      final input = PrepaymentInput(
        baseCalculation: const EmiCalculation(
          loanAmount: 500000,
          interestRate: 10.5,
          tenureMonths: 24,
        ),
        rules: [
          PrepaymentRule(
            id: '1',
            amount: 10000,
            frequency: PrepaymentFrequency.quarterly,
            startMonth: 3,
          ),
        ],
        strategy: PrepaymentStrategy.reduceTenure,
      );

      final result = engine.calculate(input);

      expect(result.interestSaved, greaterThan(0));
    });

    test('combined prepayment rules are supported', () {
      final input = PrepaymentInput(
        baseCalculation: const EmiCalculation(
          loanAmount: 500000,
          interestRate: 10.5,
          tenureMonths: 60,
        ),
        rules: [
          PrepaymentRule(
            id: '1',
            amount: 5000,
            frequency: PrepaymentFrequency.monthly,
            startMonth: 1,
          ),
          PrepaymentRule(
            id: '2',
            amount: 50000,
            frequency: PrepaymentFrequency.yearly,
            startMonth: 12,
          ),
        ],
        strategy: PrepaymentStrategy.reduceTenure,
      );

      final result = engine.calculate(input);

      expect(result.updatedTenureMonths, lessThan(result.originalTenureMonths));
      expect(result.interestSaved, greaterThan(0));
    });

    test('large prepayment that would exceed balance is capped', () {
      final input = PrepaymentInput(
        baseCalculation: const EmiCalculation(
          loanAmount: 50000,
          interestRate: 10.5,
          tenureMonths: 12,
        ),
        rules: [
          PrepaymentRule(
            id: '1',
            amount: 100000,
            frequency: PrepaymentFrequency.oneTime,
            startMonth: 1,
          ),
        ],
        strategy: PrepaymentStrategy.reduceTenure,
      );

      final result = engine.calculate(input);

      expect(result.updatedSchedule.isNotEmpty, isTrue);
      expect(result.updatedSchedule.last.closingBalance, equals(0));
    });

    test('zero interest loan handles prepayments without error', () {
      final input = PrepaymentInput(
        baseCalculation: const EmiCalculation(
          loanAmount: 100000,
          interestRate: 0,
          tenureMonths: 12,
        ),
        rules: [
          PrepaymentRule(
            id: '1',
            amount: 5000,
            frequency: PrepaymentFrequency.monthly,
            startMonth: 1,
          ),
        ],
        strategy: PrepaymentStrategy.reduceTenure,
      );

      final result = engine.calculate(input);

      expect(result.updatedSchedule.isNotEmpty, isTrue);
      expect(result.updatedSchedule.last.closingBalance, equals(0));
    });

    test('no prepayment rules returns original schedule metrics', () {
      final input = PrepaymentInput(
        baseCalculation: const EmiCalculation(
          loanAmount: 500000,
          interestRate: 10.5,
          tenureMonths: 60,
        ),
        rules: const [],
        strategy: PrepaymentStrategy.reduceTenure,
      );

      final result = engine.calculate(input);

      expect(result.updatedTenureMonths, equals(result.originalTenureMonths));
      expect(result.updatedEmi, closeTo(result.originalEmi, 0.01));
      expect(result.interestSaved, equals(0));
      expect(result.monthsSaved, equals(0));
    });
  });
}
