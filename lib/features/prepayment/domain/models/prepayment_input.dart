import '../../../calculator/domain/models/emi_calculation.dart';
import 'prepayment_rule.dart';
import 'prepayment_strategy.dart';

/// Immutable model representing the inputs for a prepayment simulation.
class PrepaymentInput {
  /// Creates a [PrepaymentInput].
  const PrepaymentInput({
    required this.baseCalculation,
    required this.rules,
    required this.strategy,
  });

  /// The original loan calculation.
  final EmiCalculation baseCalculation;

  /// The list of prepayment rules to apply.
  final List<PrepaymentRule> rules;

  /// The prepayment strategy (reduce EMI or reduce tenure).
  final PrepaymentStrategy strategy;

  /// Creates a copy of this input with the given fields replaced.
  PrepaymentInput copyWith({
    EmiCalculation? baseCalculation,
    List<PrepaymentRule>? rules,
    PrepaymentStrategy? strategy,
  }) {
    return PrepaymentInput(
      baseCalculation: baseCalculation ?? this.baseCalculation,
      rules: rules ?? this.rules,
      strategy: strategy ?? this.strategy,
    );
  }

  /// Converts this input to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'baseCalculation': baseCalculation.toJson(),
      'rules': rules.map((r) => r.toJson()).toList(),
      'strategy': strategy.name,
    };
  }

  /// Creates a [PrepaymentInput] from a JSON map.
  factory PrepaymentInput.fromJson(Map<String, dynamic> json) {
    return PrepaymentInput(
      baseCalculation: EmiCalculation.fromJson(
        json['baseCalculation'] as Map<String, dynamic>,
      ),
      rules: (json['rules'] as List<dynamic>)
          .map((e) => PrepaymentRule.fromJson(e as Map<String, dynamic>))
          .toList(),
      strategy: PrepaymentStrategy.values.firstWhere(
        (e) => e.name == json['strategy'],
      ),
    );
  }
}
