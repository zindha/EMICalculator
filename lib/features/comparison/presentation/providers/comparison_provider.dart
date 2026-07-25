import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/hive_constants.dart';
import '../../../../core/services/hive_service.dart';
import '../../../calculator/domain/models/emi_calculation.dart';
import '../../data/repositories/comparison_repository.dart';
import '../../domain/engines/comparison_engine_service.dart';
import '../../domain/engines/comparison_export_service.dart';
import '../../domain/engines/smart_insights_service.dart';
import '../../domain/models/comparison_result.dart';
import '../../domain/models/comparison_session.dart';
import '../../domain/models/loan_offer.dart';

/// Provider for the [ComparisonRepository].
final comparisonRepositoryProvider = Provider<ComparisonRepository>((ref) {
  final box = HiveService.getBox<String>(HiveConstants.comparisonBox);
  return ComparisonRepository(box: box);
});

/// Provider for the [ComparisonEngineService].
final comparisonEngineServiceProvider = Provider<ComparisonEngineService>((ref) {
  return const ComparisonEngineService();
});

/// Provider for the [SmartInsightsService].
final smartInsightsServiceProvider = Provider<SmartInsightsService>((ref) {
  return const SmartInsightsService();
});

/// Provider for the [ComparisonExportService].
final comparisonExportServiceProvider = Provider<ComparisonExportService>(
  (ref) => const ComparisonExportService(),
);

/// Notifier that manages the currently active comparison session.
class ActiveComparisonNotifier extends StateNotifier<ComparisonSession> {
  /// Creates an [ActiveComparisonNotifier].
  ActiveComparisonNotifier(this._ref)
      : super(ComparisonRepository.createDefaultSession());

  final Ref _ref;

  /// Replaces the entire active session.
  void setSession(ComparisonSession session) {
    state = session;
  }

  /// Resets the active session to the default two-loan comparison.
  void reset() {
    state = ComparisonRepository.createDefaultSession();
  }

  /// Updates the session title.
  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  /// Adds a new loan offer to the comparison.
  void addOffer([LoanOffer? offer]) {
    final newOffer = offer ?? _createNewOffer(state.offers.length);
    state = state.copyWith(offers: [...state.offers, newOffer]);
  }

  /// Updates an existing offer at [index].
  void updateOffer(int index, LoanOffer offer) {
    if (index < 0 || index >= state.offers.length) return;
    final updated = List<LoanOffer>.from(state.offers);
    updated[index] = offer;
    state = state.copyWith(offers: updated);
  }

  /// Removes the offer at [index].
  void removeOffer(int index) {
    if (index < 0 || index >= state.offers.length) return;
    if (state.offers.length <= 2) return; // Keep at least two offers.
    final updated = List<LoanOffer>.from(state.offers)..removeAt(index);
    state = state.copyWith(offers: updated);
  }

  /// Updates a specific field of an offer's calculation.
  void updateOfferCalculation(int index, EmiCalculation calculation) {
    if (index < 0 || index >= state.offers.length) return;
    final updated = List<LoanOffer>.from(state.offers);
    updated[index] = updated[index].copyWith(calculation: calculation);
    state = state.copyWith(offers: updated);
  }

  /// Updates the display name of the offer at [index].
  void updateOfferName(int index, String name) {
    if (index < 0 || index >= state.offers.length) return;
    final updated = List<LoanOffer>.from(state.offers);
    updated[index] = updated[index].copyWith(name: name);
    state = state.copyWith(offers: updated);
  }

  /// Saves the active session to the repository.
  Future<void> saveActive() async {
    final repository = _ref.read(comparisonRepositoryProvider);
    await repository.save(state);
  }

  LoanOffer _createNewOffer(int index) {
    final label = String.fromCharCode(65 + index);
    return LoanOffer(
      id: 'offer_${DateTime.now().millisecondsSinceEpoch}_$index',
      name: 'Loan $label',
      calculation: const EmiCalculation(
        loanAmount: 500000,
        interestRate: 10.5,
        tenureMonths: 60,
      ),
    );
  }
}

