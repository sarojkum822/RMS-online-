// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TenantImpl _$$TenantImplFromJson(Map<String, dynamic> json) => _$TenantImpl(
      id: (json['id'] as num).toInt(),
      houseId: (json['houseId'] as num).toInt(),
      unitId: (json['unitId'] as num).toInt(),
      tenantCode: json['tenantCode'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      status: $enumDecode(_$TenantStatusEnumMap, json['status']),
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      agreedRent: (json['agreedRent'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$TenantImplToJson(_$TenantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'houseId': instance.houseId,
      'unitId': instance.unitId,
      'tenantCode': instance.tenantCode,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'startDate': instance.startDate.toIso8601String(),
      'status': _$TenantStatusEnumMap[instance.status]!,
      'openingBalance': instance.openingBalance,
      'agreedRent': instance.agreedRent,
    };

const _$TenantStatusEnumMap = {
  TenantStatus.active: 'active',
  TenantStatus.inactive: 'inactive',
};
