import '../entities/house.dart';
import '../entities/bhk_template.dart';

abstract class IPropertyRepository {
  Stream<List<House>> getHouses();
  Future<House?> getHouse(int id);
  Future<House?> getHouseForTenant(int id, String ownerId); 
  Future<int> createHouse(House house);
  Future<void> updateHouse(House house);
  Future<void> deleteHouse(int id);

  Stream<List<Unit>> getAllUnits(); 
  Stream<List<Unit>> getUnits(int houseId);
  Future<Unit?> getUnit(int id);
  Future<Unit?> getUnitForTenant(int id, String ownerId); 
  Future<int> createUnit(Unit unit);
  Future<void> updateUnit(Unit unit);
  Future<void> updateUnitsBatch(List<Unit> units);
  Future<void> deleteUnit(int id);

  // BHK Templates
  Future<int> createBhkTemplate(BhkTemplate template);
  Future<void> updateBhkTemplate(BhkTemplate template);
  Stream<List<BhkTemplate>> getBhkTemplates(int houseId);
}
