import 'dart:io';
import '../entities/tenant.dart';

abstract class ITenantRepository {
  Stream<List<Tenant>> getAllTenants(); 
  Future<Tenant?> getTenant(int id);
  Future<Tenant?> getTenantByCode(String code);
  Future<Tenant?> getTenantByAuthId(String authId);
  Future<int> createTenant(Tenant tenant, {File? imageFile});
  Future<void> updateTenant(Tenant tenant, {File? imageFile});
  Future<void> deleteTenant(int id);
  Future<Tenant?> authenticateTenant(String email, String password);
}
