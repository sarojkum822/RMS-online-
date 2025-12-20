import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/datasources/local/database.dart' as db;
import '../../../../domain/entities/expense.dart';
import '../../../../domain/repositories/i_expense_repository.dart';

class ExpenseRepositoryImpl implements IExpenseRepository {
  final db.AppDatabase _db;
  final FirebaseAuth _auth;

  ExpenseRepositoryImpl(this._db, {FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  String? get _ownerId => _auth.currentUser?.uid;



  @override
  Future<void> addExpense(Expense expense) async {
    final ownerId = _ownerId;
    if (ownerId == null) throw Exception('No user logged in');
    
    await _db.into(_db.expenses).insert(db.ExpensesCompanion.insert(
      id: expense.id,
      ownerId: ownerId, // Use actual Firebase Auth UID
      title: expense.title,
      amount: expense.amount,
      date: expense.date,
      category: expense.category,
      description: Value(expense.notes),
      receiptPath: Value(expense.receiptPath),
    ));
  }
  
  @override
  Future<void> updateExpense(Expense expense) async {
    final ownerId = _ownerId;
    if (ownerId == null) return;
    
    await (_db.update(_db.expenses)
      ..where((tbl) => tbl.id.equals(expense.id))
      ..where((tbl) => tbl.ownerId.equals(ownerId)) // Ensure owner scope
    ).write(db.ExpensesCompanion(
       title: Value(expense.title),
       amount: Value(expense.amount),
       category: Value(expense.category),
       description: Value(expense.notes),
       receiptPath: Value(expense.receiptPath),
    ));
  }

  @override
  Future<List<Expense>> getAllExpenses() async {
    final ownerId = _ownerId;
    if (ownerId == null) return [];
    
    final rows = await (_db.select(_db.expenses)
      ..where((tbl) => tbl.ownerId.equals(ownerId)) // Filter by owner
    ).get();
    
    return rows.map((r) => Expense(
      id: r.id,
      ownerId: r.ownerId,
      title: r.title,
      amount: r.amount,
      date: r.date,
      category: r.category,
      notes: r.description,
      receiptPath: r.receiptPath,
    )).toList();
  }
  @override
  Future<void> deleteExpense(String id) async {
    final ownerId = _ownerId;
    if (ownerId == null) return;
    
    await (_db.delete(_db.expenses)
      ..where((tbl) => tbl.id.equals(id))
      ..where((tbl) => tbl.ownerId.equals(ownerId))
    ).go();
  }

  @override
  Stream<List<Expense>> watchAllExpenses() {
    final ownerId = _ownerId;
    if (ownerId == null) return Stream.value([]);
    
    return (_db.select(_db.expenses)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)])
    ).watch().map((rows) => rows.map((r) => Expense(
      id: r.id,
      ownerId: r.ownerId,
      title: r.title,
      amount: r.amount,
      date: r.date,
      category: r.category,
      notes: r.description,
      receiptPath: r.receiptPath,
    )).toList());
  }
}

