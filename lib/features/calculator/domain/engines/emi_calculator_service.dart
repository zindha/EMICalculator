import 'dart:math';

import '../models/amortization_month.dart';
import '../models/emi_calculation.dart';

/// Pure Dart service that performs all EMI-related mathematical calculations.
///
/// This service contains **no Flutter imports** and **no UI logic** — it is
/// a pure domain service that can be unit-tested independently.
///
/// ## Formulas Used
///
/// **EMI Formula (Standard):**
/// ```
/// EMI = P × R × (1 + R)^N / [(1 + R)^N - 1]
/// ```
/// Where:
/// - P = Loan principal (after down payment)
/// - R = Monthly interest rate (annual rate / 12 / 100)
/// - N = Loan tenure in months
///
/// **Total Interest:** (EMI × N) - P
/// **Total Payment:** EMI × N
class EmiCalculatorService {
  /// Creates an [EmiCalculatorService].
  const EmiCalculatorService();

  // ──────────────────────────────────────────────
  // Public API
  // ──────────────────────────────────────────────

  /// Computes the monthly EMI amount for the given [calculation].
  ///
  /// Returns the EMI amount in the same currency unit as the input.
  ///
  /// Throws a [CalculationException] if the input is invalid.
  double calculateEmi(EmiCalculation calculation) {
    _validateInput(calculation);

    final principal = calculation.loanAmount - calculation.downPayment;
    if (principal <= 0) return 0.0;
    if (calculation.interestRate == 0) {
      // Zero interest: EMI = principal / tenure.
      return principal / calculation.tenureMonths;
    }

    final monthlyRate = _getMonthlyRate(calculation.interestRate);
    final tenure = calculation.tenureMonths;

    // Standard EMI formula: P × R × (1+R)^N / [(1+R)^N - 1]
    final compoundFactor = pow(1 + monthlyRate, tenure);
    final emi = principal * monthlyRate * compoundFactor / (compoundFactor - 1);

    return emi;
  }

  /// Computes the total interest payable over the full loan tenure.
  double calculateTotalInterest(EmiCalculation calculation) {
    final emi = calculateEmi(calculation);
    final principal = calculation.loanAmount - calculation.downPayment;
    return (emi * calculation.tenureMonths) - principal;
  }

  /// Computes the total payment (principal + interest) over the full tenure.
  double calculateTotalPayment(EmiCalculation calculation) {
    final emi = calculateEmi(calculation);
    return emi * calculation.tenureMonths;
  }

  /// Computes the effective loan amount after deducting [downPayment] and
  /// adding [processingFee] and [insurance].
  double calculateEffectiveLoanAmount(EmiCalculation calculation) {
    final principal = calculation.loanAmount - calculation.downPayment;
    final feeAmount = calculation.loanAmount * (calculation.processingFee / 100);
    return principal + feeAmount + calculation.insurance;
  }

  /// Generates the complete amortization schedule for the given [calculation].
  ///
  /// Returns a list of [AmortizationMonth] entries, one for each month of
  /// the loan tenure. The list is empty if the input is invalid.
  ///
  /// Each entry includes the opening balance, principal paid, interest paid,
  /// closing balance, and cumulative total paid.
  List<AmortizationMonth> generateAmortizationSchedule(
    EmiCalculation calculation,
  ) {
    _validateInput(calculation);

    final monthlyEmi = calculateEmi(calculation);
    final monthlyRate = _getMonthlyRate(calculation.interestRate);
    final tenure = calculation.tenureMonths;
    final schedule = <AmortizationMonth>[];
    final principal = calculation.loanAmount - calculation.downPayment;

    if (principal <= 0 || tenure <= 0) return schedule;

    double openingBalance = principal;
    double totalPaidSoFar = 0;

    for (int month = 1; month <= tenure; month++) {
      // Interest for this month = opening balance × monthly rate.
      final interestPaid = openingBalance * monthlyRate;

      // Principal paid = EMI - interest (or the remaining balance if it's the last month).
      double principalPaid;
      if (month == tenure) {
        // On the last month, pay off the exact remaining balance.
        principalPaid = openingBalance;
      } else {
        principalPaid = monthlyEmi - interestPaid;
      }

      // Ensure we don't overpay on the last month due to floating point.
      if (principalPaid > openingBalance) {
        principalPaid = openingBalance;
      }

      final closingBalance = openingBalance - principalPaid;
      totalPaidSoFar += principalPaid + interestPaid;

      schedule.add(AmortizationMonth(
        monthNumber: month,
        openingBalance: openingBalance,
        emiAmount: principalPaid + interestPaid,
        principalPaid: principalPaid,
        interestPaid: interestPaid,
        closingBalance: closingBalance,
        totalPaidSoFar: totalPaidSoFar,
      ));

      openingBalance = closingBalance;
    }

    return schedule;
  }

  /// Computes the Loan Health Score (0–100) for the given [calculation].
  ///
  /// The score is based on:
  /// - Interest rate (lower = better): 35 points max
  /// - EMI-to-income ratio (<30% = healthy): 25 points max
  /// - Loan tenure (shorter = better): 20 points max
  /// - Fees (lower = better): 10 points max
  /// - Down payment (higher = better): 10 points max
  ///
  /// Returns a score from 0 (worst) to 100 (best).
  int calculateLoanHealthScore(
    EmiCalculation calculation, {
    double monthlyIncome = 0,
  }) {
    int score = 0;

    // 1. Interest Rate Score (35 points)
    final rateScore = _calculateRateScore(calculation.interestRate);
    score += rateScore;

    // 2. EMI-to-Income Score (25 points)
    if (monthlyIncome > 0) {
      final emi = calculateEmi(calculation);
      final incomeRatio = emi / monthlyIncome;
      score += _calculateIncomeRatioScore(incomeRatio);
    } else {
      // Default to moderate if income is not provided.
      score += 15;
    }

    // 3. Tenure Score (20 points)
    score += _calculateTenureScore(calculation.tenureMonths);

    // 4. Processing Fee Score (10 points)
    score += _calculateFeeScore(calculation.processingFee);

    // 5. Down Payment Score (10 points)
    score += _calculateDownPaymentScore(
      calculation.downPayment,
      calculation.loanAmount,
    );

    return score.clamp(0, 100);
  }

