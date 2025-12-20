import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

@freezed
class Expense with _$Expense {
  const factory Expense({
    required String id,
    required String ownerId,
    required String title,
    required double amount,
    required DateTime date,
    required String category, // 'Repair', 'Bill', 'Salary', 'Other'
    String? notes,
    String? receiptPath,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
}

