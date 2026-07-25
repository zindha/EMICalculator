import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../calculator/domain/models/emi_calculation.dart';

part 'loan_offer.freezed.dart';
part 'loan_offer.g.dart';

/// Immutable data class representing a single loan offer within a comparison
/// session.
///
/// Each offer wraps an [EmiCalculation] along with user-facing metadata such
/// as a display name and an optional chart color.
@freezed
class LoanOffer with _$LoanOffer {
  /// Creates a [LoanOffer].
  ///
  /// [id]: Unique identifier for this offer within a comparison.
  /// [name]: Human-readable name of the loan (e.g., "HDFC Home Loan").
  /// [calculation]: The underlying EMI calculation inputs.
  /// [color]: Optional hex color string used to identify the offer in charts.
  const factory LoanOffer({
    required String id,
    required String name,
    required EmiCalculation calculation,
    String? color,
  }) = _LoanOffer;

  /// Creates a [LoanOffer] from a JSON map.
  factory LoanOffer.fromJson(Map<String, dynamic> json) =>
      _$LoanOfferFromJson(json);
}
