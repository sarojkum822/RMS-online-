import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/house.dart';
import '../../../../domain/entities/bhk_template.dart';
import '../../../providers/data_providers.dart';
import 'house_controller.dart';
import 'bhk_template_controller.dart';

class UnitEditScreen extends ConsumerStatefulWidget {
  final Unit unit;
  const UnitEditScreen({super.key, required this.unit});

  @override
  ConsumerState<UnitEditScreen> createState() => _UnitEditScreenState();
}

class _UnitEditScreenState extends ConsumerState<UnitEditScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _floorCtrl;
  late TextEditingController _baseRentCtrl;
  
  int? _selectedBhkTemplateId;
  String? _selectedBhkType;
  
  late TextEditingController _carpetAreaCtrl;
  late TextEditingController _parkingCtrl;
  late TextEditingController _meterCtrl;
  String? _furnishingStatus;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.unit.nameOrNumber);
    _floorCtrl = TextEditingController(text: widget.unit.floor?.toString() ?? '');
    _baseRentCtrl = TextEditingController(text: widget.unit.baseRent.toString());
    _selectedBhkTemplateId = widget.unit.bhkTemplateId;
    _selectedBhkType = widget.unit.bhkType;

    _carpetAreaCtrl = TextEditingController(text: widget.unit.carpetArea?.toString() ?? '');
    _parkingCtrl = TextEditingController(text: widget.unit.parkingSlot ?? '');
    _meterCtrl = TextEditingController(text: widget.unit.meterNumber ?? '');
    _furnishingStatus = widget.unit.furnishingStatus;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _floorCtrl.dispose();
    _baseRentCtrl.dispose();
    _carpetAreaCtrl.dispose();
    _parkingCtrl.dispose();
    _meterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bhkTemplatesAsync = ref.watch(bhkTemplateControllerProvider(widget.unit.houseId));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Unit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Basic Info', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Flat Number / Name', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _floorCtrl,
                    decoration: const InputDecoration(labelText: 'Floor', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            Text('BHK & Pricing', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 12),
            
            bhkTemplatesAsync.when(
              data: (templates) {
                 if (templates.isEmpty) {
                   return Container(
                     padding: const EdgeInsets.all(12),
                     color: Colors.orange.shade50,
                     child: const Text('No BHK Templates created. Create templates first to assign them.'),
                   );
                 }
                 
                 return DropdownButtonFormField<int>(
                   value: _selectedBhkTemplateId,
                   decoration: const InputDecoration(
                     labelText: 'Select BHK Type',
                     border: OutlineInputBorder(),
                   ),
                   items: templates.map((t) {
                     return DropdownMenuItem(
                       value: t.id,
                       child: Text('${t.bhkType} - ₹${t.defaultRent}'),
                     );
                   }).toList(),
                   onChanged: (val) {
                     if (val != null) {
                       final t = templates.firstWhere((e) => e.id == val);
                       setState(() {
                         _selectedBhkTemplateId = val;
                         _selectedBhkType = t.bhkType;
                         _baseRentCtrl.text = t.defaultRent.toString(); // Auto-fill Rent
                       });
                     }
                   },
                 );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e,s) => Text('Error loading templates: $e'),
            ),
            
            const SizedBox(height: 12),
            TextFormField(
              controller: _baseRentCtrl,
              decoration: const InputDecoration(
                labelText: 'Base Rent (Default)',
                helperText: 'This rent is pulled from template but can be overridden.',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 24),
            Text('Advanced Details', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 12),
            
            // Furnishing
            DropdownButtonFormField<String>(
              value: _furnishingStatus,
              decoration: const InputDecoration(labelText: 'Furnishing Status', border: OutlineInputBorder()),
              items: ['Unfurnished', 'Semi-Furnished', 'Fully-Furnished'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _furnishingStatus = v),
            ),
            const SizedBox(height: 12),
            
            // Area and Parking
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _carpetAreaCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Carpet Area (sq ft)', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _parkingCtrl,
                    decoration: const InputDecoration(labelText: 'Parking Slot', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _meterCtrl,
              decoration: const InputDecoration(labelText: 'Electric Meter #', border: OutlineInputBorder()),
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update Unit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final repo = ref.read(propertyRepositoryProvider);
    
    final updatedUnit = widget.unit.copyWith(
      nameOrNumber: _nameCtrl.text,
      floor: int.tryParse(_floorCtrl.text),
      baseRent: double.tryParse(_baseRentCtrl.text) ?? 0.0,
      bhkTemplateId: _selectedBhkTemplateId,
      bhkType: _selectedBhkType,
      
      furnishingStatus: _furnishingStatus,
      carpetArea: double.tryParse(_carpetAreaCtrl.text),
      parkingSlot: _parkingCtrl.text.isEmpty ? null : _parkingCtrl.text,
      meterNumber: _meterCtrl.text.isEmpty ? null : _meterCtrl.text,
    );
    
    await repo.updateUnit(updatedUnit);
    ref.invalidate(houseUnitsProvider(widget.unit.houseId)); // Refresh list
    if (mounted) Navigator.pop(context);
  }
}
