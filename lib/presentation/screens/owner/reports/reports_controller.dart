
import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../../../../domain/entities/house.dart'; 
import '../../../../domain/entities/tenancy.dart'; // Import
import '../../../../features/rent/domain/entities/rent_cycle.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../../domain/entities/expense.dart'; 

import '../../../../domain/entities/report_range.dart';
import '../../../providers/data_providers.dart';
import '../../../../core/services/app_prefs_cache.dart';
import 'reports_data.dart';
import 'dart:convert';

part 'reports_controller.g.dart';


@riverpod
class ReportsController extends _$ReportsController {
  @override
  FutureOr<ReportsData> build(ReportRange range) async {
    // 1. Try to load from cache first
    final cachedJson = AppPrefsCache.getCachedReport(range.label);
    if (cachedJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(cachedJson);
        final cachedData = ReportsData.fromJson(json);
        // Trigger fresh fetch in background
        Future.microtask(() => _fetchAndCache(range));
        return cachedData;
      } catch (e) {
        debugPrint('Error decoding cached report: $e');
      }
    }

    // 2. Fallback to full fetch if no cache or error
    return await _fetchAndCache(range);
  }

  Future<ReportsData> _fetchAndCache(ReportRange range) async {
    final rentRepo = ref.watch(rentRepositoryProvider);
    final tenantRepo = ref.watch(tenantRepositoryProvider);
    final houseRepo = ref.watch(propertyRepositoryProvider);

    final results = await Future.wait<dynamic>([
      rentRepo.getAllRentCycles(),
      rentRepo.getAllPayments(),
      rentRepo.getAllExpenses(),
      houseRepo.getHouses().first,
      tenantRepo.getAllTenants().first,
      tenantRepo.getAllTenancies().first,
      houseRepo.getAllUnits().first,
    ]);

    final freshData = await compute(_processReportsData, [results, range]);
    
    // Cache the fresh data
    AppPrefsCache.setCachedReport(range.label, jsonEncode(freshData.toJson()));
    
    // Update state with fresh data
    state = AsyncData(freshData);
    
    return freshData;
  }
}

// Top-level function for Isolate
ReportsData _processReportsData(List<dynamic> input) {
    final results = input[0] as List<dynamic>;
    final range = input[1] as ReportRange;

    final allRentCycles = results[0] as List<RentCycle>;
    final allPayments = results[1] as List<Payment>;
    final allExpenses = results[2] as List<Expense>;
    final allHouses = results[3] as List<House>;
    final allTenants = results[4] as List<Tenant>;
    final allTenancies = results[5] as List<Tenancy>;
    final allUnits = results[6] as List<Unit>;

    // 1. Financials (Selected Range)
    final currentCycles = allRentCycles.where((c) {
       final date = c.billPeriodStart ?? c.billGeneratedDate;
       return date.isAfter(range.start.subtract(const Duration(seconds: 1))) && 
              date.isBefore(range.end.add(const Duration(seconds: 1)));
    }).toList();
    
    double totalExpected = 0;
    double accrualPaid = 0; // Paid specifically for this month's bills
    
    for (final c in currentCycles) {
      totalExpected += c.totalDue;
      accrualPaid += c.totalPaid;
    }
    final totalPending = max(0.0, totalExpected - accrualPaid);

    // 2. Expenses & Net Profit
    final rangeExpenses = allExpenses.where((e) {
       return e.date.isAfter(range.start.subtract(const Duration(seconds: 1))) && 
              e.date.isBefore(range.end.add(const Duration(seconds: 1)));
    }).toList();
    
    final totalExpenses = rangeExpenses.fold(0.0, (sum, item) => sum + item.amount);

    // 3. Payment Methods (Selected Range) - CASH BASIS
    final rangePayments = allPayments.where((p) {
        return p.date.isAfter(range.start.subtract(const Duration(seconds: 1))) && 
               p.date.isBefore(range.end.add(const Duration(seconds: 1)));
    }).toList();

    Map<String, double> paymentMethods = {};
    double totalCashCollected = 0;
    for (final p in rangePayments) {
        paymentMethods[p.method] = (paymentMethods[p.method] ?? 0) + p.amount;
        totalCashCollected += p.amount;
    }
    
    // Net Profit = Cash In - Cash Out
    final netProfit = totalCashCollected - totalExpenses;

    // 4. Revenue Trend (Lookback from Range End)
    List<MonthlyStats> revenueTrend = [];
    double previousMonthCollected = 0;
    
    final trendEnd = range.end;
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(trendEnd.year, trendEnd.month - i, 1);
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
      
      // Track previous month relative to the FIRST month in our current range
      // (Simplified logic to maintain UI MoM badge)
      if (i == 1) {
        previousMonthCollected = collected;
      }
    }

    // 4b. Expense Trend (Lookback from Range End)
    List<MonthlyStats> expenseTrend = [];
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(trendEnd.year, trendEnd.month - i, 1);
      final monthKey = DateFormat('yyyy-MM').format(date);
      final monthLabel = DateFormat('MMM').format(date);
      
      final monthExpenses = allExpenses.where((e) {
        final eMonth = DateFormat('yyyy-MM').format(e.date);
        return eMonth == monthKey;
      }).toList();
      
      double total = monthExpenses.fold(0.0, (sum, e) => sum + e.amount);
      expenseTrend.add(MonthlyStats(monthLabel: monthLabel, collected: total, pending: 0));
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

    // 7. Recent Activity (Filtered by Range)
    final filteredPayments = rangePayments;
    filteredPayments.sort((a, b) => b.date.compareTo(a.date));
    final recentPayments = filteredPayments.take(10).toList();

    return ReportsData(
      totalCollected: totalCashCollected,
      totalPending: totalPending,
      totalExpected: totalExpected,
      totalExpenses: totalExpenses,
      netProfit: netProfit,
      previousMonthCollected: previousMonthCollected,
      totalUnits: totalUnits,
      occupiedUnits: activeTenanciesCount,
      vacantUnits: vacantUnits,
      recentPayments: recentPayments,
      revenueTrend: revenueTrend,
      expenseTrend: expenseTrend,
      paymentMethods: paymentMethods,
      topDefaulters: defaulters,
      propertyPerformance: propertyPerformance,
    );
}
