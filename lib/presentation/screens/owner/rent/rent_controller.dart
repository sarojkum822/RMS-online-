
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart'; // Add uuid

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../features/rent/domain/entities/rent_cycle.dart';
import '../../../../features/rent/domain/usecases/generate_rent_use_case.dart';
import '../../../../domain/entities/tenant.dart';

import '../../../providers/data_providers.dart';
import '../../../../domain/repositories/i_rent_repository.dart'; 

import '../../../../domain/entities/house.dart'; 
import '../reports/reports_controller.dart';

part 'rent_controller.g.dart';

@Riverpod(keepAlive: true)
class RentController extends _$RentController {
  @override
  FutureOr<List<RentCycle>> build() async {
    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    return _fetchDashboardCycles(currentMonth);
  }

  Future<List<RentCycle>> _fetchDashboardCycles(String currentMonth) async {
     final repo = ref.read(rentRepositoryProvider);
     
     // 1. Current Month (All statuses)
     final currentValues = await repo.getRentCyclesForMonth(currentMonth);
     
     // 2. Past Pending (All months)
     final pendingValues = await repo.getAllPendingRentCycles();
     
     // 3. Merge & Deduplicate
     final Map<String, RentCycle> merged = {};
     for(final c in currentValues) {
       merged[c.id] = c;
     }
     for(final c in pendingValues) {
       merged[c.id] = c;
     }
     
     // 4. Return Values
     return merged.values.toList();
  }

  Future<List<RentCycle>> _fetchRentCycles(String month) async {
     return ref.read(rentRepositoryProvider).getRentCyclesForMonth(month);
  }

  Future<void> generateRentForCurrentMonth() async {
    final useCase = GenerateRentUseCase(
      ref.read(rentRepositoryProvider),
      ref.read(propertyRepositoryProvider),
      ref.read(tenantRepositoryProvider),
    );

    // Execute safe, deterministic generation
    await useCase.execute();

    // Refresh State
    final now = DateTime.now();
    final currentMonth = DateFormat('yyyy-MM').format(now);
    state = AsyncValue.data(await _fetchDashboardCycles(currentMonth));
    
    // Invalidate dependent providers
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(reportsControllerProvider); 
    
    // Invalidate tenant-specific providers
    final tenants = await ref.read(tenantRepositoryProvider).getAllTenants().first;
    for(final t in tenants) {
      if (t.status == TenantStatus.active) {
         ref.invalidate(rentCyclesForTenantProvider(t.id));
      }
    }
  }
  
  // Updated Method to match TenantDetailScreen usage
  Future<void> addPastRentCycle({
    required String tenancyId, // Changed to tenancyId
    required String ownerId,
    required String month, 
    required double totalDue, 
    required double totalPaid, 
    required DateTime date,
  }) async {
    
    // Check if exists using Tenancy
    final existing = await ref.read(rentRepositoryProvider).getRentCyclesForTenancy(tenancyId);
    final hasCycle = existing.any((c) => c.month == month);
    
    if(hasCycle) {
      throw Exception('Rent Record for this month already exists.');
    }

     final parsedDate = DateFormat('yyyy-MM').parse(month);
     final id = const Uuid().v4();

    final newCycle = RentCycle(
      id: id,
      tenancyId: tenancyId,
      ownerId: ownerId,
      month: month,
      billNumber: 'MANUAL-$month',
      billPeriodStart: DateTime(parsedDate.year, parsedDate.month, 1),
      billPeriodEnd: DateTime(parsedDate.year, parsedDate.month + 1, 0),
      billGeneratedDate: date,
      baseRent: totalDue,
      electricAmount: 0,
      otherCharges: 0,
      discount: 0,
      totalDue: totalDue,
      // Initialize as Unpaid. Logic below creates payment if needed.
      totalPaid: 0, 
      status: RentStatus.pending,
      dueDate: DateTime(parsedDate.year, parsedDate.month, 5),
      notes: 'Manual Past Record',
    );
    
    // Create Cycle and get ID
    final newId = await ref.read(rentRepositoryProvider).createRentCycle(newCycle);
    
    // Record Payment if applicable
    if (totalPaid > 0) {
       await recordPayment(
         rentCycleId: newId,
         tenantId: tenancyId, // Using tenancyId as tenantId in payment for now
         amount: totalPaid,
         date: date,
         method: 'Cash', // Default for manual entry
         notes: 'Manual Entry (Past Record)'
       );
    } else {
       // If no payment, we must refresh manually
       ref.invalidate(dashboardStatsProvider);
       ref.invalidate(reportsControllerProvider);
       ref.invalidate(rentCyclesForTenancyProvider(tenancyId));
       // Force Refresh of Main List
       ref.invalidateSelf();
       final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
       if(month == currentMonth){
         state = AsyncValue.data(await _fetchDashboardCycles(currentMonth));
       }
    }
  }

