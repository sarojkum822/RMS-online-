import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../../domain/entities/house.dart';
import '../../../providers/data_providers.dart';

part 'tenant_controller.g.dart';

@riverpod
class TenantController extends _$TenantController {
  @override
  FutureOr<List<Tenant>> build() async {
    return _fetchTenants();
  }

  Future<List<Tenant>> _fetchTenants() async {
    final repo = ref.watch(tenantRepositoryProvider);
    return repo.getAllTenants();
  }

  Future<void> addTenant(Tenant tenant, {double? initialElectricReading}) async {
    final repo = ref.read(tenantRepositoryProvider);
    await repo.createTenant(tenant);

    if (initialElectricReading != null) {
      await ref.read(rentRepositoryProvider).addElectricReading(
        tenant.unitId,
        tenant.startDate,
        initialElectricReading,
      );
    }
    
    ref.invalidateSelf();
  }

  Future<void> addTenantWithManualUnit({
    required int houseId,
    required String unitName,
    required String floor, // Accepting String, parsing to int or defaulting for now? User said "flat floor".
    required String tenantName,
    required String phone,
    String? email,
    double? agreedRent,
    double? initialElectricReading,
  }) async {
    final propertyRepo = ref.read(propertyRepositoryProvider);
    
    // 1. Check or Create Unit
    final units = await propertyRepo.getUnits(houseId);
    Unit? targetUnit;
    try {
      targetUnit = units.firstWhere(
        (u) => u.nameOrNumber.trim().toLowerCase() == unitName.trim().toLowerCase(),
      );
    } catch (_) {
      targetUnit = null;
    }

    int unitId;
    if (targetUnit != null) {
      unitId = targetUnit.id;
    } else {
      // Create Unit
      int parsedFloor = 0;
      final floorInt = int.tryParse(floor);
      if (floorInt != null) parsedFloor = floorInt;

      final newUnit = Unit(
        id: 0,
        houseId: houseId,
        nameOrNumber: unitName,
        floor: parsedFloor,
        baseRent: agreedRent ?? 0.0,
        defaultDueDay: 1,
      );
      unitId = await propertyRepo.createUnit(newUnit);
    }

    // 2. Create Tenant
    // Ensure tenantCode is unique? If phone is used, we only allow 1 active tenant per phone.
    // To allow multiple, we might need composite key or random code. 
    // For now, catching error.
    final tenant = Tenant(
        id: 0,
        houseId: houseId,
        unitId: unitId,
        tenantCode: phone, 
        name: tenantName,
        phone: phone,
        email: email,
        startDate: DateTime.now(),
        status: TenantStatus.active,
        agreedRent: agreedRent
    );

    try {
      await addTenant(tenant, initialElectricReading: initialElectricReading);
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
         throw Exception('A tenant with this phone number already exists.');
      }
      rethrow;
    }
  }

  // Tenant Authentication Logic
  Future<Tenant?> login(String code) async {
    // In a real app, this would verify password/OTP.
    // For this MVP, we verify if a user with this 'tenantCode' or 'phone' exists.
    // We'll treat the 'code' input as the unique Tenant Code.
    final repo = ref.read(tenantRepositoryProvider);
    final tenant = await repo.getTenantByCode(code); 
    // If not found by code, try validation logic or return null
    return tenant;
  }
}
