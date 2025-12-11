import '../entities/house.dart';
// Unit is in house.dart

abstract class IPropertyRepository {
  Future<List<House>> getHouses();
  Future<House?> getHouse(int id);
  Future<int> createHouse(House house);
  Future<void> updateHouse(House house);
  Future<void> deleteHouse(int id);

  Future<List<Unit>> getAllUnits(); // NEW
  Future<List<Unit>> getUnits(int houseId);
  Future<Unit?> getUnit(int id);
  Future<int> createUnit(Unit unit);
  Future<void> updateUnit(Unit unit);
  Future<void> deleteUnit(int id);
}
