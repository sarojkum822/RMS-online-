
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/house.dart';
import '../../../providers/data_providers.dart';
import 'package:uuid/uuid.dart';

part 'house_controller.g.dart';

@riverpod
class HouseController extends _$HouseController {
  /// Get current authenticated user's ID or throw if not logged in
  String get _currentUserId {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not authenticated. Please log in again.');
    }
    return uid;
  }

  @override
  Stream<List<House>> build() {
    final repo = ref.watch(propertyRepositoryProvider);
    return repo.getHouses();
  }

  Future<void> addHouse(String name, String address, String notes, int? totalUnits, {String? imageUrl, String? imageBase64, String propertyType = 'Apartment'}) async {
    final repo = ref.read(propertyRepositoryProvider);
    final houseId = const Uuid().v4();
    final ownerId = _currentUserId; // Get actual authenticated user ID
    
    final house = House(
      id: houseId, 
      name: name,
      address: address,
      notes: notes,
      imageUrl: imageUrl, 
      imageBase64: imageBase64,
      propertyType: propertyType,
      ownerId: ownerId,
    );
    
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
          ownerId: ownerId,
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
        ownerId: ownerId,
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

  Future<void> addUnit(String houseId, String name, {
     double? baseRent,
     String? bhkTemplateId,
     String? bhkType,
     String? imageBase64,
     String? furnishingStatus,
     double? carpetArea,
     String? parkingSlot,
     String? meterNumber,
  }) async {
     final repo = ref.read(propertyRepositoryProvider);
     final unit = Unit(
       id: const Uuid().v4(),
       houseId: houseId,
       nameOrNumber: name,
       baseRent: baseRent ?? 0.0,
       defaultDueDay: 1,
       ownerId: _currentUserId,
       bhkTemplateId: bhkTemplateId,
       bhkType: bhkType,
       imagesBase64: imageBase64 != null ? [imageBase64] : const [],
       furnishingStatus: furnishingStatus,
       carpetArea: carpetArea,
       parkingSlot: parkingSlot,
       meterNumber: meterNumber,
     );
     await repo.createUnit(unit);
  }

  Future<void> addUnitsBulk({
    required String houseId, 
    required int count,
    required int startNumber, 
    String prefix = 'Flat',
    double? baseRent,
    String? bhkTemplateId,
    String? bhkType,
    String? imageBase64, // Single image for all units
  }) async {
     final repo = ref.read(propertyRepositoryProvider);
     
     for (int i = 0; i < count; i++) {
        final number = startNumber + i;
        final name = '$prefix $number';
        final unit = Unit(
          id: const Uuid().v4(),
          houseId: houseId,
          nameOrNumber: name,
          baseRent: baseRent ?? 0.0,
          defaultDueDay: 1,
          ownerId: _currentUserId,
          bhkTemplateId: bhkTemplateId,
          bhkType: bhkType,
          imagesBase64: imageBase64 != null ? [imageBase64] : const [],
        );
        await repo.createUnit(unit);
     }
  }

  /// Generate units with floor-wise naming scheme
  /// Example: floors=2, unitsPerFloor=3 produces: 101, 102, 103, 201, 202, 203
  Future<void> addUnitsFloorWise({
    required String houseId,
    required int floors,
    required int unitsPerFloor,
    double? baseRent,
    String? bhkTemplateId,
    String? bhkType,
    String? imageBase64, // Single image for all units
  }) async {
    final repo = ref.read(propertyRepositoryProvider);
    
    for (int floor = 1; floor <= floors; floor++) {
      for (int unitNum = 1; unitNum <= unitsPerFloor; unitNum++) {
        // Generate name like 101, 102, 201, 202
        final name = '$floor${unitNum.toString().padLeft(2, '0')}';
        
        final unit = Unit(
          id: const Uuid().v4(),
          houseId: houseId,
          nameOrNumber: name,
          baseRent: baseRent ?? 0.0,
          defaultDueDay: 1,
          ownerId: _currentUserId,
          bhkTemplateId: bhkTemplateId,
          bhkType: bhkType,
          imagesBase64: imageBase64 != null ? [imageBase64] : const [],
        );
        await repo.createUnit(unit);
      }
    }
  }

  Future<void> duplicateUnit(Unit unit, {String? newName}) async {
    final repo = ref.read(propertyRepositoryProvider);
    
    // Use provided name or default to " (Copy)"
    final String actualName = newName ?? '${unit.nameOrNumber} (Copy)';
    
    final duplicatedUnit = unit.copyWith(
      id: const Uuid().v4(),
      nameOrNumber: actualName,
      isOccupied: false,
      currentTenancyId: null,
      imagesBase64: List.from(unit.imagesBase64 ?? []),
    );
    
    await repo.createUnit(duplicatedUnit);
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
