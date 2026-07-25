// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_offer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoanOfferImpl _$$LoanOfferImplFromJson(Map<String, dynamic> json) =>
    _$LoanOfferImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      calculation: EmiCalculation.fromJson(
          json['calculation'] as Map<String, dynamic>),
      color: json['color'] as String?,
    );

Map<String, dynamic> _$$LoanOfferImplToJson(_$LoanOfferImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'calculation': instance.calculation.toJson(),
      'color': instance.color,
    };
