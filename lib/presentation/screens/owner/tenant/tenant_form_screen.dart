import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io'; 
import 'package:image_picker/image_picker.dart';
import 'tenant_controller.dart';
import '../house/house_controller.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/utils/dialog_utils.dart';

class TenantFormScreen extends ConsumerStatefulWidget {
  const TenantFormScreen({super.key});

  @override
  ConsumerState<TenantFormScreen> createState() => _TenantFormScreenState();
}

class _TenantFormScreenState extends ConsumerState<TenantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _rentCtrl = TextEditingController(); 
  final _electricCtrl = TextEditingController(); 
  
  // Manual Unit Entry Fields REMOVED
  
  int? _selectedHouseId;
  int? _selectedUnitId;
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final housesValue = ref.watch(houseControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Tenant'), elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Image Picker (Circle)
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                  child: _selectedImage == null
                      ? const Icon(Icons.add_a_photo, size: 30, color: Colors.grey)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(child: Text('Add Photo', style: TextStyle(color: Colors.grey))),
            const SizedBox(height: 24),

            Text('Assign Property', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // House Selection
            housesValue.when(
              data: (houses) => DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Select House',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: houses.map((h) => DropdownMenuItem(value: h.id, child: Text(h.name))).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedHouseId = val;
                  });
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (v) => v == null ? 'Required' : null,
              ),
              error: (e, _) => Text('Error loading houses: $e'),
              loading: () => const LinearProgressIndicator(),
            ),
            const SizedBox(height: 16),
            
            // Unit Selection (Only if House Selected)
            if (_selectedHouseId != null) ...[
                Consumer(
                  builder: (context, ref, child) {
                    final unitsAsync = ref.watch(availableUnitsProvider(_selectedHouseId!));
                    return unitsAsync.when(
                      data: (units) {
                         if (units.isEmpty) return const Text('No available flats in this property.', style: TextStyle(color: Colors.red));
                         
                         return DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'Select Flat / Unit',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                             items: units.map((u) {
                               final label = StringBuffer(u.nameOrNumber);
                               if (u.bhkType != null) label.write(' • ${u.bhkType}');
                               if (u.furnishingStatus != null) label.write(' • ${u.furnishingStatus}');
                               label.write(' • ₹${u.baseRent}');
                               
                               return DropdownMenuItem(
                                 value: u.id,
                                 child: Text(label.toString(), style: const TextStyle(fontSize: 14)),
                               );
                             }).toList(),
                             onChanged: (val) {
                               setState(() {
                                 _selectedUnitId = val;
                                 if (val != null) {
                                   final selectedUnit = units.firstWhere((u) => u.id == val);
                                   _rentCtrl.text = selectedUnit.baseRent.toString();
                                 }
                               });
                             },
                             validator: (v) => v == null ? 'Required' : null,
                          );
                      },
                      error: (e, _) => Text('Error: $e'),
                      loading: () => const LinearProgressIndicator(),
                    );
                  },
                ),
            ],
              
            const SizedBox(height: 24),
             
            Text('Tenant Details', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
             const SizedBox(height: 16),

            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              decoration: InputDecoration(labelText: 'Phone', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              decoration: InputDecoration(labelText: 'Email (Login ID)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              textCapitalization: TextCapitalization.none,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.isEmpty ? 'Required for Login' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordCtrl,
              decoration: InputDecoration(labelText: 'Password (For Tenant Login)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              obscureText: false, 
              validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
            ),
            const SizedBox(height: 16),
            
            // Agreed Rent Field
            TextFormField(
              controller: _rentCtrl,
              decoration: InputDecoration(
                labelText: 'Agreed Rent Amount (Optional)', 
                helperText: 'Leave empty to use Unit\'s default rent',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.currency_rupee),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Electric Reading Field
            TextFormField(
              controller: _electricCtrl,
              decoration: InputDecoration(
                labelText: 'Initial Electric Reading (Optional)',
                helperText: 'Current meter reading (e.g. 1045.5)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.electric_meter),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),

            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : () async {
                  if (_formKey.currentState!.validate() && _selectedHouseId != null && _selectedUnitId != null) {
                     setState(() => _isLoading = true);
                     
                     final rent = double.tryParse(_rentCtrl.text);
                     final initialElectric = double.tryParse(_electricCtrl.text);

                     try {
                       await ref.read(tenantControllerProvider.notifier).registerTenant(
                         houseId: _selectedHouseId!,
                         unitId: _selectedUnitId!,
                         tenantName: _nameCtrl.text.trim().toTitleCase(),
                         phone: _phoneCtrl.text.trim(),
                         email: _emailCtrl.text.trim().toLowerCase(),
                         password: _passwordCtrl.text.trim(),
                         agreedRent: rent,
                         initialElectricReading: initialElectric,
                         imageFile: _selectedImage, 
                       );

                       if (mounted) context.pop();
                       } catch (e) {
                         if (mounted) {
                           // Extract clean message
                           final msg = e.toString().replaceAll('Exception: ', '');
                           DialogUtils.showErrorDialog(context, title: 'Registration Failed', message: msg);
                         }
                       } finally {
                        if (mounted) setState(() => _isLoading = false);
                     }
                  } else if (_selectedHouseId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a house')));
                  }
                },
                child: _isLoading 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text('Save Tenant', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
