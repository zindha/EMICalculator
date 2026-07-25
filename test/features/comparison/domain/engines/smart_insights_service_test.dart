import 'package:emi_calculator/features/calculator/domain/models/emi_calculation.dart';
import 'package:emi_calculator/features/comparison/domain/engines/comparison_engine_service.dart';
import 'package:emi_calculator/features/comparison/domain/engines/smart_insights_service.dart';
import 'package:emi_calculator/features/comparison/domain/models/loan_offer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartInsightsService', () {
    const engine = ComparisonEngineService();
    const service = SmartInsightsService();

    LoanOffer _createOffer({
      required String id,
      required String name,
      required double loanAmount,
      required double interestRate,
      required int tenureMonths,
    }) {
      return LoanOffer(
        id: id,
        name: name,
        calculation: EmiCalculation(
          loanAmount: loanAmount,
          interestRate: interestRate,
          tenureMonths: tenureMonths,
        ),
      );
    }

    test('generates insights comparing two loans', () {
      final offers = [
        _createOffer(
          id: 'a',
          name: 'Loan A',
          loanAmount: 500000,
          interestRate: 10.5,
          tenureMonths: 60,
        ),
        _createOffer(
          id: 'b',
          name: 'Loan B',
          loanAmount: 500000,
          interestRate: 9.5,
          tenureMonths: 60,
        ),
      ];

      final result = engine.analyze(offers);
      final insights = service.generateInsights(
        result,
        formatCurrency: (amount) => '₹${amount.toStringAsFixed(0)}',
      );

      expect(insights, isNotEmpty);
      expect(
        insights.any((i) => i.contains('lowest EMI')),
        isTrue,
        reason: 'Should mention lowest EMI',
      );
      expect(
        insights.any((i) => i.contains('saves')),
        isTrue,
        reason: 'Should mention savings',
      );
    });

    test('includes what-if down payment recommendation', () {
      final offers = [
        _createOffer(
          id: 'a',
          name: 'Loan A',
          loanAmount: 500000,
          interestRate: 10.5,
          tenureMonths: 60,
        ),
        _createOffer(
          id: 'b',
          name: 'Loan B',
          loanAmount: 500000,
          interestRate: 11.5,
          tenureMonths: 60,
        ),
      ];

      final result = engine.analyze(offers);
      final insights = service.generateInsights(
        result,
        formatCurrency: (amount) => '₹${amount.toStringAsFixed(0)}',
      );

      expect(
        insights.any((i) => i.contains('down payment')),
        isTrue,
        reason: 'Should recommend increasing down payment',
      );
    });
  });
}
