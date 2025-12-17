
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/house.dart';
import '../../../providers/data_providers.dart';
import '../../../../domain/entities/tenant.dart'; 

part 'house_controller.g.dart';

@riverpod
class HouseController extends _$HouseController {
  @override
  Stream<List<House>> build() {
    final repo = ref.watch(propertyRepositoryProvider);
    return repo.getHouses();
  }

  Future<void> addHouse(String name, String address, String notes, int? totalUnits, {String? imageUrl, String? imageBase64}) async {
    final repo = ref.read(propertyRepositoryProvider);
    final house = House(
      id: 0, 
      name: name,
      address: address,
      notes: notes,
      imageUrl: imageUrl, 
      imageBase64: imageBase64,
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
       final unit = Unit(
        id: 0,
        houseId: houseId,
        nameOrNumber: 'Main Unit',
        baseRent: 0.0,
        defaultDueDay: 1,
      );
      await repo.createUnit(unit);
    }
  }

  Future<void> updateHouse(House house) async {
    final repo = ref.read(propertyRepositoryProvider);
    await repo.updateHouse(house);
  }
  
  Future<void> bulkUpdateUnits(List<Unit> units) async {
     final repo = ref.read(propertyRepositoryProvider);
     await repo.updateUnitsBatch(units);
  }

  Future<void> deleteHouse(int id) async {
     final repo = ref.read(propertyRepositoryProvider);
     await repo.deleteHouse(id);
  }

  Future<void> deleteUnit(int id) async {
     final repo = ref.read(propertyRepositoryProvider);
     await repo.deleteUnit(id);
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
  }
}

@riverpod
Stream<List<Unit>> houseUnits(HouseUnitsRef ref, int houseId) {
  final repo = ref.watch(propertyRepositoryProvider);
  return repo.getUnits(houseId);
}

@riverpod
Future<List<Unit>> availableUnits(AvailableUnitsRef ref, int houseId) async {
  final repo = ref.watch(propertyRepositoryProvider);
  final units = await repo.getUnits(houseId).first; 
  return units.where((u) => !u.isOccupied).toList();
}

@riverpod
Future<Map<String, dynamic>> houseStats(HouseStatsRef ref, int houseId) async {
  // Stats will update when this provider is invalidated or re-read
  final allTenantsStream = ref.watch(tenantRepositoryProvider).getAllTenants();
  final allTenants = await allTenantsStream.first;
  
  // Wait for units stream
  final unitsStream = ref.watch(propertyRepositoryProvider).getUnits(houseId);
  final units = await unitsStream.first; 
  
  final activeTenants = allTenants.where((t) => t.houseId == houseId && t.status == TenantStatus.active).toList();
  
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
