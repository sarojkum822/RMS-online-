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
      imageUrl: json['imageUrl'] as String?,
      imageBase64: json['imageBase64'] as String?,
      authId: json['authId'] as String?,
      advanceAmount: (json['advanceAmount'] as num?)?.toDouble() ?? 0.0,
      policeVerification: json['policeVerification'] as bool? ?? false,
      idProof: json['idProof'] as String?,
      address: json['address'] as String?,
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 1,
      notes: json['notes'] as String?,
      documents: (json['documents'] as List<dynamic>?)
              ?.map((e) =>
                  VerificationDocument.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
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
      'imageUrl': instance.imageUrl,
      'imageBase64': instance.imageBase64,
      'authId': instance.authId,
      'advanceAmount': instance.advanceAmount,
      'policeVerification': instance.policeVerification,
      'idProof': instance.idProof,
      'address': instance.address,
      'dob': instance.dob,
      'gender': instance.gender,
      'memberCount': instance.memberCount,
      'notes': instance.notes,
      'documents': instance.documents,
    };
