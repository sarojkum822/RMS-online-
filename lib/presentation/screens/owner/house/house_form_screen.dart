
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'house_controller.dart';
import '../../../../domain/entities/house.dart';
import '../../../../core/extensions/string_extensions.dart';

class HouseFormScreen extends ConsumerStatefulWidget {
  final House? house; // Optional for Edit
  const HouseFormScreen({super.key, this.house});

  @override
  ConsumerState<HouseFormScreen> createState() => _HouseFormScreenState();
}

class _HouseFormScreenState extends ConsumerState<HouseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _unitsCtrl = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.house != null) {
      _nameCtrl.text = widget.house!.name;
      _addressCtrl.text = widget.house!.address;
      _notesCtrl.text = widget.house!.notes ?? '';
    }
  }



  void _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        if (widget.house != null) {
          // Edit Mode
          final updatedHouse = House(
            id: widget.house!.id,
            name: _nameCtrl.text.toTitleCase(),
            address: _addressCtrl.text.toTitleCase(),
            notes: _notesCtrl.text,
            imageUrl: widget.house!.imageUrl, // Keep old url unless new file overwrites in repo
          );
          // If _selectedImage is not null, repo will upload it and replace url
          await ref.read(houseControllerProvider.notifier).updateHouse(updatedHouse);
        } else {
          // Add Mode
          await ref.read(houseControllerProvider.notifier).addHouse(
            _nameCtrl.text.toTitleCase(),
            _addressCtrl.text.toTitleCase(),
            _notesCtrl.text,
            int.tryParse(_unitsCtrl.text),
          );
        }
        if (mounted) context.pop();
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.house != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit House' : 'Add House')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Picker Removed as per request


            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'House Name', hintText: 'e.g. Sunset Villa'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Address', hintText: 'Enter full address'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            if (!isEditing) ...[
              TextFormField(
                controller: _unitsCtrl,
                decoration: const InputDecoration(labelText: 'Total Number of Flats / Units', hintText: 'Optional, e.g. 10'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes', hintText: 'Optional'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading ? const CircularProgressIndicator() : Text(isEditing ? 'Update House' : 'Save House'),
            ),
          ],
        ),
      ),
    );
  }
}
