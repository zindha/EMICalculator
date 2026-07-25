import 'dart:convert';
import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/hive_constants.dart';
import '../../../calculator/domain/models/emi_calculation.dart';
import '../../domain/models/comparison_session.dart';
import '../../domain/models/loan_offer.dart';

/// Repository that persists [ComparisonSession] objects using Hive.
///
/// Sessions are stored as JSON string so the repository does not depend on
/// generated Hive type adapters. This keeps the domain layer free of
/// Flutter/storage imports.
class ComparisonRepository {
  /// Creates a [ComparisonRepository].
  ///
  /// If [box] is omitted, the repository opens the default comparison box.
  ComparisonRepository({Box<String>? box})
      : _box = box ?? Hive.box<String>(HiveConstants.comparisonBox);

  final Box<String> _box;

  /// Persists a [ComparisonSession]. Overwrites any existing entry with the
  /// same id.
  Future<void> save(ComparisonSession session) async {
    final json = jsonEncode(session.toJson());
    await _box.put(session.id, json);
  }

  /// Retrieves a session by its [id].
  ///
  /// Returns null if the id is not found or the stored JSON cannot be parsed.
  Future<ComparisonSession?> getById(String id) async {
    final json = _box.get(id);
    if (json == null) return null;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return ComparisonSession.fromJson(map);
    } catch (e) {
      print('Failed to parse comparison session JSON: $e');
      return null;
    }
  }

  /// Returns all saved sessions sorted by creation date (newest first).
  Future<List<ComparisonSession>> getAll() async {
    final sessions = <ComparisonSession>[];
    for (final key in _box.keys.cast<String>()) {
      final session = await getById(key);
      if (session != null) {
        sessions.add(session);
      }
    }
    sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sessions;
  }

  /// Returns all sessions marked as favorites.
  Future<List<ComparisonSession>> getFavorites() async {
    final all = await getAll();
    return all.where((s) => s.isFavorite).toList();
  }

  /// Deletes the session with the given [id].
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Deletes all saved sessions.
  Future<void> clear() async {
    await _box.clear();
  }

  /// Renames the session with [id] to [newTitle].
  Future<void> rename(String id, String newTitle) async {
    final session = await getById(id);
    if (session == null) return;
    await save(session.copyWith(title: newTitle));
  }

  /// Toggles the favorite status of the session with [id].
  Future<void> toggleFavorite(String id) async {
    final session = await getById(id);
    if (session == null) return;
    await save(session.copyWith(isFavorite: !session.isFavorite));
  }

  /// Creates a duplicate of the session with [id].
  ///
  /// The duplicated session receives a new id and an updated title.
  Future<ComparisonSession?> duplicate(String id) async {
    final session = await getById(id);
    if (session == null) return null;

    final duplicate = session.copyWith(
      id: _generateId(),
      title: '${session.title} (Copy)',
      createdAt: DateTime.now(),
    );
    await save(duplicate);
    return duplicate;
  }

  /// Creates a new empty comparison session.
  static ComparisonSession createEmptySession() {
    return ComparisonSession(
      id: _generateId(),
      title: 'New Comparison',
      offers: [],
      createdAt: DateTime.now(),
    );
  }

  /// Creates a default comparison session with two starter loans.
  static ComparisonSession createDefaultSession() {
    return ComparisonSession(
      id: _generateId(),
      title: 'Loan Comparison',
      offers: [_defaultLoanOffer(0), _defaultLoanOffer(1)],
      createdAt: DateTime.now(),
    );
  }

  static LoanOffer _defaultLoanOffer(int index) {
    return LoanOffer(
      id: 'offer_$index',
      name: 'Loan ${String.fromCharCode(65 + index)}',
      calculation: EmiCalculation(
        loanAmount: 500000 + (index * 100000).toDouble(),
        interestRate: 10.5 + (index * 0.5),
        tenureMonths: 60,
      ),
    );
  }

  static String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(999999)}';
  }

  static final _random = Random();
}
