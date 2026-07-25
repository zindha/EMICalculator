import 'dart:math';

import '../../../calculator/domain/engines/emi_calculator_service.dart';
import '../../../calculator/domain/models/amortization_month.dart';
import '../models/prepayment_frequency.dart';
import '../models/prepayment_input.dart';
import '../models/prepayment_result.dart';
import '../models/prepayment_rule.dart';
import '../models/prepayment_strategy.dart';

/// Pure Dart service that simulates the effect of prepayments on a loan.
///
/// Supports one-time, periodic (monthly/quarterly/half-yearly/yearly),
/// custom, and combined prepayment schedules. Supports both strategy modes:
/// reduce tenure (keep EMI, shorten duration) and reduce EMI (keep tenure,
/// lower EMI).
class PrepaymentEngineService {
  /// Creates a [PrepaymentEngineService].
  const PrepaymentEngineService();

  static const _calculator = EmiCalculatorService();

  /// Simulates prepayments based on [input] and returns a [PrepaymentResult].
  PrepaymentResult calculate(PrepaymentInput input) {
    final base = input.baseCalculation;
    final principal = base.loanAmount - base.downPayment;
    final monthlyRate = base.interestRate / 12 / 100;
    final originalEmi = _calculator.calculateEmi(base);
    final originalTotalInterest = _calculator.calculateTotalInterest(base);
    final originalTotalPayment = _calculator.calculateTotalPayment(base);

    final prepaymentMap = _buildPrepaymentMap(input.rules, base.tenureMonths);

    final perRuleInsights = _generatePerRuleRecommendations(
      input,
      principal,
      monthlyRate,
      originalEmi,
      originalTotalInterest,
    );

    final updatedSchedule = input.strategy == PrepaymentStrategy.reduceTenure
        ? _simulateReduceTenure(
            principal,
            monthlyRate,
            originalEmi,
            prepaymentMap,
          )
        : _simulateReduceEmi(
            principal,
            monthlyRate,
            base.tenureMonths,
            prepaymentMap,
          );

    final updatedTotalInterest = updatedSchedule.fold<double>(
      0,
      (sum, entry) => sum + entry.interestPaid,
    );

    // Total payment is the exact amount paid over the updated schedule,
    // including principal, interest, and any extra prepayments.
    final updatedTotalPayment = updatedSchedule.isNotEmpty
        ? updatedSchedule.last.totalPaidSoFar
        : 0.0;

    final updatedEmi = _extractUpdatedEmi(updatedSchedule, originalEmi);
    final updatedTenureMonths = updatedSchedule.length;
    final monthsSaved = base.tenureMonths - updatedTenureMonths;
    final interestSaved = originalTotalInterest - updatedTotalInterest;
    final moneySaved = originalTotalPayment - updatedTotalPayment;
    final totalExtraPayments = updatedTotalPayment -
        (updatedSchedule.fold<double>(0, (sum, e) => sum + e.emiAmount));

    return PrepaymentResult(
      originalEmi: originalEmi,
      originalTenureMonths: base.tenureMonths,
      originalTotalInterest: originalTotalInterest,
      originalTotalPayment: originalTotalPayment,
      updatedSchedule: updatedSchedule,
      updatedEmi: updatedEmi,
      updatedTenureMonths: updatedTenureMonths,
      updatedTotalInterest: updatedTotalInterest,
      updatedTotalPayment: updatedTotalPayment,
      totalExtraPayments: totalExtraPayments,
      interestSaved: interestSaved,
      moneySaved: moneySaved,
      monthsSaved: monthsSaved,
      completionDate: _calculateCompletionDate(updatedTenureMonths),
      insights: [
        ...perRuleInsights,
        ..._generateInsights(
          input,
          interestSaved,
          monthsSaved,
          totalExtraPayments,
        ),
      ],
    );
  }

  /// Builds a map from month number to total extra prepayment amount.
  Map<int, double> _buildPrepaymentMap(
    List<PrepaymentRule> rules,
    int tenureMonths,
  ) {
    final map = <int, double>{};

    for (final rule in rules) {
      if (rule.amount <= 0) continue;

      final months = _resolveMonths(rule, tenureMonths);
      for (final month in months) {
        if (month < 1 || month > tenureMonths) continue;
        map[month] = (map[month] ?? 0) + rule.amount;
      }
    }

    return map;
  }

