import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'maintenance_request.freezed.dart';
part 'maintenance_request.g.dart';

enum MaintenanceStatus {
  pending,
  inProgress,
  completed,
  rejected
}

@freezed
class MaintenanceRequest with _$MaintenanceRequest {
  const factory MaintenanceRequest({
    required String id,
    required String ownerId,
    required String pId, // Property ID
    required String unitId,
    required String tenantId,
    required String category, // Plumbing, Electrical, etc.
    required String description,
    String? photoUrl,
    required DateTime date,
    required MaintenanceStatus status,
    double? cost, // Optional cost tracking
    String? resolutionNotes,
  }) = _MaintenanceRequest;

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) => _$MaintenanceRequestFromJson(json);

  factory MaintenanceRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Create a mutable copy to modify parameters
    final mutableData = Map<String, dynamic>.from(data);
    
    if (mutableData['date'] is Timestamp) {
      mutableData['date'] = (mutableData['date'] as Timestamp).toDate().toIso8601String();
    }
    
    return MaintenanceRequest.fromJson(mutableData).copyWith(id: doc.id);
  }
}
