import 'dart:convert'; // NEW
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // NEW: For photo upload
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/house.dart';
import 'house_controller.dart';
import 'bhk_template_screen.dart'; // Import

import 'widgets/unit_list_tile.dart';
import 'bhk_template_controller.dart'; 
import '../../../../domain/entities/bhk_template.dart'; 
import '../../../../core/utils/dialog_utils.dart'; 

import 'package:kirayabook/presentation/providers/data_providers.dart';
import '../../notice/notice_controller.dart'; 
import 'package:kirayabook/presentation/screens/notice/notice_history_screen.dart';
import 'package:go_router/go_router.dart'; // Added
import '../settings/owner_controller.dart'; // Added
import 'package:kirayabook/presentation/widgets/empty_state_widget.dart';
import '../../../../core/utils/currency_utils.dart';

class HouseDetailScreen extends ConsumerStatefulWidget {
  final House house;

  const HouseDetailScreen({super.key, required this.house});

  @override
  ConsumerState<HouseDetailScreen> createState() => _HouseDetailScreenState();
}

class _HouseDetailScreenState extends ConsumerState<HouseDetailScreen> {
  bool _isBulkConfigEnabled = false;
  
  // Bulk Form State
  String? _bulkBhkTemplateId;
  String? _bulkBhkType;
  double? _bulkRent;
  double? _bulkArea;
  String? _bulkFurnishing;

