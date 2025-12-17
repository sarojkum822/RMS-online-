// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rent_cycle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RentCycleImpl _$$RentCycleImplFromJson(Map<String, dynamic> json) =>
    _$RentCycleImpl(
      id: (json['id'] as num).toInt(),
      tenantId: (json['tenantId'] as num).toInt(),
      month: json['month'] as String,
      billNumber: json['billNumber'] as String?,
      billPeriodStart: json['billPeriodStart'] == null
          ? null
          : DateTime.parse(json['billPeriodStart'] as String),
      billPeriodEnd: json['billPeriodEnd'] == null
          ? null
          : DateTime.parse(json['billPeriodEnd'] as String),
      billGeneratedDate: DateTime.parse(json['billGeneratedDate'] as String),
      baseRent: (json['baseRent'] as num).toDouble(),
      electricAmount: (json['electricAmount'] as num?)?.toDouble() ?? 0.0,
      otherCharges: (json['otherCharges'] as num?)?.toDouble() ?? 0.0,
      lateFee: (json['lateFee'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      totalDue: (json['totalDue'] as num).toDouble(),
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
      status: $enumDecodeNullable(_$RentStatusEnumMap, json['status']) ??
          RentStatus.pending,
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$RentCycleImplToJson(_$RentCycleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'month': instance.month,
      'billNumber': instance.billNumber,
      'billPeriodStart': instance.billPeriodStart?.toIso8601String(),
      'billPeriodEnd': instance.billPeriodEnd?.toIso8601String(),
      'billGeneratedDate': instance.billGeneratedDate.toIso8601String(),
      'baseRent': instance.baseRent,
      'electricAmount': instance.electricAmount,
      'otherCharges': instance.otherCharges,
      'lateFee': instance.lateFee,
      'discount': instance.discount,
      'totalDue': instance.totalDue,
      'totalPaid': instance.totalPaid,
      'status': _$RentStatusEnumMap[instance.status]!,
      'dueDate': instance.dueDate?.toIso8601String(),
      'notes': instance.notes,
    };

const _$RentStatusEnumMap = {
  RentStatus.pending: 'pending',
  RentStatus.partial: 'partial',
  RentStatus.paid: 'paid',
  RentStatus.overdue: 'overdue',
};

_$PaymentImpl _$$PaymentImplFromJson(Map<String, dynamic> json) =>
    _$PaymentImpl(
      id: (json['id'] as num).toInt(),
      rentCycleId: (json['rentCycleId'] as num).toInt(),
      tenantId: (json['tenantId'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      method: json['method'] as String,
      channelId: (json['channelId'] as num?)?.toInt(),
      referenceId: json['referenceId'] as String?,
      collectedBy: json['collectedBy'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$PaymentImplToJson(_$PaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rentCycleId': instance.rentCycleId,
      'tenantId': instance.tenantId,
      'amount': instance.amount,
      'date': instance.date.toIso8601String(),
      'method': instance.method,
      'channelId': instance.channelId,
      'referenceId': instance.referenceId,
      'collectedBy': instance.collectedBy,
      'notes': instance.notes,
    };

_$OtherChargeImpl _$$OtherChargeImplFromJson(Map<String, dynamic> json) =>
    _$OtherChargeImpl(
      id: (json['id'] as num).toInt(),
      rentCycleId: (json['rentCycleId'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$OtherChargeImplToJson(_$OtherChargeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rentCycleId': instance.rentCycleId,
      'amount': instance.amount,
      'category': instance.category,
      'notes': instance.notes,
    };

_$PaymentChannelImpl _$$PaymentChannelImplFromJson(Map<String, dynamic> json) =>
    _$PaymentChannelImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      type: json['type'] as String,
      details: json['details'] as String?,
    );

Map<String, dynamic> _$$PaymentChannelImplToJson(
        _$PaymentChannelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'details': instance.details,
    };
