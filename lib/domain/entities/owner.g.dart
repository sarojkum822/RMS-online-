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
      currency: json['currency'] as String? ?? 'INR',
      timezone: json['timezone'] as String?,
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
      'currency': instance.currency,
      'timezone': instance.timezone,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$ExpenseImpl _$$ExpenseImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseImpl(
      id: (json['id'] as num).toInt(),
      ownerId: (json['ownerId'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$ExpenseImplToJson(_$ExpenseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerId': instance.ownerId,
      'date': instance.date.toIso8601String(),
      'amount': instance.amount,
      'category': instance.category,
      'description': instance.description,
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
