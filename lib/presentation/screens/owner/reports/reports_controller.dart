import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/rent_cycle.dart';
import '../../../../domain/entities/tenant.dart';

import '../../../providers/data_providers.dart';

part 'reports_controller.g.dart';

class MonthlyStats {
  final String monthLabel; // e.g., "Jan"
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
    final now = DateTime.now();
    final rentRepo = ref.watch(rentRepositoryProvider);
    final tenantRepo = ref.watch(tenantRepositoryProvider);
    final houseRepo = ref.watch(propertyRepositoryProvider);

    // 1. Financials (Current Month)
    final currentMonthStr = DateFormat('yyyy-MM').format(now);
    final currentCycles = await rentRepo.getRentCyclesForMonth(currentMonthStr);
    
    double totalExpected = 0;
    double totalPaid = 0; // Revenue
    
    for (final c in currentCycles) {
      totalExpected += c.totalDue;
      totalPaid += c.totalPaid;
    }
    final totalPending = totalExpected - totalPaid;

    // 2. Expenses & Net Profit
    final expensesList = await rentRepo.getExpenses(currentMonthStr);
    double totalExpenses = expensesList.fold(0, (sum, item) => sum + item.amount);
    final netProfit = totalPaid - totalExpenses;

    // 3. Payment Methods (This Month)
    // We iterate currentCycles -> get payments
    // NOTE: This assumes 'paid' amount matches payments. 
    Map<String, double> paymentMethods = {};
    for (final cycle in currentCycles) {
       // Only fetch payments if there is paid amount
       if (cycle.totalPaid > 0) {
          final payments = await rentRepo.getPaymentsForRentCycle(cycle.id);
          for (final p in payments) {
             paymentMethods[p.method] = (paymentMethods[p.method] ?? 0) + p.amount;
          }
       }
    }

    // 4. Revenue Trend (Last 6 Months)
    List<MonthlyStats> revenueTrend = [];
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthKey = DateFormat('yyyy-MM').format(date);
      final monthLabel = DateFormat('MMM').format(date);
      
      final cycles = await rentRepo.getRentCyclesForMonth(monthKey);
      double collected = 0;
      double pending = 0;

      for (final c in cycles) {
        collected += c.totalPaid;
        pending += (c.totalDue - c.totalPaid);
      }
      revenueTrend.add(MonthlyStats(monthLabel: monthLabel, collected: collected, pending: pending));
    }

    // 5. Occupancy & Property Performance
    final houses = await houseRepo.getHouses();
    int totalUnits = 0;
    List<PropertyRevenue> propertyPerformance = [];
    
    // We need All Rent Cycles to sum up All Time Revenue per property? Or just this month?
    // Usually "Performance" implies a period. Let's do "All Time" to show asset value, or "This Month".
    // Let's do "All Time" for now or "Yearly". "All Time" is easiest.
    
    for(final house in houses) {
      final units = await houseRepo.getUnits(house.id);
      totalUnits += units.length;
      
      double houseRevenue = 0;
      for (final unit in units) {
         // Get tenants for unit (active or inactive? All)
         // Check tenantRepo.getAllTenants() and filter?
         // This is heavy. Optimized:
         // Just fetch all tenants once outside loop.
      }
    }
    
    // Optimized Logic for Property Performance & Occupancy & Defaulters
    final allTenants = await tenantRepo.getAllTenants();
    final activeTenantsCount = allTenants.where((t) => t.status == TenantStatus.active).length;
    final vacantUnits = totalUnits - activeTenantsCount;

    // Property Performance (All Time Revenue)
    for(final house in houses) {
       double houseRevenue = 0;
       // Find units for house
       final units = await houseRepo.getUnits(house.id);
       for(final unit in units) {
          // Find tenants who lived in this unit
          final unitTenants = allTenants.where((t) => t.unitId == unit.id);
          for (final t in unitTenants) {
             final cycles = await rentRepo.getRentCyclesForTenant(t.id);
             for(final c in cycles) {
                houseRevenue += c.totalPaid;
             }
          }
       }
       propertyPerformance.add(PropertyRevenue(houseName: house.name, revenue: houseRevenue));
    }
    
    // Top Defaulters
    List<TenantDue> defaulters = [];
    for (final t in allTenants) {
       if (t.status == TenantStatus.active) { // Only track active tenants for now? Or all? Active makes sense for actionable.
          final cycles = await rentRepo.getRentCyclesForTenant(t.id);
          double due = 0;
          for (final c in cycles) {
             due += (c.totalDue - c.totalPaid);
          }
          if (due > 0) {
             defaulters.add(TenantDue(name: t.name, amount: due, phone: t.phone));
          }
       }
    }
    // Sort descending
    defaulters.sort((a, b) => b.amount.compareTo(a.amount));
    // Take top 5
    if (defaulters.length > 5) defaulters = defaulters.sublist(0, 5);

    // 6. Recent Activity
    final recentPayments = await rentRepo.getRecentPayments(10);
    
    return ReportsData(
      totalCollected: totalPaid,
      totalPending: totalPending,
      totalExpected: totalExpected,
      totalExpenses: totalExpenses,
      netProfit: netProfit,
      totalUnits: totalUnits,
      occupiedUnits: activeTenantsCount,
      vacantUnits: vacantUnits,
      recentPayments: recentPayments,
      revenueTrend: revenueTrend,
      paymentMethods: paymentMethods,
      topDefaulters: defaulters,
      propertyPerformance: propertyPerformance,
    );
  }
}
