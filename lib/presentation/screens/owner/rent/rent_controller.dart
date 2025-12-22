
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

import '../reports/reports_controller.dart';
import '../tenant/tenant_controller.dart';

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
      if (t.isActive) {
          final tenancy = await ref.read(tenantRepositoryProvider).getActiveTenancyForTenant(t.id);
          if (tenancy != null) {
             ref.invalidate(rentCyclesForTenancyProvider(tenancy.id));
             ref.invalidate(tenantAllBillsProvider(t.id));
          }
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
       // Need real tenantId
       String? realTenantId;
       final t = await ref.read(tenantRepositoryProvider).getTenancy(tenancyId);
       if(t != null) realTenantId = t.tenantId;
       
       if (realTenantId != null) {
           await recordPayment(
             rentCycleId: newId,
             tenantId: realTenantId, 
             amount: totalPaid,
             date: date,
             method: 'Cash', // Default for manual entry
             notes: 'Manual Entry (Past Record)'
           );
       }
    } else {
       // If no payment, we must refresh manually
       ref.invalidate(dashboardStatsProvider);
       ref.invalidate(reportsControllerProvider);
       ref.invalidate(rentCyclesForTenancyProvider(tenancyId));
       
       // Need to find tenantId from tenancyId to invalidate tenantAllBillsProvider
       final t = await ref.read(tenantRepositoryProvider).getTenancy(tenancyId);
       if(t != null) ref.invalidate(tenantAllBillsProvider(t.tenantId));
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
    
    // Safety: don't allow current reading to be less than previous
    if (currentReading < prevReading) {
       throw Exception('Current reading cannot be less than previous reading ($prevReading).');
    }

    final unitsConsumed = currentReading - prevReading;
    final electricBill = unitsConsumed * ratePerUnit;
    
    final newTotalDue = cycle.baseRent + electricBill + cycle.otherCharges - cycle.discount;
    
    final updatedCycle = cycle.copyWith(
      electricAmount: electricBill,
      totalDue: newTotalDue,
      status: cycle.totalPaid >= newTotalDue ? RentStatus.paid : (cycle.totalPaid > 0 ? RentStatus.partial : RentStatus.pending),
    );
    
    await rentRepo.updateRentCycle(updatedCycle);
    
    try {
       // Sync to Electric History
       final tenancyRepo = ref.read(tenantRepositoryProvider);
       final tenancy = await tenancyRepo.getTenancy(cycle.tenancyId);
       
       if (tenancy != null && tenancy.unitId.isNotEmpty) {
           // Improved Duplicate Check: If a reading for this unit and value exists today, skip adding to history
           // Note: We still update the bill above, but avoid polluting history
           final existingReadings = await rentRepo.getElectricReadingsWithDetails(tenancy.unitId);
           final now = DateTime.now();
           final isDuplicate = existingReadings.any((r) {
               final rDate = r['date'] as DateTime;
               return (r['reading'] as double) == currentReading && 
                      rDate.year == now.year &&
                      rDate.month == now.month &&
                      rDate.day == now.day;
           });

           if (!isDuplicate) {
              await rentRepo.addElectricReading(
                tenancy.unitId, 
                now, 
                currentReading, 
                rate: ratePerUnit
              );
              
              // Invalidate caches
              ref.invalidate(initialReadingProvider(tenancy.unitId)); 
              ref.invalidate(electricReadingsProvider(tenancy.unitId));
              ref.invalidate(latestReadingProvider(tenancy.unitId));
           }
       }
    } catch (e) {
       debugPrint('Failed to save electric history: $e');
    }

     final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    state = AsyncValue.data(await _fetchDashboardCycles(currentMonth));
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(reportsControllerProvider); 
    ref.invalidate(rentCyclesForTenancyProvider(cycle.tenancyId));
    
    // Resolve tenantId to invalidate history
    try {
      final t = await ref.read(tenantRepositoryProvider).getTenancy(cycle.tenancyId);
      if(t != null) {
        ref.invalidate(tenantAllBillsProvider(t.tenantId));
        ref.invalidate(activeTenancyProvider(t.tenantId));
      }
    } catch (_) {}
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

    // Invalidate Tenant History
    try {
      final t = await ref.read(tenantRepositoryProvider).getTenancy(cycle.tenancyId);
      if(t != null) ref.invalidate(tenantAllBillsProvider(t.tenantId));
    } catch (_) {}
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
     // Fetch cycle to get tenancyId
     final cycle = await ref.read(rentRepositoryProvider).getRentCycle(rentCycleId);
     if (cycle == null) throw Exception('Rent cycle not found');

     final payment = Payment(
        id: const Uuid().v4(),
        rentCycleId: rentCycleId,
        tenancyId: cycle.tenancyId,
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
     
     // Fix: Invalidate using tenancyId from the cycle already fetched
     ref.invalidate(rentCyclesForTenancyProvider(cycle.tenancyId));
     
     // Also invalidate generic bills provider
     ref.invalidate(tenantAllBillsProvider(tenantId));
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
    await _refreshAllState(cycle.tenancyId);
  }

  Future<void> recoverBill(RentCycle cycle) async {
    final repo = ref.read(rentRepositoryProvider);
    await repo.recoverRentCycle(cycle.id);
    
    // Refresh State
    await _refreshAllState(cycle.tenancyId);
  }

  Future<void> permanentlyDeleteBill(RentCycle cycle) async {
    final repo = ref.read(rentRepositoryProvider);
    await repo.permanentlyDeleteRentCycle(cycle);
    
    // Refresh State
    await _refreshAllState(cycle.tenancyId);
  }

  Future<void> _refreshAllState(String tenancyId) async {
    try {
      final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
      // Await dashboard fetch to prevent hanging/race conditions
      final updatedDashboard = await _fetchDashboardCycles(currentMonth);
      state = AsyncValue.data(updatedDashboard);
      
      // Invalidate everything else
      ref.invalidate(dashboardStatsProvider);
      ref.invalidate(reportsControllerProvider);
      ref.invalidate(rentCyclesForTenancyProvider(tenancyId));
      ref.invalidate(deletedRentCyclesForTenancyProvider(tenancyId));

      // Resolve tenantId to invalidate history
      final tenancy = await ref.read(tenantRepositoryProvider).getTenancy(tenancyId);
      if (tenancy != null) {
          ref.invalidate(tenantAllBillsProvider(tenancy.tenantId));
      }
    } catch (e) {
      debugPrint('Error refreshing rent state: $e');
      // Ensure state is not stuck in loading if refresh fails
      final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
      state = AsyncValue.data(await _fetchDashboardCycles(currentMonth));
    }
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
      status: cycle.totalPaid >= newTotalDue - 0.01
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
    
    final t = await ref.read(tenantRepositoryProvider).getTenancy(cycle.tenancyId);
    if(t != null) ref.invalidate(tenantAllBillsProvider(t.tenantId));
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
         status: newTotalPaid >= cycle.totalDue - 0.01 
            ? RentStatus.paid 
            : (newTotalPaid > 0 ? RentStatus.partial : RentStatus.pending),
       );
       await repo.updateRentCycle(updatedCycle);
    }

    // 4. Refresh State
    await _refreshAllState(tenancyId);
  }

  Future<void> recoverPayment(String paymentId, String rentCycleId, String tenancyId) async {
    final repo = ref.read(rentRepositoryProvider);
    await repo.recoverPayment(paymentId);
    
    // Refresh State
    await _refreshAllState(tenancyId);
  }

  Future<void> permanentlyDeletePayment(String paymentId, String rentCycleId, String tenancyId) async {
    final repo = ref.read(rentRepositoryProvider);
    await repo.permanentlyDeletePayment(paymentId);
    
    // Refresh State
    await _refreshAllState(tenancyId);
  }
}

