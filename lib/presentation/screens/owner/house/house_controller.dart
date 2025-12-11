import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/house.dart';
import '../../../providers/data_providers.dart';
import '../../../../domain/entities/tenant.dart'; 

part 'house_controller.g.dart';

@riverpod
class HouseController extends _$HouseController {
  @override
  FutureOr<List<House>> build() async {
    final repo = ref.watch(propertyRepositoryProvider);
    return repo.getHouses();
  }

  Future<void> addHouse(String name, String address, String notes, int? totalUnits) async {
    final repo = ref.read(propertyRepositoryProvider);
    final house = House(
      id: 0, 
      name: name,
      address: address,
      notes: notes,
    );
    final houseId = await repo.createHouse(house);

    // Auto-create units
    if (totalUnits != null && totalUnits > 0) {
      for (int i = 1; i <= totalUnits; i++) {
        final unit = Unit(
          id: 0,
          houseId: houseId,
          nameOrNumber: 'Flat $i',
          baseRent: 0.0,
          defaultDueDay: 1,
        );
        await repo.createUnit(unit);
      }
    } else {
      // Default fallback
       final unit = Unit(
        id: 0,
        houseId: houseId,
        nameOrNumber: 'Main Unit',
        baseRent: 0.0,
        defaultDueDay: 1,
      );
      await repo.createUnit(unit);
    }

    ref.invalidateSelf(); 
  }
  
  Future<void> deleteHouse(int id) async {
     final repo = ref.read(propertyRepositoryProvider);
     await repo.deleteHouse(id);
     ref.invalidateSelf();
  }
}

@riverpod
Future<List<Unit>> houseUnits(HouseUnitsRef ref, int houseId) {
  final repo = ref.watch(propertyRepositoryProvider);
  return repo.getUnits(houseId);
}

@riverpod
Future<Map<String, dynamic>> houseStats(HouseStatsRef ref, int houseId) async {
  final allTenants = await ref.watch(tenantRepositoryProvider).getAllTenants();
  final activeTenants = allTenants.where((t) => t.houseId == houseId && t.status == TenantStatus.active).toList();
  
  final units = await ref.watch(propertyRepositoryProvider).getUnits(houseId);
  
  double occupancy = 0.0;
  if (units.isNotEmpty) {
    final occupiedUnitIds = activeTenants.map((t) => t.unitId).toSet();
    occupancy = occupiedUnitIds.length / units.length;
  }
  
  return {
    'occupiedCount': activeTenants.length, 
    'occupancyRate': occupancy,
  };
}
