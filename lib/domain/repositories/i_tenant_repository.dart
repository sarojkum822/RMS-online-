import 'dart:io';
import '../entities/tenant.dart';
import '../entities/tenancy.dart';

abstract class ITenantRepository {
  Stream<List<Tenant>> getAllTenants(); 
  Future<Tenant?> getTenant(String id);
  Future<Tenant?> getTenantByCode(String code);
  Future<Tenant?> getTenantByAuthId(String authId);
  Future<String> createTenant(Tenant tenant, {File? imageFile});
  Future<void> updateTenant(Tenant tenant, {File? imageFile});
  Future<void> deleteTenant(String id);
  Future<Tenant?> authenticateTenant(String email, String password);
  
  // NEW: Tenancy Management
  Future<String> createTenancy(Tenancy tenancy);
  Future<void> endTenancy(String tenancyId);
}
