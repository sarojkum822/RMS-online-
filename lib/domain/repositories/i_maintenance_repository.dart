import '../entities/maintenance_request.dart';

abstract class IMaintenanceRepository {
  Future<void> submitRequest(MaintenanceRequest request);
  Stream<List<MaintenanceRequest>> watchRequestsForTenant(String tenantId, String ownerId);
  Stream<List<MaintenanceRequest>> watchRequestsForOwner(String ownerId, {bool pendingOnly = false});
  Future<void> updateStatus(String requestId, MaintenanceStatus status, {double? cost, String? notes});
}
