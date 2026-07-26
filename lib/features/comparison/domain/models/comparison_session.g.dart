// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comparison_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ComparisonSessionImpl _$$ComparisonSessionImplFromJson(
        Map<String, dynamic> json) =>
    _$ComparisonSessionImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      offers: (json['offers'] as List<dynamic>)
          .map((e) => LoanOffer.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );

Map<String, dynamic> _$$ComparisonSessionImplToJson(
        _$ComparisonSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'offers': instance.offers,
      'createdAt': instance.createdAt.toIso8601String(),
      'isFavorite': instance.isFavorite,
    };
