import 'package:drift/drift.dart';
import '../../core/error/exception.dart';
import '../../domain/entities/rent_cycle.dart' as domain;
import '../../domain/repositories/i_rent_repository.dart';
import '../datasources/local/database.dart'; 
import '../../domain/entities/expense.dart' as domain;
import '../../core/services/notification_service.dart'; 

class RentRepositoryImpl implements IRentRepository {
  final AppDatabase _db;

  RentRepositoryImpl(this._db);

  @override
  Future<List<domain.RentCycle>> getRentCyclesForTenant(int tenantId) async {
    final cycles = await (_db.select(_db.rentCycles)..where((tbl) => tbl.tenantId.equals(tenantId))).get();
    return cycles.map((c) => _mapToDomain(c)).toList();
  }

  @override
  Future<List<domain.RentCycle>> getRentCyclesForMonth(String month) async {
    final cycles = await (_db.select(_db.rentCycles)..where((tbl) => tbl.month.equals(month))).get();
    return cycles.map((c) => _mapToDomain(c)).toList();
  }

  @override
  Future<domain.RentCycle?> getRentCycle(int id) async {
    final c = await (_db.select(_db.rentCycles)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    return c != null ? _mapToDomain(c) : null;
  }

  @override
  Future<int> createRentCycle(domain.RentCycle rentCycle) async {
    final id = await _db.into(_db.rentCycles).insert(RentCyclesCompanion(
      tenantId: Value(rentCycle.tenantId),
      month: Value(rentCycle.month),
      billNumber: Value(rentCycle.billNumber),
      billPeriodStart: Value(rentCycle.billPeriodStart),
      billPeriodEnd: Value(rentCycle.billPeriodEnd),
      billGeneratedDate: Value(rentCycle.billGeneratedDate),
      baseRent: Value(rentCycle.baseRent),
      electricAmount: Value(rentCycle.electricAmount),
      otherCharges: Value(rentCycle.otherCharges),
      discount: Value(rentCycle.discount),
      totalDue: Value(rentCycle.totalDue),
      totalPaid: Value(rentCycle.totalPaid),
      status: Value(rentCycle.status.index),
      dueDate: Value(rentCycle.dueDate),
      notes: Value(rentCycle.notes),
    ));

    if (rentCycle.dueDate != null) {
      try {
        await NotificationService().scheduleNotification(
          id: id,
          title: 'Rent Due Reminder',
          body: 'Rent for ${rentCycle.month} is due today.',
          scheduledDate: rentCycle.dueDate!,
        );
      } catch (e) {
        // Ignore notification errors
        print('Error scheduling notification: $e');
      }
    }

    return id;
  }

  @override
  Future<void> updateRentCycle(domain.RentCycle rentCycle) {
    return (_db.update(_db.rentCycles)..where((tbl) => tbl.id.equals(rentCycle.id))).write(RentCyclesCompanion(
       electricAmount: Value(rentCycle.electricAmount),
       otherCharges: Value(rentCycle.otherCharges),
       totalDue: Value(rentCycle.totalDue),
       totalPaid: Value(rentCycle.totalPaid),
       status: Value(rentCycle.status.index),
       notes: Value(rentCycle.notes),
    ));
  }

  @override
  Future<List<domain.Payment>> getPaymentsForRentCycle(int rentCycleId) async {
    final payments = await (_db.select(_db.payments)..where((tbl) => tbl.rentCycleId.equals(rentCycleId))).get();
    return payments.map((p) => _mapPaymentToDomain(p)).toList();
  }

  @override
  Future<List<domain.Payment>> getPaymentsForTenant(int tenantId) async {
    final payments = await (_db.select(_db.payments)..where((tbl) => tbl.tenantId.equals(tenantId))).get();
    return payments.map((p) => _mapPaymentToDomain(p)).toList();
  }

  @override
  Future<List<domain.Payment>> getRecentPayments(int limit) async {
    final payments = await (_db.select(_db.payments)
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)])
      ..limit(limit)
    ).get();
    return payments.map((p) => _mapPaymentToDomain(p)).toList();
  }

  @override
  Future<DashboardStats> getDashboardStats() async {
    final now = DateTime.now();
    final currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    final allCycles = await _db.select(_db.rentCycles).get();
    
    double totalCollected = 0;
    double totalPending = 0;
    double thisMonthCollected = 0;
    double thisMonthPending = 0;

    for (final c in allCycles) {
      // All Time
      totalCollected += c.totalPaid;
      totalPending += (c.totalDue - c.totalPaid);

      // This Month
      if (c.month == currentMonth) {
        thisMonthCollected += c.totalPaid;
        thisMonthPending += (c.totalDue - c.totalPaid);
      }
    }

    return DashboardStats(
      totalCollected: totalCollected,
      totalPending: totalPending,
      thisMonthCollected: thisMonthCollected,
      thisMonthPending: thisMonthPending,
    );
  }

  @override
  Future<int> recordPayment(domain.Payment payment) {
    return _db.transaction(() async {
      // 1. Insert Payment
      final id = await _db.into(_db.payments).insert(PaymentsCompanion(
        rentCycleId: Value(payment.rentCycleId),
        tenantId: Value(payment.tenantId),
        amount: Value(payment.amount),
        date: Value(payment.date),
        method: Value(payment.method),
        channelId: Value(payment.channelId),
        referenceId: Value(payment.referenceId),
        collectedBy: Value(payment.collectedBy),
        notes: Value(payment.notes),
      ));

      // 2. Update RentCycle Stats
      final cycle = await getRentCycle(payment.rentCycleId);
      if (cycle != null) {
        final newTotalPaid = cycle.totalPaid + payment.amount;
        domain.RentStatus newStatus = cycle.status;
        
        if (newTotalPaid >= cycle.totalDue) {
          newStatus = domain.RentStatus.paid;
        } else if (newTotalPaid > 0) {
          newStatus = domain.RentStatus.partial;
        }
        
        await updateRentCycle(cycle.copyWith(
          totalPaid: newTotalPaid,
          status: newStatus,
        ));
      }

      return id;
    });
  }

  // Mappers
  domain.RentCycle _mapToDomain(RentCycle c) { 
    return domain.RentCycle(
      id: c.id,
      tenantId: c.tenantId,
      month: c.month,
      billNumber: c.billNumber,
      billPeriodStart: c.billPeriodStart,
      billPeriodEnd: c.billPeriodEnd,
      billGeneratedDate: c.billGeneratedDate,
      baseRent: c.baseRent,
      electricAmount: c.electricAmount,
      otherCharges: c.otherCharges,
      discount: c.discount,
      totalDue: c.totalDue,
      totalPaid: c.totalPaid,
      status: domain.RentStatus.values[c.status],
      dueDate: c.dueDate,
      notes: c.notes,
    );
  }

  domain.Payment _mapPaymentToDomain(Payment p) {
    return domain.Payment(
      id: p.id,
      rentCycleId: p.rentCycleId,
      tenantId: p.tenantId,
      amount: p.amount,
      date: p.date,
      method: p.method,
      channelId: p.channelId,
      referenceId: p.referenceId,
      collectedBy: p.collectedBy,
      notes: p.notes,
    );
  }

  @override
  Future<void> addElectricReading(int unitId, DateTime date, double reading) async {
     await _db.into(_db.electricReadings).insert(ElectricReadingsCompanion(
      unitId: Value(unitId),
      readingDate: Value(date),
      currentReading: Value(reading),
      amount: const Value(0.0), // Initial reading has no cost
      notes: const Value('Initial Reading on Tenant Entry'),
    ));
  }

  @override
  Future<List<double>> getElectricReadings(int unitId) async {
    final readings = await (_db.select(_db.electricReadings)
      ..where((tbl) => tbl.unitId.equals(unitId))
      ..orderBy([(t) => OrderingTerm(expression: t.readingDate, mode: OrderingMode.asc)]))
      .get();
    return readings.map((r) => r.currentReading).toList();
  }

  // Expenses Implementation
  @override
  Future<void> addExpense(domain.Expense expense) async {
    await _db.into(_db.expenses).insert(ExpensesCompanion(
      title: Value(expense.title),
      amount: Value(expense.amount),
      date: Value(expense.date),
      category: Value(expense.category),
      description: Value(expense.notes),
      ownerId: const Value(1),
    ));
  }

  @override
  Future<List<domain.Expense>> getExpenses(String month) async {
    final start = DateTime.parse('$month-01');
    final end = DateTime(start.year, start.month + 1, 0); 
    
    final query = _db.select(_db.expenses)
      ..where((tbl) => tbl.date.isBetweenValues(start, end));
      
    final results = await query.get();
    return results.map((e) => _mapExpenseToDomain(e)).toList();
  }

  @override
  Future<List<domain.Expense>> getAllExpenses() async {
    final results = await _db.select(_db.expenses).get();
    return results.map((e) => _mapExpenseToDomain(e)).toList();
  }

  @override
  Future<void> deleteExpense(int id) async {
    await (_db.delete(_db.expenses)..where((tbl) => tbl.id.equals(id))).go();
  }

  domain.Expense _mapExpenseToDomain(dynamic e) { // dynamic to handle table row type
    return domain.Expense(
      id: e.id,
      title: e.title,
      amount: e.amount,
      date: e.date,
      category: e.category,
      notes: e.description,
    );
  }
}
