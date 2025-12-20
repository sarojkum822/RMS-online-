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
  Future<List<RentCycle>> getRentCyclesForTenancy(String tenancyId); // Changed from Tenant to Tenancy
  Future<List<RentCycle>> getRentCyclesByTenancyAccess(String tenancyId, String ownerId); 
  Stream<List<RentCycle>> watchRentCyclesByTenancyAccess(String tenancyId, String ownerId);
  Future<List<RentCycle>> getRentCyclesForMonth(String month); // YYYY-MM
  Future<List<RentCycle>> getAllPendingRentCycles();
  Future<List<RentCycle>> getAllRentCycles();
  Future<RentCycle?> getRentCycle(String id);
  Future<String> createRentCycle(RentCycle rentCycle);
  Future<void> updateRentCycle(RentCycle rentCycle);
  Future<void> deleteRentCycle(RentCycle cycle);
  Future<void> recoverRentCycle(String id);
  Future<void> permanentlyDeleteRentCycle(RentCycle cycle);
  Future<List<RentCycle>> getDeletedRentCyclesForTenancy(String tenancyId);

  // Payments
  Future<List<Payment>> getAllPayments();
  Future<List<Payment>> getPaymentsForRentCycle(String rentCycleId);
  Future<List<Payment>> getPaymentsForRentCycleForTenant(String rentCycleId, String ownerId);
  Future<List<RentCycle>> getRentCyclesForTenant(String tenantId); // NEW: Clean Architecture for Tenant History
  Future<List<Payment>> getPaymentsForTenancy(String tenancyId); // Changed
  Future<List<Payment>> getPaymentsByTenancyAccess(String tenancyId, String ownerId);
  Stream<List<Payment>> watchPaymentsByTenancyAccess(String tenancyId, String ownerId);
  Future<List<Payment>> getRecentPayments(int limit);
  Future<DashboardStats> getDashboardStats(); 
  Future<List<Map<String, dynamic>>> getMonthlyRevenue(int months); // NEW: For charts 
  Future<String> recordPayment(Payment payment);
  Future<void> deletePayment(String id);
  Future<void> recoverPayment(String id);
  Future<void> permanentlyDeletePayment(String id);
  Future<List<Payment>> getDeletedPaymentsForRentCycle(String rentCycleId);
  
  // Electric Readings
  Future<void> addElectricReading(String unitId, DateTime date, double reading, {String? imagePath, double? rate});
  Future<List<double>> getElectricReadings(String unitId);
  Future<List<Map<String, dynamic>>> getElectricReadingsWithDetails(String unitId);
  Future<List<Map<String, dynamic>>> getElectricReadingsForTenant(String unitId, String ownerId);
  Future<Map<String, double>?> getLastElectricReading(String unitId);
  
  // Expenses
  Future<void> addExpense(Expense expense);
  Future<List<Expense>> getExpenses(String month);
  Future<List<Expense>> getAllExpenses();
  Future<void> deleteExpense(String id);
}
