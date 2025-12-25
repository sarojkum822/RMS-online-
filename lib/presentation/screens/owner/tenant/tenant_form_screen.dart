import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for InputFormatters
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io'; 
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
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
  late TextEditingController _securityDepositCtrl;
  late TextEditingController _openingBalanceCtrl; // NEW
  late TextEditingController _tenancyNotesCtrl; // NEW
  late TextEditingController _initialReadingCtrl; 
  late TextEditingController _dateCtrl; // NEW for Date Picker
  // NEW Fields
  late TextEditingController _addressCtrl;
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
    _memberCountCtrl.dispose();
    _advanceAmountCtrl.dispose();
    _dobCtrl.dispose();

    // _ocrService disposed by provider
    super.dispose();
  }



  Future<void> _pickImage() async {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1080, maxHeight: 1080);
    
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Adjust Photo',
            toolbarColor: primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Adjust Photo',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile != null && mounted) {
        setState(() {
          _selectedImage = File(croppedFile.path);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep OCR Service alive while screen is open


    final theme = Theme.of(context);
    final housesValue = ref.watch(houseControllerProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Tenant' : 'Add Tenant',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.textTheme.titleLarge?.color,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            // 1. Profile Photo Section
            _buildPhotoSection(theme, isDark),
            const SizedBox(height: 32),

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
                           if (units.isEmpty) return _buildNoUnitsConfigured(theme);
                           
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
             
            // 3. Personal Details Section
            _buildSectionHeader('Personal Details', Icons.person_rounded),
            _buildSectionCard([
              _buildTextField(
                controller: _nameCtrl,
                label: 'Full Name',
                icon: Icons.person_outline_rounded,
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v ?? '').isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneCtrl,
                label: 'Phone Number',
                icon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 15,
                validator: (v) {
                  if ((v ?? '').isEmpty) return 'Required';
                  if (v!.length < 10) return 'Invalid phone';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _dobCtrl,
                      label: 'DOB',
                      icon: Icons.cake_outlined,
                      readOnly: true,
                      onTap: () => _selectDate(context, isDob: true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField<String>(
                      label: 'Gender',
                      value: _selectedGender,
                      items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (v) => setState(() => _selectedGender = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressCtrl,
                label: 'Permanent Address',
                icon: Icons.location_on_outlined,
                maxLines: 2,
                maxLength: 200,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _memberCountCtrl,
                      label: 'Family Members',
                      icon: Icons.group_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SwitchListTile(
                      title: Text('Police Verified', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500)),
                      value: _policeVerification,
                      onChanged: (v) => setState(() => _policeVerification = v),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 24),
            // 4. Credential Section
            _buildSectionHeader('Login Credentials', Icons.vpn_key_rounded),
            _buildSectionCard([
              _buildTextField(
                controller: _emailCtrl,
                label: 'Email (Login ID)',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required for Login';
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(v.trim())) return 'Invalid format';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordCtrl,
                label: _isEditing ? 'New Password (Optional)' : 'Password',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (v) {
                  if (_isEditing && (v == null || v.isEmpty)) return null; 
                  if (v == null || v.length < 6) return 'Min 6 chars';
                  return null;
                },
              ),
            ]),
            const SizedBox(height: 24),

            // 5. Financial Section
            if (!_isEditing) ...[
              _buildSectionHeader('Financial Details', Icons.account_balance_wallet_rounded),
              _buildSectionCard([
                _buildTextField(
                  controller: _rentCtrl,
                  label: 'Monthly Rent',
                  icon: Icons.currency_rupee_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _securityDepositCtrl,
                        label: 'Security Deposit',
                        icon: Icons.shield_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _advanceAmountCtrl,
                        label: 'Advance',
                        icon: Icons.payments_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _openingBalanceCtrl,
                  label: 'Opening Balance',
                  icon: Icons.history_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _initialReadingCtrl,
                  label: 'Current Meter Reading',
                  icon: Icons.flash_on_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _dateCtrl,
                  label: 'Lease Start Date',
                  icon: Icons.calendar_today_rounded,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _tenancyNotesCtrl,
                  label: 'Internal Notes',
                  icon: Icons.notes_rounded,
                  maxLines: 2,
                  maxLength: 500,
                ),
              ]),
              const SizedBox(height: 32),
            ],

            // 6. Submit Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
                ),
                child: _isLoading 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        _isEditing ? 'Update Tenant Profile' : 'Register Tenant Account', 
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)
                      ),
              ),
            ),
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

  // --- UI Helper Widgets ---

  Widget _buildPhotoSection(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                backgroundImage: _selectedImage != null 
                    ? FileImage(_selectedImage!) 
                    : (widget.tenant?.imageBase64 != null 
                        ? MemoryImage(base64Decode(widget.tenant!.imageBase64!))
                    : (widget.tenant?.imageUrl != null 
                          ? CachedNetworkImageProvider(widget.tenant!.imageUrl!) as ImageProvider 
                          : null)),
                child: (_selectedImage == null && widget.tenant?.imageUrl == null && widget.tenant?.imageBase64 == null)
                    ? Icon(Icons.add_a_photo_rounded, size: 36, color: theme.colorScheme.primary.withValues(alpha: 0.6))
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isEditing ? 'Tap to Change Photo' : 'Upload Profile Photo',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    int? maxLines = 1,
    int? maxLength,
    bool readOnly = false,
    VoidCallback? onTap,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      style: GoogleFonts.outfit(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffixIcon,
        counterText: "",
        labelStyle: GoogleFonts.outfit(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
        filled: true,
        fillColor: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.03) : Colors.grey[50],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? Function(T?)? validator,
  }) {
    final theme = Theme.of(context);
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      style: GoogleFonts.outfit(fontSize: 15, color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
        filled: true,
        fillColor: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.03) : Colors.grey[50],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, {bool isDob = false}) async {
    final now = DateTime.now();
    final initialDate = isDob ? DateTime(now.year - 18, now.month, now.day) : _startDate;
    final firstDate = isDob ? DateTime(1900) : DateTime(2020);
    final lastDate = isDob ? DateTime(now.year - 18, now.month, now.day) : DateTime(now.year + 5);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Theme.of(context).colorScheme.primary,
              brightness: Theme.of(context).brightness,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDob) {
          _dobCtrl.text = _formatDate(picked);
        } else {
          _startDate = picked;
          _dateCtrl.text = _formatDate(picked);
        }
      });
    }
  }

  Widget _buildNoUnitsConfigured(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            "No units available in this house.",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.push('/owner/houses/$_selectedHouseId'),
            child: Text('Configure Units', style: GoogleFonts.outfit(fontSize: 12)),
          )
        ],
      ),
    );
  }
}
