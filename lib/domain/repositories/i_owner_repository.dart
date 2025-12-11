import '../entities/owner.dart';

abstract class IOwnerRepository {
  Future<Owner?> getOwner(); // Single owner for now
  Future<void> saveOwner(Owner owner);
  Future<void> updateOwner(Owner owner);
}
