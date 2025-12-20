import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/snackbar_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'expense_controller.dart';

class AddExpenseModal extends ConsumerStatefulWidget {
  const AddExpenseModal({super.key});

  @override
  ConsumerState<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends ConsumerState<AddExpenseModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Repairs';
  bool _isLoading = false;

  final List<String> _categories = ['Repairs', 'Maintenance', 'Electricity', 'Water', 'Tax', 'Salary', 'Cleaning', 'Other'];

  File? _pickedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Repairs': return Icons.build;
      case 'Maintenance': return Icons.handyman;
      case 'Electricity': return Icons.bolt;
      case 'Water': return Icons.water_drop;
      case 'Tax': return Icons.receipt_long;
      case 'Salary': return Icons.people;
      case 'Cleaning': return Icons.cleaning_services;
      default: return Icons.more_horiz;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 20, 
        right: 20, 
        top: 24, 
        bottom: MediaQuery.of(context).viewInsets.bottom + 20
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor, // Match scaffold for consistency
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24))
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView( // Add Scroll View for smaller screens
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add Expense', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))
                ],
              ),
              const SizedBox(height: 20),
              
              // Amount
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  labelText: 'Amount',
                  floatingLabelAlignment: FloatingLabelAlignment.center,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: theme.cardColor,
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              // Title
              TextFormField(
                controller: _titleCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'What was this for?',
                  hintText: 'e.g. Plumber for Flat 101',
                  prefixIcon: const Icon(Icons.edit_note),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              // Category & Date Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(_getCategoryIcon(_selectedCategory), size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: theme.cardColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14)
                      ),
                      isExpanded: true,
                      items: _categories.map((c) => DropdownMenuItem(
                        value: c, 
                        child: Row(
                          children: [
                            Icon(_getCategoryIcon(c), size: 18, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(c, style: GoogleFonts.outfit(fontSize: 14)),
                          ],
                        )
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: theme.cardColor,
                          prefixIcon: const Icon(Icons.calendar_today, size: 18),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14)
                        ),
                        child: Text(DateFormat('dd MMM').format(_selectedDate), style: GoogleFonts.outfit(fontSize: 14)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Receipt Image Picker
              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 80,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                     color: theme.cardColor,
                     borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                       Container(
                         width: 50, height: 50,
                         decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                         child: _pickedImage != null 
                            ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(_pickedImage!, fit: BoxFit.cover))
                            : Icon(Icons.receipt_long, color: theme.colorScheme.primary),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               _pickedImage != null ? 'Receipt Attached' : 'Attach Receipt', 
                               style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)
                             ),
                             Text(
                               _pickedImage != null ? 'Tap to change' : 'Photo from Gallery', 
                               style: GoogleFonts.outfit(fontSize: 12, color: theme.hintColor)
                             ),
                           ],
                         ),
                       ),
                       if (_pickedImage != null)
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () => setState(() => _pickedImage = null),
                          )
                       else
                          const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              
              // Notes
               TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: theme.cardColor,
                ),
              ),
              const SizedBox(height: 24),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
                  ),
                  onPressed: _isLoading ? null : _saveExpense, 
                  child: _isLoading 
                     ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                     : Text('Save Expense', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final amount = double.tryParse(_amountCtrl.text) ?? 0.0;
      await ref.read(expenseControllerProvider.notifier).addExpense(
        title: _titleCtrl.text.trim(),
        amount: amount,
        date: _selectedDate,
        category: _selectedCategory,
        notes: _notesCtrl.text.trim(),
        receiptPath: _pickedImage?.path, // Pass path
      );
      
      if (mounted) {
        Navigator.pop(context);
        SnackbarUtils.showSuccess(context, 'Expense Added Successfully');
      }
    } catch (e) {
      if (mounted) SnackbarUtils.showError(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
