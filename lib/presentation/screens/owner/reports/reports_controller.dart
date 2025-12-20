
import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../../../../domain/entities/house.dart'; 
import '../../../../domain/entities/tenancy.dart'; // Import
import '../../../../features/rent/domain/entities/rent_cycle.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../../domain/entities/expense.dart'; 

import '../../../providers/data_providers.dart';

part 'reports_controller.g.dart';

class MonthlyStats {
  final String monthLabel; 
  final double collected;
  final double pending;

  MonthlyStats({required this.monthLabel, required this.collected, required this.pending});
}

class TenantDue {
  final String name;
  final double amount;
  final String phone;
  TenantDue({required this.name, required this.amount, required this.phone});
}

class PropertyRevenue {
  final String houseName;
  final double revenue;
  PropertyRevenue({required this.houseName, required this.revenue});
}

class ReportsData {
  final double totalCollected;
  final double totalPending;
  final double totalExpected;
  
  // New Financials
  final double totalExpenses;
  final double netProfit;
  
  // Operational
  final int totalUnits;
  final int occupiedUnits;
  final int vacantUnits;
  
  // Analysis
  final List<Payment> recentPayments;
  final List<MonthlyStats> revenueTrend;
  final Map<String, double> paymentMethods;
  final List<TenantDue> topDefaulters;
  final List<PropertyRevenue> propertyPerformance;

  ReportsData({
    required this.totalCollected,
    required this.totalPending,
    required this.totalExpected,
    required this.totalExpenses,
    required this.netProfit,
    required this.totalUnits,
    required this.occupiedUnits,
    required this.vacantUnits,
    required this.recentPayments,
    required this.revenueTrend,
    required this.paymentMethods,
    required this.topDefaulters,
    required this.propertyPerformance,
  });
}

@riverpod
class ReportsController extends _$ReportsController {
  @override
  FutureOr<ReportsData> build() async {
    final rentRepo = ref.watch(rentRepositoryProvider);
    final tenantRepo = ref.watch(tenantRepositoryProvider);
    final houseRepo = ref.watch(propertyRepositoryProvider);

    // 0. Bulk Fetch
    // We handle Futures and Streams appropriately here.
    final rentCyclesFuture = rentRepo.getAllRentCycles();
    final paymentsFuture = rentRepo.getAllPayments();
    final expensesFuture = rentRepo.getAllExpenses();
    
    // Convert Streams to Futures (Snapshot) for Reports
    final housesFuture = houseRepo.getHouses().first; // Get current state
    final tenantsFuture = tenantRepo.getAllTenants().first; // Get current state


    final results = await Future.wait([
      rentCyclesFuture,          // [0]
      paymentsFuture,            // [1]
      expensesFuture,            // [2]
      housesFuture,              // [3]
      tenantsFuture,             // [4]
      tenantRepo.getAllTenancies().first, // [5] Fixed
      houseRepo.getAllUnits().first,      // [6] New
    ]);

    // Offload heavy calculation to background isolate to keep UI smooth
    return await compute(_processReportsData, results);
  }
}

