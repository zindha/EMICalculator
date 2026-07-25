import 'package:freezed_annotation/freezed_annotation.dart';

import 'loan_offer.dart';

part 'comparison_session.freezed.dart';
part 'comparison_session.g.dart';

/// Immutable data class representing a saved loan comparison session.
///
/// A session groups a collection of [LoanOffer] entries under a user-editable
/// title and tracks metadata such as creation date and favorite status.
@freezed
class ComparisonSession with _$ComparisonSession {
  /// Creates a [ComparisonSession].
  ///
  /// [id]: Unique identifier used as the Hive key.
  /// [title]: User-facing name of the comparison (e.g., "Home Loan Offers").
  /// [offers]: The list of loan offers being compared.
  /// [createdAt]: Timestamp when the session was originally created.
  /// [isFavorite]: Whether this session is marked as a favorite.
  const factory ComparisonSession({
    required String id,
    required String title,
    required List<LoanOffer> offers,
    required DateTime createdAt,
    @Default(false) bool isFavorite,
  }) = _ComparisonSession;

  /// Creates a [ComparisonSession] from a JSON map.
  factory ComparisonSession.fromJson(Map<String, dynamic> json) =>
      _$ComparisonSessionFromJson(json);
}
