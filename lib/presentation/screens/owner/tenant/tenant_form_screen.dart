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
import '../../../../core/services/ocr_service.dart';
import 'package:easy_localization/easy_localization.dart'; // NEW IMPORT

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
  late TextEditingController _securityDepositCtrl;
  late TextEditingController _openingBalanceCtrl; // NEW
  late TextEditingController _tenancyNotesCtrl; // NEW
  late TextEditingController _initialReadingCtrl; 
  late TextEditingController _dateCtrl; // NEW for Date Picker
  // NEW Fields
  late TextEditingController _addressCtrl;
  late TextEditingController _idProofCtrl;
  late TextEditingController _memberCountCtrl;
  late TextEditingController _advanceAmountCtrl; 
  late TextEditingController _dobCtrl; // NEW
  bool _policeVerification = false;
  String? _selectedGender; // NEW

  
  String? _selectedHouseId;
  String? _selectedUnitId;
  File? _selectedImage;
  // New: Start Date
  DateTime _startDate = DateTime.now();
  
  String _formatDate(DateTime d) => "${d.day}/${d.month}/${d.year}"; // Simple formatter
  final bool _attendanceLoading = false; // Unused but kept if strictly needed, or just remove
  bool _isLoading = false;
  bool _isScanning = false; // NEW: Track OCR progress
  bool _obscurePassword = true; 
  // OcrService managed by Riverpod


  bool get _isEditing => widget.tenant != null;

  @override
  void initState() {
    super.initState();
    final t = widget.tenant;
    _nameCtrl = TextEditingController(text: t?.name ?? '');
    _phoneCtrl = TextEditingController(text: t?.phone ?? '');
    _emailCtrl = TextEditingController(text: t?.email ?? '');
    _passwordCtrl = TextEditingController(); 
    _rentCtrl = TextEditingController(); 
    _securityDepositCtrl = TextEditingController();
    _openingBalanceCtrl = TextEditingController(); // NEW
    _tenancyNotesCtrl = TextEditingController(); // NEW
    _initialReadingCtrl = TextEditingController(); 
    _dateCtrl = TextEditingController(text: _formatDate(_startDate));
    // NEW
    _addressCtrl = TextEditingController(text: t?.address ?? '');
    _idProofCtrl = TextEditingController(text: t?.idProof ?? '');
    _memberCountCtrl = TextEditingController(text: (t?.memberCount ?? 1).toString());
    _advanceAmountCtrl = TextEditingController(text: t?.advanceAmount.toString() ?? '');
    _dobCtrl = TextEditingController(text: t?.dob ?? '');
    _selectedGender = t?.gender;
    _policeVerification = t?.policeVerification ?? false;
    
    if (_isEditing) {
       // ...
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _rentCtrl.dispose();
    _securityDepositCtrl.dispose();
    _openingBalanceCtrl.dispose(); // NEW
    _tenancyNotesCtrl.dispose(); // NEW
    _initialReadingCtrl.dispose(); 
    _dateCtrl.dispose();
    _addressCtrl.dispose();
    _idProofCtrl.dispose();
    _memberCountCtrl.dispose();
    _advanceAmountCtrl.dispose();
    _dobCtrl.dispose();
    _initialReadingCtrl.dispose(); 
    _dateCtrl.dispose();
    _dateCtrl.dispose();
    // _ocrService disposed by provider
    super.dispose();
  }

  Future<void> _scanIdCard({bool isBackSide = false}) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isBackSide ? 'Scan ID Back Side' : 'Scan ID Document', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: Colors.indigo),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Colors.indigo),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source, 
      maxWidth: 1200, 
      maxHeight: 1200,
    );
    
    if (pickedFile != null) {
      if (!mounted) return;
      setState(() => _isScanning = true);
      try {
        final ocrService = ref.read(ocrServiceProvider);
        final result = await ocrService.scanImage(File(pickedFile.path));
        
        if (mounted) {
          bool dataFound = false;
          
          if (!isBackSide) {
             // Front Scan Logic
             if (result.name != null && _nameCtrl.text.isEmpty) {
                _nameCtrl.text = result.name!;
                dataFound = true;
             }
             if (result.idNumber != null) {
                _idProofCtrl.text = result.idNumber!;
                dataFound = true;
             }
             if (result.dob != null) {
                _dobCtrl.text = result.dob!;
             }
             if (result.gender != null) {
                setState(() => _selectedGender = result.gender);
             }
             
             // Check if address found on front (rare)
             if (result.address != null && _addressCtrl.text.isEmpty) {
                 _addressCtrl.text = result.address!;
                 dataFound = true;
             }
          } else {
             // Back Scan Logic (Focus on Address)
             if (result.address != null) {
                 _addressCtrl.text = result.address!;
                 dataFound = true;
             }
          }
          
          
          if (!dataFound && !isBackSide) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Could not extract details clearly. Please fill manually.'))
             );
          } else {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Details scanned successfully!'))
             );
          }
          
          // Trigger Back Side Scan if Address missing
          if (!isBackSide && _addressCtrl.text.isEmpty) {
               await showDialog(
                 context: context, 
                 builder: (ctx) => AlertDialog(
                    title: const Text("Scan Back Side?"),
                    content: const Text("Address was not detected on the front side. Would you like to scan the back side of the ID?"),
                    actions: [
                       TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Skip")),
                       FilledButton(
                          onPressed: () { 
                             Navigator.pop(ctx); 
                             _scanIdCard(isBackSide: true); 
                          }, 
                          child: const Text("Scan Back")
                       )
                    ],
                 )
               );
          }

        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Scan Error: $e'))
          );
        }
      } finally {
        if (mounted) setState(() => _isScanning = false);
      }
    }
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
    // Keep OCR Service alive while screen is open
    ref.watch(ocrServiceProvider);

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
                data: (houses) => DropdownButtonFormField<String>(
                  initialValue: _selectedHouseId,
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
                           if (units.isEmpty) {
                               return Container(
                                 width: double.infinity,
                                 margin: const EdgeInsets.symmetric(vertical: 8),
                                 padding: const EdgeInsets.all(24),
                                 decoration: BoxDecoration(
                                   color: theme.cardColor,
                                   borderRadius: BorderRadius.circular(20),
                                   border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                                   boxShadow: [
                                      BoxShadow(
                                         color: Colors.black.withValues(alpha: 0.03),
                                         blurRadius: 10,
                                         offset: const Offset(0, 4)
                                      )
                                   ]
                                 ),
                                 child: Column(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.playlist_add_rounded, size: 32, color: theme.colorScheme.primary),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "Units Not Configured",
                                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textTheme.titleMedium?.color),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                         "Here, add the number of units (flats/rooms/shops) you have at this property to start assigning tenants.",
                                         textAlign: TextAlign.center,
                                         style: GoogleFonts.outfit(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6), fontSize: 13),
                                      ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton(
                                           onPressed: () => context.push('/owner/houses/$_selectedHouseId'),
                                           style: OutlinedButton.styleFrom(
                                             side: BorderSide(color: theme.colorScheme.primary),
                                             padding: const EdgeInsets.symmetric(vertical: 12),
                                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                           ),
                                           child: Text('Configure Units', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                                        ),
                                      )
                                   ],
                                 ),
                               );
                           }
                           
                           return DropdownButtonFormField<String>(
                              initialValue: _selectedUnitId,
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
              validator: (v) => (v ?? '').isEmpty ? 'Required' : null, // Fix Null Check
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              decoration: InputDecoration(labelText: 'Phone', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              keyboardType: TextInputType.phone,
              validator: (v) => (v ?? '').isEmpty ? 'Required' : null, 
            ),

            // NEW: DOB and Gender
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dobCtrl,
                    decoration: InputDecoration(
                       labelText: 'DOB (DD/MM/YYYY)', 
                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                       suffixIcon: const Icon(Icons.cake)
                    ),
                    keyboardType: TextInputType.datetime,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                   child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (v) => setState(() => _selectedGender = v),
                   ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // NEW Fields
            TextFormField(
              controller: _addressCtrl,
              decoration: InputDecoration(labelText: 'Permanent Address', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
             TextFormField(
              controller: _idProofCtrl,
              decoration: InputDecoration(
                labelText: 'ID Proof Number (Aadhaar/PAN)', 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: _isScanning 
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : IconButton(
                      icon: const Icon(Icons.document_scanner_outlined, color: Colors.indigo),
                      onPressed: () => _scanIdCard(isBackSide: false),
                      tooltip: 'tenants.scan_id'.tr(),
                    ),
              ),
            ),
            if (!_isScanning)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'tenants.scan_tip'.tr(),
                  style: GoogleFonts.outfit(fontSize: 12, color: theme.hintColor, fontStyle: FontStyle.italic),
                ),
              ),
            const SizedBox(height: 16),
            Row(
               children: [
                 Expanded(
                   child: TextFormField(
                      controller: _memberCountCtrl,
                      decoration: InputDecoration(labelText: 'Members Count', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      keyboardType: TextInputType.number,
                   ),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: SwitchListTile(
                     title: const Text('Police Verified', style: TextStyle(fontSize: 14)),
                     value: _policeVerification,
                     onChanged: (v) => setState(() => _policeVerification = v),
                     contentPadding: EdgeInsets.zero,
                   ),
                 ),
               ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              decoration: InputDecoration(labelText: 'Email (Login ID)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required for Login';
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(v.trim())) return 'Invalid email format';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordCtrl,
              decoration: InputDecoration(
                labelText: _isEditing ? 'New Password (Optional)' : 'Password (For Tenant Login)', 
                helperText: _isEditing ? 'Leave empty to keep current password' : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              obscureText: _obscurePassword, 
              validator: (v) {
                if (_isEditing && (v == null || v.isEmpty)) return null; 
                if (v == null || v.length < 6) return 'Min 6 chars';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            if (!_isEditing) ...[
              TextFormField(
                controller: _rentCtrl,
                decoration: InputDecoration(
                  labelText: 'Agreed Rent Amount', 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.currency_rupee),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _securityDepositCtrl,
                decoration: InputDecoration(
                  labelText: 'Security Deposit (Optional)', 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.shield), 
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
               TextFormField(
                controller: _advanceAmountCtrl,
                decoration: InputDecoration(
                  labelText: 'Advance Amount (If any)', 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.money), 
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Opening Balance (for migrating existing tenants)
              TextFormField(
                controller: _openingBalanceCtrl,
                decoration: InputDecoration(
                  labelText: 'Opening Balance (Optional)', 
                  helperText: 'Previous dues when migrating existing tenants',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.account_balance_wallet), 
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              // Restore Initial Reading
              TextFormField(
                controller: _initialReadingCtrl,
                decoration: InputDecoration(
                  labelText: 'Initial Meter Reading (Optional)', 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.flash_on),
                  suffixText: 'units'
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() {
                      _startDate = picked;
                      _dateCtrl.text = _formatDate(picked);
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Lease Start Date',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 16),

              // Tenancy Notes
              TextFormField(
                controller: _tenancyNotesCtrl,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)', 
                  hintText: 'e.g. Special agreements, tekirayabook, etc.',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.notes), 
                ),
                maxLines: 2,
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
    final securityDeposit = double.tryParse(_securityDepositCtrl.text);
    final openingBalance = double.tryParse(_openingBalanceCtrl.text); // NEW
    final initialReading = double.tryParse(_initialReadingCtrl.text);
    final tenancyNotes = _tenancyNotesCtrl.text.trim(); // NEW
    
    // NEW fields
    final advanceAmount = double.tryParse(_advanceAmountCtrl.text);
    final address = _addressCtrl.text.trim();
    final idProof = _idProofCtrl.text.trim();
    final memberCount = int.tryParse(_memberCountCtrl.text) ?? 1;

    try {
      if (_isEditing) {
        // UPDATE Logic
        final updatedTenant = widget.tenant!.copyWith(
          name: _nameCtrl.text.trim().toTitleCase(),
          phone: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim().toLowerCase(),
          // password: _passwordCtrl.text.isNotEmpty ? _passwordCtrl.text.trim() : widget.tenant!.password, // Removed
        );
        
        await ref.read(tenantControllerProvider.notifier).updateTenant(updatedTenant, imageFile: _selectedImage);

      } else {
         // CREATE Logic
           await ref.read(tenantControllerProvider.notifier).registerTenant(
           houseId: _selectedHouseId!,
           unitId: _selectedUnitId!,
           tenantName: _nameCtrl.text.trim().toTitleCase(),
           phone: _phoneCtrl.text.trim(),
           email: _emailCtrl.text.trim().toLowerCase(),
           password: _passwordCtrl.text.trim(),
           agreedRent: rent,
           securityDeposit: securityDeposit,
           openingBalance: openingBalance, // NEW
           notes: tenancyNotes.isNotEmpty ? tenancyNotes : null, // NEW
           imageFile: _selectedImage, 
           startDate: _startDate, 
           initialElectricReading: initialReading,
           // NEW Arguments
           advanceAmount: advanceAmount,
           policeVerification: _policeVerification,
           idProof: idProof.isNotEmpty ? idProof : null,
           address: address.isNotEmpty ? address : null,
           dob: _dobCtrl.text.isEmpty ? null : _dobCtrl.text,
           gender: _selectedGender,
           memberCount: memberCount,
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
