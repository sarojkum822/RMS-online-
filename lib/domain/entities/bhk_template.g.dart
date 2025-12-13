// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bhk_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BhkTemplateImpl _$$BhkTemplateImplFromJson(Map<String, dynamic> json) =>
    _$BhkTemplateImpl(
      id: (json['id'] as num).toInt(),
      houseId: (json['houseId'] as num).toInt(),
      bhkType: json['bhkType'] as String,
      defaultRent: (json['defaultRent'] as num).toDouble(),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$BhkTemplateImplToJson(_$BhkTemplateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'houseId': instance.houseId,
      'bhkType': instance.bhkType,
      'defaultRent': instance.defaultRent,
      'description': instance.description,
    };
