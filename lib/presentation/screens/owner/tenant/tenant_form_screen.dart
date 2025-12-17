import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io'; 
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'tenant_controller.dart';
import '../house/house_controller.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../../domain/entities/tenant.dart';

class TenantFormScreen extends ConsumerStatefulWidget {
  final Tenant? tenant; // Optional for Edit Mode
  const TenantFormScreen({super.key, this.tenant});

  @override
  ConsumerState<TenantFormScreen> createState() => _TenantFormScreenState();
}

class _TenantFormScreenState extends ConsumerState<TenantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _passwordCtrl;
  late TextEditingController _rentCtrl; 
  late TextEditingController _electricCtrl; 
  
  int? _selectedHouseId;
  int? _selectedUnitId;
  File? _selectedImage;
  bool _isLoading = false;

  bool get _isEditing => widget.tenant != null;

  @override
  void initState() {
    super.initState();
    final t = widget.tenant;
    _nameCtrl = TextEditingController(text: t?.name ?? '');
    _phoneCtrl = TextEditingController(text: t?.phone ?? '');
    _emailCtrl = TextEditingController(text: t?.email ?? '');
    _passwordCtrl = TextEditingController(); // Empty for security, optional in edit
    _rentCtrl = TextEditingController(text: t?.agreedRent?.toString() ?? '');
    _electricCtrl = TextEditingController(); // usually cleared for new reading, but maybe N/A for edit
    
    if (_isEditing) {
      _selectedHouseId = t!.houseId;
      _selectedUnitId = t.unitId;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _rentCtrl.dispose();
    _electricCtrl.dispose();
    super.dispose();
  }

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
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Tenant' : 'Add Tenant'), 
        elevation: 0, 
        backgroundColor: theme.appBarTheme.backgroundColor, 
        foregroundColor: theme.appBarTheme.foregroundColor
      ),
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
                  backgroundColor: theme.cardColor,
                  backgroundImage: _selectedImage != null 
                      ? FileImage(_selectedImage!) 
                      : (widget.tenant?.imageBase64 != null 
                          ? MemoryImage(base64Decode(widget.tenant!.imageBase64!))
                      : (widget.tenant?.imageUrl != null 
                            ? CachedNetworkImageProvider(widget.tenant!.imageUrl!) as ImageProvider 
                            : null)),
                  child: (_selectedImage == null && widget.tenant?.imageUrl == null && widget.tenant?.imageBase64 == null)
                      ? Icon(Icons.add_a_photo, size: 30, color: theme.hintColor)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(child: Text(_isEditing ? 'Tap to Change Photo' : 'Add Photo', style: TextStyle(color: theme.hintColor))),
            const SizedBox(height: 24),

            if (!_isEditing) ...[
              Text('Assign Property', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              // House Selection
              housesValue.when(
                data: (houses) => DropdownButtonFormField<int>(
                  value: _selectedHouseId,
                  decoration: InputDecoration(
                    labelText: 'Select House',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: houses.map((h) => DropdownMenuItem(value: h.id, child: Text(h.name))).toList(),
                  onChanged: _isEditing ? null : (val) { // Lock house in edit mode
                    setState(() {
                      _selectedHouseId = val;
                      _selectedUnitId = null; 
                      _rentCtrl.clear();
                    });
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) => v == null ? 'Required' : null,
                ),
                error: (e, _) => Text('Error loading houses: $e'),
                loading: () => const LinearProgressIndicator(),
              ),
              const SizedBox(height: 16),
              
              // Unit Selection
              if (_selectedHouseId != null)
                  Consumer(
                    builder: (context, ref, child) {
                      final unitsAsync = ref.watch(availableUnitsProvider(_selectedHouseId!));
                      return unitsAsync.when(
                        data: (units) {
                           if (units.isEmpty) return const Text('No available flats in this property.', style: TextStyle(color: Colors.red));
                           
                           return DropdownButtonFormField<int>(
                              value: _selectedUnitId,
                              decoration: InputDecoration(
                                labelText: 'Select Flat / Unit',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                               items: units.map((u) {
                                  // Label logic...
                                 final label = StringBuffer(u.nameOrNumber);
                                 if (u.bhkType != null) label.write(' • ${u.bhkType}');
                                 label.write(' • ₹${u.baseRent}');
                                 
                                 return DropdownMenuItem(value: u.id, child: Text(label.toString(), style: const TextStyle(fontSize: 14)));
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
                
              const SizedBox(height: 24),
            ],
             
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
              decoration: InputDecoration(
                labelText: _isEditing ? 'New Password (Optional)' : 'Password (For Tenant Login)', 
                helperText: _isEditing ? 'Leave empty to keep current password' : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
              ),
              obscureText: false, 
              validator: (v) {
                if (_isEditing && (v == null || v.isEmpty)) return null; // Optional in edit
                if (v == null || v.length < 6) return 'Min 6 chars';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _rentCtrl,
              decoration: InputDecoration(
                labelText: 'Agreed Rent Amount', 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.currency_rupee),
              ),
              keyboardType: TextInputType.number,
            ),
            
            if (!_isEditing) ...[
              const SizedBox(height: 16),
              FormField<String>( // Dummy field for visual consistency if needed, but keeping actual logic simple
                 builder: (_) => TextFormField(
                  controller: _electricCtrl,
                  decoration: InputDecoration(
                    labelText: 'Initial Electric Reading (Optional)',
                    helperText: 'Current meter reading',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.electric_meter),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],

            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_isEditing ? 'Update Tenant' : 'Save Tenant', style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEditing && (_selectedHouseId == null || _selectedUnitId == null)) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select property details')));
       return;
    }

    setState(() => _isLoading = true);
    final rent = double.tryParse(_rentCtrl.text);

    try {
      if (_isEditing) {
        // UPDATE Logic
        final updatedTenant = widget.tenant!.copyWith(
          name: _nameCtrl.text.trim().toTitleCase(),
          phone: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim().toLowerCase(),
          agreedRent: rent,
          // Only update password if provided
          password: _passwordCtrl.text.isNotEmpty ? _passwordCtrl.text.trim() : widget.tenant!.password,
        );
        
        await ref.read(tenantControllerProvider.notifier).updateTenant(updatedTenant, imageFile: _selectedImage);

        // Also update Auth if credentials changed (Advanced: handled in controller usually or skip for now)
        if (_passwordCtrl.text.isNotEmpty || _emailCtrl.text.trim() != widget.tenant!.email) {
           // We might need a separate call for auth update if repository doesn't handle it fully automatically 
           // But assumed repository/controller handles basic sync.
        }

      } else {
         // CREATE Logic
         final initialElectric = double.tryParse(_electricCtrl.text);
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
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEditing ? 'Tenant updated' : 'Tenant added')));
      }

    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceAll('Exception: ', '');
        DialogUtils.showErrorDialog(context, title: 'Error', message: msg);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
