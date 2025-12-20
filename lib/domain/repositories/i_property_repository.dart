import '../entities/house.dart';
import '../entities/bhk_template.dart';

abstract class IPropertyRepository {
  Stream<List<House>> getHouses();
  Future<House?> getHouse(String id);
  Future<House?> getHouseForTenant(String id, String ownerId); 
  Future<String> createHouse(House house);
  Future<void> updateHouse(House house);
  Future<void> deleteHouse(String id);

  Stream<List<Unit>> getAllUnits(); 
  Stream<List<Unit>> getUnits(String houseId);
  Future<Unit?> getUnit(String id);
  Future<Unit?> getUnitForTenant(String id, String ownerId); 
  Future<String> createUnit(Unit unit);
  Future<void> updateUnit(Unit unit);
  Future<void> updateUnitsBatch(List<Unit> units);
  Future<void> deleteUnit(String id);

  // BHK Templates
  Future<String> createBhkTemplate(BhkTemplate template);
  Future<void> updateBhkTemplate(BhkTemplate template);
  Stream<List<BhkTemplate>> getBhkTemplates(String houseId);
}
