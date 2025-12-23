import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../widgets/voice_assistant_sheet.dart';
import 'dart:async';

class TenantFormScreen extends ConsumerStatefulWidget {
  final Tenant? tenant; // Optional for Edit Mode
  final Map<String, dynamic>? initialEntities; // NEW: For Voice Assistant
  const TenantFormScreen({super.key, this.tenant, this.initialEntities});

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
  bool _isLoading = false;
  bool _obscurePassword = true;

  Timer? _debounce;
  String? _emailWarning;
  String? _phoneWarning;


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
    
    // Handle Voice Assistant Entities
    if (widget.initialEntities != null) {
      if (widget.initialEntities!['name'] != null) {
        _nameCtrl.text = widget.initialEntities!['name'];
      }
      if (widget.initialEntities!['rent'] != null) {
        _rentCtrl.text = widget.initialEntities!['rent'].toString();
      }
    }

    if (_isEditing) {
       // ...
    }

    _emailCtrl.addListener(_onEmailChanged);
    _phoneCtrl.addListener(_onPhoneChanged);
  }

  void _onEmailChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _checkDuplicate(_emailCtrl.text, true);
    });
  }

  void _onPhoneChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _checkDuplicate(_phoneCtrl.text, false);
    });
  }

  Future<void> _checkDuplicate(String value, bool isEmail) async {
    if (value.isEmpty || _isEditing) return;
    
    final controller = ref.read(tenantControllerProvider.notifier);
    final exists = isEmail 
        ? await controller.checkEmailRegistered(value)
        : await controller.checkPhoneRegistered(value);
    
    if (mounted) {
      setState(() {
        if (isEmail) {
          _emailWarning = exists ? 'Tenant with this email already exists' : null;
        } else {
          _phoneWarning = exists ? 'Tenant with this phone already exists' : null;
        }
      });
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
    _debounce?.cancel();
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
        actions: [
          if (!_isEditing)
             IconButton(
               icon: const Icon(Icons.mic_none_rounded),
               onPressed: () => _showVoiceAssistant(context),
               tooltip: 'Fill by Voice',
             ),
        ],
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
              decoration: InputDecoration(
                labelText: 'Phone', 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                errorText: _phoneWarning,
              ),
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
                      initialValue: _selectedGender,
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
                labelText: 'ID Proof Number', 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                       validator: (v) {
                         if (v == null || v.isEmpty) return null;
                         final val = int.tryParse(v);
                         if (val == null || val <= 0) return 'Must be > 0';
                         return null;
                       },
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
              decoration: InputDecoration(
                labelText: 'Email (Login ID)', 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                errorText: _emailWarning,
              ),
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final val = double.tryParse(v);
                  if (val == null || val < 0) return 'Invalid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _securityDepositCtrl,
                decoration: InputDecoration(
                  labelText: 'Security Deposit (Optional)', 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.shield), 
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  final val = double.tryParse(v);
                  if (val == null || val < 0) return 'Cannot be negative';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
               TextFormField(
                controller: _advanceAmountCtrl,
                decoration: InputDecoration(
                  labelText: 'Advance Amount (If any)', 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.money), 
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  final val = double.tryParse(v);
                  if (val == null || val < 0) return 'Cannot be negative';
                  return null;
                },
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
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d+\.?\d{0,2}'))], // Allow negative for balance maybe? 
                // Wait, User said "Restrictions or validating of all fields where the input is only in Numbers so that it should not be in Negative or zero"
                // Actually balance can be negative (advance) but let's stick to non-negative as per user requested strictness if they meant debts.
                // But usually balance in KirayaBook is "Dues". So negative = advance.
                // I'll stick to non-negative for NOW if user said "should not be in Negative or zero" for NUMBERS.
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  final val = double.tryParse(v);
                  if (val == null || val < 0) return 'Cannot be negative';
                  return null;
                },
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
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  final val = double.tryParse(v);
                  if (val == null || val < 0) return 'Cannot be negative';
                  return null;
                },
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
       SnackbarUtils.showError(context, 'Please select property details');
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
        // UPDATED SAVE FEEDBACK
        if (!_isEditing) {
           _showSuccessDialog();
        } else {
           SnackbarUtils.showSuccess(context, 'Tenant updated successfully');
           Navigator.pop(context);
        }
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Tenant Added!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('The tenant has been successfully registered and a verification email has been sent.'),
            const SizedBox(height: 16),
            _buildDetailRow('Name', _nameCtrl.text),
            _buildDetailRow('Phone', _phoneCtrl.text),
            _buildDetailRow('Email', _emailCtrl.text),
            const SizedBox(height: 16),
            const Text('Would you like to review or edit the details?', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close Dialog
              // Keep Form Open for editing
            },
            child: const Text('Edit Details'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close Dialog
              Navigator.pop(this.context); // Close Form
            },
            child: const Text('OK, Finished'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  void _showVoiceAssistant(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoiceAssistantSheet(),
    );
  }
}
