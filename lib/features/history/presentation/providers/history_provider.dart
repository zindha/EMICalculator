import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/hive_constants.dart';
import '../../../../core/services/hive_service.dart';
import '../../../calculator/domain/models/emi_calculation.dart';
import '../../data/repositories/history_repository.dart';

/// Provider for the [HistoryRepository].
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final box = HiveService.getBox<String>(HiveConstants.loanHistoryBox);
  return HistoryRepository(box: box);
});

/// Notifier that manages the list of saved calculations.
class HistoryNotifier extends StateNotifier<AsyncValue<List<CalculationHistoryEntry>>> {
  /// Creates a [HistoryNotifier].
  HistoryNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    try {
      final repository = _ref.read(historyRepositoryProvider);
      final entries = await repository.getAll();
      state = AsyncValue.data(entries);
    } catch (e, stack) {
      debugPrint('History load failed: $e');
      debugPrint('$stack');
      // Never stay in loading state; show an empty list so the user sees
      // the empty state instead of a spinner.
      state = const AsyncValue.data(<CalculationHistoryEntry>[]);
    }
  }

  /// Refreshes the history list.
  Future<void> refresh() async {
    try {
      final repository = _ref.read(historyRepositoryProvider);
      final entries = await repository.getAll();
      state = AsyncValue.data(entries);
    } catch (e, stack) {
      debugPrint('History refresh failed: $e');
      debugPrint('$stack');
      // Preserve existing data on refresh failure to avoid flickering
      // back to the empty state unexpectedly.
      if (state case AsyncError(:final error)) {
        debugPrint('Previous history error: $error');
      }
      if (state is! AsyncData) {
        state = const AsyncValue.data(<CalculationHistoryEntry>[]);
      }
    }
  }

  /// Saves a new calculation entry with the given [calculation] and [title].
  Future<void> save(EmiCalculation calculation, {String? title}) async {
    final repository = _ref.read(historyRepositoryProvider);
    final entry = CalculationHistoryEntry(
      id: HistoryRepository.generateId(),
      calculation: calculation,
      createdAt: DateTime.now(),
      isFavorite: false,
      title: title,
    );
    await repository.save(entry);
    await refresh();
  }

  /// Toggles the favorite status of the entry with [id].
  Future<void> toggleFavorite(String id) async {
    final repository = _ref.read(historyRepositoryProvider);
    await repository.toggleFavorite(id);
    await refresh();
  }

  /// Deletes the entry with [id].
  Future<void> delete(String id) async {
    final repository = _ref.read(historyRepositoryProvider);
    await repository.delete(id);
    await refresh();
  }

  /// Deletes all history entries.
  Future<void> clearAll() async {
    final repository = _ref.read(historyRepositoryProvider);
    final entries = await repository.getAll();
    for (final entry in entries) {
      await repository.delete(entry.id);
    }
    await refresh();
  }
}

/// Provider that exposes saved calculation history.
final historyNotifierProvider = StateNotifierProvider<HistoryNotifier, AsyncValue<List<CalculationHistoryEntry>>>(
  (ref) => HistoryNotifier(ref),
);
