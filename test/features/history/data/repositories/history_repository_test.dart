import 'dart:io';

import 'package:emi_calculator/features/calculator/domain/models/emi_calculation.dart';
import 'package:emi_calculator/features/history/data/repositories/history_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  group('HistoryRepository', () {
    late Box<String> box;
    late HistoryRepository repository;

    setUpAll(() async {
      final tempDir = Directory.systemTemp.createTempSync();
      Hive.init(tempDir.path);
      box = await Hive.openBox<String>('test_history_box');
      repository = HistoryRepository(box: box);
    });

    tearDownAll(() async {
      await box.close();
      await Hive.deleteBoxFromDisk('test_history_box');
    });

    tearDown(() async {
      await box.clear();
    });

    EmiCalculation _sampleCalculation() {
      return const EmiCalculation(
        loanAmount: 500000,
        interestRate: 10.5,
        tenureMonths: 60,
      );
    }

    test('save and retrieve an entry', () async {
      final entry = CalculationHistoryEntry(
        id: HistoryRepository.generateId(),
        calculation: _sampleCalculation(),
        createdAt: DateTime.now(),
      );

      await repository.save(entry);
      final retrieved = await repository.getById(entry.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.calculation.loanAmount, equals(500000));
    });

    test('toggle favorite updates the entry', () async {
      final entry = CalculationHistoryEntry(
        id: HistoryRepository.generateId(),
        calculation: _sampleCalculation(),
        createdAt: DateTime.now(),
        isFavorite: false,
      );

      await repository.save(entry);
      await repository.toggleFavorite(entry.id);

      final updated = await repository.getById(entry.id);
      expect(updated!.isFavorite, isTrue);
    });

    test('delete removes the entry', () async {
      final entry = CalculationHistoryEntry(
        id: HistoryRepository.generateId(),
        calculation: _sampleCalculation(),
        createdAt: DateTime.now(),
      );

      await repository.save(entry);
      expect(await repository.getById(entry.id), isNotNull);

      await repository.delete(entry.id);
      expect(await repository.getById(entry.id), isNull);
    });
  });
}
