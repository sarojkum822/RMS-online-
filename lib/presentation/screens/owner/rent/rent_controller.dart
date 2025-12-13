import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/rent_cycle.dart';
import '../../../../domain/entities/tenant.dart';

import '../../../providers/data_providers.dart';
import '../../../../domain/repositories/i_rent_repository.dart'; // Import for DashboardStats

import '../../../../domain/entities/house.dart'; // Import for Unit

part 'rent_controller.g.dart';

@riverpod
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
     final Map<int, RentCycle> merged = {};
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
    final now = DateTime.now();
    final currentMonth = DateFormat('yyyy-MM').format(now); // 2023-10
    
    // 1. Check if generating for existing month
    final existingCycles = await _fetchRentCycles(currentMonth);
    
    // 2. Fetch Active Tenants
    final tenants = await ref.read(tenantRepositoryProvider).getAllTenants();
    final activeTenants = tenants.where((t) => t.status == TenantStatus.active).toList();

    // 3. Create Cycle for each Active Tenant if missing
    for (final tenant in activeTenants) {
      final exists = existingCycles.any((c) => c.tenantId == tenant.id);
      if (!exists) {
        // Fetch Unit for Base Rent
        final units = await ref.read(propertyRepositoryProvider).getUnits(tenant.houseId); 
        final unit = units.firstWhere((u) => u.id == tenant.unitId);

        // Determine Rent Amount (Agreed vs Base)
        // Determine Rent Amount (Prioritize Unit's editableRent -> Tenant's agreedRent -> Base Rent)
        final rentAmount = unit.editableRent ?? 
                           (tenant.agreedRent != null && tenant.agreedRent! > 0 ? tenant.agreedRent! : unit.baseRent);

        final newCycle = RentCycle(
          id: 0, // Auto-inc
          tenantId: tenant.id,
          month: currentMonth,
           // New Fields
          billNumber: 'INV-${now.year}${now.month}-${tenant.id}',
          billPeriodStart: DateTime(now.year, now.month, 1),
          billPeriodEnd: DateTime(now.year, now.month + 1, 0),
          billGeneratedDate: now,
          
          baseRent: rentAmount,
          electricAmount: 0,
          otherCharges: 0,
          discount: 0,
          totalDue: rentAmount,
          totalPaid: 0,
          status: RentStatus.pending,
          dueDate: DateTime(now.year, now.month, 5), // Due on 5th
          notes: '',
        );
        await ref.read(rentRepositoryProvider).createRentCycle(newCycle);
      }
    }

    // Refresh State
    state = AsyncValue.data(await _fetchDashboardCycles(currentMonth));
    ref.invalidate(dashboardStatsProvider);
    // Invalidate for all active tenants to ensure consistency if they are viewing details
    for(final t in activeTenants) {
      ref.invalidate(rentCyclesForTenantProvider(t.id));
    }
  }
  
  // Updated Method to match TenantDetailScreen usage
  Future<void> addPastRentCycle({
    required int tenantId,
    required String month, // Passed as String from UI
    required double totalDue, // UI passes 'totalDue'
    required double totalPaid, // UI passes 'totalPaid'
    required DateTime date,
  }) async {
    
    // Check if exists
    final existing = await ref.read(rentRepositoryProvider).getRentCyclesForTenant(tenantId);
    final hasCycle = existing.any((c) => c.month == month);
    
    if(hasCycle) {
      throw Exception('Rent Record for this month already exists.');
    }

     final parsedDate = DateFormat('yyyy-MM').parse(month);

    final newCycle = RentCycle(
      id: 0,
      tenantId: tenantId,
      month: month,
      billNumber: 'MANUAL-$month-$tenantId',
      billPeriodStart: DateTime(parsedDate.year, parsedDate.month, 1),
      billPeriodEnd: DateTime(parsedDate.year, parsedDate.month + 1, 0),
      billGeneratedDate: date,
      baseRent: totalDue, // Assuming base rent = total due for manual
      electricAmount: 0,
       otherCharges: 0,
       discount: 0,
      totalDue: totalDue,
      totalPaid: totalPaid,
      status: totalPaid >= totalDue ? RentStatus.paid : (totalPaid > 0 ? RentStatus.partial : RentStatus.pending),
      dueDate: DateTime(parsedDate.year, parsedDate.month, 5),
      notes: 'Manual Past Record',
    );
    
    await ref.read(rentRepositoryProvider).createRentCycle(newCycle);
    
    // Refresh stats
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(rentCyclesForTenantProvider(tenantId));
     final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
     if(month == currentMonth){
       state = AsyncValue.data(await _fetchDashboardCycles(currentMonth));
     }
  }

  // Restore Missing Method
  Future<void> updateRentCycleWithElectric({
    required int rentCycleId,
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
    
    // SAVE READING TO HISTORY for next month's auto-fill
    // 1. Need Unit ID (via Tenant)
    try {
       // We can iterate cached tenants/repo since we need unitId
       final allTenants = await ref.read(tenantRepositoryProvider).getAllTenants();
       final tenant = allTenants.firstWhere((t) => t.id == cycle.tenantId);
       
       await rentRepo.addElectricReading(
         tenant.unitId,
         DateTime.now(), 
         currentReading,
         rate: ratePerUnit
       );
    } catch (e) {
       debugPrint('Failed to save electric history: $e');
    }

     final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    state = AsyncValue.data(await _fetchDashboardCycles(currentMonth));
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(rentCyclesForTenantProvider(cycle.tenantId));
  }

  // Restore Missing Method
  Future<void> addOtherCharge({
    required int rentCycleId,
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
    ref.invalidate(rentCyclesForTenantProvider(cycle.tenantId));
  }
  
  // Update recordPayment to match UI usage (Named parameters)
  Future<void> recordPayment({
    required int rentCycleId,
    required int tenantId,
    required double amount,
    required DateTime date,
    required String method,
    String? referenceId, 
    String? notes,
  }) async {
     final payment = Payment(
        id: 0,
        rentCycleId: rentCycleId,
        tenantId: tenantId,
        amount: amount,
        date: date,
        method: method,
        referenceId: referenceId,
        notes: notes ?? '',
        channelId: null, // Optional for now
        collectedBy: null // Optional
     );

     await ref.read(rentRepositoryProvider).recordPayment(payment);
     // Refresh everything
      final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
     state = AsyncValue.data(await _fetchDashboardCycles(currentMonth));
     ref.invalidate(dashboardStatsProvider);
     ref.invalidate(rentCyclesForTenantProvider(tenantId));
  }
  Future<Map<String, double>?> getLastElectricReading(int unitId) async {
    return ref.read(rentRepositoryProvider).getLastElectricReading(unitId);
  }

  // --- Deletion Logic ---

  Future<void> deleteBill(int rentCycleId, int tenantId) async {
    final repo = ref.read(rentRepositoryProvider);
    await repo.deleteRentCycle(rentCycleId);
    
    // Refresh State
    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    state = AsyncValue.data(await _fetchDashboardCycles(currentMonth));
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(rentCyclesForTenantProvider(tenantId));
  }

  Future<void> deletePayment(int paymentId, int rentCycleId, int tenantId) async {
    final repo = ref.read(rentRepositoryProvider);
    
    // 1. Delete Payment
    await repo.deletePayment(paymentId);
    
    // 2. Recalculate Total Paid for the Cycle
    final remainingPayments = await repo.getPaymentsForRentCycle(rentCycleId);
    double newTotalPaid = remainingPayments.fold(0.0, (sum, p) => sum + p.amount); // fold handles empty list
    
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
    ref.invalidate(rentCyclesForTenantProvider(tenantId));
  }
}

// Stats Provider
@riverpod
Future<DashboardStats> dashboardStats(Ref ref) async {
  return ref.watch(rentRepositoryProvider).getDashboardStats();
}

final rentCyclesForTenantProvider = FutureProvider.family<List<RentCycle>, int>((ref, tenantId) async {
  return ref.read(rentRepositoryProvider).getRentCyclesForTenant(tenantId);
});

final initialReadingProvider = FutureProvider.family<double?, int>((ref, unitId) async {
  final readings = await ref.read(rentRepositoryProvider).getElectricReadings(unitId);
  return readings.isNotEmpty ? readings.first : null;
});

final unitDetailsProvider = FutureProvider.family<Unit?, int>((ref, unitId) async {
  return ref.read(propertyRepositoryProvider).getUnit(unitId);
});
