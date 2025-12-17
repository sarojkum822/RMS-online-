import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'house_controller.dart';
import '../../../../domain/entities/house.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../presentation/providers/data_providers.dart'; // storageServiceProvider
import '../settings/owner_controller.dart';

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
  
  File? _selectedImage;
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
      // Check Plan Limit for New House
      if (widget.house == null && _unitsCtrl.text.isNotEmpty) {
         final units = int.tryParse(_unitsCtrl.text) ?? 0;
         final owner = ref.read(ownerControllerProvider).value;
         final plan = owner?.subscriptionPlan ?? 'free';
         
         int limit = 2;
         if (plan == 'pro') limit = 20;
         if (plan == 'power') limit = 999999;
         
         if (units > limit) {
             showDialog(
               context: context, 
               builder: (_) => AlertDialog(
                 title: const Text('Limit Reached'),
                 content: Text('You cannot create more than $limit units on the ${plan.toUpperCase()} plan. Upgrade to add more.'),
                 actions: [
                   TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                   ElevatedButton(
                     onPressed: () {
                       Navigator.pop(context);
                       context.push('/owner/settings/subscription');
                     }, 
                     child: const Text('Upgrade')
                   ),
                 ],
               )
             );
             return;
         }
      }

      setState(() => _isLoading = true);
      try {
        String? imageBase64 = widget.house?.imageBase64;

        // 1. Process Image if Selected
        if (_selectedImage != null) {
          final storageService = ref.read(storageServiceProvider);
          // Compress aggressively (512x512, 60%) to ensure it fits in Firestore < 1MB
          final compressed = await storageService.compressImage(_selectedImage!, minWidth: 512, quality: 60);
          
          if (compressed != null) {
             final bytes = await compressed.readAsBytes();
             imageBase64 = base64Encode(bytes);
          } else {
             throw Exception('Failed to process image.');
          }
        }

        if (widget.house != null) {
          // Edit Mode
          final updatedHouse = House(
            id: widget.house!.id,
            name: _nameCtrl.text.toTitleCase(),
            address: _addressCtrl.text.toTitleCase(),
            notes: _notesCtrl.text,
            imageUrl: widget.house!.imageUrl, // Keep legacy URL
            imageBase64: imageBase64, // Update Base64
          );
          await ref.read(houseControllerProvider.notifier).updateHouse(updatedHouse);
        } else {
          // Add Mode
          // Fix: Removed direct repo.createHouse call which was causing duplicates
          
          await ref.read(houseControllerProvider.notifier).addHouse(
            _nameCtrl.text.toTitleCase(),
            _addressCtrl.text.toTitleCase(),
            _notesCtrl.text,
            int.tryParse(_unitsCtrl.text),
            imageUrl: null, 
            imageBase64: imageBase64,
          );
        }
        if (mounted) context.pop();
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
             content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'),
             backgroundColor: Colors.red,
           ));
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
            // Image Picker
            // Image Picker
            GestureDetector(
              onTap: () async {
                final picker = ref.read(storageServiceProvider);
                final file = await picker.pickImage(ImageSource.gallery);
                if (file != null) setState(() => _selectedImage = file);
              },
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                  image: _selectedImage != null 
                    ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                    : (widget.house?.imageBase64 != null 
                        ? DecorationImage(image: MemoryImage(base64Decode(widget.house!.imageBase64!)), fit: BoxFit.cover)
                        : (widget.house?.imageUrl != null 
                            ? DecorationImage(image: NetworkImage(widget.house!.imageUrl!), fit: BoxFit.cover)
                            : null)),
                ),
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3), // Keep semi-transparent for contrast over image
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add_a_photo, size: 40, color: Colors.white.withOpacity(0.9)),
                ),
              ),
            ),
            const SizedBox(height: 24),


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
                validator: (v) {
                   if (v != null && v.isNotEmpty) {
                      final n = int.tryParse(v);
                      if (n != null && n > 999999) return 'Maximum limit reached';
                   }
                   return null;
                },
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