/// Provider that exposes the active comparison session.
final activeComparisonNotifierProvider =
    StateNotifierProvider<ActiveComparisonNotifier, ComparisonSession>((ref) {
  return ActiveComparisonNotifier(ref);
});

/// Derived provider that exposes the analyzed [ComparisonResult] for the
/// active session.
final comparisonResultProvider = Provider<ComparisonResult>((ref) {
  final session = ref.watch(activeComparisonNotifierProvider);
  final engine = ref.watch(comparisonEngineServiceProvider);
  return engine.analyze(session.offers);
});

/// Derived provider that exposes human-readable insights for the active
/// comparison session.
final comparisonInsightsProvider = Provider<ComparisonInsights>((ref) {
  final result = ref.watch(comparisonResultProvider);
  final service = ref.watch(smartInsightsServiceProvider);
  final insights = service.generateInsights(
    result,
    formatCurrency: _formatInsightCurrency,
  );
  return ComparisonInsights(insights: insights);
});

/// Simple value object that wraps a list of insight strings.
class ComparisonInsights {
  /// Creates a [ComparisonInsights].
  const ComparisonInsights({required this.insights});

  /// The generated insight strings.
  final List<String> insights;
}

String _formatInsightCurrency(double amount) {
  if (amount.abs() >= 10000000) {
    return '${(amount / 10000000).toStringAsFixed(1)} Crores';
  } else if (amount.abs() >= 100000) {
    return '${(amount / 100000).toStringAsFixed(1)} Lakhs';
  } else if (amount.abs() >= 1000) {
    return '${(amount / 1000).toStringAsFixed(1)}K';
  }
  return amount.toStringAsFixed(0);
}

/// Notifier that manages saved comparison sessions.
class SavedComparisonsNotifier
    extends StateNotifier<AsyncValue<List<ComparisonSession>>> {
  /// Creates a [SavedComparisonsNotifier].
  SavedComparisonsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final repository = _ref.read(comparisonRepositoryProvider);
    final sessions = await repository.getAll();
    state = AsyncValue.data(sessions);
  }

  /// Refreshes the list of saved sessions.
  Future<void> refresh() async {
    final repository = _ref.read(comparisonRepositoryProvider);
    state = AsyncValue.data(await repository.getAll());
  }

  /// Loads a saved session into the active comparison notifier.
  Future<void> loadSession(String id) async {
    final repository = _ref.read(comparisonRepositoryProvider);
    final session = await repository.getById(id);
    if (session != null) {
      _ref.read(activeComparisonNotifierProvider.notifier).setSession(session);
    }
  }

  /// Deletes a saved session and refreshes the list.
  Future<void> delete(String id) async {
    final repository = _ref.read(comparisonRepositoryProvider);
    await repository.delete(id);
    await refresh();
  }

  /// Toggles the favorite status of a session and refreshes the list.
  Future<void> toggleFavorite(String id) async {
    final repository = _ref.read(comparisonRepositoryProvider);
    await repository.toggleFavorite(id);
    await refresh();
  }

  /// Renames a saved session and refreshes the list.
  Future<void> rename(String id, String newTitle) async {
    final repository = _ref.read(comparisonRepositoryProvider);
    await repository.rename(id, newTitle);
    await refresh();
  }

  /// Duplicates a saved session and refreshes the list.
  Future<void> duplicate(String id) async {
    final repository = _ref.read(comparisonRepositoryProvider);
    await repository.duplicate(id);
    await refresh();
  }
}

/// Provider that exposes saved comparison sessions.
final savedComparisonsNotifierProvider = StateNotifierProvider<
    SavedComparisonsNotifier, AsyncValue<List<ComparisonSession>>>((ref) {
  return SavedComparisonsNotifier(ref);
});
