// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'loan_offer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LoanOffer _$LoanOfferFromJson(Map<String, dynamic> json) {
  return _LoanOffer.fromJson(json);
}

/// @nodoc
mixin _$LoanOffer {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  EmiCalculation get calculation => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LoanOfferCopyWith<LoanOffer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoanOfferCopyWith<$Res> {
  factory $LoanOfferCopyWith(LoanOffer value, $Res Function(LoanOffer) then) =
      _$LoanOfferCopyWithImpl<$Res, LoanOffer>;
  @useResult
  $Res call(
      {String id, String name, EmiCalculation calculation, String? color});

  $EmiCalculationCopyWith<$Res> get calculation;
}

/// @nodoc
class _$LoanOfferCopyWithImpl<$Res, $Val extends LoanOffer>
    implements $LoanOfferCopyWith<$Res> {
  _$LoanOfferCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? calculation = null,
    Object? color = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      calculation: null == calculation
          ? _value.calculation
          : calculation // ignore: cast_nullable_to_non_nullable
              as EmiCalculation,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $EmiCalculationCopyWith<$Res> get calculation {
    return $EmiCalculationCopyWith<$Res>(_value.calculation, (value) {
      return _then(_value.copyWith(calculation: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LoanOfferImplCopyWith<$Res>
    implements $LoanOfferCopyWith<$Res> {
  factory _$$LoanOfferImplCopyWith(
          _$LoanOfferImpl value, $Res Function(_$LoanOfferImpl) then) =
      __$$LoanOfferImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, String name, EmiCalculation calculation, String? color});

  @override
  $EmiCalculationCopyWith<$Res> get calculation;
}

/// @nodoc
class __$$LoanOfferImplCopyWithImpl<$Res>
    extends _$LoanOfferCopyWithImpl<$Res, _$LoanOfferImpl>
    implements _$$LoanOfferImplCopyWith<$Res> {
  __$$LoanOfferImplCopyWithImpl(
      _$LoanOfferImpl _value, $Res Function(_$LoanOfferImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? calculation = null,
    Object? color = freezed,
  }) {
    return _then(_$LoanOfferImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      calculation: null == calculation
          ? _value.calculation
          : calculation // ignore: cast_nullable_to_non_nullable
              as EmiCalculation,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoanOfferImpl implements _LoanOffer {
  const _$LoanOfferImpl(
      {required this.id,
      required this.name,
      required this.calculation,
      this.color});

  factory _$LoanOfferImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoanOfferImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final EmiCalculation calculation;
  @override
  final String? color;

  @override
  String toString() {
    return 'LoanOffer(id: $id, name: $name, calculation: $calculation, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoanOfferImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.calculation, calculation) ||
                other.calculation == calculation) &&
            (identical(other.color, color) || other.color == color));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, calculation, color);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoanOfferImplCopyWith<_$LoanOfferImpl> get copyWith =>
      __$$LoanOfferImplCopyWithImpl<_$LoanOfferImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoanOfferImplToJson(
      this,
    );
  }
}

abstract class _LoanOffer implements LoanOffer {
  const factory _LoanOffer(
      {required final String id,
      required final String name,
      required final EmiCalculation calculation,
      final String? color}) = _$LoanOfferImpl;

  factory _LoanOffer.fromJson(Map<String, dynamic> json) =
      _$LoanOfferImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  EmiCalculation get calculation;
  @override
  String? get color;
  @override
  @JsonKey(ignore: true)
  _$$LoanOfferImplCopyWith<_$LoanOfferImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
