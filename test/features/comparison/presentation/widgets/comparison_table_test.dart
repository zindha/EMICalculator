import 'package:emi_calculator/features/calculator/domain/models/emi_calculation.dart';
import 'package:emi_calculator/features/comparison/domain/engines/comparison_engine_service.dart';
import 'package:emi_calculator/features/comparison/domain/models/comparison_result.dart';
import 'package:emi_calculator/features/comparison/domain/models/loan_offer.dart';
import 'package:emi_calculator/features/comparison/presentation/widgets/comparison_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide ComparisonResult;

void main() {
  group('ComparisonTable', () {
    final offers = [
      const LoanOffer(
        id: 'a',
        name: 'Loan A',
        calculation: EmiCalculation(
          loanAmount: 500000,
          interestRate: 10.5,
          tenureMonths: 60,
        ),
      ),
      const LoanOffer(
        id: 'b',
        name: 'Loan B',
        calculation: EmiCalculation(
          loanAmount: 500000,
          interestRate: 9.5,
          tenureMonths: 60,
        ),
      ),
    ];

    late ComparisonResult result;

    setUp(() {
      const engine = ComparisonEngineService();
      result = engine.analyze(offers);
    });

    testWidgets('renders loan names and highlights lowest EMI',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ComparisonTable(result: result, offers: offers),
            ),
          ),
        ),
      );

      expect(find.text('Loan A'), findsOneWidget);
      expect(find.text('Loan B'), findsOneWidget);
      expect(find.text('Loan Name'), findsOneWidget);
      expect(find.text('EMI'), findsOneWidget);
    });
  });
}
