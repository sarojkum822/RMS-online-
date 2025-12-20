// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OwnerImpl _$$OwnerImplFromJson(Map<String, dynamic> json) => _$OwnerImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      firestoreId: json['firestoreId'] as String?,
      subscriptionPlan: json['subscriptionPlan'] as String? ?? 'free',
      currency: json['currency'] as String? ?? 'INR',
      timezone: json['timezone'] as String?,
      upiId: json['upiId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$OwnerImplToJson(_$OwnerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'firestoreId': instance.firestoreId,
      'subscriptionPlan': instance.subscriptionPlan,
      'currency': instance.currency,
      'timezone': instance.timezone,
      'upiId': instance.upiId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$ElectricReadingImpl _$$ElectricReadingImplFromJson(
        Map<String, dynamic> json) =>
    _$ElectricReadingImpl(
      id: (json['id'] as num).toInt(),
      unitId: (json['unitId'] as num).toInt(),
      readingDate: DateTime.parse(json['readingDate'] as String),
      meterName: json['meterName'] as String?,
      prevReading: (json['prevReading'] as num?)?.toDouble() ?? 0.0,
      currentReading: (json['currentReading'] as num).toDouble(),
      ratePerUnit: (json['ratePerUnit'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num).toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$ElectricReadingImplToJson(
        _$ElectricReadingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'unitId': instance.unitId,
      'readingDate': instance.readingDate.toIso8601String(),
      'meterName': instance.meterName,
      'prevReading': instance.prevReading,
      'currentReading': instance.currentReading,
      'ratePerUnit': instance.ratePerUnit,
      'amount': instance.amount,
      'notes': instance.notes,
    };
