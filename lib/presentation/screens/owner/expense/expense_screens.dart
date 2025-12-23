import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../domain/entities/expense.dart';
import '../../../providers/data_providers.dart'; 
import 'expense_controller.dart';
import '../../../../core/extensions/string_extensions.dart';
import 'package:kirayabook/presentation/widgets/empty_state_widget.dart';
import 'package:kirayabook/presentation/widgets/skeleton_loader.dart';

// -----------------------------------------------------------------------------
// Add Expense Screen
// -----------------------------------------------------------------------------
class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Maintenance';
  bool _isLoading = false;

  final List<String> _categories = ['Maintenance', 'Electricity', 'Water', 'Tax', 'Salary', 'Repairs', 'Other'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final expensesAsync = ref.watch(expenseControllerProvider);
                  return expensesAsync.when(
                    data: (expenses) {
                      final suggestions = expenses.map((e) => e.title).toSet().toList();
                      return Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                          return suggestions.where((option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (String selection) {
                           _titleCtrl.text = selection;
                        },
                        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                          if (_titleCtrl.text.isNotEmpty && controller.text.isEmpty) {
                            controller.text = _titleCtrl.text;
                          }
                          controller.addListener(() {
                            _titleCtrl.text = controller.text;
                          });
                          
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Broken Tap Repair'),
                            onFieldSubmitted: (value) => onFieldSubmitted(),
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          );
                        },
                      );
                    },
                    loading: () => TextFormField(
                      controller: _titleCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Broken Tap Repair'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    error: (e, _) => TextFormField(
                      controller: _titleCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Broken Tap Repair'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountCtrl,
                      decoration: const InputDecoration(labelText: 'Amount (₹)', prefixText: '₹ '),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final val = double.tryParse(v);
                        if (val == null || val <= 0) return 'Must be > 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context, 
                    initialDate: _selectedDate, 
                    firstDate: DateTime(2020), 
                    lastDate: DateTime.now()
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date', suffixIcon: Icon(Icons.calendar_today)),
                  child: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Notes', hintText: 'Optional details...'),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary),
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading ? CircularProgressIndicator(color: theme.colorScheme.onPrimary) : const Text('Save Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final amount = double.parse(_amountCtrl.text);
        final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
        final expense = Expense(
          id: '0',
          ownerId: uid,
          title: _titleCtrl.text.toTitleCase(),
          amount: amount,
          date: _selectedDate,
          category: _selectedCategory,
          notes: _notesCtrl.text,
        );

        await ref.read(rentRepositoryProvider).addExpense(expense);
        if (mounted) {
           context.pop(); 
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}

// -----------------------------------------------------------------------------
// Expense List Screen
// -----------------------------------------------------------------------------
class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Expense History')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_expense',
        onPressed: () {
          context.push('/owner/expenses/add').then((_) {
             setState(() {}); 
          });
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Expense>>(
        future: ref.read(rentRepositoryProvider).getAllExpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SkeletonList();
          }
          if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: theme.colorScheme.error)));
          }
          final expenses = snapshot.data ?? [];
          if (expenses.isEmpty) {
             return EmptyStateWidget(
               title: 'No Expenses Recorded',
               subtitle: 'Track maintenance, bills, and property costs here.',
               icon: Icons.receipt_long_outlined,
               buttonText: 'Add Expense',
               onButtonPressed: () {
                  context.push('/owner/expenses/add').then((_) {
                     setState(() {}); 
                  });
               },
             );
          }
          
          expenses.sort((a,b) => b.date.compareTo(a.date));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: expenses.length,
            separatorBuilder: (_,__) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final e = expenses[index];
              return Card(
                elevation: 0,
                color: theme.cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: isDark ? const BorderSide(color: Colors.white12) : BorderSide(color: Colors.grey.shade200)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    child: const Icon(Icons.receipt_long, color: Color(0xFFEF4444), size: 20),
                  ),
                  title: Text(e.title, style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
                  subtitle: Text('${DateFormat('dd MMM').format(e.date)} • ${e.category}', style: TextStyle(color: theme.textTheme.bodySmall?.color)),
                  trailing: Text('-₹${e.amount.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 16)),
                  onLongPress: () async {
                     final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
                        title: const Text('Delete Expense?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                        ],
                     ));
                     if (confirm == true) {
                        await ref.read(rentRepositoryProvider).deleteExpense(e.id);
                        setState(() {});
                     }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
