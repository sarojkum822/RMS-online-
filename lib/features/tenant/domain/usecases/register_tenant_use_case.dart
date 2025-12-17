import '../../../../domain/entities/tenant.dart';
import '../../../../domain/repositories/i_tenant_repository.dart';
import '../../../../domain/repositories/i_property_repository.dart';
import '../../../../domain/entities/house.dart';

class RegisterTenantUseCase {
  final ITenantRepository _tenantRepository;
  final IPropertyRepository _propertyRepository;

  RegisterTenantUseCase(this._tenantRepository, this._propertyRepository);

  /// Registers a new tenant and updates the unit status.
  Future<void> execute(Tenant tenant, {dynamic imageFile}) async {
    // 1. Create Tenant
    final newTenantId = await _tenantRepository.createTenant(tenant, imageFile: imageFile);
    
    // 2. Lock Unit & Update Rent
    final unit = await _propertyRepository.getUnit(tenant.unitId);
    if (unit != null) {
      final rentToLock = tenant.agreedRent ?? unit.baseRent;
      
      final updatedUnit = unit.copyWith(
        isOccupied: true,
        tenantId: newTenantId,
        editableRent: rentToLock,
        // baseRent might be permanent property of unit, but editableRent is for this tenancy
        // The original logic updated baseRent too, which might be wrong if tenant leaves?
        // But following original logic for now to ensure consistency.
        baseRent: rentToLock, 
      );
      
      await _propertyRepository.updateUnit(updatedUnit);
    }
  }
}
