// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comparison_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ComparisonSession _$ComparisonSessionFromJson(Map<String, dynamic> json) {
  return _ComparisonSession.fromJson(json);
}

/// @nodoc
mixin _$ComparisonSession {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  List<LoanOffer> get offers => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ComparisonSessionCopyWith<ComparisonSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComparisonSessionCopyWith<$Res> {
  factory $ComparisonSessionCopyWith(
          ComparisonSession value, $Res Function(ComparisonSession) then) =
      _$ComparisonSessionCopyWithImpl<$Res, ComparisonSession>;
  @useResult
  $Res call(
      {String id,
      String title,
      List<LoanOffer> offers,
      DateTime createdAt,
      bool isFavorite});
}

/// @nodoc
class _$ComparisonSessionCopyWithImpl<$Res, $Val extends ComparisonSession>
    implements $ComparisonSessionCopyWith<$Res> {
  _$ComparisonSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? offers = null,
    Object? createdAt = null,
    Object? isFavorite = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      offers: null == offers
          ? _value.offers
          : offers // ignore: cast_nullable_to_non_nullable
              as List<LoanOffer>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ComparisonSessionImplCopyWith<$Res>
    implements $ComparisonSessionCopyWith<$Res> {
  factory _$$ComparisonSessionImplCopyWith(_$ComparisonSessionImpl value,
          $Res Function(_$ComparisonSessionImpl) then) =
      __$$ComparisonSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      List<LoanOffer> offers,
      DateTime createdAt,
      bool isFavorite});
}

/// @nodoc
class __$$ComparisonSessionImplCopyWithImpl<$Res>
    extends _$ComparisonSessionCopyWithImpl<$Res, _$ComparisonSessionImpl>
    implements _$$ComparisonSessionImplCopyWith<$Res> {
  __$$ComparisonSessionImplCopyWithImpl(
      _$ComparisonSessionImpl _value, $Res Function(_$ComparisonSessionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? offers = null,
    Object? createdAt = null,
    Object? isFavorite = null,
  }) {
    return _then(_$ComparisonSessionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      offers: null == offers
          ? _value.offers
          : offers // ignore: cast_nullable_to_non_nullable
              as List<LoanOffer>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ComparisonSessionImpl implements _ComparisonSession {
  const _$ComparisonSessionImpl(
      {required this.id,
      required this.title,
      required this.offers,
      required this.createdAt,
      this.isFavorite = false});

  factory _$ComparisonSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ComparisonSessionImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final List<LoanOffer> offers;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final bool isFavorite;

  @override
  String toString() {
    return 'ComparisonSession(id: $id, title: $title, offers: $offers, createdAt: $createdAt, isFavorite: $isFavorite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComparisonSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.offers, offers) || other.offers == offers) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
        runtimeType,
        id,
        title,
        offers,
        createdAt,
        isFavorite,
      );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ComparisonSessionImplCopyWith<_$ComparisonSessionImpl> get copyWith =>
      __$$ComparisonSessionImplCopyWithImpl<_$ComparisonSessionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ComparisonSessionImplToJson(
      this,
    );
  }
}

abstract class _ComparisonSession implements ComparisonSession {
  const factory _ComparisonSession(
          {required final String id,
          required final String title,
          required final List<LoanOffer> offers,
          required final DateTime createdAt,
          final bool isFavorite}) = _$ComparisonSessionImpl;

  factory _ComparisonSession.fromJson(Map<String, dynamic> json) =
      _$ComparisonSessionImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  List<LoanOffer> get offers;
  @override
  DateTime get createdAt;
  @override
  bool get isFavorite;
  @override
  @JsonKey(ignore: true)
  _$$ComparisonSessionImplCopyWith<_$ComparisonSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
