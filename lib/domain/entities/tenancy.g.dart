// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenancy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TenancyImpl _$$TenancyImplFromJson(Map<String, dynamic> json) =>
    _$TenancyImpl(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      unitId: json['unitId'] as String,
      ownerId: json['ownerId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      agreedRent: (json['agreedRent'] as num).toDouble(),
      securityDeposit: (json['securityDeposit'] as num?)?.toDouble() ?? 0.0,
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      status: $enumDecode(_$TenancyStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$TenancyImplToJson(_$TenancyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'unitId': instance.unitId,
      'ownerId': instance.ownerId,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'agreedRent': instance.agreedRent,
      'securityDeposit': instance.securityDeposit,
      'openingBalance': instance.openingBalance,
      'status': _$TenancyStatusEnumMap[instance.status]!,
      'notes': instance.notes,
    };

const _$TenancyStatusEnumMap = {
  TenancyStatus.active: 'active',
  TenancyStatus.ended: 'ended',
  TenancyStatus.evicted: 'evicted',
};
