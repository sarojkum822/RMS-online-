import '../entities/rent_cycle.dart';
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
  Future<List<RentCycle>> getRentCyclesForMonth(String month); // YYYY-MM
  Future<RentCycle?> getRentCycle(int id);
  Future<int> createRentCycle(RentCycle rentCycle);
  Future<void> updateRentCycle(RentCycle rentCycle);

  // Payments
  Future<List<Payment>> getPaymentsForRentCycle(int rentCycleId);
  Future<List<Payment>> getPaymentsForTenant(int tenantId);
  Future<List<Payment>> getRecentPayments(int limit);
  Future<DashboardStats> getDashboardStats(); 
  Future<int> recordPayment(Payment payment);
  Future<void> addElectricReading(int unitId, DateTime date, double reading);
  Future<List<double>> getElectricReadings(int unitId); // Returning list of readings (just values? or objects?)
  
  // Expenses
  Future<void> addExpense(Expense expense);
  Future<List<Expense>> getExpenses(String month);
  Future<List<Expense>> getAllExpenses();
  Future<void> deleteExpense(int id);
}
