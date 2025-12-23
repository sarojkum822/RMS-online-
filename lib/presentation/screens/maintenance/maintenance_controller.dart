import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kirayabook/domain/entities/maintenance_request.dart';
import 'package:kirayabook/presentation/providers/data_providers.dart';

part 'maintenance_controller.g.dart';

@riverpod
class MaintenanceController extends _$MaintenanceController {
  @override
  FutureOr<void> build() {}

  Future<void> submitRequest({
    required String ownerId,
    required String houseId,
    required String unitId,
    required String tenantId,
    required String category,
    required String description,
    String? photoUrl,
  }) async {
    final repo = ref.read(maintenanceRepositoryProvider);
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final request = MaintenanceRequest(
        id: '', // To be filled by repo if possible or just left for Firestore
        ownerId: ownerId,
        pId: houseId,
        unitId: unitId,
        tenantId: tenantId,
        category: category,
        description: description,
        photoUrl: photoUrl,
        date: DateTime.now(),
        status: MaintenanceStatus.pending,
      );

      await repo.submitRequest(request);
      
      // Trigger Push Notification for Owner
      // 1. Owner Notification (FCM) removed as per user request
    });
  }

  Future<void> updateStatus(String requestId, String ownerId, MaintenanceStatus status, {double? cost, String? notes}) async {
    final repo = ref.read(maintenanceRepositoryProvider);
    // We don't set state to loading here to avoid jerky UI in the list
    final result = await AsyncValue.guard(() async {
       await repo.updateStatus(requestId, ownerId, status, cost: cost, notes: notes);
       
       // Trigger Push Notification for Tenant
       // 2. Tenant Notification (FCM) removed as per user request
    });
    
    if (result.hasError) {
      state = result;
    }
  }

  Future<void> deleteRequest(String requestId, String ownerId) async {
    final repo = ref.read(maintenanceRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repo.deleteRequest(requestId, ownerId));
  }
}

final tenantMaintenanceProvider = StreamProvider.family<List<MaintenanceRequest>, ({String tenantId, String ownerId})>((ref, arg) {
  final repo = ref.watch(maintenanceRepositoryProvider);
  return repo.watchRequestsForTenant(arg.tenantId, arg.ownerId);
});

final ownerMaintenanceProvider = StreamProvider.family<List<MaintenanceRequest>, String>((ref, ownerId) {
  final repo = ref.watch(maintenanceRepositoryProvider);
  return repo.watchRequestsForOwner(ownerId);
});
