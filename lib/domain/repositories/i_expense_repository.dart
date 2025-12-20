import '../../../../domain/entities/expense.dart';

abstract class IExpenseRepository {
  Future<List<Expense>> getAllExpenses();
  Future<void> addExpense(Expense expense);
  Future<void> deleteExpense(String id);
  Future<void> updateExpense(Expense expense);
  Stream<List<Expense>> watchAllExpenses();
}
