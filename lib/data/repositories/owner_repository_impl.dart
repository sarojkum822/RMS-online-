import 'package:drift/drift.dart';
import '../../domain/repositories/i_owner_repository.dart';
import '../../domain/entities/owner.dart';
import '../datasources/local/database.dart' hide Owner;

class OwnerRepositoryImpl implements IOwnerRepository {
  final AppDatabase _db;

  OwnerRepositoryImpl(this._db);

  @override
  Future<Owner?> getOwner() async {
    final query = _db.select(_db.owners)..limit(1);
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return Owner(
      id: row.id,
      name: row.name,
      phone: row.phone,
      email: row.email,
      currency: row.currency,
      timezone: row.timezone,
      createdAt: row.createdAt,
    );
  }

  @override
  Future<void> saveOwner(Owner owner) async {
    // If ID is 0 or -1, insert. Else update.
    // Actually typically there's only one owner.
    final companion = OwnersCompanion(
      name: Value(owner.name),
      phone: Value(owner.phone),
      email: Value(owner.email),
      currency: Value(owner.currency),
      timezone: Value(owner.timezone),
    );
    
    await _db.into(_db.owners).insertOnConflictUpdate(companion);
  }

  @override
  Future<void> updateOwner(Owner owner) async {
    final companion = OwnersCompanion(
      id: Value(owner.id),
      name: Value(owner.name),
      phone: Value(owner.phone),
      email: Value(owner.email),
      currency: Value(owner.currency),
      timezone: Value(owner.timezone),
    );
    await _db.update(_db.owners).replace(companion);
  }
}
