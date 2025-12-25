// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VerificationDocumentImpl _$$VerificationDocumentImplFromJson(
        Map<String, dynamic> json) =>
    _$VerificationDocumentImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      status:
          $enumDecodeNullable(_$VerificationStatusEnumMap, json['status']) ??
              VerificationStatus.pending,
      referenceNumber: json['referenceNumber'] as String?,
      notes: json['notes'] as String?,
      fileUrl: json['fileUrl'] as String?,
    );

Map<String, dynamic> _$$VerificationDocumentImplToJson(
        _$VerificationDocumentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'status': _$VerificationStatusEnumMap[instance.status]!,
      'referenceNumber': instance.referenceNumber,
      'notes': instance.notes,
      'fileUrl': instance.fileUrl,
    };

const _$VerificationStatusEnumMap = {
  VerificationStatus.pending: 'pending',
  VerificationStatus.verified: 'verified',
  VerificationStatus.rejected: 'rejected',
};
