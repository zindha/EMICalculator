// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emi_calculation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EmiCalculationImpl _$$EmiCalculationImplFromJson(Map<String, dynamic> json) =>
    _$EmiCalculationImpl(
      loanAmount: (json['loanAmount'] as num).toDouble(),
      interestRate: (json['interestRate'] as num).toDouble(),
      tenureMonths: (json['tenureMonths'] as num).toInt(),
      processingFee: (json['processingFee'] as num?)?.toDouble() ?? 0.0,
      insurance: (json['insurance'] as num?)?.toDouble() ?? 0.0,
      downPayment: (json['downPayment'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$EmiCalculationImplToJson(
        _$EmiCalculationImpl instance) =>
    <String, dynamic>{
      'loanAmount': instance.loanAmount,
      'interestRate': instance.interestRate,
      'tenureMonths': instance.tenureMonths,
      'processingFee': instance.processingFee,
      'insurance': instance.insurance,
      'downPayment': instance.downPayment,
    };
