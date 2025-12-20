import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/maintenance_request.dart';
import '../../domain/repositories/i_maintenance_repository.dart';
import '../../core/constants/firebase_collections.dart'; // Import Constants

class MaintenanceRepositoryImpl implements IMaintenanceRepository {
  final FirebaseFirestore _firestore;

  MaintenanceRepositoryImpl(this._firestore);

  @override
  Future<void> submitRequest(MaintenanceRequest request) async {
    await _firestore.collection(FirebaseCollections.tickets).add({
      ...request.toJson(),
      'date': Timestamp.fromDate(request.date),
    });
  }

  @override
  Stream<List<MaintenanceRequest>> watchRequestsForTenant(String tenantId, String ownerId) {
    return _firestore
        .collection(FirebaseCollections.tickets)
        .where('ownerId', isEqualTo: ownerId)
        .where('tenantId', isEqualTo: tenantId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MaintenanceRequest.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<MaintenanceRequest>> watchRequestsForOwner(String ownerId, {bool pendingOnly = false}) {
    Query query = _firestore
        .collection(FirebaseCollections.tickets)
        .where('ownerId', isEqualTo: ownerId);
        
    if (pendingOnly) {
      query = query.where('status', whereIn: ['pending', 'inProgress']);
    }
    
    // orderBy 'date' requires index if pendingOnly is used with equality filter on status? 
    // Actually 'status' is inequality/in logic so it might need index.
    // For now we sort in memory to avoid index errors blocking the user immediately.
    
    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => MaintenanceRequest.fromFirestore(doc)).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  @override
  Future<void> updateStatus(String requestId, String ownerId, MaintenanceStatus status, {double? cost, String? notes}) async {
    final data = <String, dynamic>{
      'status': status.name,
    };
    if (cost != null) data['cost'] = cost;
    if (notes != null) data['resolutionNotes'] = notes;
    
    // Explicitly filter by ownerId
    final snapshot = await _firestore
        .collection(FirebaseCollections.tickets)
        .where(FieldPath.documentId, isEqualTo: requestId)
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update(data);
    }
  }

  @override
  Future<void> deleteRequest(String requestId, String ownerId) async {
    final snapshot = await _firestore
        .collection(FirebaseCollections.tickets)
        .where(FieldPath.documentId, isEqualTo: requestId)
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.delete();
    }
  }
}
