import 'package:drift/drift.dart';
import '../../core/error/exception.dart';
import '../../domain/entities/tenant.dart' as domain;
import '../../domain/repositories/i_tenant_repository.dart';
import '../datasources/local/database.dart'; 

class TenantRepositoryImpl implements ITenantRepository {
  final AppDatabase _db;

  TenantRepositoryImpl(this._db);

  @override
  Future<List<domain.Tenant>> getAllTenants() async {
    final tenants = await _db.select(_db.tenants).get();
    return tenants.map((t) => _mapToDomain(t)).toList();
  }

  @override
  Future<domain.Tenant?> getTenant(int id) async {
    final t = await (_db.select(_db.tenants)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    return t != null ? _mapToDomain(t) : null;
  }

  @override
  Future<domain.Tenant?> getTenantByCode(String code) async {
    final t = await (_db.select(_db.tenants)..where((tbl) => tbl.tenantCode.equals(code))).getSingleOrNull();
    return t != null ? _mapToDomain(t) : null;
  }

  @override
  Future<int> createTenant(domain.Tenant tenant) {
    return _db.into(_db.tenants).insert(TenantsCompanion(
      houseId: Value(tenant.houseId),
      unitId: Value(tenant.unitId),
      tenantCode: Value(tenant.tenantCode),
      name: Value(tenant.name),
      phone: Value(tenant.phone),
      email: Value(tenant.email),
      startDate: Value(tenant.startDate),
      isActive: Value(tenant.status == domain.TenantStatus.active),
      agreedRent: Value(tenant.agreedRent), // NEW
    ));
  }

  @override
  Future<void> updateTenant(domain.Tenant tenant) {
    return (_db.update(_db.tenants)..where((tbl) => tbl.id.equals(tenant.id))).write(TenantsCompanion(
       name: Value(tenant.name),
       phone: Value(tenant.phone),
       email: Value(tenant.email),
       isActive: Value(tenant.status == domain.TenantStatus.active),
       agreedRent: Value(tenant.agreedRent), // NEW
    ));
  }

  domain.Tenant _mapToDomain(Tenant t) {
    return domain.Tenant(
      id: t.id,
      houseId: t.houseId,
      unitId: t.unitId,
      tenantCode: t.tenantCode,
      name: t.name,
      phone: t.phone,
      email: t.email,
      startDate: t.startDate,
      status: t.isActive ? domain.TenantStatus.active : domain.TenantStatus.inactive,
      openingBalance: t.openingBalance,
      agreedRent: t.agreedRent, // NEW
    );
  }
}