  // Restore Missing Method
  Future<void> updateRentCycleWithElectric({
    required String rentCycleId,
    required double prevReading,
    required double currentReading,
    required double ratePerUnit,
  }) async {
    final rentRepo = ref.read(rentRepositoryProvider);
    final cycle = await rentRepo.getRentCycle(rentCycleId);
    if(cycle == null) return;
    
    final unitsConsumed = currentReading - prevReading;
    final electricBill = unitsConsumed * ratePerUnit;
    
    final newTotalDue = cycle.baseRent + electricBill + cycle.otherCharges - cycle.discount;
    
    final updatedCycle = cycle.copyWith(
      electricAmount: electricBill,
      totalDue: newTotalDue,
      // Status update logic
      status: cycle.totalPaid >= newTotalDue ? RentStatus.paid : (cycle.totalPaid > 0 ? RentStatus.partial : RentStatus.pending),
    );
    
    await rentRepo.updateRentCycle(updatedCycle);
    
    try {
       // Get Unit ID from Tenancy? 
       // For now assuming we need to fetch Tenancy or we can cheat if we have Tenancy stored
       // But RentCycle has tenancyId.
       // We can get Tenancy -> unitId
       // Or find tenant by tenancy...?
       // Let's assume we can fetch unitId via other means or pass it. 
       // Simpler: Just skip updating "Tenant Profile" last reading if complicated, 
       // BUT we need 'addElectricReading' for history.
       
       // Note: In new schema, addElectricReading is on Unit.
       // We need UnitID.
       // TODO: Fetch UnitID properly. 
       
    } catch (e) {
       debugPrint('Failed to save electric history: $e');
    }

     final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    state = AsyncValue.data(await _fetchDashboardCycles(currentMonth));
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(reportsControllerProvider); 
    ref.invalidate(rentCyclesForTenancyProvider(cycle.tenancyId));
  }

  // Restore Missing Method
  // Restore Missing Method
  Future<void> addOtherCharge({
    required String rentCycleId,
    required double amount,
    required String note,
  }) async {
     final cycle = await ref.read(rentRepositoryProvider).getRentCycle(rentCycleId);
    if(cycle == null) return;
    
    final newOtherCharges = cycle.otherCharges + amount;
    final newTotalDue = cycle.baseRent + cycle.electricAmount + newOtherCharges - cycle.discount;

    final updatedCycle = cycle.copyWith(
      otherCharges: newOtherCharges,
      totalDue: newTotalDue,
      status: cycle.totalPaid >= newTotalDue ? RentStatus.paid : (cycle.totalPaid > 0 ? RentStatus.partial : RentStatus.pending),
      notes: (cycle.notes != null && cycle.notes!.isNotEmpty) ? '${cycle.notes}, $note' : note,
    );
    
    await ref.read(rentRepositoryProvider).updateRentCycle(updatedCycle);
     final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    state = AsyncValue.data(await _fetchDashboardCycles(currentMonth));
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(reportsControllerProvider); 
    ref.invalidate(rentCyclesForTenancyProvider(cycle.tenancyId));
  }
  
  Future<void> recordPayment({
    required String rentCycleId,
    required String tenantId,
    required double amount,
    required DateTime date,
    required String method,
    String? referenceId, 
    String? notes,
  }) async {
     final payment = Payment(
        id: const Uuid().v4(),
        rentCycleId: rentCycleId,
        tenantId: tenantId,
        amount: amount,
        date: date,
        method: method,
        referenceId: referenceId,
        notes: notes ?? '',
        channelId: null, 
        collectedBy: null 
     );

     await ref.read(rentRepositoryProvider).recordPayment(payment);
     // Refresh everything
      final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
     state = AsyncValue.data(await _fetchDashboardCycles(currentMonth));
     ref.invalidate(dashboardStatsProvider);
     ref.invalidate(reportsControllerProvider); 
     ref.invalidate(rentCyclesForTenancyProvider(tenantId));
  }
  Future<Map<String, double>?> getLastElectricReading(String unitId) async {
    return ref.read(rentRepositoryProvider).getLastElectricReading(unitId);
  }