  /// Resolves the months on which a rule applies.
  List<int> _resolveMonths(PrepaymentRule rule, int tenureMonths) {
    switch (rule.frequency) {
      case PrepaymentFrequency.oneTime:
        return [rule.startMonth];
      case PrepaymentFrequency.monthly:
        return List.generate(
          max(0, tenureMonths - rule.startMonth + 1),
          (i) => rule.startMonth + i,
        );
      case PrepaymentFrequency.quarterly:
        return _generatePeriodicMonths(rule.startMonth, tenureMonths, 3);
      case PrepaymentFrequency.halfYearly:
        return _generatePeriodicMonths(rule.startMonth, tenureMonths, 6);
      case PrepaymentFrequency.yearly:
        return _generatePeriodicMonths(rule.startMonth, tenureMonths, 12);
      case PrepaymentFrequency.custom:
        return rule.customMonths ?? [];
    }
  }

  List<int> _generatePeriodicMonths(int start, int tenureMonths, int interval) {
    final months = <int>[];
    var month = start;
    while (month <= tenureMonths) {
      months.add(month);
      month += interval;
    }
    return months;
  }

  /// Simulates prepayments by keeping EMI constant and reducing tenure.
  List<AmortizationMonth> _simulateReduceTenure(
    double principal,
    double monthlyRate,
    double emi,
    Map<int, double> prepaymentMap,
  ) {
    final schedule = <AmortizationMonth>[];
    double openingBalance = principal;
    double totalPaidSoFar = 0;
    int monthNumber = 1;

    while (openingBalance > 0.001) {
      final interestPaid = openingBalance * monthlyRate;
      double principalPaid = emi - interestPaid;
      final requestedExtraPayment = prepaymentMap[monthNumber] ?? 0;

      // Ensure principal paid does not exceed the opening balance.
      if (principalPaid > openingBalance) {
        principalPaid = openingBalance;
      }

      // Cap extra payment so the loan is never overpaid.
      final maxExtraPayment = max(0, openingBalance - principalPaid);
      final extraPayment = requestedExtraPayment > maxExtraPayment
          ? maxExtraPayment
          : requestedExtraPayment;

      // Apply extra payment to principal.
      double newBalance = openingBalance - principalPaid - extraPayment;
      if (newBalance < 0) {
        newBalance = 0;
      }

      final totalPaidThisMonth = principalPaid + interestPaid + extraPayment;
      totalPaidSoFar += totalPaidThisMonth;

      schedule.add(AmortizationMonth(
        monthNumber: monthNumber,
        openingBalance: openingBalance,
        emiAmount: principalPaid + interestPaid,
        principalPaid: principalPaid,
        interestPaid: interestPaid,
        closingBalance: newBalance,
        totalPaidSoFar: totalPaidSoFar,
      ));

      openingBalance = newBalance;
      monthNumber++;

      if (monthNumber > 3600) break; // Safety valve.
    }

    return schedule;
  }

  /// Simulates prepayments by keeping tenure constant and reducing EMI.
  List<AmortizationMonth> _simulateReduceEmi(
    double principal,
    double monthlyRate,
    int tenureMonths,
    Map<int, double> prepaymentMap,
  ) {
    final schedule = <AmortizationMonth>[];
    double openingBalance = principal;
    double totalPaidSoFar = 0;

    for (int monthNumber = 1; monthNumber <= tenureMonths; monthNumber++) {
      final remainingMonths = tenureMonths - monthNumber + 1;
      final requestedExtraPayment = prepaymentMap[monthNumber] ?? 0;

      // Cap extra payment so the loan is never overpaid.
      final extraPayment = requestedExtraPayment > openingBalance
          ? openingBalance
          : requestedExtraPayment;

      // Apply extra payment to principal before calculating EMI for this month.
      openingBalance -= extraPayment;
      if (openingBalance < 0) openingBalance = 0;

      // Recalculate EMI based on remaining principal and months.
      double emi;
      if (monthlyRate <= 0) {
        emi = remainingMonths > 0 ? openingBalance / remainingMonths : 0;
      } else if (remainingMonths <= 0) {
        emi = openingBalance;
      } else {
        final compoundFactor = pow(1 + monthlyRate, remainingMonths);
        emi = openingBalance *
            monthlyRate *
            compoundFactor /
            (compoundFactor - 1);
      }

      final interestPaid = openingBalance * monthlyRate;
      double principalPaid = emi - interestPaid;
      if (principalPaid > openingBalance) {
        principalPaid = openingBalance;
      }

      final totalPaidThisMonth = principalPaid + interestPaid + extraPayment;
      totalPaidSoFar += totalPaidThisMonth;

      schedule.add(AmortizationMonth(
        monthNumber: monthNumber,
        openingBalance: openingBalance,
        emiAmount: principalPaid + interestPaid,
        principalPaid: principalPaid,
        interestPaid: interestPaid,
        closingBalance: max(0, openingBalance - principalPaid),
        totalPaidSoFar: totalPaidSoFar,
      ));

      openingBalance = max(0, openingBalance - principalPaid);

      if (openingBalance <= 0.001) break;
    }

    return schedule;
  }

