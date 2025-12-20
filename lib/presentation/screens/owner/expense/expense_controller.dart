import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../domain/entities/expense.dart';
import '../../../providers/data_providers.dart'; 
import 'package:uuid/uuid.dart';

part 'expense_controller.g.dart';

@riverpod
class ExpenseController extends _$ExpenseController {
  @override
  Stream<List<Expense>> build() {
    return ref.watch(expenseRepositoryProvider).watchAllExpenses();
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required DateTime date,
    required String category,
    String? notes,
    String? receiptPath,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final expense = Expense(
      id: const Uuid().v4(),
      ownerId: uid,
      title: title,
      amount: amount,
      date: date,
      category: category,
      notes: notes,
      receiptPath: receiptPath,
    );
    await ref.read(expenseRepositoryProvider).addExpense(expense);
  }

  Future<void> deleteExpense(String id) async {
    await ref.read(expenseRepositoryProvider).deleteExpense(id);
  }
}
