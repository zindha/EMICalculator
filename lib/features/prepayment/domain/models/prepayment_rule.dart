import 'prepayment_frequency.dart';

/// Immutable model representing a prepayment rule.
///
/// A rule defines an extra payment amount, its frequency, and when it starts.
/// For custom schedules, [customMonths] holds the explicit 1-based month
/// numbers on which the payment occurs.
class PrepaymentRule {
  /// Creates a [PrepaymentRule].
  const PrepaymentRule({
    required this.id,
    required this.amount,
    required this.frequency,
    required this.startMonth,
    this.name,
    this.customMonths,
  });

  /// Unique identifier for this rule.
  final String id;

  /// The extra payment amount.
  final double amount;

  /// How often the prepayment occurs.
  final PrepaymentFrequency frequency;

  /// The first month (1-based) from which this rule applies.
  final int startMonth;

  /// Optional display name for the rule.
  final String? name;

  /// For [PrepaymentFrequency.custom], the explicit months (1-based) on which
  /// the payment occurs.
  final List<int>? customMonths;

  /// Creates a copy of this rule with the given fields replaced.
  PrepaymentRule copyWith({
    String? id,
    double? amount,
    PrepaymentFrequency? frequency,
    int? startMonth,
    String? name,
    List<int>? customMonths,
  }) {
    return PrepaymentRule(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      startMonth: startMonth ?? this.startMonth,
      name: name ?? this.name,
      customMonths: customMonths ?? this.customMonths,
    );
  }

  /// Converts this rule to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'frequency': frequency.name,
      'startMonth': startMonth,
      'name': name,
      'customMonths': customMonths,
    };
  }

  /// Creates a [PrepaymentRule] from a JSON map.
  factory PrepaymentRule.fromJson(Map<String, dynamic> json) {
    return PrepaymentRule(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      frequency: PrepaymentFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
      ),
      startMonth: json['startMonth'] as int,
      name: json['name'] as String?,
      customMonths: (json['customMonths'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
    );
  }
}
