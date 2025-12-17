import 'dart:convert'; // NEW
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

import 'package:rentpilotpro/presentation/providers/data_providers.dart';
import '../../notice/notice_controller.dart'; 
import 'package:rentpilotpro/presentation/screens/notice/notice_history_screen.dart';
import 'package:go_router/go_router.dart'; // Added
import '../settings/owner_controller.dart'; // Added

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

  void _showBroadcastDialog() {
    final titleController = TextEditingController();
    final msgController = TextEditingController();
    String selectedPriority = 'medium';
    
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            // Glass Dialog Container
            return Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                margin: const EdgeInsets.only(bottom: 40), // Keyboard spacing
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95), // High opacity for readability
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    )
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: SingleChildScrollView( // Fix Overflow
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.campaign_outlined, color: Colors.orange, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Broadcast Notice',
                                    style: GoogleFonts.outfit(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: theme.textTheme.titleLarge?.color
                                    ),
                                  ),
                                  Text(
                                    'To: ${widget.house.name}',
                                    style: GoogleFonts.outfit(fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                                    maxLines: 1, 
                                    overflow: TextOverflow.ellipsis
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                  
                        // Subject Input
                        TextFormField(
                          controller: titleController,
                          textCapitalization: TextCapitalization.sentences,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            labelText: 'Subject',
                            hintText: 'e.g. Water Tank Cleaning',
                            filled: true,
                            fillColor: theme.scaffoldBackgroundColor,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            labelStyle: GoogleFonts.outfit(color: Colors.grey),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Message Input
                        TextFormField(
                          controller: msgController,
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 4,
                          style: GoogleFonts.outfit(),
                          decoration: InputDecoration(
                            labelText: 'Message',
                            hintText: 'Enter all details...',
                            filled: true,
                            fillColor: theme.scaffoldBackgroundColor,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            alignLabelWithHint: true,
                            labelStyle: GoogleFonts.outfit(color: Colors.grey),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Priority Selector
                        Text('Priority Level', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey[700])),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildGlassPriorityChip('High', 'high', Colors.red, selectedPriority, (val) => setDialogState(() => selectedPriority = val)),
                            const SizedBox(width: 8),
                            _buildGlassPriorityChip('Medium', 'medium', Colors.orange, selectedPriority, (val) => setDialogState(() => selectedPriority = val)),
                            const SizedBox(width: 8),
                            _buildGlassPriorityChip('Low', 'low', Colors.green, selectedPriority, (val) => setDialogState(() => selectedPriority = val)),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Actions
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.grey, fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (titleController.text.isNotEmpty && msgController.text.isNotEmpty) {
                                     Navigator.pop(ctx);
                                     final user = ref.read(userSessionServiceProvider).currentUser;
                                     if (user == null) return;
                                     
                                     await DialogUtils.runWithLoading(context, () async {
                                        await ref.read(noticeControllerProvider.notifier).sendNotice(
                                          houseId: widget.house.id.toString(),
                                          ownerId: user.uid,
                                          subject: titleController.text.trim(),
                                          message: msgController.text.trim(),
                                          priority: selectedPriority,
                                        );
                                     });
                                     if (context.mounted) {
                                       ScaffoldMessenger.of(context).showSnackBar(
                                         const SnackBar(content: Text('Notice Broadcasted Successfully!'), backgroundColor: Colors.green)
                                       );
                                     }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: Text('Broadcast', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack), // Nice bounce
          child: child,
        );
      },
    );
  }
  
  Widget _buildGlassPriorityChip(String label, String value, Color color, String current, Function(String) onSelect) {
    final isSelected = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 1.5 : 1),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: isSelected ? color : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13
            ),
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final unitsAsync = ref.watch(houseUnitsProvider(widget.house.id));
    final templatesAsync = ref.watch(bhkTemplateControllerProvider(widget.house.id));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Announcement Icon
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                 BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
              ]
            ),
            child: IconButton(
              icon: const Icon(Icons.campaign_outlined, size: 22),
              tooltip: 'Broadcast Notice',
              onPressed: _showBroadcastDialog,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          // Notification Icon
          Container(
            margin: const EdgeInsets.only(right: 16),
             decoration: BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.circle,
               boxShadow: [
                 BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
              ]
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none, size: 22),
              tooltip: 'Notifications',
              onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => NoticeHistoryScreen(
                   houseId: widget.house.id.toString(),
                   ownerId: ref.read(userSessionServiceProvider).currentUser?.uid ?? '',
                 )));
              },
               color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'edit_house_details',
        onPressed: () => _showAddUnitDialog(context, ref),
        label: Text('Add Unit', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.primary,
        elevation: 4,
        highlightElevation: 8,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Clean Header (No Hero Image)
            Text(
              widget.house.name,
              style: GoogleFonts.playfairDisplay( // Elegant Serif
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  widget.house.address,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            // 2. Glass Stats Row
             unitsAsync.when(
               data: (units) {
                  final totalUnits = units.length;
                  final occupiedUnits = units.where((u) => u.isOccupied).length;
                  final occupancyRate = totalUnits > 0 ? occupiedUnits / totalUnits : 0.0;
                  final revenue = units.where((u) => u.isOccupied).fold(0.0, (sum, u) => sum + (u.editableRent ?? u.baseRent));
                  
                  String formatRevenue(double val) {
                    if (val >= 10000000) return '₹${(val / 10000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}Cr';
                    if (val >= 100000) return '₹${(val / 100000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}L';
                    if (val >= 1000) return '₹${(val / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}k';
                    return '₹${val.toStringAsFixed(0)}';
                  }

                  return Row(
                    children: [
                      Expanded(child: _GlassStat(
                        label: 'Revenue', 
                        value: formatRevenue(revenue), 
                        isPositive: true, // Placeholder logic
                        color: Colors.green, // Revenue green
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _GlassStat(
                        label: 'Occupancy', 
                        value: '${(occupancyRate * 100).toInt()}%', 
                        isPositive: occupancyRate >= 0.8, 
                        color: Colors.blue, 
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _GlassStat(
                        label: 'Tenants', 
                        value: '$occupiedUnits/$totalUnits', 
                        isPositive: true, 
                        color: Colors.orange, 
                      )),
                    ],
                  );
               },
               loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
               error: (_,__) => const SizedBox(),
             ),

            const SizedBox(height: 32),

            // 3. Units Header
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text('Units', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                 TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BhkTemplateListScreen(houseId: widget.house.id)),
                    ),
                    child: Text('Manage Types', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                 ),
               ],
             ),

             // Bulk Toggle
             SwitchListTile(
               title: Text('Apply same configuration to all units', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: theme.textTheme.bodyMedium?.color)),
               value: _isBulkConfigEnabled, 
               activeThumbColor: theme.colorScheme.primary, 
               contentPadding: EdgeInsets.zero,
               onChanged: (val) => setState(() => _isBulkConfigEnabled = val),
             ),
             
             const SizedBox(height: 8),
             
             if (_isBulkConfigEnabled)
               _buildBulkConfigSection(templatesAsync, unitsAsync, theme, isDark)
             else 
               unitsAsync.when(
                 data: (units) {
                   if (units.isEmpty) {
                     return Container(
                       padding: const EdgeInsets.all(40),
                       alignment: Alignment.center,
                       child: Column(
                         children: [
                           Icon(Icons.meeting_room_outlined, size: 48, color: theme.disabledColor),
                           const SizedBox(height: 16),
                           Text('No units added yet.', style: GoogleFonts.outfit(color: theme.disabledColor)),
                         ],
                       ),
                     );
                   }
                   return ListView.separated(
                     shrinkWrap: true,
                     physics: const NeverScrollableScrollPhysics(),
                     itemCount: units.length,
                     separatorBuilder: (c, i) => const SizedBox(height: 12),
                     itemBuilder: (context, index) {
                       return UnitListTile(unit: units[index]); // Assumes UnitListTile handles its own styling
                     },
                   );
                 },
                 loading: () => const Center(child: CircularProgressIndicator()),
                 error: (e, s) => Text('Error: $e', style: TextStyle(color: theme.colorScheme.error)),
               ),
              
              const SizedBox(height: 80), // Fab spacing
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
                 final currentUnits = ref.read(houseUnitsProvider(widget.house.id)).valueOrNull ?? [];
                 final owner = ref.read(ownerControllerProvider).value;
                 final plan = owner?.subscriptionPlan ?? 'free';
                 
                 int limit = 2; // Free
                 if (plan == 'pro') limit = 20;
                 if (plan == 'power') limit = 999999;

                 if (currentUnits.length >= limit) {
                    Navigator.pop(context);
                    if (context.mounted) {
                       showDialog(
                         context: context, 
                         builder: (_) => AlertDialog(
                           title: const Text('Limit Reached'),
                           content: Text('You have reached the limit of $limit units for the ${plan.toUpperCase()} plan. Upgrade to add more.'),
                           actions: [
                             TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                             ElevatedButton(
                               onPressed: () {
                                 Navigator.pop(context);
                                 context.push('/owner/settings/subscription');
                               }, 
                               child: const Text('Upgrade')
                             ),
                           ],
                         )
                       );
                    }
                    return;
                 }
                 
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

class _GlassStat extends StatelessWidget {
  final String label;
  final String value;
  final bool isPositive;
  final Color color;

  const _GlassStat({
    required this.label,
    required this.value,
    required this.isPositive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Reusing AppTheme.glassDecoration if available, else defining here
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        // Gradient fill for subtle glass effect? 
        // Or just keep it clean white as per "Clean Data View"
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
           const SizedBox(height: 4),
           // Optional Trend Indicator
           if (isPositive)
             Row(
               children: [
                 Icon(Icons.trending_up, size: 14, color: color),
                 const SizedBox(width: 4),
                 Text(
                   'Stable', 
                   style: GoogleFonts.outfit(fontSize: 10, color: color, fontWeight: FontWeight.bold)
                 )
               ],
             )
        ],
      ),
    );
  }
}
