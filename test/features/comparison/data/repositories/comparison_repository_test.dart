import 'dart:io';

import 'package:emi_calculator/features/calculator/domain/models/emi_calculation.dart';
import 'package:emi_calculator/features/comparison/data/repositories/comparison_repository.dart';
import 'package:emi_calculator/features/comparison/domain/models/comparison_session.dart';
import 'package:emi_calculator/features/comparison/domain/models/loan_offer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('ComparisonRepository', () {
    late Directory tempDir;
    late Box<String> box;
    late ComparisonRepository repository;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('comparison_test');
      Hive.init(tempDir.path);
    });

    tearDownAll(() async {
      await Hive.deleteFromDisk();
      await tempDir.delete(recursive: true);
    });

    setUp(() async {
      box = await Hive.openBox<String>('test_comparison');
      await box.clear();
      repository = ComparisonRepository(box: box);
    });

    tearDown(() async {
      await box.deleteFromDisk();
    });

    ComparisonSession createSession(String title) {
      return ComparisonSession(
        id: 'session_1',
        title: title,
        offers: [
          LoanOffer(
            id: 'offer_1',
            name: 'Loan A',
            calculation: const EmiCalculation(
              loanAmount: 500000,
              interestRate: 10.5,
              tenureMonths: 60,
            ),
          ),
        ],
        createdAt: DateTime(2024, 1, 1),
      );
    }

    test('saves and retrieves a session', () async {
      final session = createSession('Test Comparison');
      await repository.save(session);

      final retrieved = await repository.getById(session.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.title, 'Test Comparison');
      expect(retrieved.offers.length, 1);
      expect(retrieved.offers.first.name, 'Loan A');
    });

    test('returns all sessions sorted by createdAt descending', () async {
      final older = ComparisonSession(
        id: 'older',
        title: 'Older',
        offers: [],
        createdAt: DateTime(2024, 1, 1),
      );
      final newer = ComparisonSession(
        id: 'newer',
        title: 'Newer',
        offers: [],
        createdAt: DateTime(2024, 1, 2),
      );

      await repository.save(older);
      await repository.save(newer);

      final all = await repository.getAll();
      expect(all.first.id, 'newer');
      expect(all.last.id, 'older');
    });

    test('deletes a session', () async {
      final session = createSession('To Delete');
      await repository.save(session);
      await repository.delete(session.id);

      final retrieved = await repository.getById(session.id);
      expect(retrieved, isNull);
    });

    test('toggles favorite status', () async {
      final session = createSession('Favorite Test');
      await repository.save(session);

      await repository.toggleFavorite(session.id);
      final updated = await repository.getById(session.id);
      expect(updated!.isFavorite, isTrue);
    });

    test('duplicates a session', () async {
      final session = createSession('Original');
      await repository.save(session);

      final duplicate = await repository.duplicate(session.id);
      expect(duplicate, isNotNull);
      expect(duplicate!.title, 'Original (Copy)');
      expect(duplicate.id, isNot(equals(session.id)));

      final all = await repository.getAll();
      expect(all.length, 2);
    });
  });
}