  /// Determines the EMI stress level for the given [calculation] and
  /// [monthlyIncome].
  ///
  /// Returns a [StressLevel] enum value and the ratio as a percentage.
  ({StressLevel level, double ratio}) calculateStressLevel(
    EmiCalculation calculation, {
    required double monthlyIncome,
  }) {
    if (monthlyIncome <= 0) {
      return (level: StressLevel.unknown, ratio: 0);
    }

    final emi = calculateEmi(calculation);
    final ratio = emi / monthlyIncome;

    if (ratio <= 0.20) {
      return (level: StressLevel.low, ratio: ratio);
    } else if (ratio <= 0.35) {
      return (level: StressLevel.moderate, ratio: ratio);
    } else if (ratio <= 0.50) {
      return (level: StressLevel.high, ratio: ratio);
    } else {
      return (level: StressLevel.critical, ratio: ratio);
    }
  }

  // ──────────────────────────────────────────────
  // Private Helpers
  // ──────────────────────────────────────────────

  /// Validates the [calculation] input, throwing a [CalculationException]
  /// if any value is invalid.
  void _validateInput(EmiCalculation calculation) {
    if (calculation.loanAmount < 0) {
      throw const CalculationException('Loan amount cannot be negative.');
    }
    if (calculation.interestRate < 0) {
      throw const CalculationException('Interest rate cannot be negative.');
    }
    if (calculation.tenureMonths <= 0) {
      throw const CalculationException('Tenure must be greater than 0 months.');
    }
    if (calculation.tenureMonths > 360) {
      throw const CalculationException('Tenure cannot exceed 360 months (30 years).');
    }
    if (calculation.processingFee < 0) {
      throw const CalculationException('Processing fee cannot be negative.');
    }
    if (calculation.downPayment < 0) {
      throw const CalculationException('Down payment cannot be negative.');
    }
    if (calculation.downPayment > calculation.loanAmount) {
      throw const CalculationException('Down payment cannot exceed loan amount.');
    }
  }

  /// Converts the annual interest rate to a monthly decimal rate.
  double _getMonthlyRate(double annualRate) {
    return annualRate / 12 / 100;
  }

  /// Computes the interest rate score component (0–35 points).
  int _calculateRateScore(double rate) {
    if (rate <= 0) return 35;
    if (rate <= 5) return 30;
    if (rate <= 8) return 25;
    if (rate <= 10) return 20;
    if (rate <= 12) return 15;
    if (rate <= 15) return 10;
    if (rate <= 20) return 5;
    return 0;
  }

  /// Computes the EMI-to-income ratio score component (0–25 points).
  int _calculateIncomeRatioScore(double ratio) {
    if (ratio <= 0.10) return 25;
    if (ratio <= 0.20) return 20;
    if (ratio <= 0.30) return 15;
    if (ratio <= 0.35) return 10;
    if (ratio <= 0.40) return 5;
    return 0;
  }

  /// Computes the tenure score component (0–20 points).
  int _calculateTenureScore(int months) {
    if (months <= 12) return 20;
    if (months <= 24) return 18;
    if (months <= 36) return 15;
    if (months <= 60) return 12;
    if (months <= 120) return 8;
    if (months <= 180) return 5;
    if (months <= 240) return 2;
    return 0;
  }

  /// Computes the processing fee score component (0–10 points).
  int _calculateFeeScore(double feePercent) {
    if (feePercent <= 0) return 10;
    if (feePercent <= 0.5) return 8;
    if (feePercent <= 1.0) return 6;
    if (feePercent <= 2.0) return 4;
    if (feePercent <= 3.0) return 2;
    return 0;
  }

  /// Computes the down payment score component (0–10 points).
  int _calculateDownPaymentScore(double downPayment, double loanAmount) {
    if (loanAmount <= 0) return 0;
    final ratio = downPayment / loanAmount;
    if (ratio >= 0.40) return 10;
    if (ratio >= 0.30) return 8;
    if (ratio >= 0.20) return 6;
    if (ratio >= 0.10) return 4;
    if (ratio > 0) return 2;
    return 0;
  }
}

/// Exception thrown when an EMI calculation input is invalid.
class CalculationException implements Exception {
  /// Creates a [CalculationException] with the given [message].
  const CalculationException(this.message);

  /// Description of what went wrong.
  final String message;

  @override
  String toString() => 'CalculationException: $message';
}

/// Represents the level of financial stress an EMI imposes on the borrower.
enum StressLevel {
  /// Low stress — EMI is ≤20% of monthly income.
  low,

  /// Moderate stress — EMI is between 20% and 35% of monthly income.
  moderate,

  /// High stress — EMI is between 35% and 50% of monthly income.
  high,

  /// Critical stress — EMI exceeds 50% of monthly income.
  critical,

  /// Unknown — monthly income was not provided.
  unknown,
}
