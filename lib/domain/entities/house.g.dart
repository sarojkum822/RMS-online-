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
      imageBase64: json['imageBase64'] as String?,
      unitCount: (json['unitCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$HouseImplToJson(_$HouseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'notes': instance.notes,
      'imageUrl': instance.imageUrl,
      'imageBase64': instance.imageBase64,
      'unitCount': instance.unitCount,
    };

_$UnitImpl _$$UnitImplFromJson(Map<String, dynamic> json) => _$UnitImpl(
      id: (json['id'] as num).toInt(),
      houseId: (json['houseId'] as num).toInt(),
      nameOrNumber: json['nameOrNumber'] as String,
      floor: (json['floor'] as num?)?.toInt(),
      baseRent: (json['baseRent'] as num).toDouble(),
      bhkTemplateId: (json['bhkTemplateId'] as num?)?.toInt(),
      bhkType: json['bhkType'] as String?,
      editableRent: (json['editableRent'] as num?)?.toDouble(),
      tenantId: (json['tenantId'] as num?)?.toInt(),
      furnishingStatus: json['furnishingStatus'] as String?,
      carpetArea: (json['carpetArea'] as num?)?.toDouble(),
      parkingSlot: json['parkingSlot'] as String?,
      meterNumber: json['meterNumber'] as String?,
      defaultDueDay: (json['defaultDueDay'] as num?)?.toInt() ?? 1,
      isOccupied: json['isOccupied'] as bool? ?? false,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      imagesBase64: (json['imagesBase64'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$UnitImplToJson(_$UnitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'houseId': instance.houseId,
      'nameOrNumber': instance.nameOrNumber,
      'floor': instance.floor,
      'baseRent': instance.baseRent,
      'bhkTemplateId': instance.bhkTemplateId,
      'bhkType': instance.bhkType,
      'editableRent': instance.editableRent,
      'tenantId': instance.tenantId,
      'furnishingStatus': instance.furnishingStatus,
      'carpetArea': instance.carpetArea,
      'parkingSlot': instance.parkingSlot,
      'meterNumber': instance.meterNumber,
      'defaultDueDay': instance.defaultDueDay,
      'isOccupied': instance.isOccupied,
      'imageUrls': instance.imageUrls,
      'imagesBase64': instance.imagesBase64,
    };
