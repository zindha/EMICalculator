// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'emi_calculation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EmiCalculation _$EmiCalculationFromJson(Map<String, dynamic> json) {
  return _EmiCalculation.fromJson(json);
}

/// @nodoc
mixin _$EmiCalculation {
  double get loanAmount => throw _privateConstructorUsedError;
  double get interestRate => throw _privateConstructorUsedError;
  int get tenureMonths => throw _privateConstructorUsedError;
  double get processingFee => throw _privateConstructorUsedError;
  double get insurance => throw _privateConstructorUsedError;
  double get downPayment => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EmiCalculationCopyWith<EmiCalculation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmiCalculationCopyWith<$Res> {
  factory $EmiCalculationCopyWith(
          EmiCalculation value, $Res Function(EmiCalculation) then) =
      _$EmiCalculationCopyWithImpl<$Res, EmiCalculation>;
  @useResult
  $Res call(
      {double loanAmount,
      double interestRate,
      int tenureMonths,
      double processingFee,
      double insurance,
      double downPayment});
}

/// @nodoc
class _$EmiCalculationCopyWithImpl<$Res, $Val extends EmiCalculation>
    implements $EmiCalculationCopyWith<$Res> {
  _$EmiCalculationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loanAmount = null,
    Object? interestRate = null,
    Object? tenureMonths = null,
    Object? processingFee = null,
    Object? insurance = null,
    Object? downPayment = null,
  }) {
    return _then(_value.copyWith(
      loanAmount: null == loanAmount
          ? _value.loanAmount
          : loanAmount // ignore: cast_nullable_to_non_nullable
              as double,
      interestRate: null == interestRate
          ? _value.interestRate
          : interestRate // ignore: cast_nullable_to_non_nullable
              as double,
      tenureMonths: null == tenureMonths
          ? _value.tenureMonths
          : tenureMonths // ignore: cast_nullable_to_non_nullable
              as int,
      processingFee: null == processingFee
          ? _value.processingFee
          : processingFee // ignore: cast_nullable_to_non_nullable
              as double,
      insurance: null == insurance
          ? _value.insurance
          : insurance // ignore: cast_nullable_to_non_nullable
              as double,
      downPayment: null == downPayment
          ? _value.downPayment
          : downPayment // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EmiCalculationImplCopyWith<$Res>
    implements $EmiCalculationCopyWith<$Res> {
  factory _$$EmiCalculationImplCopyWith(_$EmiCalculationImpl value,
          $Res Function(_$EmiCalculationImpl) then) =
      __$$EmiCalculationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double loanAmount,
      double interestRate,
      int tenureMonths,
      double processingFee,
      double insurance,
      double downPayment});
}

/// @nodoc
class __$$EmiCalculationImplCopyWithImpl<$Res>
    extends _$EmiCalculationCopyWithImpl<$Res, _$EmiCalculationImpl>
    implements _$$EmiCalculationImplCopyWith<$Res> {
  __$$EmiCalculationImplCopyWithImpl(
      _$EmiCalculationImpl _value, $Res Function(_$EmiCalculationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loanAmount = null,
    Object? interestRate = null,
    Object? tenureMonths = null,
    Object? processingFee = null,
    Object? insurance = null,
    Object? downPayment = null,
  }) {
    return _then(_$EmiCalculationImpl(
      loanAmount: null == loanAmount
          ? _value.loanAmount
          : loanAmount // ignore: cast_nullable_to_non_nullable
              as double,
      interestRate: null == interestRate
          ? _value.interestRate
          : interestRate // ignore: cast_nullable_to_non_nullable
              as double,
      tenureMonths: null == tenureMonths
          ? _value.tenureMonths
          : tenureMonths // ignore: cast_nullable_to_non_nullable
              as int,
      processingFee: null == processingFee
          ? _value.processingFee
          : processingFee // ignore: cast_nullable_to_non_nullable
              as double,
      insurance: null == insurance
          ? _value.insurance
          : insurance // ignore: cast_nullable_to_non_nullable
              as double,
      downPayment: null == downPayment
          ? _value.downPayment
          : downPayment // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EmiCalculationImpl implements _EmiCalculation {
  const _$EmiCalculationImpl(
      {required this.loanAmount,
      required this.interestRate,
      required this.tenureMonths,
      this.processingFee = 0.0,
      this.insurance = 0.0,
      this.downPayment = 0.0});

  factory _$EmiCalculationImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmiCalculationImplFromJson(json);

  @override
  final double loanAmount;
  @override
  final double interestRate;
  @override
  final int tenureMonths;
  @override
  @JsonKey()
  final double processingFee;
  @override
  @JsonKey()
  final double insurance;
  @override
  @JsonKey()
  final double downPayment;

  @override
  String toString() {
    return 'EmiCalculation(loanAmount: $loanAmount, interestRate: $interestRate, tenureMonths: $tenureMonths, processingFee: $processingFee, insurance: $insurance, downPayment: $downPayment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmiCalculationImpl &&
            (identical(other.loanAmount, loanAmount) ||
                other.loanAmount == loanAmount) &&
            (identical(other.interestRate, interestRate) ||
                other.interestRate == interestRate) &&
            (identical(other.tenureMonths, tenureMonths) ||
                other.tenureMonths == tenureMonths) &&
            (identical(other.processingFee, processingFee) ||
                other.processingFee == processingFee) &&
            (identical(other.insurance, insurance) ||
                other.insurance == insurance) &&
            (identical(other.downPayment, downPayment) ||
                other.downPayment == downPayment));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, loanAmount, interestRate,
      tenureMonths, processingFee, insurance, downPayment);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EmiCalculationImplCopyWith<_$EmiCalculationImpl> get copyWith =>
      __$$EmiCalculationImplCopyWithImpl<_$EmiCalculationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EmiCalculationImplToJson(
      this,
    );
  }
}

abstract class _EmiCalculation implements EmiCalculation {
  const factory _EmiCalculation(
      {required final double loanAmount,
      required final double interestRate,
      required final int tenureMonths,
      final double processingFee,
      final double insurance,
      final double downPayment}) = _$EmiCalculationImpl;

  factory _EmiCalculation.fromJson(Map<String, dynamic> json) =
      _$EmiCalculationImpl.fromJson;

  @override
  double get loanAmount;
  @override
  double get interestRate;
  @override
  int get tenureMonths;
  @override
  double get processingFee;
  @override
  double get insurance;
  @override
  double get downPayment;
  @override
  @JsonKey(ignore: true)
  _$$EmiCalculationImplCopyWith<_$EmiCalculationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
