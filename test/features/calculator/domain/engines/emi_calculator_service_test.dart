import 'package:flutter_test/flutter_test.dart';

import 'package:emi_calculator/features/calculator/domain/engines/emi_calculator_service.dart';
import 'package:emi_calculator/features/calculator/domain/models/emi_calculation.dart';

void main() {
  late EmiCalculatorService service;

  setUp(() {
    service = const EmiCalculatorService();
  });

  group('calculateEmi', () {
    test('standard loan produces correct EMI', () {
      const input = EmiCalculation(
        loanAmount: 500000,
        interestRate: 10.5,
        tenureMonths: 60,
      );
      final emi = service.calculateEmi(input);
      // Manual verification: P=500000, R=0.00875, N=60
      // EMI = 500000 * 0.00875 * (1.00875^60) / ((1.00875^60) - 1) ≈ 10,747
      expect(emi, greaterThan(10700));
      expect(emi, lessThan(10800));
    });

    test('zero interest rate divides principal evenly', () {
      const input = EmiCalculation(
        loanAmount: 1200000,
        interestRate: 0,
        tenureMonths: 12,
      );
      final emi = service.calculateEmi(input);
      expect(emi, 100000);
    });

    test('minimum tenure of 1 month returns full amount', () {
      const input = EmiCalculation(
        loanAmount: 100000,
        interestRate: 10,
        tenureMonths: 1,
      );
      final emi = service.calculateEmi(input);
      // One month at 10%: interest = 100000 * 0.00833 = 833.33
      // Total = 100000 + 833.33 ≈ 100833.33
      expect(emi, greaterThan(100800));
      expect(emi, lessThan(100900));
    });

    test('large principal (1 crore) computes correctly', () {
      const input = EmiCalculation(
        loanAmount: 10000000,
        interestRate: 8.5,
        tenureMonths: 240,
      );
      final emi = service.calculateEmi(input);
      expect(emi, greaterThan(86000));
      expect(emi, lessThan(87000));
    });

    test('down payment reduces principal', () {
      const input = EmiCalculation(
        loanAmount: 500000,
        interestRate: 10,
        tenureMonths: 12,
        downPayment: 100000,
      );
      final emi = service.calculateEmi(input);
      // Principal = 400000 after down payment
      final noDownPaymentEmi = service.calculateEmi(
        const EmiCalculation(
          loanAmount: 400000,
          interestRate: 10,
          tenureMonths: 12,
        ),
      );
      expect(emi, noDownPaymentEmi);
    });

    test('down payment equals loan amount returns zero EMI', () {
      const input = EmiCalculation(
        loanAmount: 500000,
        interestRate: 10,
        tenureMonths: 12,
        downPayment: 500000,
      );
      final emi = service.calculateEmi(input);
      expect(emi, 0.0);
    });
  });

  group('calculateTotalInterest', () {
    test('returns correct total interest for standard loan', () {
      const input = EmiCalculation(
        loanAmount: 500000,
        interestRate: 10.5,
        tenureMonths: 60,
      );
      final emi = service.calculateEmi(input);
      final totalInterest = service.calculateTotalInterest(input);
      expect(totalInterest, (emi * 60) - 500000);
    });

    test('zero interest returns zero', () {
      const input = EmiCalculation(
        loanAmount: 100000,
        interestRate: 0,
        tenureMonths: 12,
      );
      expect(service.calculateTotalInterest(input), 0.0);
    });
  });

  group('calculateTotalPayment', () {
    test('equals principal + interest', () {
      const input = EmiCalculation(
        loanAmount: 500000,
        interestRate: 10.5,
        tenureMonths: 60,
      );
      final totalPayment = service.calculateTotalPayment(input);
      final totalInterest = service.calculateTotalInterest(input);
      expect(totalPayment, 500000 + totalInterest);
    });
  });

  group('calculateEffectiveLoanAmount', () {
    test('no fees returns principal', () {
      const input = EmiCalculation(
        loanAmount: 500000,
        interestRate: 10,
        tenureMonths: 12,
      );
      expect(service.calculateEffectiveLoanAmount(input), 500000);
    });

    test('processing fee adds to effective amount', () {
      const input = EmiCalculation(
        loanAmount: 500000,
        interestRate: 10,
        tenureMonths: 12,
        processingFee: 2.0, // 2% = 10,000
      );
      expect(service.calculateEffectiveLoanAmount(input), 510000);
    });

    test('down payment subtracts from effective amount', () {
      const input = EmiCalculation(
        loanAmount: 500000,
        interestRate: 10,
        tenureMonths: 12,
        downPayment: 100000,
      );
      expect(service.calculateEffectiveLoanAmount(input), 400000);
    });

    test('insurance adds to effective amount', () {
      const input = EmiCalculation(
        loanAmount: 500000,
        interestRate: 10,
        tenureMonths: 12,
        insurance: 5000,
      );
      expect(service.calculateEffectiveLoanAmount(input), 505000);
    });
  });

  group('generateAmortizationSchedule', () {
    test('produces correct number of months', () {
      const input = EmiCalculation(
        loanAmount: 500000,
        interestRate: 10.5,
        tenureMonths: 12,
      );
      final schedule = service.generateAmortizationSchedule(input);
      expect(schedule.length, 12);
    });

    test('last month closing balance is zero', () {
      const input = EmiCalculation(
        loanAmount: 500000,
        interestRate: 10.5,
        tenureMonths: 12,
      );
      final schedule = service.generateAmortizationSchedule(input);
      final last = schedule.last;
      expect(last.closingBalance, lessThan(1));
    });

    test('total paid sums correctly', () {
      const input = EmiCalculation(
        loanAmount: 500000,
        interestRate: 10.5,
        tenureMonths: 12,
      );
      final schedule = service.generateAmortizationSchedule(input);
      final last = schedule.last;
      final totalPayment = service.calculateTotalPayment(input);
      expect(last.totalPaidSoFar, closeTo(totalPayment, 1));
    });

    test('zero interest schedule has equal principal each month', () {
      const input = EmiCalculation(
        loanAmount: 120000,
        interestRate: 0,
        tenureMonths: 12,
      );
      final schedule = service.generateAmortizationSchedule(input);
      for (final entry in schedule) {
        expect(entry.principalPaid, closeTo(10000, 0.01));
        expect(entry.interestPaid, 0);
      }
    });

    test('empty schedule for invalid input', () {
      const input = EmiCalculation(
        loanAmount: 0,
        interestRate: 10,
        tenureMonths: 12,
      );
      final schedule = service.generateAmortizationSchedule(input);
      expect(schedule.isEmpty, isTrue);
    });
  });

  group('calculateLoanHealthScore', () {
    test('ideal loan gets high score', () {
      const input = EmiCalculation(
        loanAmount: 500000,
        interestRate: 5,
        tenureMonths: 12,
        downPayment: 200000,
      );
      final score = service.calculateLoanHealthScore(
        input,
        monthlyIncome: 100000,
      );
      expect(score, greaterThanOrEqualTo(70));
      expect(score, lessThanOrEqualTo(100));
    });

    test('risky loan gets low score', () {
      const input = EmiCalculation(
        loanAmount: 500000,
        interestRate: 25,
        tenureMonths: 240,
        processingFee: 5,
        downPayment: 0,
      );
      final score = service.calculateLoanHealthScore(
        input,
        monthlyIncome: 20000,
      );
      expect(score, lessThan(40));
    });

    test('score is clamped to 0-100 range', () {
      const input = EmiCalculation(
        loanAmount: 1000,
        interestRate: 0,
        tenureMonths: 1,
        downPayment: 990,
      );
      final score = service.calculateLoanHealthScore(
        input,
        monthlyIncome: 1000000,
      );
      expect(score, inInclusiveRange(0, 100));
    });
  });

  group('calculateStressLevel', () {
    test('low stress when EMI is under 20% of income', () {
      const input = EmiCalculation(
        loanAmount: 100000,
        interestRate: 10,
        tenureMonths: 12,
      );
      const income = 50000.0;
      final result = service.calculateStressLevel(
        input,
        monthlyIncome: income,
      );
      expect(result.level, StressLevel.low);
    });

    test('moderate stress between 20-35%', () {
      const input = EmiCalculation(
        loanAmount: 500000,
        interestRate: 10,
        tenureMonths: 60,
      );
      const income = 35000.0;
      final result = service.calculateStressLevel(
        input,
        monthlyIncome: income,
      );
      expect(result.level, StressLevel.moderate);
    });

    test('high stress between 35-50%', () {
      const input = EmiCalculation(
        loanAmount: 500000,
        interestRate: 10,
        tenureMonths: 24,
      );
      const income = 50000.0;
      final result = service.calculateStressLevel(
        input,
        monthlyIncome: income,
      );
      expect(result.level, StressLevel.high);
    });

    test('critical stress above 50%', () {
      const input = EmiCalculation(
        loanAmount: 500000,
        interestRate: 10,
        tenureMonths: 12,
      );
      const income = 50000.0;
      final result = service.calculateStressLevel(
        input,
        monthlyIncome: income,
      );
      expect(result.level, StressLevel.critical);
    });

    test('unknown when income is zero', () {
      const input = EmiCalculation(
        loanAmount: 500000,
        interestRate: 10,
        tenureMonths: 12,
      );
      final result = service.calculateStressLevel(
        input,
        monthlyIncome: 0,
      );
      expect(result.level, StressLevel.unknown);
      expect(result.ratio, 0);
    });
  });

  group('Validation', () {
    test('negative loan amount throws', () {
      expect(
        () => service.calculateEmi(const EmiCalculation(
          loanAmount: -1000,
          interestRate: 10,
          tenureMonths: 12,
        )),
        throwsA(isA<CalculationException>()),
      );
    });

    test('negative interest rate throws', () {
      expect(
        () => service.calculateEmi(const EmiCalculation(
          loanAmount: 1000,
          interestRate: -5,
          tenureMonths: 12,
        )),
        throwsA(isA<CalculationException>()),
      );
    });

    test('zero tenure throws', () {
      expect(
        () => service.calculateEmi(const EmiCalculation(
          loanAmount: 1000,
          interestRate: 10,
          tenureMonths: 0,
        )),
        throwsA(isA<CalculationException>()),
      );
    });

    test('tenure above 360 throws', () {
      expect(
        () => service.calculateEmi(const EmiCalculation(
          loanAmount: 1000,
          interestRate: 10,
          tenureMonths: 361,
        )),
        throwsA(isA<CalculationException>()),
      );
    });

    test('down payment above loan amount throws', () {
      expect(
        () => service.calculateEmi(const EmiCalculation(
          loanAmount: 1000,
          interestRate: 10,
          tenureMonths: 12,
          downPayment: 2000,
        )),
        throwsA(isA<CalculationException>()),
      );
    });
  });
}
