// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NoticeImpl _$$NoticeImplFromJson(Map<String, dynamic> json) => _$NoticeImpl(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      houseId: json['houseId'] as String,
      subject: json['subject'] as String,
      message: json['message'] as String,
      date: DateTime.parse(json['date'] as String),
      readBy: (json['readBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      readAt: (json['readAt'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, DateTime.parse(e as String)),
          ) ??
          const {},
      priority: json['priority'] as String? ?? 'medium',
      targetType: json['targetType'] as String? ?? 'house',
      targetId: json['targetId'] as String?,
    );

Map<String, dynamic> _$$NoticeImplToJson(_$NoticeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerId': instance.ownerId,
      'houseId': instance.houseId,
      'subject': instance.subject,
      'message': instance.message,
      'date': instance.date.toIso8601String(),
      'readBy': instance.readBy,
      'readAt': instance.readAt.map((k, e) => MapEntry(k, e.toIso8601String())),
      'priority': instance.priority,
      'targetType': instance.targetType,
      'targetId': instance.targetId,
    };
