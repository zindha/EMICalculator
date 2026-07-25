import 'dart:convert';
import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/hive_constants.dart';
import '../../domain/models/prepayment_input.dart';
import '../../domain/models/prepayment_result.dart';

/// A saved prepayment plan with its input, optional cached result, and metadata.
class SavedPrepaymentPlan {
  /// Creates a [SavedPrepaymentPlan].
  SavedPrepaymentPlan({
    required this.id,
    required this.title,
    required this.input,
    this.result,
    required this.createdAt,
    this.isFavorite = false,
  });

  /// Unique identifier for this saved plan.
  final String id;

  /// User-facing title for this plan.
  final String title;

  /// The prepayment input that defines this plan.
  final PrepaymentInput input;

  /// Cached result from the last simulation. May be null if the result has
  /// not been computed yet or is stale.
  final PrepaymentResult? result;

  /// Timestamp when the plan was created.
  final DateTime createdAt;

  /// Whether this plan is marked as a favorite.
  final bool isFavorite;
}

/// Repository that persists prepayment plans using Hive.
class PrepaymentRepository {
  /// Creates a [PrepaymentRepository].
  ///
  /// If [box] is omitted, the repository opens the default prepayment box.
  PrepaymentRepository({Box<String>? box})
      : _box = box ?? Hive.box<String>(HiveConstants.prepaymentBox);

  final Box<String> _box;

  /// Persists a [SavedPrepaymentPlan]. Overwrites any existing entry with
  /// the same id.
  Future<void> save(SavedPrepaymentPlan plan) async {
    final json = jsonEncode({
      'id': plan.id,
      'title': plan.title,
      'input': plan.input.toJson(),
      'createdAt': plan.createdAt.toIso8601String(),
      'isFavorite': plan.isFavorite,
    });
    await _box.put(plan.id, json);
  }

  /// Retrieves a saved plan by its [id].
  Future<SavedPrepaymentPlan?> getById(String id) async {
    final json = _box.get(id);
    if (json == null) return null;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return SavedPrepaymentPlan(
        id: map['id'] as String,
        title: map['title'] as String,
        input: PrepaymentInput.fromJson(
          map['input'] as Map<String, dynamic>,
        ),
        result: null,
        createdAt: DateTime.parse(map['createdAt'] as String),
        isFavorite: (map['isFavorite'] as bool?) ?? false,
      );
    } catch (_) {
      return null;
    }
  }

  /// Returns all saved plans sorted by creation date (newest first).
  Future<List<SavedPrepaymentPlan>> getAll() async {
    final plans = <SavedPrepaymentPlan>[];
    for (final key in _box.keys.cast<String>()) {
      final plan = await getById(key);
      if (plan != null) plans.add(plan);
    }
    plans.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return plans;
  }

  /// Deletes the plan with the given [id].
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Toggles the favorite status of the plan with [id].
  Future<void> toggleFavorite(String id) async {
    final plan = await getById(id);
    if (plan == null) return;
    await save(SavedPrepaymentPlan(
      id: plan.id,
      title: plan.title,
      input: plan.input,
      result: plan.result,
      createdAt: plan.createdAt,
      isFavorite: !plan.isFavorite,
    ));
  }

  /// Generates a unique id.
  static String generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(999999)}';
  }

  static final _random = Random();
}
