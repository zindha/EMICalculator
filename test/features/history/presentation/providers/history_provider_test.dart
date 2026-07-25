import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:emi_calculator/features/calculator/domain/models/emi_calculation.dart';
import 'package:emi_calculator/features/history/data/repositories/history_repository.dart';
import 'package:emi_calculator/features/history/presentation/providers/history_provider.dart';

class MockHistoryRepository extends Mock implements HistoryRepository {}

void main() {
  group('HistoryNotifier', () {
    late MockHistoryRepository mockRepository;

    setUp(() {
      mockRepository = MockHistoryRepository();
    });

    ProviderContainer createContainer() {
      final container = ProviderContainer(
        overrides: [
          historyRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    /// Waits until [condition] returns true for the current state, then
    /// returns the state. Avoids relying on a fixed duration.
    Future<AsyncValue<List<CalculationHistoryEntry>>> waitForState(
      ProviderContainer container,
      bool Function(AsyncValue<List<CalculationHistoryEntry>>) condition,
    ) async {
      final completer = Completer<AsyncValue<List<CalculationHistoryEntry>>>();
      AsyncValue<List<CalculationHistoryEntry>>? lastState;

      final sub = container.listen(
        historyNotifierProvider,
        (previous, next) {
          lastState = next;
          if (!completer.isCompleted && condition(next)) {
            completer.complete(next);
          }
        },
      );

      // Check the current state in case it already satisfies the condition.
      lastState ??= container.read(historyNotifierProvider);
      if (condition(lastState!)) {
        sub.close();
        return lastState!;
      }

      addTearDown(sub.close);
      return completer.future;
    }

    test('emits empty list when repository throws during initial load', () async {
      when(() => mockRepository.getAll()).thenThrow(
        Exception('Hive box unavailable'),
      );

      final container = createContainer();
      final state = await waitForState(container, (state) => state is AsyncData);

      expect(state, const AsyncData<List<CalculationHistoryEntry>>([]));
    });

    test('preserves existing data when refresh throws after initial success',
        () async {
      final existingEntry = CalculationHistoryEntry(
        id: '1',
        calculation: const EmiCalculation(
          loanAmount: 500000,
          interestRate: 10.5,
          tenureMonths: 60,
        ),
        createdAt: DateTime(2026, 1, 1),
      );

      var callCount = 0;
      when(() => mockRepository.getAll()).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return [existingEntry];
        }
        throw Exception('Refresh failed');
      });

      final container = createContainer();
      final initialState = await waitForState(
        container,
        (state) =>
            state is AsyncData && (state.value?.isNotEmpty ?? false),
      );
      expect(initialState.value, [existingEntry]);

      // Refresh should throw but keep the previous data.
      final notifier = container.read(historyNotifierProvider.notifier);
      await notifier.refresh();

      final state = container.read(historyNotifierProvider);
      expect(state.value, [existingEntry]);
    });
  });
}
