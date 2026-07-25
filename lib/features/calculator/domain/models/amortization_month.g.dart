// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'amortization_month.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AmortizationMonthImpl _$$AmortizationMonthImplFromJson(
        Map<String, dynamic> json) =>
    _$AmortizationMonthImpl(
      monthNumber: (json['monthNumber'] as num).toInt(),
      openingBalance: (json['openingBalance'] as num).toDouble(),
      emiAmount: (json['emiAmount'] as num).toDouble(),
      principalPaid: (json['principalPaid'] as num).toDouble(),
      interestPaid: (json['interestPaid'] as num).toDouble(),
      closingBalance: (json['closingBalance'] as num).toDouble(),
      totalPaidSoFar: (json['totalPaidSoFar'] as num).toDouble(),
    );

Map<String, dynamic> _$$AmortizationMonthImplToJson(
        _$AmortizationMonthImpl instance) =>
    <String, dynamic>{
      'monthNumber': instance.monthNumber,
      'openingBalance': instance.openingBalance,
      'emiAmount': instance.emiAmount,
      'principalPaid': instance.principalPaid,
      'interestPaid': instance.interestPaid,
      'closingBalance': instance.closingBalance,
      'totalPaidSoFar': instance.totalPaidSoFar,
    };
