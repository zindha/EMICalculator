import 'package:emi_calculator/features/calculator/domain/models/emi_calculation.dart';
import 'package:emi_calculator/features/comparison/domain/engines/comparison_engine_service.dart';
import 'package:emi_calculator/features/comparison/domain/models/loan_offer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ComparisonEngineService', () {
    const service = ComparisonEngineService();

    LoanOffer _createOffer({
      required String id,
      required String name,
      required double loanAmount,
      required double interestRate,
      required int tenureMonths,
      double processingFee = 0,
      double insurance = 0,
      double downPayment = 0,
    }) {
      return LoanOffer(
        id: id,
        name: name,
        calculation: EmiCalculation(
          loanAmount: loanAmount,
          interestRate: interestRate,
          tenureMonths: tenureMonths,
          processingFee: processingFee,
          insurance: insurance,
          downPayment: downPayment,
        ),
      );
    }

    test('analyzes two loans and identifies lowest EMI', () {
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

      final result = service.analyze(offers);

      expect(result.offers.length, 2);
      expect(result.lowestEmiOfferId, 'b');
      expect(result.lowestInterestOfferId, 'b');
      expect(result.bestOverallOfferId, 'b');
    });

    test('identifies shortest tenure independently', () {
      final offers = [
        _createOffer(
          id: 'a',
          name: 'Loan A',
          loanAmount: 500000,
          interestRate: 10.5,
          tenureMonths: 48,
        ),
        _createOffer(
          id: 'b',
          name: 'Loan B',
          loanAmount: 500000,
          interestRate: 10.5,
          tenureMonths: 60,
        ),
      ];

      final result = service.analyze(offers);

      expect(result.shortestTenureOfferId, 'a');
    });

    test('handles four loans with mixed characteristics', () {
      final offers = [
        _createOffer(
          id: 'a',
          name: 'Loan A',
          loanAmount: 1000000,
          interestRate: 11,
          tenureMonths: 120,
        ),
        _createOffer(
          id: 'b',
          name: 'Loan B',
          loanAmount: 1000000,
          interestRate: 10,
          tenureMonths: 120,
        ),
        _createOffer(
          id: 'c',
          name: 'Loan C',
          loanAmount: 1000000,
          interestRate: 10.5,
          tenureMonths: 96,
        ),
        _createOffer(
          id: 'd',
          name: 'Loan D',
          loanAmount: 1000000,
          interestRate: 9.5,
          tenureMonths: 120,
        ),
      ];

      final result = service.analyze(offers);

      expect(result.offers.length, 4);
      expect(result.lowestEmiOfferId, isNotNull);
      expect(result.lowestInterestOfferId, isNotNull);
      expect(result.shortestTenureOfferId, isNotNull);
      expect(result.lowestTotalPaymentOfferId, isNotNull);
      expect(result.bestOverallOfferId, isNotNull);
    });

    test('returns empty result for invalid offers', () {
      final offers = <LoanOffer>[];
      final result = service.analyze(offers);
      expect(result.offers, isEmpty);
    });
  });
}
