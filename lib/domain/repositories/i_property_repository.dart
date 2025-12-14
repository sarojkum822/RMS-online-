// Need File type
import '../entities/house.dart';
// Unit is in house.dart

import '../entities/bhk_template.dart';

abstract class IPropertyRepository {
  Future<List<House>> getHouses();
  Future<House?> getHouse(int id);
  Future<House?> getHouseForTenant(int id, String ownerId); // NEW
  Future<int> createHouse(House house);
  Future<void> updateHouse(House house);
  Future<void> deleteHouse(int id);

  Future<List<Unit>> getAllUnits(); 
  Future<List<Unit>> getUnits(int houseId);
  Future<Unit?> getUnit(int id);
  Future<Unit?> getUnitForTenant(int id, String ownerId); // NEW
  Future<int> createUnit(Unit unit);
  Future<void> updateUnit(Unit unit);
  Future<void> updateUnitsBatch(List<Unit> units);
  Future<void> deleteUnit(int id);

  // BHK Templates
  Future<int> createBhkTemplate(BhkTemplate template);
  Future<List<BhkTemplate>> getBhkTemplates(int houseId);
}
