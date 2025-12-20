import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../domain/entities/house.dart';
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
  
  String? _selectedBhkTemplateId;
  String? _selectedBhkType;
  
  late TextEditingController _carpetAreaCtrl;
  late TextEditingController _parkingCtrl;
  late TextEditingController _meterCtrl;
  late TextEditingController _defaultDueDayCtrl;
  String? _furnishingStatus;
  List<String> _imagesBase64 = []; // NEW: Unit images

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
    _defaultDueDayCtrl = TextEditingController(text: widget.unit.defaultDueDay.toString());
    _furnishingStatus = widget.unit.furnishingStatus;
    _imagesBase64 = List.from(widget.unit.imagesBase64); // NEW: Load existing images
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _floorCtrl.dispose();
    _baseRentCtrl.dispose();
    _carpetAreaCtrl.dispose();
    _parkingCtrl.dispose();
    _meterCtrl.dispose();
    _defaultDueDayCtrl.dispose(); // NEW
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
            Text('Basic Info', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
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
            Text('BHK & Pricing', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
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
                 
                 return DropdownButtonFormField<String>(
                   value: _selectedBhkTemplateId,
                   decoration: const InputDecoration(
                     labelText: 'Select BHK Type',
                     border: OutlineInputBorder(),
                   ),
                   items: templates.map((t) {
                     return DropdownMenuItem<String>(
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
            Text('Advanced Details', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 12),
            
            // Furnishing
            DropdownButtonFormField<String>(
              initialValue: _furnishingStatus,
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
            const SizedBox(height: 12),
            // Default Due Day
            TextFormField(
              controller: _defaultDueDayCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Default Due Day',
                helperText: 'Day of month when rent is due (1-28)',
                border: OutlineInputBorder(),
              ),
            ),

            // Unit Photos Section (NEW)
            const SizedBox(height: 24),
            Text('Unit Photos', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 8),
            Text('Add up to 4 photos of this unit', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._imagesBase64.asMap().entries.map((entry) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          base64Decode(entry.value),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: -8,
                        right: -8,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          color: Colors.red,
                          onPressed: () {
                            setState(() => _imagesBase64.removeAt(entry.key));
                          },
                        ),
                      ),
                    ],
                  );
                }),
                if (_imagesBase64.length < 4)
                  InkWell(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 600, maxHeight: 600);
                      if (picked != null) {
                        final bytes = await File(picked.path).readAsBytes();
                        final base64 = base64Encode(bytes);
                        setState(() => _imagesBase64.add(base64));
                      }
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add_a_photo, color: Colors.grey.shade400, size: 28),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Theme.of(context).colorScheme.primary,
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
      defaultDueDay: int.tryParse(_defaultDueDayCtrl.text) ?? 1,
      imagesBase64: _imagesBase64, // NEW
    );
    
    await repo.updateUnit(updatedUnit);
    ref.invalidate(houseUnitsProvider(widget.unit.houseId)); // Refresh list
    if (mounted) Navigator.pop(context);
  }
}
