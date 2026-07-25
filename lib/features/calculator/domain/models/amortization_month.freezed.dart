// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'amortization_month.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AmortizationMonth _$AmortizationMonthFromJson(Map<String, dynamic> json) {
  return _AmortizationMonth.fromJson(json);
}

/// @nodoc
mixin _$AmortizationMonth {
  int get monthNumber => throw _privateConstructorUsedError;
  double get openingBalance => throw _privateConstructorUsedError;
  double get emiAmount => throw _privateConstructorUsedError;
  double get principalPaid => throw _privateConstructorUsedError;
  double get interestPaid => throw _privateConstructorUsedError;
  double get closingBalance => throw _privateConstructorUsedError;
  double get totalPaidSoFar => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AmortizationMonthCopyWith<AmortizationMonth> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AmortizationMonthCopyWith<$Res> {
  factory $AmortizationMonthCopyWith(
          AmortizationMonth value, $Res Function(AmortizationMonth) then) =
      _$AmortizationMonthCopyWithImpl<$Res, AmortizationMonth>;
  @useResult
  $Res call(
      {int monthNumber,
      double openingBalance,
      double emiAmount,
      double principalPaid,
      double interestPaid,
      double closingBalance,
      double totalPaidSoFar});
}

/// @nodoc
class _$AmortizationMonthCopyWithImpl<$Res, $Val extends AmortizationMonth>
    implements $AmortizationMonthCopyWith<$Res> {
  _$AmortizationMonthCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthNumber = null,
    Object? openingBalance = null,
    Object? emiAmount = null,
    Object? principalPaid = null,
    Object? interestPaid = null,
    Object? closingBalance = null,
    Object? totalPaidSoFar = null,
  }) {
    return _then(_value.copyWith(
      monthNumber: null == monthNumber
          ? _value.monthNumber
          : monthNumber // ignore: cast_nullable_to_non_nullable
              as int,
      openingBalance: null == openingBalance
          ? _value.openingBalance
          : openingBalance // ignore: cast_nullable_to_non_nullable
              as double,
      emiAmount: null == emiAmount
          ? _value.emiAmount
          : emiAmount // ignore: cast_nullable_to_non_nullable
              as double,
      principalPaid: null == principalPaid
          ? _value.principalPaid
          : principalPaid // ignore: cast_nullable_to_non_nullable
              as double,
      interestPaid: null == interestPaid
          ? _value.interestPaid
          : interestPaid // ignore: cast_nullable_to_non_nullable
              as double,
      closingBalance: null == closingBalance
          ? _value.closingBalance
          : closingBalance // ignore: cast_nullable_to_non_nullable
              as double,
      totalPaidSoFar: null == totalPaidSoFar
          ? _value.totalPaidSoFar
          : totalPaidSoFar // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AmortizationMonthImplCopyWith<$Res>
    implements $AmortizationMonthCopyWith<$Res> {
  factory _$$AmortizationMonthImplCopyWith(_$AmortizationMonthImpl value,
          $Res Function(_$AmortizationMonthImpl) then) =
      __$$AmortizationMonthImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int monthNumber,
      double openingBalance,
      double emiAmount,
      double principalPaid,
      double interestPaid,
      double closingBalance,
      double totalPaidSoFar});
}

/// @nodoc
class __$$AmortizationMonthImplCopyWithImpl<$Res>
    extends _$AmortizationMonthCopyWithImpl<$Res, _$AmortizationMonthImpl>
    implements _$$AmortizationMonthImplCopyWith<$Res> {
  __$$AmortizationMonthImplCopyWithImpl(_$AmortizationMonthImpl _value,
      $Res Function(_$AmortizationMonthImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthNumber = null,
    Object? openingBalance = null,
    Object? emiAmount = null,
    Object? principalPaid = null,
    Object? interestPaid = null,
    Object? closingBalance = null,
    Object? totalPaidSoFar = null,
  }) {
    return _then(_$AmortizationMonthImpl(
      monthNumber: null == monthNumber
          ? _value.monthNumber
          : monthNumber // ignore: cast_nullable_to_non_nullable
              as int,
      openingBalance: null == openingBalance
          ? _value.openingBalance
          : openingBalance // ignore: cast_nullable_to_non_nullable
              as double,
      emiAmount: null == emiAmount
          ? _value.emiAmount
          : emiAmount // ignore: cast_nullable_to_non_nullable
              as double,
      principalPaid: null == principalPaid
          ? _value.principalPaid
          : principalPaid // ignore: cast_nullable_to_non_nullable
              as double,
      interestPaid: null == interestPaid
          ? _value.interestPaid
          : interestPaid // ignore: cast_nullable_to_non_nullable
              as double,
      closingBalance: null == closingBalance
          ? _value.closingBalance
          : closingBalance // ignore: cast_nullable_to_non_nullable
              as double,
      totalPaidSoFar: null == totalPaidSoFar
          ? _value.totalPaidSoFar
          : totalPaidSoFar // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AmortizationMonthImpl implements _AmortizationMonth {
  const _$AmortizationMonthImpl(
      {required this.monthNumber,
      required this.openingBalance,
      required this.emiAmount,
      required this.principalPaid,
      required this.interestPaid,
      required this.closingBalance,
      required this.totalPaidSoFar});

  factory _$AmortizationMonthImpl.fromJson(Map<String, dynamic> json) =>
      _$$AmortizationMonthImplFromJson(json);

  @override
  final int monthNumber;
  @override
  final double openingBalance;
  @override
  final double emiAmount;
  @override
  final double principalPaid;
  @override
  final double interestPaid;
  @override
  final double closingBalance;
  @override
  final double totalPaidSoFar;

  @override
  String toString() {
    return 'AmortizationMonth(monthNumber: $monthNumber, openingBalance: $openingBalance, emiAmount: $emiAmount, principalPaid: $principalPaid, interestPaid: $interestPaid, closingBalance: $closingBalance, totalPaidSoFar: $totalPaidSoFar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AmortizationMonthImpl &&
            (identical(other.monthNumber, monthNumber) ||
                other.monthNumber == monthNumber) &&
            (identical(other.openingBalance, openingBalance) ||
                other.openingBalance == openingBalance) &&
            (identical(other.emiAmount, emiAmount) ||
                other.emiAmount == emiAmount) &&
            (identical(other.principalPaid, principalPaid) ||
                other.principalPaid == principalPaid) &&
            (identical(other.interestPaid, interestPaid) ||
                other.interestPaid == interestPaid) &&
            (identical(other.closingBalance, closingBalance) ||
                other.closingBalance == closingBalance) &&
            (identical(other.totalPaidSoFar, totalPaidSoFar) ||
                other.totalPaidSoFar == totalPaidSoFar));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, monthNumber, openingBalance,
      emiAmount, principalPaid, interestPaid, closingBalance, totalPaidSoFar);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AmortizationMonthImplCopyWith<_$AmortizationMonthImpl> get copyWith =>
      __$$AmortizationMonthImplCopyWithImpl<_$AmortizationMonthImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AmortizationMonthImplToJson(
      this,
    );
  }
}

abstract class _AmortizationMonth implements AmortizationMonth {
  const factory _AmortizationMonth(
      {required final int monthNumber,
      required final double openingBalance,
      required final double emiAmount,
      required final double principalPaid,
      required final double interestPaid,
      required final double closingBalance,
      required final double totalPaidSoFar}) = _$AmortizationMonthImpl;

  factory _AmortizationMonth.fromJson(Map<String, dynamic> json) =
      _$AmortizationMonthImpl.fromJson;

  @override
  int get monthNumber;
  @override
  double get openingBalance;
  @override
  double get emiAmount;
  @override
  double get principalPaid;
  @override
  double get interestPaid;
  @override
  double get closingBalance;
  @override
  double get totalPaidSoFar;
  @override
  @JsonKey(ignore: true)
  _$$AmortizationMonthImplCopyWith<_$AmortizationMonthImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