  double _extractUpdatedEmi(
    List<AmortizationMonth> schedule,
    double originalEmi,
  ) {
    if (schedule.isEmpty) return originalEmi;
    // For reduce tenure, EMI stays the same; for reduce EMI, take the first
    // non-zero EMI from the updated schedule.
    for (final entry in schedule) {
      if (entry.emiAmount > 0) return entry.emiAmount;
    }
    return originalEmi;
  }

  DateTime _calculateCompletionDate(int tenureMonths) {
    return DateTime.now().add(Duration(days: tenureMonths * 30));
  }

  List<String> _generateInsights(
    PrepaymentInput input,
    double interestSaved,
    int monthsSaved,
    double totalExtraPayments,
  ) {
    final insights = <String>[];
    final base = input.baseCalculation;

    if (interestSaved > 0) {
      insights.add(
        'You will save ₹${_formatCompact(interestSaved)} in interest with this prepayment plan.',
      );
    }

    if (monthsSaved > 0) {
      insights.add(
        'Your loan will be paid off $monthsSaved months earlier than scheduled.',
      );
    }

    if (totalExtraPayments > 0) {
      insights.add(
        'Total extra payments: ₹${_formatCompact(totalExtraPayments)}.',
      );
    }

    if (input.strategy == PrepaymentStrategy.reduceEmi) {
      insights.add(
        'Choosing "Reduce EMI" keeps your tenure the same while lowering your monthly burden.',
      );
    } else {
      insights.add(
        'Choosing "Reduce Tenure" keeps your EMI the same and clears the loan faster.',
      );
    }

    final prepaymentsInFirstFiveYears = input.rules.any((rule) {
      if (rule.frequency == PrepaymentFrequency.custom) {
        return rule.customMonths?.any((m) => m <= 60) ?? false;
      }
      return rule.startMonth <= 60;
    });
    if (base.interestRate > 0 &&
        base.tenureMonths > 60 &&
        prepaymentsInFirstFiveYears) {
      insights.add(
        'Prepaying before year 5 maximizes savings because interest is front-loaded.',
      );
    }

    return insights;
  }

  /// Generates a recommendation for each prepayment rule, showing how much
  /// interest that specific rule saves on its own.
  List<String> _generatePerRuleRecommendations(
    PrepaymentInput input,
    double principal,
    double monthlyRate,
    double originalEmi,
    double originalTotalInterest,
  ) {
    final insights = <String>[];

    for (final rule in input.rules) {
      if (rule.amount <= 0) continue;

      final singleRuleMap = _buildPrepaymentMap([rule], input.baseCalculation.tenureMonths);

      final schedule = input.strategy == PrepaymentStrategy.reduceTenure
          ? _simulateReduceTenure(
              principal,
              monthlyRate,
              originalEmi,
              singleRuleMap,
            )
          : _simulateReduceEmi(
              principal,
              monthlyRate,
              input.baseCalculation.tenureMonths,
              singleRuleMap,
            );

      final interestAfter = schedule.fold<double>(
        0,
        (sum, entry) => sum + entry.interestPaid,
      );
      final saved = originalTotalInterest - interestAfter;

      if (saved <= 0) continue;

      final frequencyLabel = _recommendationFrequencyLabel(rule.frequency);
      insights.add(
        'Paying ₹${_formatCompact(rule.amount)} extra $frequencyLabel saves ₹${_formatCompact(saved)} in interest.',
      );
    }

    return insights;
  }

  String _recommendationFrequencyLabel(PrepaymentFrequency frequency) {
    switch (frequency) {
      case PrepaymentFrequency.oneTime:
        return 'as a one-time prepayment';
      case PrepaymentFrequency.monthly:
        return 'every month';
      case PrepaymentFrequency.quarterly:
        return 'every quarter';
      case PrepaymentFrequency.halfYearly:
        return 'every six months';
      case PrepaymentFrequency.yearly:
        return 'every year';
      case PrepaymentFrequency.custom:
        return 'on the custom schedule';
    }
  }

  String _formatCompact(double value) {
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(1)} Cr';
    } else if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)} L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)} K';
    }
    return value.toStringAsFixed(0);
  }
}