  void _showBroadcastDialog() {
    final titleController = TextEditingController();
    final msgController = TextEditingController();
    String selectedPriority = 'medium';
    bool isLoading = false; // Prevent duplicates

    // Pre-defined Templates
    final templates = {
      'Rent Due': 'Dear Tenant, your rent for this month is due. Please pay by the due date to avoid late fees.',
      'Maintenance': 'Maintenance work is scheduled for [Date]. Please cooperate.',
      'Water Supply': 'Water supply will be affected on [Date] due to tank cleaning.',
      'Meeting': 'A general meeting is scheduled on [Date] regarding building maintenance.',
    };

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.5),
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
                  color: Colors.white.withValues(alpha: 0.95), // High opacity for readability
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    )
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: SingleChildScrollView( 
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
                                    style: GoogleFonts.outfit(fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6)),
                                    maxLines: 1, 
                                    overflow: TextOverflow.ellipsis
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),

                        // Templates Section
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: templates.entries.map((e) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ActionChip(
                                  label: Text(e.key),
                                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  labelStyle: TextStyle(color: theme.colorScheme.primary, fontSize: 12),
                                  onPressed: () {
                                    titleController.text = e.key;
                                    msgController.text = e.value;
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 16),
                  
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
                                onPressed: isLoading ? null : () async {
                                  if (titleController.text.isNotEmpty && msgController.text.isNotEmpty) {
                                     setDialogState(() => isLoading = true); // Disable button
                                     
                                     final user = ref.read(userSessionServiceProvider).currentUser;
                                     if (user == null) {
                                       Navigator.pop(ctx);
                                       return;
                                     }
                                     
                                     try {
                                        await ref.read(noticeControllerProvider.notifier).sendNotice(
                                          houseId: widget.house.id.toString(),
                                          ownerId: user.uid,
                                          subject: titleController.text.trim(),
                                          message: msgController.text.trim(),
                                          priority: selectedPriority,
                                        );
                                        
                                        if (context.mounted) {
                                          Navigator.pop(ctx);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Notice Broadcasted Successfully!'), backgroundColor: Colors.green)
                                          );
                                        }
                                     } catch (e) {
                                        setDialogState(() => isLoading = false); // Re-enable on error
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                        }
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
                                child: isLoading 
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text('Broadcast', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
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
            color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 1.5 : 1),
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
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

          // Notification Icon
          Container(
            margin: const EdgeInsets.only(right: 16),
             decoration: BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.circle,
               boxShadow: [
                 BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
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
        onPressed: () => _showAddUnitOptions(context, ref),
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
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
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

                  final ownerAsync = ref.watch(ownerControllerProvider);
                  final currencySymbol = CurrencyUtils.getSymbol(ownerAsync.value?.currency);
                  
                  String formatRevenue(double val) {
                    if (val >= 10000000) return '$currencySymbol${(val / 10000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}Cr';
                    if (val >= 100000) return '$currencySymbol${(val / 100000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}L';
                    if (val >= 1000) return '$currencySymbol${(val / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}k';
                    return '$currencySymbol${val.toStringAsFixed(0)}';
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

             const SizedBox(height: 24),

             // Quick Actions Section
             Text('Quick Actions', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
             const SizedBox(height: 12),
             Row(
               children: [
                 Expanded(
                   child: Material(
                     color: Colors.transparent,
                     child: InkWell(
                       onTap: _showBroadcastDialog,
                       borderRadius: BorderRadius.circular(16),
                       child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                         decoration: BoxDecoration(
                           gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)]),
                           borderRadius: BorderRadius.circular(16),
                           boxShadow: [
                             BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                           ]
                         ),
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Container(
                               padding: const EdgeInsets.all(8),
                               decoration: BoxDecoration(
                                 color: Colors.white.withValues(alpha: 0.2),
                                 shape: BoxShape.circle,
                               ),
                               child: const Icon(Icons.campaign_outlined, color: Colors.white, size: 24),
                             ),
                             const SizedBox(width: 12),
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text('Broadcast Notice', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                   Text('To all tenants', style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                                 ],
                               ),
                             )
                           ],
                         ),
                       ),
                     ),
                   ),
                 ),
               ],
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
                     return EmptyStateWidget(
                       title: 'No Units Added',
                       subtitle: 'Add specific flats (e.g. 101, 102) or generate floor-wise config rapidly.',
                       icon: Icons.meeting_room_outlined,
                       buttonText: 'Add Units',
                       onButtonPressed: () => _showAddUnitOptions(context, ref),
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

  // NEW: Bottom sheet with 3 Add Unit options
  void _showAddUnitOptions(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            Text(
              'Add Units',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 20),
            
            // Option 1: Add Single Unit
            _buildUnitOption(
              context: context,
              icon: Icons.add,
              iconColor: Colors.blue,
              title: 'Add Single Unit',
              subtitle: 'Add one flat manually',
              onTap: () {
                Navigator.pop(ctx);
                _showSingleUnitDialog(context, ref);
              },
            ),
            const SizedBox(height: 12),
            
            // Option 2: Bulk Add Units
            _buildUnitOption(
              context: context,
              icon: Icons.grid_view_rounded,
              iconColor: Colors.orange,
              title: 'Bulk Add Units',
              subtitle: 'Add multiple flats (Flat 1, Flat 2...)',
              onTap: () {
                Navigator.pop(ctx);
                _showBulkAddDialog(context, ref);
              },
            ),
            const SizedBox(height: 12),
            
            // Option 3: Add Floor-Wise
            _buildUnitOption(
              context: context,
              icon: Icons.apartment_rounded,
              iconColor: Colors.purple,
              title: 'Add Floor-Wise',
              subtitle: 'Generate 101, 102, 201... in one go',
              onTap: () {
                Navigator.pop(ctx);
                _showFloorWiseDialog(context, ref);
              },
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUnitOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: theme.hintColor)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.hintColor),
            ],
          ),
        ),
      ),
    );
  }

  // Single Unit Dialog
  void _showSingleUnitDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final rentController = TextEditingController();
    final areaController = TextEditingController();
    final parkingController = TextEditingController();
    final meterController = TextEditingController();
    
    String? selectedBhkTemplateId;
    String? selectedBhkType;
    String? imageBase64; // For photo
    String? furnishingStatus;
    
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final templatesAsync = ref.watch(bhkTemplateControllerProvider(widget.house.id));
          
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.add_home_work, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Add Single Unit'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Unit Number / Name',
                      hintText: 'e.g., Flat 101',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 20),
                  
                  // Optional Configuration Section
                  Text('Optional Configuration', 
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
                  const SizedBox(height: 12),
                  
                  // Add New Type Option
                  InkWell(
                    onTap: () {
                      Navigator.pop(dialogContext);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => BhkTemplateListScreen(houseId: widget.house.id),
                      )).then((_) {
                        _showSingleUnitDialog(context, ref);
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('+ Add New Type...', 
                        style: GoogleFonts.outfit(
                          color: theme.primaryColor, 
                          fontWeight: FontWeight.w600,
                        )),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // BHK Type Dropdown
                  templatesAsync.when(
                    data: (templates) {
                      if (templates.isEmpty) return const SizedBox.shrink();
                      return DropdownButtonFormField<String>(
                        initialValue: selectedBhkTemplateId,
                        decoration: const InputDecoration(labelText: 'BHK Type', border: OutlineInputBorder()),
                        items: templates.map((t) => DropdownMenuItem<String>(value: t.id, child: Text('${t.bhkType} - ₹${t.defaultRent}'))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final t = templates.firstWhere((e) => e.id == val);
                            setState(() {
                              selectedBhkTemplateId = val;
                              selectedBhkType = t.bhkType;
                              rentController.text = t.defaultRent.toString();
                            });
                          }
                        },
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 12),
                  
                  TextField(
                    controller: rentController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Base Rent (₹)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  
                  // Photo Upload
                  _buildPhotoUploadWidget(
                    context: context,
                    imageBase64: imageBase64,
                    onImageSelected: (base64) => setState(() => imageBase64 = base64),
                    onImageRemoved: () => setState(() => imageBase64 = null),
                  ),

                  const SizedBox(height: 16),

                  // Advanced Details Expander
                  ExpansionTile(
                    title: Text('Advanced Details', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 10),
                    collapsedIconColor: theme.colorScheme.primary,
                    iconColor: theme.colorScheme.primary,
                    children: [
                       DropdownButtonFormField<String>(
                         decoration: const InputDecoration(labelText: 'Furnishing Status', border: OutlineInputBorder()),
                         initialValue: furnishingStatus,
                         items: ['Unfurnished', 'Semi-Furnished', 'Fully Furnished']
                             .map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.outfit(fontSize: 14))))
                             .toList(),
                         onChanged: (v) => setState(() => furnishingStatus = v),
                       ),
                       const SizedBox(height: 12),
                       TextField(
                         controller: areaController,
                         keyboardType: TextInputType.number,
                         decoration: const InputDecoration(labelText: 'Carpet Area (Sq Ft)', border: OutlineInputBorder()),
                       ),
                       const SizedBox(height: 12),
                       TextField(
                         controller: parkingController,
                         decoration: const InputDecoration(labelText: 'Parking Slot No.', border: OutlineInputBorder()),
                       ),
                       const SizedBox(height: 12),
                       TextField(
                         controller: meterController,
                         decoration: const InputDecoration(labelText: 'Electric Meter No.', border: OutlineInputBorder()),
                       ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;
                  
                  Navigator.pop(dialogContext);
                  await DialogUtils.runWithLoading(context, () async {
                    await ref.read(houseControllerProvider.notifier).addUnit(
                      widget.house.id, name,
                      baseRent: double.tryParse(rentController.text),
                      bhkTemplateId: selectedBhkTemplateId,
                      bhkType: selectedBhkType,
                      imageBase64: imageBase64,
                      furnishingStatus: furnishingStatus,
                      carpetArea: double.tryParse(areaController.text),
                      parkingSlot: parkingController.text.trim().isEmpty ? null : parkingController.text.trim(),
                      meterNumber: meterController.text.trim().isEmpty ? null : meterController.text.trim(),
                    );
                  });
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unit added')));
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Bulk Add Dialog
  void _showBulkAddDialog(BuildContext context, WidgetRef ref) {
    final countController = TextEditingController(text: '10');
    final startController = TextEditingController(text: '1');
    final prefixController = TextEditingController(text: 'Flat');
    final rentController = TextEditingController();
    String? selectedBhkTemplateId;
    String? selectedBhkType;
    String? imageBase64; // Single photo for all units
    
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final templatesAsync = ref.watch(bhkTemplateControllerProvider(widget.house.id));
          
          return AlertDialog(
            title: const Text('Bulk Add Units'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: countController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Count', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: startController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Start No.', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: prefixController,
                    decoration: const InputDecoration(labelText: 'Prefix', hintText: 'Flat', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  
                  // Optional Configuration Section
                  Text('Optional Configuration', 
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
                  const SizedBox(height: 12),
                  
                  // Add New Type Option
                  InkWell(
                    onTap: () {
                      Navigator.pop(dialogContext);
                      // Navigate to BHK Template Screen
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => BhkTemplateListScreen(houseId: widget.house.id),
                      )).then((_) {
                        // Re-open dialog after returning
                        _showBulkAddDialog(context, ref);
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('+ Add New Type...', 
                        style: GoogleFonts.outfit(
                          color: theme.primaryColor, 
                          fontWeight: FontWeight.w600,
                        )),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // BHK Type Dropdown
                  templatesAsync.when(
                    data: (templates) {
                      if (templates.isEmpty) return const SizedBox.shrink();
                      return DropdownButtonFormField<String>(
                        initialValue: selectedBhkTemplateId,
                        decoration: const InputDecoration(labelText: 'BHK Type', border: OutlineInputBorder()),
                        items: templates.map((t) => DropdownMenuItem<String>(value: t.id, child: Text(t.bhkType))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final t = templates.firstWhere((e) => e.id == val);
                            setState(() {
                              selectedBhkTemplateId = val;
                              selectedBhkType = t.bhkType;
                              rentController.text = t.defaultRent.toString();
                            });
                          }
                        },
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 12),
                  
                  TextField(
                    controller: rentController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Default Rent (₹)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  
                  // Photo Upload - one photo for all units
                  _buildPhotoUploadWidget(
                    context: context,
                    imageBase64: imageBase64,
                    onImageSelected: (base64) => setState(() => imageBase64 = base64),
                    onImageRemoved: () => setState(() => imageBase64 = null),
                  ),
                  if (imageBase64 != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('This photo will be applied to all units', style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey)),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  final count = int.tryParse(countController.text) ?? 1;
                  final start = int.tryParse(startController.text) ?? 1;
                  
                  await DialogUtils.runWithLoading(context, () async {
                    await ref.read(houseControllerProvider.notifier).addUnitsBulk(
                      houseId: widget.house.id,
                      count: count,
                      startNumber: start,
                      prefix: prefixController.text.trim(),
                      baseRent: double.tryParse(rentController.text),
                      bhkTemplateId: selectedBhkTemplateId,
                      bhkType: selectedBhkType,
                      imageBase64: imageBase64,
                    );
                  });
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$count units added')));
                },
                child: const Text('Add All'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Floor-Wise Dialog (NEW)
  void _showFloorWiseDialog(BuildContext context, WidgetRef ref) {
    final floorsController = TextEditingController(text: '1');
    final unitsPerFloorController = TextEditingController(text: '1');
    final rentController = TextEditingController();
    String? selectedBhkTemplateId;
    String? selectedBhkType;
    String? imageBase64; // Single photo for all units
    bool showNewTypeForm = false;
    
    // Controllers for inline BHK creation
    final newTypeController = TextEditingController();
    final newTypeRentController = TextEditingController();
    String? newTypeImageBase64;
    
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final templatesAsync = ref.watch(bhkTemplateControllerProvider(widget.house.id));
          final floors = int.tryParse(floorsController.text) ?? 1;
          final unitsPerFloor = int.tryParse(unitsPerFloorController.text) ?? 1;
          
          // Generate preview text with floor groupings
          final previewParts = <String>[];
          for (int f = 1; f <= floors && f <= 2; f++) {
            final units = <String>[];
            for (int u = 1; u <= unitsPerFloor && u <= 2; u++) {
              units.add('${f}0$u');
            }
            if (unitsPerFloor > 2) units.add('...');
            previewParts.add('${units.join(', ')} (Floor $f)');
          }
          if (floors > 2) previewParts.add('...');
          final previewText = previewParts.join(', ');
          
          // If showing new type form
          if (showNewTypeForm) {
            return AlertDialog(
              title: const Text('Add Floor-Wise Units'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New BHK Type', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: newTypeController,
                            decoration: const InputDecoration(
                              labelText: 'Type (e.g. 2BHK Luxury)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: newTypeRentController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Default Rent',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Add Template Photo
                    InkWell(
                      onTap: () async {
                        final picker = ImagePicker();
                        final source = await showDialog<ImageSource>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Select Photo Source'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text('Camera'),
                                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Gallery'),
                                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                                ),
                              ],
                            ),
                          ),
                        );
                        if (source != null) {
                          final image = await picker.pickImage(source: source, maxWidth: 800, imageQuality: 70);
                          if (image != null) {
                            final bytes = await image.readAsBytes();
                            setState(() => newTypeImageBase64 = base64Encode(bytes));
                          }
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: newTypeImageBase64 != null ? Colors.green.shade50 : null,
                        ),
                        child: newTypeImageBase64 != null
                            ? Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(base64Decode(newTypeImageBase64!), height: 70, fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: 4, right: 4,
                                    child: InkWell(
                                      onTap: () => setState(() => newTypeImageBase64 = null),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined, color: Colors.grey.shade500),
                                  const SizedBox(height: 4),
                                  Text('Add Template Photo', style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 12)),
                                  Text('(Shared by all units of this type)', style: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 10)),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => setState(() => showNewTypeForm = false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (newTypeController.text.isNotEmpty) {
                      await ref.read(bhkTemplateControllerProvider(widget.house.id).notifier).addBhkTemplate(
                        houseId: widget.house.id,
                        bhkType: newTypeController.text,
                        defaultRent: double.tryParse(newTypeRentController.text) ?? 0,
                        imageBase64: newTypeImageBase64,
                      );
                      setState(() {
                        showNewTypeForm = false;
                        // After creation, the dropdown will refresh and show the new type
                      });
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          }
          
          return AlertDialog(
            title: const Text('Add Floor-Wise Units'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: floorsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'No. of Floors', border: OutlineInputBorder()),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: unitsPerFloorController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Units per Fl...', border: OutlineInputBorder()),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // BHK Type Dropdown with + Add New Type option
                  templatesAsync.when(
                    data: (templates) {
                      // Create items list with "+ Add New Type..." at top
                      final items = <DropdownMenuItem<String>>[
                        DropdownMenuItem<String>(
                          value: '__add_new__',
                          child: Text('+ Add New Type...', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600)),
                        ),
                        ...templates.map((t) => DropdownMenuItem<String>(value: t.id, child: Text(t.bhkType))),
                      ];
                      
                      return DropdownButtonFormField<String>(
                        initialValue: selectedBhkTemplateId,
                        decoration: const InputDecoration(labelText: 'BHK Type', border: OutlineInputBorder()),
                        items: items,
                        onChanged: (val) {
                          if (val == '__add_new__') {
                            setState(() => showNewTypeForm = true);
                          } else if (val != null) {
                            final t = templates.firstWhere((e) => e.id == val);
                            setState(() {
                              selectedBhkTemplateId = val;
                              selectedBhkType = t.bhkType;
                              rentController.text = t.defaultRent.toString();
                            });
                          }
                        },
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 12),
                  
                  TextField(
                    controller: rentController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Rent per Unit', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  
                  // Photo Upload - one photo for all units
                  _buildPhotoUploadWidget(
                    context: context,
                    imageBase64: imageBase64,
                    onImageSelected: (base64) => setState(() => imageBase64 = base64),
                    onImageRemoved: () => setState(() => imageBase64 = null),
                  ),
                  const SizedBox(height: 12),
                  
                  // Preview with floor groupings
                  if (previewText.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Produces: $previewText',
                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  final floors = int.tryParse(floorsController.text) ?? 1;
                  final unitsPerFloor = int.tryParse(unitsPerFloorController.text) ?? 1;
                  final rent = double.tryParse(rentController.text);
                  
                  await DialogUtils.runWithLoading(context, () async {
                    await ref.read(houseControllerProvider.notifier).addUnitsFloorWise(
                      houseId: widget.house.id,
                      floors: floors,
                      unitsPerFloor: unitsPerFloor,
                      baseRent: rent,
                      bhkTemplateId: selectedBhkTemplateId,
                      bhkType: selectedBhkType,
                      imageBase64: imageBase64,
                    );
                  });
                  
                  final total = floors * unitsPerFloor;
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$total units added')));
                },
                child: const Text('Generate Units'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Reusable Photo Upload Widget for dialogs
  Widget _buildPhotoUploadWidget({
    required BuildContext context,
    required String? imageBase64,
    required Function(String base64) onImageSelected,
    required VoidCallback onImageRemoved,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () async {
        final picker = ImagePicker();
        final source = await showDialog<ImageSource>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Select Photo Source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
        
        if (source == null) return;
        
        final image = await picker.pickImage(source: source, maxWidth: 800, imageQuality: 70);
        if (image != null) {
          final bytes = await image.readAsBytes();
          onImageSelected(base64Encode(bytes));
        }
      },
      child: Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
          color: imageBase64 != null ? Colors.green.shade50 : null,
        ),
        child: imageBase64 != null
            ? Stack(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        base64Decode(imageBase64),
                        height: 70,
                        width: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: onImageRemoved,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('Photo Added', style: GoogleFonts.outfit(fontSize: 9, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: theme.primaryColor, size: 24),
                  const SizedBox(width: 8),
                  Text('Add Photo (Optional)', style: GoogleFonts.outfit(color: theme.primaryColor, fontWeight: FontWeight.w500)),
                ],
              ),
      ),
    );
  }

  void _showAddUnitDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final countController = TextEditingController(text: '1');
    final rentController = TextEditingController();
    String? selectedBhkTemplateId;
    String? selectedBhkType;
    bool isBulkMode = false;
    
    final templatesAsync = ref.watch(bhkTemplateControllerProvider(widget.house.id));
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.add_home_work, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Add Unit(s)'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bulk Mode Toggle
                  SwitchListTile(
                    title: const Text('Bulk Add Multiple'),
                    subtitle: Text(isBulkMode ? 'Add several units at once' : 'Add single unit'),
                    value: isBulkMode,
                    onChanged: (v) => setState(() => isBulkMode = v),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  // Unit Name/Prefix
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: isBulkMode ? 'Prefix' : 'Unit Number / Name',
                      hintText: isBulkMode ? 'e.g., Flat' : 'e.g., Flat 101',
                      border: const OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 12),
                  
                  // Count (Bulk Mode Only)
                  if (isBulkMode) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: countController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Count',
                              hintText: 'How many?',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: '1',
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Start From',
                              hintText: '1',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) {}, // Store if needed
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // BHK Template Dropdown
                  templatesAsync.when(
                    data: (templates) {
                      if (templates.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                              const SizedBox(width: 8),
                              const Expanded(child: Text('Create BHK templates first to classify units', style: TextStyle(fontSize: 12))),
                            ],
                          ),
                        );
                      }
                      return DropdownButtonFormField<String>(
                        initialValue: selectedBhkTemplateId,
                        decoration: const InputDecoration(
                          labelText: 'BHK Type (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        items: templates.map((t) => DropdownMenuItem<String>(
                          value: t.id,
                          child: Text('${t.bhkType} - ₹${t.defaultRent}'),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final t = templates.firstWhere((e) => e.id == val);
                            setState(() {
                              selectedBhkTemplateId = val;
                              selectedBhkType = t.bhkType;
                              rentController.text = t.defaultRent.toString();
                            });
                          }
                        },
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => const Text('Error loading templates'),
                  ),
                  const SizedBox(height: 12),
                  
                  // Rent Field
                  TextField(
                    controller: rentController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Base Rent (₹)',
                      hintText: 'Optional - set later',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: Text(isBulkMode ? 'Add Units' : 'Add'),
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;
                  
                  final currentUnits = ref.read(houseUnitsProvider(widget.house.id)).valueOrNull ?? [];
                  final owner = ref.read(ownerControllerProvider).value;
                  final plan = owner?.subscriptionPlan ?? 'free';
                  
                  int limit = 2; // Free
                  if (plan == 'pro') limit = 20;
                  if (plan == 'power') limit = 999999;

                  final countToAdd = isBulkMode ? (int.tryParse(countController.text) ?? 1) : 1;
                  
                  if (currentUnits.length + countToAdd > limit) {
                     Navigator.pop(dialogContext);
                     if (context.mounted) {
                        showDialog(
                          context: context, 
                          builder: (_) => AlertDialog(
                            title: const Text('Limit Reached'),
                            content: Text('Adding $countToAdd units would exceed your limit of $limit units (${plan.toUpperCase()} plan). Upgrade to add more.'),
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
                  
                  Navigator.pop(dialogContext);
                  await DialogUtils.runWithLoading(context, () async {
                    final rent = double.tryParse(rentController.text);
                    
                    if (isBulkMode) {
                      await ref.read(houseControllerProvider.notifier).addUnitsBulk(
                        houseId: widget.house.id,
                        count: countToAdd,
                        startNumber: 1,
                        prefix: name,
                        baseRent: rent,
                        bhkTemplateId: selectedBhkTemplateId,
                        bhkType: selectedBhkType,
                      );
                    } else {
                      await ref.read(houseControllerProvider.notifier).addUnit(
                        widget.house.id, 
                        name,
                        baseRent: rent,
                        bhkTemplateId: selectedBhkTemplateId,
                        bhkType: selectedBhkType,
                      );
                    }
                  });
                  if(context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isBulkMode ? '$countToAdd units added' : 'Unit added')));
                  }
                },
              ),
            ],
          );
        },
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
              data: (templates) => DropdownButtonFormField<String>(
                   initialValue: _bulkBhkTemplateId,
                   decoration: InputDecoration(
                     labelText: 'Select BHK Type', 
                     border: const OutlineInputBorder(), 
                     filled: true, 
                     fillColor: theme.cardColor,
                     labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
                   ),
                   dropdownColor: theme.cardColor,
                   items: templates.map((t) => DropdownMenuItem<String>(value: t.id, child: Text(t.bhkType, style: TextStyle(color: theme.textTheme.bodyLarge?.color)))).toList(),
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
            color: color.withValues(alpha: 0.08),
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
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.7),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
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
