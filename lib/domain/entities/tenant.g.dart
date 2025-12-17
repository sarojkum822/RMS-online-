// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TenantImpl _$$TenantImplFromJson(Map<String, dynamic> json) => _$TenantImpl(
      id: json['id'] as String,
      tenantCode: json['tenantCode'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      ownerId: json['ownerId'] as String,
      isActive: json['isActive'] as bool? ?? true,
      password: json['password'] as String?,
      imageUrl: json['imageUrl'] as String?,
      imageBase64: json['imageBase64'] as String?,
      authId: json['authId'] as String?,
    );

Map<String, dynamic> _$$TenantImplToJson(_$TenantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantCode': instance.tenantCode,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'ownerId': instance.ownerId,
      'isActive': instance.isActive,
      'password': instance.password,
      'imageUrl': instance.imageUrl,
      'imageBase64': instance.imageBase64,
      'authId': instance.authId,
    };
