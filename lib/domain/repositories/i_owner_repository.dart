import '../entities/owner.dart';

abstract class IOwnerRepository {
  Future<Owner?> getOwner(); // Single owner for now
  Future<Owner?> getOwnerById(String ownerId); // For tenant-side access
  Future<void> saveOwner(Owner owner);
  Future<void> updateOwner(Owner owner);
  Future<void> deleteOwner(String uid);
}

