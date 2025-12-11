import 'package:drift/drift.dart';
import '../../core/error/exception.dart';
import '../../domain/entities/house.dart' as domain; // Prefix Domain
import '../../domain/repositories/i_property_repository.dart';
import '../datasources/local/database.dart'; // Drift database exports House/Unit too

// Use 'domain.House' for Domain entity
// Use 'House' or 'Unit' (from database.dart) for Data classes

class PropertyRepositoryImpl implements IPropertyRepository {
  final AppDatabase _db;

  PropertyRepositoryImpl(this._db);

  @override
  Future<List<domain.House>> getHouses() async {
    final driftHouses = await _db.select(_db.houses).get();
    return driftHouses.map((h) => domain.House(
      id: h.id,
      name: h.name,
      address: h.address,
      notes: h.notes,
      unitCount: 0,
    )).toList();
  }

  @override
  Future<domain.House?> getHouse(int id) async {
    final house = await (_db.select(_db.houses)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (house == null) return null;
    return domain.House(
      id: house.id,
      name: house.name,
      address: house.address,
      notes: house.notes,
    );
  }

  @override
  Future<int> createHouse(domain.House house) {
    return _db.into(_db.houses).insert(HousesCompanion(
      name: Value(house.name),
      address: Value(house.address),
      notes: Value(house.notes),
      ownerId: const Value(1),
    ));
  }

  @override
  Future<void> updateHouse(domain.House house) {
    return (_db.update(_db.houses)..where((tbl) => tbl.id.equals(house.id))).write(HousesCompanion(
      name: Value(house.name),
      address: Value(house.address),
      notes: Value(house.notes),
    ));
  }

  @override
  Future<void> deleteHouse(int id) {
    return (_db.delete(_db.houses)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Units
  @override
  Future<List<domain.Unit>> getAllUnits() async {
    final query = _db.select(_db.units);
    final rows = await query.get();
    return rows.map((row) => domain.Unit(
      id: row.id,
      houseId: row.houseId,
      nameOrNumber: row.nameOrNumber,
      floor: row.floor,
      baseRent: row.baseRent,
      defaultDueDay: row.defaultDueDay,
    )).toList();
  }

  @override
  Future<List<domain.Unit>> getUnits(int houseId) async {
    final units = await (_db.select(_db.units)..where((tbl) => tbl.houseId.equals(houseId))).get();
    return units.map((u) => domain.Unit(
      id: u.id,
      houseId: u.houseId,
      nameOrNumber: u.nameOrNumber,
      floor: u.floor,
      baseRent: u.baseRent,
      defaultDueDay: u.defaultDueDay,
    )).toList();
  }

  @override
  Future<domain.Unit?> getUnit(int id) async {
    final u = await (_db.select(_db.units)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (u == null) return null;
    return domain.Unit(
      id: u.id,
      houseId: u.houseId,
      nameOrNumber: u.nameOrNumber,
      floor: u.floor,
      baseRent: u.baseRent,
      defaultDueDay: u.defaultDueDay,
    );
  }

  @override
  Future<int> createUnit(domain.Unit unit) {
    return _db.into(_db.units).insert(UnitsCompanion(
      houseId: Value(unit.houseId),
      nameOrNumber: Value(unit.nameOrNumber),
      floor: Value(unit.floor),
      baseRent: Value(unit.baseRent),
      defaultDueDay: Value(unit.defaultDueDay),
    ));
  }

  @override
  Future<void> updateUnit(domain.Unit unit) {
    return (_db.update(_db.units)..where((tbl) => tbl.id.equals(unit.id))).write(UnitsCompanion(
      nameOrNumber: Value(unit.nameOrNumber),
      floor: Value(unit.floor),
      baseRent: Value(unit.baseRent),
      defaultDueDay: Value(unit.defaultDueDay),
    ));
  }

  @override
  Future<void> deleteUnit(int id) {
    return (_db.delete(_db.units)..where((tbl) => tbl.id.equals(id))).go();
  }
}
