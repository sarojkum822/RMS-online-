import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tenant_controller.dart';
import '../house/house_controller.dart';
import '../../../../domain/entities/house.dart';
import '../../../../domain/entities/tenant.dart'; 

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
  final _rentCtrl = TextEditingController(); 
  final _electricCtrl = TextEditingController(); 
  
  // Manual Unit Entry Fields
  final _unitNameCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();

  int? _selectedHouseId;

  @override
  Widget build(BuildContext context) {
    final housesValue = ref.watch(houseControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Tenant'), elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
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
            
            // Manual Unit Entry (Only if House Selected)
            if (_selectedHouseId != null) ...[
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _unitNameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Unit / Flat No',
                        hintText: 'e.g. Flat 101',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _floorCtrl,
                      decoration: InputDecoration(
                        labelText: 'Floor',
                        hintText: 'e.g. 1',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
            ],
              
            const SizedBox(height: 24),
             
            Text('Tenant Details', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
             const SizedBox(height: 16),

            TextFormField(
              controller: _nameCtrl,
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
              decoration: InputDecoration(labelText: 'Email (Optional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              keyboardType: TextInputType.emailAddress,
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
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate() && _selectedHouseId != null) {
                     
                     final rent = double.tryParse(_rentCtrl.text);
                     final initialElectric = double.tryParse(_electricCtrl.text);

                     try {
                       await ref.read(tenantControllerProvider.notifier).addTenantWithManualUnit(
                         houseId: _selectedHouseId!,
                         unitName: _unitNameCtrl.text,
                         floor: _floorCtrl.text,
                         tenantName: _nameCtrl.text,
                         phone: _phoneCtrl.text,
                         email: _emailCtrl.text,
                         agreedRent: rent,
                         initialElectricReading: initialElectric,
                       );

                       if (mounted) context.pop();
                     } catch (e) {
                       if (mounted) {
                         // Extract clean message
                         final msg = e.toString().replaceAll('Exception: ', '');
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text(msg), backgroundColor: Colors.red),
                         );
                       }
                     }
                  } else if (_selectedHouseId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a house')));
                  }
                },
                child: const Text('Save Tenant', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
