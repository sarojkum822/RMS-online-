
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/house.dart';
import '../../../providers/data_providers.dart';
import '../../../../domain/entities/tenant.dart'; // Maybe not needed for stats anymore?
import 'package:uuid/uuid.dart'; // Add uuid import 

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
    final houseId = const Uuid().v4();
    final ownerId = 'current_user_id'; // TODO: Get actual OwnerId via Auth or Repository handles it? 
    // Repo usually handles OwnerId injection if not passed.
    // But House entity needs an ID.
    
    final house = House(
      id: houseId, 
      name: name,
      address: address,
      notes: notes,
      imageUrl: imageUrl, 
      imageBase64: imageBase64,
      ownerId: 'placeholder', // Repo will overwrite or we should get it
    );
    // Note: If repo.createHouse takes House, it should probably respect ID if provided or generate if not.
    // My previous repo update for House is pending verification. 
    // Assuming Repo expects String ID now.
    
    await repo.createHouse(house);

    // Auto-create units
    if (totalUnits != null && totalUnits > 0) {
      for (int i = 1; i <= totalUnits; i++) {
        final unit = Unit(
          id: const Uuid().v4(),
          houseId: houseId,
          nameOrNumber: 'Flat $i',
          baseRent: 0.0,
          defaultDueDay: 1,
          ownerId: 'placeholder',
        );
        await repo.createUnit(unit);
      }
    } else {
       final unit = Unit(
        id: const Uuid().v4(),
        houseId: houseId,
        nameOrNumber: 'Main Unit',
        baseRent: 0.0,
        defaultDueDay: 1,
        ownerId: 'placeholder',
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

  Future<void> deleteHouse(String id) async {
     final repo = ref.read(propertyRepositoryProvider);
     await repo.deleteHouse(id);
  }

  Future<void> deleteUnit(String id) async {
     final repo = ref.read(propertyRepositoryProvider);
     await repo.deleteUnit(id);
  }

  Future<void> addUnit(String houseId, String name) async {
     final repo = ref.read(propertyRepositoryProvider);
     final unit = Unit(
       id: const Uuid().v4(),
       houseId: houseId,
       nameOrNumber: name,
       baseRent: 0.0,
       defaultDueDay: 1,
       ownerId: 'placeholder'
     );
     await repo.createUnit(unit);
  }
}

@riverpod
Stream<List<Unit>> houseUnits(HouseUnitsRef ref, String houseId) {
  final repo = ref.watch(propertyRepositoryProvider);
  return repo.getUnits(houseId);
}

@riverpod
Future<List<Unit>> availableUnits(AvailableUnitsRef ref, String houseId) async {
  final repo = ref.watch(propertyRepositoryProvider);
  final units = await repo.getUnits(houseId).first; 
  return units.where((u) => !u.isOccupied).toList();
}

@riverpod
Future<Map<String, dynamic>> houseStats(HouseStatsRef ref, String houseId) async {
  // Stats will update when this provider is invalidated or re-read
  // Just use units!
  final unitsStream = ref.watch(propertyRepositoryProvider).getUnits(houseId);
  final units = await unitsStream.first; 
  
  final activeCount = units.where((u) => u.isOccupied).length;
  
  double occupancy = 0.0;
  if (units.isNotEmpty) {
    occupancy = activeCount / units.length;
  }
  
  return {
    'occupiedCount': activeCount, 
    'occupancyRate': occupancy,
  };
}