  // --- Deletion Logic ---

  // --- Deletion Logic ---

  Future<void> deleteBill(RentCycle cycle) async {
    final repo = ref.read(rentRepositoryProvider);
    await repo.deleteRentCycle(cycle);
    
    // Refresh State
    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    state = AsyncValue.data(await _fetchDashboardCycles(currentMonth));
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(reportsControllerProvider);
    ref.invalidate(rentCyclesForTenantProvider(cycle.tenantId));
  }

  // --- Edit Logic ---
  Future<void> updateTotalDue({
    required String rentCycleId,
    required double newTotalDue,
    required String? notes,
  }) async {
    final repo = ref.read(rentRepositoryProvider);
    final cycle = await repo.getRentCycle(rentCycleId);
    if(cycle == null) return;
    
    final updatedCycle = cycle.copyWith(
      totalDue: newTotalDue,
      notes: notes,
      status: cycle.totalPaid >= newTotalDue 
          ? RentStatus.paid 
          : (cycle.totalPaid > 0 ? RentStatus.partial : RentStatus.pending),
    );
    
    await repo.updateRentCycle(updatedCycle);
     
    // Refresh
    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    state = AsyncValue.data(await _fetchDashboardCycles(currentMonth));
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(reportsControllerProvider);
    ref.invalidate(rentCyclesForTenancyProvider(cycle.tenancyId));
  }

  Future<void> deletePayment(String paymentId, String rentCycleId, String tenancyId) async {
    final repo = ref.read(rentRepositoryProvider);
    
    // 1. Delete Payment
    await repo.deletePayment(paymentId);
    
    // 2. Recalculate Total Paid for the Cycle
    final remainingPayments = await repo.getPaymentsForRentCycle(rentCycleId);
    double newTotalPaid = remainingPayments.fold(0.0, (sum, p) => sum + p.amount); 
    
    // 3. Update Rent Cycle Status
    final cycle = await repo.getRentCycle(rentCycleId);
    if (cycle != null) {
       final updatedCycle = cycle.copyWith(
         totalPaid: newTotalPaid,
         status: newTotalPaid >= cycle.totalDue 
            ? RentStatus.paid 
            : (newTotalPaid > 0 ? RentStatus.partial : RentStatus.pending),
       );
       await repo.updateRentCycle(updatedCycle);
    }

    // 4. Refresh State
    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    state = AsyncValue.data(await _fetchDashboardCycles(currentMonth));
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(reportsControllerProvider); 
    ref.invalidate(rentCyclesForTenancyProvider(tenancyId));
  }
}

// Stats Provider
@Riverpod(keepAlive: true)
Future<DashboardStats> dashboardStats(Ref ref) async {
  return ref.watch(rentRepositoryProvider).getDashboardStats();
}

final rentCyclesForTenancyProvider = FutureProvider.family<List<RentCycle>, String>((ref, tenancyId) async {
  return ref.read(rentRepositoryProvider).getRentCyclesForTenancy(tenancyId);
});

final initialReadingProvider = FutureProvider.family<double?, String>((ref, unitId) async {
  final readings = await ref.read(rentRepositoryProvider).getElectricReadings(unitId);
  return readings.isNotEmpty ? readings.first : null;
});

final unitDetailsProvider = FutureProvider.family<Unit?, String>((ref, unitId) async {
  return ref.read(propertyRepositoryProvider).getUnit(unitId); // Update propertyRepo too!
});

final houseDetailsProvider = FutureProvider.family<House?, String>((ref, houseId) async {
  return ref.read(propertyRepositoryProvider).getHouse(houseId); // Update propertyRepo too!
});

final tenantDetailsProvider = FutureProvider.family<Tenant?, String>((ref, tenantId) async {
  return ref.read(tenantRepositoryProvider).getTenant(tenantId);
});
