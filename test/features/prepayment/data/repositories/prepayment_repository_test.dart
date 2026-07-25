import 'dart:io';

import 'package:emi_calculator/features/calculator/domain/models/emi_calculation.dart';
import 'package:emi_calculator/features/prepayment/data/repositories/prepayment_repository.dart';
import 'package:emi_calculator/features/prepayment/domain/models/prepayment_input.dart';
import 'package:emi_calculator/features/prepayment/domain/models/prepayment_strategy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  group('PrepaymentRepository', () {
    late Box<String> box;
    late PrepaymentRepository repository;

    setUpAll(() async {
      final tempDir = Directory.systemTemp.createTempSync();
      Hive.init(tempDir.path);
      box = await Hive.openBox<String>('test_prepayment_box');
      repository = PrepaymentRepository(box: box);
    });

    tearDownAll(() async {
      await box.close();
      await Hive.deleteBoxFromDisk('test_prepayment_box');
    });

    tearDown(() async {
      await box.clear();
    });

    PrepaymentInput _sampleInput() {
      return PrepaymentInput(
        baseCalculation: const EmiCalculation(
          loanAmount: 500000,
          interestRate: 10.5,
          tenureMonths: 60,
        ),
        rules: const [],
        strategy: PrepaymentStrategy.reduceTenure,
      );
    }

    test('save and retrieve a plan', () async {
      final plan = SavedPrepaymentPlan(
        id: PrepaymentRepository.generateId(),
        title: 'Test Plan',
        input: _sampleInput(),
        result: null,
        createdAt: DateTime.now(),
      );

      await repository.save(plan);
      final retrieved = await repository.getById(plan.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.title, equals(plan.title));
      expect(retrieved.input.strategy, equals(plan.input.strategy));
    });

    test('getAll returns plans sorted by createdAt descending', () async {
      final plan1 = SavedPrepaymentPlan(
        id: PrepaymentRepository.generateId(),
        title: 'Older Plan',
        input: _sampleInput(),
        result: null,
        createdAt: DateTime(2023, 1, 1),
      );
      final plan2 = SavedPrepaymentPlan(
        id: PrepaymentRepository.generateId(),
        title: 'Newer Plan',
        input: _sampleInput(),
        result: null,
        createdAt: DateTime(2024, 1, 1),
      );

      await repository.save(plan1);
      await repository.save(plan2);

      final plans = await repository.getAll();

      expect(plans.length, equals(2));
      expect(plans.first.title, equals('Newer Plan'));
      expect(plans.last.title, equals('Older Plan'));
    });

    test('delete removes a plan', () async {
      final plan = SavedPrepaymentPlan(
        id: PrepaymentRepository.generateId(),
        title: 'Delete Me',
        input: _sampleInput(),
        result: null,
        createdAt: DateTime.now(),
      );

      await repository.save(plan);
      expect(await repository.getById(plan.id), isNotNull);

      await repository.delete(plan.id);
      expect(await repository.getById(plan.id), isNull);
    });

    test('toggleFavorite updates favorite status', () async {
      final plan = SavedPrepaymentPlan(
        id: PrepaymentRepository.generateId(),
        title: 'Favorite Plan',
        input: _sampleInput(),
        result: null,
        createdAt: DateTime.now(),
        isFavorite: false,
      );

      await repository.save(plan);
      await repository.toggleFavorite(plan.id);

      final updated = await repository.getById(plan.id);
      expect(updated!.isFavorite, isTrue);
    });
  });
}
