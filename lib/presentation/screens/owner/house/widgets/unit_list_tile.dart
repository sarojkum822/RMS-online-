import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../domain/entities/house.dart';
import '../../../../../domain/entities/bhk_template.dart';
import '../../../../providers/data_providers.dart';
import '../bhk_template_controller.dart';
import '../house_controller.dart';

class UnitListTile extends ConsumerStatefulWidget {
  final Unit unit;
  
  const UnitListTile({super.key, required this.unit});

  @override
  ConsumerState<UnitListTile> createState() => _UnitListTileState();
}

class _UnitListTileState extends ConsumerState<UnitListTile> {
  // Controllers
  late TextEditingController _baseRentCtrl;
  late TextEditingController _carpetAreaCtrl;
  
  int? _selectedBhkTemplateId;
  String? _selectedBhkType;
  String? _furnishingStatus;
  
  bool _isExpanded = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _baseRentCtrl = TextEditingController(text: widget.unit.baseRent.toString());
    _carpetAreaCtrl = TextEditingController(text: widget.unit.carpetArea?.toString() ?? '');
    
    _selectedBhkTemplateId = widget.unit.bhkTemplateId;
    _selectedBhkType = widget.unit.bhkType;
    _furnishingStatus = widget.unit.furnishingStatus;
  }

  @override
  void didUpdateWidget(covariant UnitListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.unit != widget.unit) {
       // Sync if closed, or maybe just sync always? 
       // If user is editing, we shouldn't overwrite unless they saved.
       // But if we just saved, we receive new props.
       if (!_isExpanded) {
          _baseRentCtrl.text = widget.unit.baseRent.toString();
          _carpetAreaCtrl.text = widget.unit.carpetArea?.toString() ?? '';
          _selectedBhkTemplateId = widget.unit.bhkTemplateId;
          _selectedBhkType = widget.unit.bhkType;
          _furnishingStatus = widget.unit.furnishingStatus;
       }
    }
  }

  @override
  void dispose() {
    _baseRentCtrl.dispose();
    _carpetAreaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bhkTemplatesAsync = ref.watch(bhkTemplateControllerProvider(widget.unit.houseId));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
             color: Colors.grey.withOpacity(0.05),
             blurRadius: 10, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(widget.unit.nameOrNumber, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          subtitle: _buildSubtitle(),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          trailing: const Icon(Icons.edit, size: 20, color: Colors.blueGrey),
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded = expanded);
          },
          children: [
            const Divider(),
            const SizedBox(height: 10),
            
            // --- EDIT FORM ---
            
            // BHK Dropdown
            bhkTemplatesAsync.when(
              data: (templates) => DropdownButtonFormField<int>(
                   value: _selectedBhkTemplateId,
                   decoration: const InputDecoration(
                     labelText: 'BHK Type',
                     contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                     border: OutlineInputBorder(),
                   ),
                   items: templates.map((t) => DropdownMenuItem(
                     value: t.id,
                     child: Text('${t.bhkType} (₹${t.defaultRent})'),
                   )).toList(),
                   onChanged: (val) {
                     if (val != null) {
                       final t = templates.firstWhere((e) => e.id == val);
                       setState(() {
                         _selectedBhkTemplateId = val;
                         _selectedBhkType = t.bhkType;
                         _baseRentCtrl.text = t.defaultRent.toString();
                       });
                     }
                   },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => const Text('Error loading templates'),
            ),
            
            const SizedBox(height: 12),
            
            // Rent & Area Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _baseRentCtrl,
                    decoration: const InputDecoration(labelText: 'Rent', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _carpetAreaCtrl,
                    decoration: const InputDecoration(labelText: 'Area (sqft)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Furnishing
            DropdownButtonFormField<String>(
              value: _furnishingStatus,
              decoration: const InputDecoration(labelText: 'Furnishing', border: OutlineInputBorder()),
              items: ['Unfurnished', 'Semi-Furnished', 'Fully-Furnished']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (v) => setState(() => _furnishingStatus = v),
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                child: _isSaving 
                   ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                   : const Text('Save Changes', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    final parts = [
      if(widget.unit.bhkType != null) widget.unit.bhkType!,
      if(widget.unit.furnishingStatus != null) widget.unit.furnishingStatus!,
      '₹${widget.unit.baseRent.toStringAsFixed(0)}',
    ];
    return Text(parts.join(' • '), style: GoogleFonts.outfit(color: Colors.black54, fontSize: 13));
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(propertyRepositoryProvider);
      
      final updatedUnit = widget.unit.copyWith(
        baseRent: double.tryParse(_baseRentCtrl.text) ?? 0.0,
        bhkTemplateId: _selectedBhkTemplateId,
        bhkType: _selectedBhkType,
        furnishingStatus: _furnishingStatus,
        carpetArea: double.tryParse(_carpetAreaCtrl.text),
      );
      
      await repo.updateUnit(updatedUnit);
      ref.invalidate(houseUnitsProvider(widget.unit.houseId));
      
      if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unit updated'), duration: Duration(seconds: 1)));
         // Optional: Collapse tile?
         // setState(() => _isExpanded = false); // Can't easily collapse expansion tile programmatically without key/controller tricks.
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if(mounted) setState(() => _isSaving = false);
    }
  }
}
