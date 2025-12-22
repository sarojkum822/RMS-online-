import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notice.freezed.dart';
part 'notice.g.dart';

@freezed
class Notice with _$Notice {
  const factory Notice({
    required String id,
    required String ownerId,
    required String houseId, // Still needed for organization/permission
    required String subject,
    required String message,
    required DateTime date,
    @Default([]) List<String> readBy,
    @Default({}) Map<String, DateTime> readAt,
    @Default('medium') String priority,
    @Default('house') String targetType, // all, house, unit
    String? targetId, // houseId or unitId
  }) = _Notice;

  factory Notice.fromJson(Map<String, dynamic> json) => _$NoticeFromJson(json);

  factory Notice.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Fix Timestamp -> String (ISO) for fromJson
    if (data['date'] is Timestamp) {
      data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
    }
    
    // Handle readAt dates if they come as Strings or Timestamps? 
    // Usually Firestore Map stores Timestamps. json_serializable expects Strings for DateTime.
    // We might need deep conversion for valid parsing.
    if (data['readAt'] != null) {
      final map = data['readAt'] as Map<String, dynamic>;
      final newMap = <String, dynamic>{};
      map.forEach((k, v) {
        if (v is Timestamp) {
           newMap[k] = v.toDate().toIso8601String();
        } else {
           newMap[k] = v;
        }
      });
      data['readAt'] = newMap;
    }

    return Notice.fromJson(data).copyWith(id: doc.id);
  }
}
