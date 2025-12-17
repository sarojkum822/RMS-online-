import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rentpilotpro/domain/entities/maintenance_request.dart';
import 'package:rentpilotpro/presentation/providers/data_providers.dart';
import 'package:rentpilotpro/domain/repositories/i_maintenance_repository.dart';

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
    final request = MaintenanceRequest(
      id: '',
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
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
       await repo.submitRequest(request).timeout(const Duration(seconds: 15));
    });
  }

  Future<void> updateStatus(String requestId, MaintenanceStatus status, {double? cost, String? notes}) async {
    final repo = ref.read(maintenanceRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repo.updateStatus(requestId, status, cost: cost, notes: notes));
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
