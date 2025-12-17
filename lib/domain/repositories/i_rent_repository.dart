import '../../features/rent/domain/entities/rent_cycle.dart';
import '../entities/expense.dart';

class DashboardStats {
  final double totalCollected;
  final double totalPending;
  final double thisMonthCollected;
  final double thisMonthPending;

  DashboardStats({
    required this.totalCollected,
    required this.totalPending,
    required this.thisMonthCollected,
    required this.thisMonthPending,
  });
}

abstract class IRentRepository {
  // Rent Cycles
  Future<List<RentCycle>> getRentCyclesForTenant(int tenantId);
  Future<List<RentCycle>> getRentCyclesByTenantAccess(int tenantId, String ownerId); // NEW: For Tenant Dashboard
  Stream<List<RentCycle>> watchRentCyclesByTenantAccess(int tenantId, String ownerId); // NEW: Real-time
  Future<List<RentCycle>> getRentCyclesForMonth(String month); // YYYY-MM
  Future<List<RentCycle>> getAllPendingRentCycles(); // NEW: Fetch all unpaid bills
  Future<List<RentCycle>> getAllRentCycles(); // NEW: Optimized Fetch for Reports
  Future<RentCycle?> getRentCycle(int id);
  Future<int> createRentCycle(RentCycle rentCycle);
  Future<void> updateRentCycle(RentCycle rentCycle);
  Future<void> deleteRentCycle(RentCycle cycle);

  // Payments
  Future<List<Payment>> getAllPayments(); // NEW: Optimized Fetch for Reports
  Future<List<Payment>> getPaymentsForRentCycle(int rentCycleId);
  Future<List<Payment>> getPaymentsForRentCycleForTenant(int rentCycleId, String ownerId); // NEW
  Future<List<Payment>> getPaymentsForTenant(int tenantId);
  Future<List<Payment>> getPaymentsByTenantAccess(int tenantId, String ownerId); // NEW: For Tenant Dashboard
  Stream<List<Payment>> watchPaymentsByTenantAccess(int tenantId, String ownerId); // NEW: Real-time
  Future<List<Payment>> getRecentPayments(int limit);
  Future<DashboardStats> getDashboardStats(); 
  Future<int> recordPayment(Payment payment);
  Future<void> deletePayment(int id);
  Future<void> addElectricReading(int unitId, DateTime date, double reading, {String? imagePath, double? rate});
  Future<List<double>> getElectricReadings(int unitId);
  Future<List<Map<String, dynamic>>> getElectricReadingsWithDetails(int unitId);
  Future<List<Map<String, dynamic>>> getElectricReadingsForTenant(int unitId, String ownerId); // NEW
  Future<Map<String, double>?> getLastElectricReading(int unitId);
  
  // Expenses
  Future<void> addExpense(Expense expense);
  Future<List<Expense>> getExpenses(String month);
  Future<List<Expense>> getAllExpenses();
  Future<void> deleteExpense(int id);
}
