import 'package:intl/intl.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../../domain/entities/tenancy.dart'; // Import
import '../../../../domain/repositories/i_rent_repository.dart';
import '../../../../domain/repositories/i_property_repository.dart';
import '../../../../domain/repositories/i_tenant_repository.dart';
import '../../../../domain/entities/house.dart'; // Import for Unit
import 'package:uuid/uuid.dart'; // Add uuid import
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
    // 1. Fetch Active Tenancies
    final existingCycles = await _rentRepository.getRentCyclesForMonth(currentMonth);
    
    // We need ALL active tenancies. The repository should support this or we filter locally.
    final allTenancies = await _tenantRepository.getAllTenancies();
    
    // Filter active
    final activeTenancies = allTenancies.where((t) => t.status == TenancyStatus.active).toList();

    int generatedCount = 0;

    for (final tenancy in activeTenancies) {
      if (_alreadyGenerated(existingCycles, tenancy.id)) continue;

      try {
        await _generateForTenancy(tenancy, now, currentMonth);
        generatedCount++;
      } catch (e, stack) {
        print('CRITICAL: Failed to generate rent for tenancy ${tenancy.id}: $e\n$stack');
      }
    }

    return generatedCount;
  }

  bool _alreadyGenerated(List<RentCycle> existing, String tenancyId) {
    return existing.any((c) => c.tenancyId == tenancyId);
  }

  Future<void> _generateForTenancy(Tenancy tenancy, DateTime now, String currentMonth) async {
      // 2. Resolve Unit and Rent Amount
      final unit = await _propertyRepository.getUnit(tenancy.unitId);
          if (unit == null) throw Exception("Unit not found for tenancy ${tenancy.id}");

      final rentAmount = _calculateBaseRent(unit, tenancy);
      final id = const Uuid().v4();

      // 3. Construct Deterministic Cycle
      final newCycle = RentCycle(
        id: id, 
        tenancyId: tenancy.id,
        ownerId: tenancy.ownerId,
        month: currentMonth,
        billNumber: RentRules.generateBillNumber(tenantId: tenancy.tenantId, billDate: now), // Using tenantId for Bill No logic
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

  double _calculateBaseRent(Unit unit, Tenancy tenancy) {
      // Logic prioritization: 
      // 1. Unit's specific editable rent (if overridden)
      // 2. Tenancy's agreed rent (contractual)
      // 3. Unit's base market rent (fallback)
      
      // Usually Tenancy.agreedRent is the truth. 
      // Unlike Tenant, Tenancy ALWAYS has rent.
      return tenancy.agreedRent;
  }
}