// Top-level function for Isolate
ReportsData _processReportsData(List<dynamic> results) {
    final allRentCycles = results[0] as List<RentCycle>;
    final allPayments = results[1] as List<Payment>;
    final allExpenses = results[2] as List<Expense>;
    final allHouses = results[3] as List<House>;
    final allTenants = results[4] as List<Tenant>;
    final allTenancies = results[5] as List<Tenancy>;
    final allUnits = results[6] as List<Unit>;

    final now = DateTime.now();
    final currentMonthStr = DateFormat('yyyy-MM').format(now);

    // 1. Financials (Current Month)
    final currentCycles = allRentCycles.where((c) => c.month == currentMonthStr).toList();
    
    double totalExpected = 0;
    double accrualPaid = 0; // Paid specifically for this month's bills
    
    for (final c in currentCycles) {
      totalExpected += c.totalDue;
      accrualPaid += c.totalPaid;
    }
    final totalPending = max(0.0, totalExpected - accrualPaid);

    // 2. Expenses & Net Profit
    final currentMonthExpenses = allExpenses.where((e) {
       final eMonth = DateFormat('yyyy-MM').format(e.date);
       return eMonth == currentMonthStr;
    }).toList();
    
    final totalExpenses = currentMonthExpenses.fold(0.0, (sum, item) => sum + item.amount);

    // 3. Payment Methods (This Month) - CASH BASIS
    final currentPayments = allPayments.where((p) {
        final pMonth = DateFormat('yyyy-MM').format(p.date);
        return pMonth == currentMonthStr;
    }).toList();

    Map<String, double> paymentMethods = {};
    double totalCashCollected = 0;
    for (final p in currentPayments) {
        paymentMethods[p.method] = (paymentMethods[p.method] ?? 0) + p.amount;
        totalCashCollected += p.amount;
    }
    
    // Net Profit = Cash In - Cash Out
    final netProfit = totalCashCollected - totalExpenses;

    // 4. Revenue Trend (Last 6 Months)
    List<MonthlyStats> revenueTrend = [];
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthKey = DateFormat('yyyy-MM').format(date);
      final monthLabel = DateFormat('MMM').format(date);
      
      final monthCycles = allRentCycles.where((c) => c.month == monthKey).toList();
      
      double collected = 0;
      double pending = 0;

       for (final c in monthCycles) {
        collected += c.totalPaid;
        pending += max(0.0, c.totalDue - c.totalPaid);
      }
      revenueTrend.add(MonthlyStats(monthLabel: monthLabel, collected: collected, pending: pending));
    }

    // 5. Occupancy & Property Performance
    int totalUnits = 0;
    
    List<PropertyRevenue> propertyPerformance = [];
    
    // Map Tenancy -> Unit -> House
    // Map<TenancyId, HouseId>
    // Map from map TenancyId -> HouseId
    Map<String, String> tenancyIdsToHouseIds = {}; // Rename to avoid conflict if any (though scoping might be fine, duplicate local var is error)
    for (var t in allTenancies) {
        final unit = allUnits.firstWhere((u) => u.id == t.unitId, orElse: () => Unit(id: '', houseId: '', ownerId: '', nameOrNumber: '', baseRent: 0));
        if(unit.houseId.isNotEmpty) {
           tenancyIdsToHouseIds[t.id] = unit.houseId;
        }
    }

    Map<String, double> houseRevenueMap = {};
    for(final c in allRentCycles) {
        final houseId = tenancyIdsToHouseIds[c.tenancyId]; 
        if (houseId != null) {
            houseRevenueMap[houseId] = (houseRevenueMap[houseId] ?? 0) + c.totalPaid;
        }
    }
    
    for(final h in allHouses) {
        propertyPerformance.add(PropertyRevenue(houseName: h.name, revenue: houseRevenueMap[h.id] ?? 0));
    }
    
    final activeTenanciesCount = allTenancies.where((t) => t.status == TenancyStatus.active).length;
    totalUnits = activeTenanciesCount; // Placeholder, should be total units from Houses
    final vacantUnits = 0; 

    // 6. Top Defaulters
    List<TenantDue> defaulters = [];
    Map<String, double> tenancyDueMap = {};
    for(final c in allRentCycles) {
        final due = c.totalDue - c.totalPaid;
        if (due > 0) {
            tenancyDueMap[c.tenancyId] = (tenancyDueMap[c.tenancyId] ?? 0) + due;
        }
    }
    
    // We need to map TenancyId back to Tenant Name.
    // Tenancy -> TenantId
    Map<String, String> tenancyToTenantIdMap = {for (var t in allTenancies) t.id: t.tenantId};
    Map<String, Tenant> tenantMap = {for (var t in allTenants) t.id: t};

    tenancyDueMap.forEach((tenancyId, amount) {
       final tenantId = tenancyToTenantIdMap[tenancyId];
       if(tenantId != null) {
          final tenant = tenantMap[tenantId];
          if(tenant != null) {
             defaulters.add(TenantDue(name: tenant.name, amount: amount, phone: tenant.phone));
          }
       }
    });
    
    defaulters.sort((a, b) => b.amount.compareTo(a.amount));
    if (defaulters.length > 5) defaulters = defaulters.sublist(0, 5);

    // 7. Recent Activity
    allPayments.sort((a, b) => b.date.compareTo(a.date));
    final recentPayments = allPayments.take(10).toList();

    return ReportsData(
      totalCollected: totalCashCollected,
      totalPending: totalPending,
      totalExpected: totalExpected,
      totalExpenses: totalExpenses,
      netProfit: netProfit,
      totalUnits: totalUnits,
      occupiedUnits: activeTenanciesCount,
      vacantUnits: vacantUnits,
      recentPayments: recentPayments,
      revenueTrend: revenueTrend,
      paymentMethods: paymentMethods,
      topDefaulters: defaulters,
      propertyPerformance: propertyPerformance,
    );
}
