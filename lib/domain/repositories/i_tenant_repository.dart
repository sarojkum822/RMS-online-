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
  Future<Tenant?> getTenantByEmail(String email); // NEW
  Future<void> deleteTenantCascade(String tenantId, String? unitId);
  
  // NEW: Tenancy Management
  Stream<List<Tenancy>> getAllTenancies();
  Future<String> createTenancy(Tenancy tenancy);

  Future<void> endTenancy(String tenancyId);
  Future<Tenancy?> getActiveTenancyForTenant(String tenantId);
  Stream<Tenancy?> watchActiveTenancyForTenant(String tenantId); // For owner-side
  Stream<Tenancy?> watchActiveTenancyForTenantAccess(String tenantId, String ownerId); // For tenant-side (uses ownerId)
  Future<Tenancy?> getTenancy(String tenancyId);
  Future<Tenancy?> getTenancyForAccess(String tenancyId, String ownerId); // For tenant-side
  Future<bool> isEmailRegistered(String email);
  Future<bool> isPhoneRegistered(String phone);
}

