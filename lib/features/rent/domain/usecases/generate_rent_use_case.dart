import 'package:intl/intl.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../../domain/repositories/i_rent_repository.dart';
import '../../../../domain/repositories/i_property_repository.dart';
import '../../../../domain/repositories/i_tenant_repository.dart';
import '../../../../domain/entities/house.dart'; // Import for Unit
import '../rent_rules.dart';
import '../entities/rent_cycle.dart';

class GenerateRentUseCase {
  final IRentRepository _rentRepository;
  final IPropertyRepository _propertyRepository;
  final ITenantRepository _tenantRepository;

  GenerateRentUseCase(
    this._rentRepository,
    this._propertyRepository,
    this._tenantRepository,
  );

  /// Generates rent for the current month for all active tenants.
  /// Returns the number of bills generated.
  Future<int> execute() async {
    final now = DateTime.now();
    final currentMonth = DateFormat('yyyy-MM').format(now);
    
    // 1. Fetch Dependencies (Parallel if necessary, but sequential is safer for DB consistency)
    final existingCycles = await _rentRepository.getRentCyclesForMonth(currentMonth);
    
    final tenants = await _tenantRepository.getAllTenants().first;
    
    // Filter active tenants strictly
    final activeTenants = tenants.where((t) => t.status == TenantStatus.active).toList();

    int generatedCount = 0;

    for (final tenant in activeTenants) {
      if (_alreadyGenerated(existingCycles, tenant.id)) continue;

      try {
        await _generateForTenant(tenant, now, currentMonth);
        generatedCount++;
      } catch (e, stack) {
        // Log error but allow other tenants to process
        // In a real app, inject a Logger here.
        print('CRITICAL: Failed to generate rent for tenant ${tenant.id}: $e\n$stack');
      }
    }

    return generatedCount;
  }

  bool _alreadyGenerated(List<RentCycle> existing, int tenantId) {
    return existing.any((c) => c.tenantId == tenantId);
  }

  Future<void> _generateForTenant(Tenant tenant, DateTime now, String currentMonth) async {
      // 2. Resolve Unit and Rent Amount
      final units = await _propertyRepository.getUnits(tenant.houseId).first;
      final unit = units.firstWhere((u) => u.id == tenant.unitId,
          orElse: () => throw Exception("Unit not found for tenant ${tenant.id}"));

      final rentAmount = _calculateBaseRent(unit, tenant);

      // 3. Construct Deterministic Cycle
      final newCycle = RentCycle(
        id: 0, // DB Auto-increment
        tenantId: tenant.id,
        month: currentMonth,
        billNumber: RentRules.generateBillNumber(tenantId: tenant.id, billDate: now),
        billPeriodStart: RentRules.calculateBillPeriodStart(now),
        billPeriodEnd: RentRules.calculateBillPeriodEnd(now),
        billGeneratedDate: now,
        baseRent: rentAmount,
        totalDue: rentAmount, // Starts equal to base rent
        dueDate: RentRules.calculateDueDate(now),
        status: RentStatus.pending,
        notes: 'Auto-generated via RentPilot Pro',
        
        // Strict Defaults
        electricAmount: 0,
        otherCharges: 0,
        discount: 0,
        totalPaid: 0,
        lateFee: 0,
      );

      await _rentRepository.createRentCycle(newCycle);
  }

  double _calculateBaseRent(Unit unit, Tenant tenant) {
      // Logic prioritization: 
      // 1. Unit's specific editable rent (if overridden)
      // 2. Tenant's agreed rent (contractual)
      // 3. Unit's base market rent (fallback)
      if (unit.editableRent != null) return unit.editableRent!;
      if (tenant.agreedRent != null && tenant.agreedRent! > 0) return tenant.agreedRent!;
      return unit.baseRent;
  }
}
