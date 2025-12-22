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
    try {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final mutableData = Map<String, dynamic>.from(data);
      
      // Handle the 'date' field converting from Timestamp/DateTime to String for JSON
      if (mutableData['date'] is Timestamp) {
        mutableData['date'] = (mutableData['date'] as Timestamp).toDate().toIso8601String();
      } else if (mutableData['date'] == null) {
        mutableData['date'] = DateTime.now().toIso8601String(); // Fallback to now
      }
      
      return MaintenanceRequest.fromJson(mutableData).copyWith(id: doc.id);
    } catch (e) {
      print('Error parsing MaintenanceRequest ${doc.id}: $e');
      // Return a dummy/empty request or rethrow?
      // Better to rethrow so it shows in AsyncError during development
      rethrow;
    }
  }
}
