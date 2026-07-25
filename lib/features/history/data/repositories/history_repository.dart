import 'dart:convert';
import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/hive_constants.dart';
import '../../../calculator/domain/models/emi_calculation.dart';

/// A single saved calculation entry in the history.
class CalculationHistoryEntry {
  /// Creates a [CalculationHistoryEntry].
  const CalculationHistoryEntry({
    required this.id,
    required this.calculation,
    required this.createdAt,
    this.isFavorite = false,
    this.title,
  });

  /// Unique identifier for this entry.
  final String id;

  /// The calculation that was saved.
  final EmiCalculation calculation;

  /// Timestamp when the entry was created.
  final DateTime createdAt;

  /// Whether this entry is marked as favorite.
  final bool isFavorite;

  /// Optional display title.
  final String? title;

  /// Creates a copy with the given fields replaced.
  CalculationHistoryEntry copyWith({
    String? id,
    EmiCalculation? calculation,
    DateTime? createdAt,
    bool? isFavorite,
    String? title,
  }) {
    return CalculationHistoryEntry(
      id: id ?? this.id,
      calculation: calculation ?? this.calculation,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      title: title ?? this.title,
    );
  }
}

/// Repository that persists calculation history using Hive.
class HistoryRepository {
  /// Creates a [HistoryRepository].
  ///
  /// If [box] is omitted, the repository opens the default history box.
  HistoryRepository({Box<String>? box})
      : _box = box ?? Hive.box<String>(HiveConstants.loanHistoryBox);

  final Box<String> _box;

  /// Persists [entry]. Overwrites any existing entry with the same id.
  Future<void> save(CalculationHistoryEntry entry) async {
    final json = jsonEncode({
      'id': entry.id,
      'calculation': entry.calculation.toJson(),
      'createdAt': entry.createdAt.toIso8601String(),
      'isFavorite': entry.isFavorite,
      'title': entry.title,
    });
    await _box.put(entry.id, json);
  }

  /// Retrieves a history entry by [id].
  Future<CalculationHistoryEntry?> getById(String id) async {
    final json = _box.get(id);
    if (json == null) return null;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return CalculationHistoryEntry(
        id: map['id'] as String,
        calculation: EmiCalculation.fromJson(
          map['calculation'] as Map<String, dynamic>,
        ),
        createdAt: DateTime.parse(map['createdAt'] as String),
        isFavorite: (map['isFavorite'] as bool?) ?? false,
        title: map['title'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  /// Returns all history entries sorted by creation date (newest first).
  Future<List<CalculationHistoryEntry>> getAll() async {
    final entries = <CalculationHistoryEntry>[];
    for (final key in _box.keys.cast<String>()) {
      final entry = await getById(key);
      if (entry != null) entries.add(entry);
    }
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  /// Deletes the entry with the given [id].
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Toggles the favorite status of the entry with [id].
  Future<void> toggleFavorite(String id) async {
    final entry = await getById(id);
    if (entry == null) return;
    await save(entry.copyWith(isFavorite: !entry.isFavorite));
  }

  /// Generates a unique id.
  static String generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(999999)}';
  }

  static final _random = Random();
}
