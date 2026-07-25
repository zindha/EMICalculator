import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/hive_constants.dart';
import '../../../../core/services/hive_service.dart';
import '../../../calculator/domain/models/emi_calculation.dart';
import '../../data/repositories/prepayment_repository.dart';
import '../../domain/engines/prepayment_engine_service.dart';
import '../../domain/engines/prepayment_export_service.dart';
import '../../domain/models/prepayment_input.dart';
import '../../domain/models/prepayment_result.dart';
import '../../domain/models/prepayment_rule.dart';
import '../../domain/models/prepayment_strategy.dart';

/// Provider for the [PrepaymentRepository].
final prepaymentRepositoryProvider = Provider<PrepaymentRepository>((ref) {
  final box = HiveService.getBox<String>(HiveConstants.prepaymentBox);
  return PrepaymentRepository(box: box);
});

/// Provider for the [PrepaymentEngineService].
final prepaymentEngineServiceProvider = Provider<PrepaymentEngineService>(
  (ref) => const PrepaymentEngineService(),
);

/// Provider for the [PrepaymentExportService].
final prepaymentExportServiceProvider = Provider<PrepaymentExportService>(
  (ref) => const PrepaymentExportService(),
);

/// Notifier that manages the current prepayment input.
class PrepaymentInputNotifier extends StateNotifier<PrepaymentInput> {
  /// Creates a [PrepaymentInputNotifier].
  PrepaymentInputNotifier() : super(_defaultInput());

  static PrepaymentInput _defaultInput() {
    return PrepaymentInput(
      baseCalculation: const EmiCalculation(
        loanAmount: 500000,
        interestRate: 10.5,
        tenureMonths: 60,
      ),
      rules: [],
      strategy: PrepaymentStrategy.reduceTenure,
    );
  }

  /// Resets the input to the default state.
  void reset() {
    state = _defaultInput();
  }

  /// Replaces the entire input.
  void setInput(PrepaymentInput input) {
    state = input;
  }

  /// Updates the base loan calculation.
  void setBaseCalculation(EmiCalculation calculation) {
    state = state.copyWith(baseCalculation: calculation);
  }

  /// Adds a prepayment rule.
  void addRule(PrepaymentRule rule) {
    state = state.copyWith(rules: [...state.rules, rule]);
  }

  /// Removes the rule at [index].
  void removeRule(int index) {
    if (index < 0 || index >= state.rules.length) return;
    final updated = List<PrepaymentRule>.from(state.rules)..removeAt(index);
    state = state.copyWith(rules: updated);
  }

  /// Updates the rule at [index].
  void updateRule(int index, PrepaymentRule rule) {
    if (index < 0 || index >= state.rules.length) return;
    final updated = List<PrepaymentRule>.from(state.rules);
    updated[index] = rule;
    state = state.copyWith(rules: updated);
  }

  /// Sets the prepayment strategy.
  void setStrategy(PrepaymentStrategy strategy) {
    state = state.copyWith(strategy: strategy);
  }

  /// Updates the base loan amount.
  void setLoanAmount(double value) {
    state = state.copyWith(
      baseCalculation: state.baseCalculation.copyWith(loanAmount: value),
    );
  }

  /// Updates the base interest rate.
  void setInterestRate(double value) {
    state = state.copyWith(
      baseCalculation: state.baseCalculation.copyWith(interestRate: value),
    );
  }

  /// Updates the base tenure.
  void setTenureMonths(int value) {
    state = state.copyWith(
      baseCalculation: state.baseCalculation.copyWith(tenureMonths: value),
    );
  }
}

/// Provider that exposes the current prepayment input.
final prepaymentInputNotifierProvider =
    StateNotifierProvider<PrepaymentInputNotifier, PrepaymentInput>(
  (ref) => PrepaymentInputNotifier(),
);

/// Derived provider that computes the prepayment result for the current input.
final prepaymentResultProvider = Provider<PrepaymentResult>((ref) {
  final input = ref.watch(prepaymentInputNotifierProvider);
  final engine = ref.watch(prepaymentEngineServiceProvider);
  return engine.calculate(input);
});

/// Notifier that manages saved prepayment plans.
class SavedPrepaymentPlansNotifier
    extends StateNotifier<AsyncValue<List<SavedPrepaymentPlan>>> {
  /// Creates a [SavedPrepaymentPlansNotifier].
  SavedPrepaymentPlansNotifier(this._ref)
      : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final repository = _ref.read(prepaymentRepositoryProvider);
    final plans = await repository.getAll();
    state = AsyncValue.data(plans);
  }

  /// Refreshes the list of saved plans.
  Future<void> refresh() async {
    final repository = _ref.read(prepaymentRepositoryProvider);
    state = AsyncValue.data(await repository.getAll());
  }

  /// Saves the current prepayment input as a new plan with the given [title].
  Future<void> saveCurrent(String title) async {
    final repository = _ref.read(prepaymentRepositoryProvider);
    final input = _ref.read(prepaymentInputNotifierProvider);
    final result = _ref.read(prepaymentResultProvider);
    final plan = SavedPrepaymentPlan(
      id: PrepaymentRepository.generateId(),
      title: title,
      input: input,
      result: result,
      createdAt: DateTime.now(),
    );
    await repository.save(plan);
    await refresh();
  }

  /// Deletes a saved plan.
  Future<void> delete(String id) async {
    final repository = _ref.read(prepaymentRepositoryProvider);
    await repository.delete(id);
    await refresh();
  }

  /// Toggles the favorite status of a saved plan.
  Future<void> toggleFavorite(String id) async {
    final repository = _ref.read(prepaymentRepositoryProvider);
    await repository.toggleFavorite(id);
    await refresh();
  }
}

/// Provider that exposes saved prepayment plans.
final savedPrepaymentPlansNotifierProvider = StateNotifierProvider<
    SavedPrepaymentPlansNotifier, AsyncValue<List<SavedPrepaymentPlan>>>(
  (ref) => SavedPrepaymentPlansNotifier(ref),
);
