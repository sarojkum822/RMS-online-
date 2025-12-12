// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'house.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HouseImpl _$$HouseImplFromJson(Map<String, dynamic> json) => _$HouseImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      address: json['address'] as String,
      notes: json['notes'] as String?,
      imageUrl: json['imageUrl'] as String?,
      unitCount: (json['unitCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$HouseImplToJson(_$HouseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'notes': instance.notes,
      'imageUrl': instance.imageUrl,
      'unitCount': instance.unitCount,
    };

_$UnitImpl _$$UnitImplFromJson(Map<String, dynamic> json) => _$UnitImpl(
      id: (json['id'] as num).toInt(),
      houseId: (json['houseId'] as num).toInt(),
      nameOrNumber: json['nameOrNumber'] as String,
      floor: (json['floor'] as num?)?.toInt(),
      baseRent: (json['baseRent'] as num).toDouble(),
      defaultDueDay: (json['defaultDueDay'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$UnitImplToJson(_$UnitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'houseId': instance.houseId,
      'nameOrNumber': instance.nameOrNumber,
      'floor': instance.floor,
      'baseRent': instance.baseRent,
      'defaultDueDay': instance.defaultDueDay,
    };
