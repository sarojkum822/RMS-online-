import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/house.dart';
import 'house_controller.dart';
import 'bhk_template_screen.dart'; // Import

import 'widgets/unit_list_tile.dart';
import 'bhk_template_controller.dart'; 
import '../../../../domain/entities/bhk_template.dart'; 
import '../../../../core/utils/dialog_utils.dart'; 

class HouseDetailScreen extends ConsumerStatefulWidget {
  final House house;

  const HouseDetailScreen({super.key, required this.house});

  @override
  ConsumerState<HouseDetailScreen> createState() => _HouseDetailScreenState();
}

class _HouseDetailScreenState extends ConsumerState<HouseDetailScreen> {
  bool _isBulkConfigEnabled = false;
  
  // Bulk Form State
  int? _bulkBhkTemplateId;
  String? _bulkBhkType;
  double? _bulkRent;
  double? _bulkArea;
  String? _bulkFurnishing;

  @override
  Widget build(BuildContext context) {
    final unitsAsync = ref.watch(houseUnitsProvider(widget.house.id));
    final templatesAsync = ref.watch(bhkTemplateControllerProvider(widget.house.id));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.house.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme, 
        titleTextStyle: TextStyle(color: theme.textTheme.titleLarge?.color, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddUnitDialog(context, ref),
        label: Text('Add Unit', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             if (widget.house.imageUrl != null)
               Padding(
                 padding: const EdgeInsets.only(bottom: 24.0),
                 child: Hero(
                   tag: 'house_${widget.house.id}',
                   child: ClipRRect(
                     borderRadius: BorderRadius.circular(20),
                     child: CachedNetworkImage(
                       imageUrl: widget.house.imageUrl!,
                       height: 200,
                       width: double.infinity,
                       fit: BoxFit.cover,
                       placeholder: (context, url) => Container(height: 200, color: Colors.grey[200], child: const Center(child: CircularProgressIndicator())),
                       errorWidget: (context, url, error) => Container(height: 200, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)),
                     ),
                   ),
                 ),
               ),

             _HouseInfoCard(house: widget.house),
             const SizedBox(height: 24),
             
             // --- ACTIONS & CONFIG ---
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text('Units', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                 TextButton.icon(
                   onPressed: () => Navigator.push(
                     context,
                     MaterialPageRoute(builder: (_) => BhkTemplateListScreen(houseId: widget.house.id)),
                   ),
                   icon: const Icon(Icons.class_outlined, size: 18),
                   label: const Text('Manage BHK Types'),
                 ),
               ],
             ),
             
             // Bulk Toggle
             SwitchListTile(
               title: Text('Apply same configuration to all units', style: GoogleFonts.outfit(fontSize: 14, color: theme.textTheme.bodyMedium?.color)),
               value: _isBulkConfigEnabled, 
               activeThumbColor: theme.colorScheme.primary, 
               contentPadding: EdgeInsets.zero,
               onChanged: (val) => setState(() => _isBulkConfigEnabled = val),
             ),
             
             const SizedBox(height: 12),
             
             if (_isBulkConfigEnabled)
               _buildBulkConfigSection(templatesAsync, unitsAsync, theme, isDark)
             else 
               unitsAsync.when(
                 data: (units) {
                   if (units.isEmpty) return Text('No units found.', style: TextStyle(color: theme.textTheme.bodyMedium?.color));
                   return ListView.separated(
                     shrinkWrap: true,
                     physics: const NeverScrollableScrollPhysics(),
                     itemCount: units.length,
                     separatorBuilder: (c, i) => const SizedBox(height: 12),
                     itemBuilder: (context, index) {
                       return UnitListTile(unit: units[index]);
                     },
                   );
                 },
                 loading: () => const Center(child: CircularProgressIndicator()),
                 error: (e, s) => Text('Error: $e', style: TextStyle(color: theme.colorScheme.error)),
               ),
          ],
        ),
      ),
    );
  }

  void _showAddUnitDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(); // Start empty
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Unit'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Unit Number / Name', hintText: 'e.g., Flat 101'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                 Navigator.pop(context); // Close input dialog first
                 await DialogUtils.runWithLoading(context, () async {
                    await ref.read(houseControllerProvider.notifier).addUnit(widget.house.id, controller.text.trim());
                 });
                 if(context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unit added')));
                 }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBulkConfigSection(AsyncValue<List<BhkTemplate>> templatesAsync, AsyncValue<List<Unit>> unitsAsync, ThemeData theme, bool isDark) {
     return Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: isDark ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.blue.shade50,
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: isDark ? theme.colorScheme.primary.withValues(alpha: 0.3) : Colors.blue.shade100),
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text('Master Configuration', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
           const SizedBox(height: 4),
           Text('Saving will update ALL units in this property.', style: GoogleFonts.outfit(fontSize: 12, color: isDark ? Colors.blueAccent : Colors.blue.shade800)),
           const SizedBox(height: 16),
           
           templatesAsync.when(
              data: (templates) => DropdownButtonFormField<int>(
                   initialValue: _bulkBhkTemplateId,
                   decoration: InputDecoration(
                     labelText: 'Select BHK Type', 
                     border: const OutlineInputBorder(), 
                     filled: true, 
                     fillColor: theme.cardColor,
                     labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
                   ),
                   dropdownColor: theme.cardColor,
                   items: templates.map((t) => DropdownMenuItem(value: t.id, child: Text(t.bhkType, style: TextStyle(color: theme.textTheme.bodyLarge?.color)))).toList(),
                   onChanged: (val) {
                     if (val != null) {
                       final t = templates.firstWhere((e) => e.id == val);
                       setState(() {
                         _bulkBhkTemplateId = val;
                         _bulkBhkType = t.bhkType;
                         _bulkRent = t.defaultRent; // Auto-set rent
                       });
                     }
                   },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e,_) => const Text('Error loading templates'),
           ),
           const SizedBox(height: 12),
           
           Row(
             children: [
               Expanded(
                 child: TextFormField(
                   key: ValueKey(_bulkRent), // Force rebuild if key changes
                   initialValue: _bulkRent?.toString(),
                   decoration: InputDecoration(
                     labelText: 'Rent', 
                     border: const OutlineInputBorder(), 
                     filled: true, 
                     fillColor: theme.cardColor,
                     labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
                   ),
                   style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                   keyboardType: TextInputType.number,
                   onChanged: (v) => _bulkRent = double.tryParse(v),
                 ),
               ),
               const SizedBox(width: 12),
               Expanded(
                 child: TextFormField(
                   decoration: InputDecoration(
                     labelText: 'Area (sqft)', 
                     border: const OutlineInputBorder(), 
                     filled: true, 
                     fillColor: theme.cardColor,
                     labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
                   ),
                   style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                   keyboardType: TextInputType.number,
                   onChanged: (v) => _bulkArea = double.tryParse(v),
                 ),
               ),
             ],
           ),
           const SizedBox(height: 12),
           DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Furnishing', 
                border: const OutlineInputBorder(), 
                filled: true, 
                fillColor: theme.cardColor,
                labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
              dropdownColor: theme.cardColor,
              items: ['Unfurnished', 'Semi-Furnished', 'Fully-Furnished'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(color: theme.textTheme.bodyLarge?.color)))).toList(),
              onChanged: (v) => _bulkFurnishing = v,
           ),
           const SizedBox(height: 16),
           
           SizedBox(
             width: double.infinity,
             child: ElevatedButton(
               style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white),
               onPressed: () async {
                  if (_bulkBhkTemplateId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a BHK Template')));
                    return;
                  }
                  
                  final units = unitsAsync.valueOrNull;
                  if (units == null || units.isEmpty) return;
                  
                  // Confirmation
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Confirm Bulk Update'),
                      content: Text('This will update ${units.length} units to:\n$_bulkBhkType • ₹$_bulkRent'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Apply')),
                      ],
                    ),
                  );
                  
                  if (confirm == true) {
                    try {
                      final updatedUnits = units.map((u) => u.copyWith(
                        bhkTemplateId: _bulkBhkTemplateId,
                        bhkType: _bulkBhkType,
                        baseRent: _bulkRent ?? 0,
                        carpetArea: _bulkArea,
                        furnishingStatus: _bulkFurnishing,
                      )).toList();
                      
                      await DialogUtils.runWithLoading(context, () async {
                         await ref.read(houseControllerProvider.notifier).bulkUpdateUnits(updatedUnits);
                      });
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All units updated successfully')));
                        setState(() => _isBulkConfigEnabled = false); // Switch back to list view
                      }
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
               },
               child: const Text('Apply Configuration to All Units'),
             ),
           ),
         ],
       ),
     );
  }
}

class _HouseInfoCard extends StatelessWidget {
  final House house;
  const _HouseInfoCard({required this.house});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(house.address, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14)),
            ],
          ),
          if (house.notes != null) ...[
            const SizedBox(height: 12),
             Text(house.notes!, style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontStyle: FontStyle.italic)),
          ],
        ],
      )
    );
  }
}