final deletedPaymentsForRentCycleProvider = FutureProvider.family<List<Payment>, String>((ref, rentCycleId) async {
  return ref.read(rentRepositoryProvider).getDeletedPaymentsForRentCycle(rentCycleId);
});

// Stats Provider
@Riverpod(keepAlive: true)
Future<DashboardStats> dashboardStats(Ref ref) async {
  return ref.watch(rentRepositoryProvider).getDashboardStats();
}

final rentCyclesForTenancyProvider = FutureProvider.family<List<RentCycle>, String>((ref, tenancyId) async {
  return ref.read(rentRepositoryProvider).getRentCyclesForTenancy(tenancyId);
});

final deletedRentCyclesForTenancyProvider = FutureProvider.family<List<RentCycle>, String>((ref, tenancyId) async {
  return ref.read(rentRepositoryProvider).getDeletedRentCyclesForTenancy(tenancyId);
});

final initialReadingProvider = FutureProvider.family<double?, String>((ref, unitId) async {
  final readings = await ref.read(rentRepositoryProvider).getElectricReadings(unitId);
  return readings.isNotEmpty ? readings.first : null;
});

final latestReadingProvider = FutureProvider.family<double?, String>((ref, unitId) async {
  final result = await ref.read(rentRepositoryProvider).getLastElectricReading(unitId);
  return result?['currentReading'];
});

final electricReadingsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, unitId) async {
  return ref.read(rentRepositoryProvider).getElectricReadingsWithDetails(unitId);
});



final tenantDetailsProvider = FutureProvider.family<Tenant?, String>((ref, tenantId) async {
  return ref.read(tenantRepositoryProvider).getTenant(tenantId);
});

// NEW: Robust Provider to find ALL bills for a tenant (History)
final tenantAllBillsProvider = FutureProvider.family<List<RentCycle>, String>((ref, tenantId) async {
   return ref.watch(rentRepositoryProvider).getRentCyclesForTenant(tenantId);
});
