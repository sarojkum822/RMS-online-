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

  Future<void> updateHouse(House house) async {
    final repo = ref.read(propertyRepositoryProvider);
    await repo.updateHouse(house);
    ref.invalidateSelf();
  }
  
  Future<void> bulkUpdateUnits(List<Unit> units) async {
     final repo = ref.read(propertyRepositoryProvider);
     await repo.updateUnitsBatch(units);
     // We need to invalidate the specific houseUnits provider. 
     // Since we don't know houseId easily here without passing it or checking units:
     if (units.isNotEmpty) {
       ref.invalidate(houseUnitsProvider(units.first.houseId));
     }
  }

  Future<void> deleteHouse(int id) async {
     final repo = ref.read(propertyRepositoryProvider);
     await repo.deleteHouse(id);
     ref.invalidateSelf();
  }

  Future<void> deleteUnit(int id) async {
     final repo = ref.read(propertyRepositoryProvider);
     await repo.deleteUnit(id);
     ref.invalidate(houseUnitsProvider); 
     // We don't necessarily need to invalidate 'build' (houses list) unless unit count is shown there dynamically and not via separate provider.
     // But wait, HouseListScreen shows occupancy stats which depends on units. So we might need to invalidate houseStats.
     // houseStats is a family provider. We can't invalidate all. 
     // But houseUnitsProvider is what HouseDetailScreen watches.
  }

  Future<void> addUnit(int houseId, String name) async {
     final repo = ref.read(propertyRepositoryProvider);
     final unit = Unit(
       id: 0,
       houseId: houseId,
       nameOrNumber: name,
       baseRent: 0.0,
       defaultDueDay: 1,
     );
     await repo.createUnit(unit);
     ref.invalidate(houseUnitsProvider(houseId));
  }
}

@riverpod
Future<List<Unit>> houseUnits(HouseUnitsRef ref, int houseId) {
  final repo = ref.watch(propertyRepositoryProvider);
  return repo.getUnits(houseId);
}

@riverpod
Future<List<Unit>> availableUnits(AvailableUnitsRef ref, int houseId) async {
  final repo = ref.watch(propertyRepositoryProvider);
  final units = await repo.getUnits(houseId);
  return units.where((u) => !u.isOccupied).toList();
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
