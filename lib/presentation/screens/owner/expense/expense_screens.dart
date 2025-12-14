import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/expense.dart';
import '../../../providers/data_providers.dart';
import '../../../../core/extensions/string_extensions.dart';

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
              TextFormField(
                controller: _titleCtrl,
                textCapitalization: TextCapitalization.words, // User requested First Letter Capital
                decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Broken Tap Repair'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountCtrl,
                      decoration: const InputDecoration(labelText: 'Amount (₹)', prefixText: '₹ '),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
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
        final expense = Expense(
          id: 0,
          title: _titleCtrl.text.toTitleCase(),
          amount: amount,
          date: _selectedDate,
          category: _selectedCategory,
          notes: _notesCtrl.text,
        );

        await ref.read(rentRepositoryProvider).addExpense(expense);
        if (mounted) {
           context.pop(); // Close screen
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
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())).then((_) {
             setState(() {}); // Refresh list
          });
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Expense>>(
        future: ref.read(rentRepositoryProvider).getAllExpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: theme.colorScheme.error)));
          }
          final expenses = snapshot.data ?? [];
          if (expenses.isEmpty) {
             return Center(child: Text('No expenses recorded', style: TextStyle(color: theme.textTheme.bodyMedium?.color)));
          }
          
          // Sort by date desc
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
                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                    child: const Icon(Icons.receipt_long, color: Colors.red, size: 20),
                  ),
                  title: Text(e.title, style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
                  subtitle: Text('${DateFormat('dd MMM').format(e.date)} • ${e.category}', style: TextStyle(color: theme.textTheme.bodySmall?.color)),
                  trailing: Text('-₹${e.amount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                  onLongPress: () async {
                     // Delete option
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
