// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MaintenanceRequestImpl _$$MaintenanceRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$MaintenanceRequestImpl(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      pId: json['pId'] as String,
      unitId: json['unitId'] as String,
      tenantId: json['tenantId'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      photoUrl: json['photoUrl'] as String?,
      date: DateTime.parse(json['date'] as String),
      status: $enumDecode(_$MaintenanceStatusEnumMap, json['status']),
      cost: (json['cost'] as num?)?.toDouble(),
      resolutionNotes: json['resolutionNotes'] as String?,
    );

Map<String, dynamic> _$$MaintenanceRequestImplToJson(
        _$MaintenanceRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerId': instance.ownerId,
      'pId': instance.pId,
      'unitId': instance.unitId,
      'tenantId': instance.tenantId,
      'category': instance.category,
      'description': instance.description,
      'photoUrl': instance.photoUrl,
      'date': instance.date.toIso8601String(),
      'status': _$MaintenanceStatusEnumMap[instance.status]!,
      'cost': instance.cost,
      'resolutionNotes': instance.resolutionNotes,
    };

const _$MaintenanceStatusEnumMap = {
  MaintenanceStatus.pending: 'pending',
  MaintenanceStatus.inProgress: 'inProgress',
  MaintenanceStatus.completed: 'completed',
  MaintenanceStatus.rejected: 'rejected',
};
