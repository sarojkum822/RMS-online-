import '../entities/tenant.dart';

abstract class ITenantRepository {
  Future<List<Tenant>> getAllTenants();
  Future<Tenant?> getTenant(int id);
  Future<Tenant?> getTenantByCode(String code);
  Future<int> createTenant(Tenant tenant);
  Future<void> updateTenant(Tenant tenant);
}
