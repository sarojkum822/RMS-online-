import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../../features/rent/domain/entities/rent_cycle.dart';
import '../rent/rent_controller.dart';
import '../../../providers/data_providers.dart';
import '../../../widgets/dotted_line_separator.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../../../core/utils/dialog_utils.dart';
import 'package:printing/printing.dart'; // NEW
import '../../../../core/services/pdf_service.dart'; // NEW
import 'package:kirayabook/presentation/screens/owner/settings/owner_controller.dart'; // NEW
import 'tenant_form_screen.dart'; // NEW
import 'tenant_controller.dart';

class TenantDetailScreen extends ConsumerStatefulWidget {
  final Tenant tenant;

  const TenantDetailScreen({super.key, required this.tenant});

  @override
  ConsumerState<TenantDetailScreen> createState() => _TenantDetailScreenState();
}

class _TenantDetailScreenState extends ConsumerState<TenantDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = (screenHeight * 0.45).clamp(300.0, 420.0);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final tenantsAsync = ref.watch(tenantControllerProvider);
    final currentTenant = tenantsAsync.valueOrNull?.firstWhere(
      (t) => t.id == widget.tenant.id,
      orElse: () => widget.tenant,
    ) ?? widget.tenant;

    // Fetch Active Tenancy
    final tenancyAsync = ref.watch(activeTenancyProvider(widget.tenant.id));
    final currentTenancy = tenancyAsync.valueOrNull;

    // Resolve details ONLY if Tenancy exists
    final unitId = currentTenancy?.unitId;
    final tenancyId = currentTenancy?.id;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: Consumer(
          builder: (context, ref, _) {
            if (unitId == null) return const Text('No Associated Property');
            final unitVal = ref.watch(unitDetailsProvider(unitId));
            
            return unitVal.when(
              data: (unit) {
                  if (unit == null) return const Text('Unknown Property');
                  // Fetch House Name for Unit
                  final houseVal = ref.watch(houseDetailsProvider(unit.houseId));
                  return houseVal.when(
                     data: (h) => Text(h?.name ?? '', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white)),
                     error: (_,__) => const SizedBox(),
                     loading: () => const SizedBox(),
                  );
              }, 
              error: (_,__) => const SizedBox(),
              loading: () => const SizedBox(),
            );
          }
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Edit Tenant',
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => TenantFormScreen(tenant: currentTenant)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            tooltip: 'Download Statement',
            onPressed: () => _handleDownloadStatement(context, ref, currentTenant),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
                if (value == 'move_out') _confirmMoveOut(context, ref, currentTenant, currentTenancy?.id);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'move_out',
                child: Row(
                   children: [
                      Icon(Icons.exit_to_app, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Move Out / End Tenancy'),
                   ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Compact Gradient Header
            Column(
              children: [
                // Dynamic Gradient Header Container
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                         Color(0xFF2C2C2C), // Matte Black Top
                         Color(0xFF000000), // Pure Black Bottom
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                    border: Border(
                      bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
                    ), 
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 100, 20, 60), 
                    child: Column(
                      children: [
                        // Avatar and Basic Info Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              child: CircleAvatar(
                                radius: 32, 
                                backgroundColor: const Color(0xFF333333), 
                                backgroundImage: currentTenant.imageBase64 != null 
                                  ? MemoryImage(base64Decode(currentTenant.imageBase64!))
                                  : ((currentTenant.imageUrl != null && currentTenant.imageUrl!.isNotEmpty)
                                      ? (currentTenant.imageUrl!.startsWith('http') 
                                        ? NetworkImage(currentTenant.imageUrl!) 
                                        : FileImage(File(currentTenant.imageUrl!))) as ImageProvider
                                      : null),
                                child: (currentTenant.imageBase64 == null && (currentTenant.imageUrl == null || currentTenant.imageUrl!.isEmpty)) ? Text(
                                  currentTenant.name[0].toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ) : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentTenant.name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        // Phone with Copy
                                        InkWell(
                                          onTap: () {
                                            Clipboard.setData(ClipboardData(text: currentTenant.phone));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Phone number copied to clipboard'), duration: Duration(seconds: 1)),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.phone, size: 12, color: Colors.greenAccent),
                                                const SizedBox(width: 4),
                                                Text(
                                                  currentTenant.phone,
                                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                                                ),
                                                const SizedBox(width: 4),
                                                const Icon(Icons.copy, size: 10, color: Colors.white54),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // ID with Copy
                                        InkWell(
                                          onTap: () {
                                            Clipboard.setData(ClipboardData(text: currentTenant.id.toString()));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('ID copied to clipboard'), duration: Duration(seconds: 1)),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'ID: ${currentTenant.id.length > 12 ? '${currentTenant.id.substring(0, 12)}...' : currentTenant.id}',
                                                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                                                ),
                                                const SizedBox(width: 4),
                                                const Icon(Icons.copy, size: 10, color: Colors.white54),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // NEW FIELDS DISPLAY
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                       if(currentTenant.policeVerification)
                                       Container(
                                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                         decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.blue.withValues(alpha: 0.5))),
                                         child: Row(
                                           mainAxisSize: MainAxisSize.min,
                                           children: [
                                             const Icon(Icons.verified_user, color: Colors.blueAccent, size: 12),
                                             const SizedBox(width: 4),
                                             Text('Police Verified', style: GoogleFonts.outfit(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                                           ],
                                         ),
                                       ),

                                       Container(
                                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                         decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                         child: Row(
                                           mainAxisSize: MainAxisSize.min,
                                           children: [
                                             const Icon(Icons.people, color: Colors.white70, size: 12),
                                             const SizedBox(width: 4),
                                             Text('${currentTenant.memberCount} Mbrs', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11)),
                                           ],
                                         ),
                                       ),
                                       
                                       if(currentTenant.idProof != null && currentTenant.idProof!.isNotEmpty)
                                       InkWell(
                                          onTap: () {
                                            Clipboard.setData(ClipboardData(text: currentTenant.idProof!));
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID Proof Copied')));
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                            child: Text('ID: ${currentTenant.idProof}', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11)),
                                          ),
                                       ),
                                    ],
                                  ),
                                  
                                  if(currentTenant.address != null && currentTenant.address!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.location_on, color: Colors.white54, size: 12),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            currentTenant.address!, 
                                            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                                            maxLines: 1, 
                                            overflow: TextOverflow.ellipsis
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Unit & Reading Card (Overlapping)
                Transform.translate(
                  offset: const Offset(0, -40), // Move Up to Overlap
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor, // Adapts to Dark Mode
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.transparent : Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Unit Info
                          Expanded(
                              child: Consumer(
                              builder: (context, ref, _) {
                                if (unitId == null) return const Text('No Unit Assigned');
                                final unitValue = ref.watch(unitDetailsProvider(unitId));
                                return Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.blue.withValues(alpha: 0.1) : Colors.blue.shade50, 
                                        borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: const Icon(Icons.apartment, color: Colors.blue, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Unit Details', style: GoogleFonts.outfit(fontSize: 12, color: theme.hintColor)),
                                          Text(
                                            unitValue.when(
                                              data: (u) => '${u?.nameOrNumber ?? '-'} • ₹${u?.editableRent?.toInt() ?? 0}',
                                              error: (_,__) => 'Error',
                                              loading: () => '...',
                                            ),
                                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: theme.textTheme.bodyLarge?.color),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Container(width: 1, height: 40, color: Colors.grey.shade200), // Divider
                          // Initial Reading
                          Expanded(
                            child: Consumer(
                              builder: (context, ref, _) {
                                if (unitId == null) return const Center(child: Text('-'));
                                final readingValue = ref.watch(initialReadingProvider(unitId));
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('Initial Reading', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600)),
                                        Text(
                                          readingValue.when(
                                            data: (r) => r?.toString() ?? 'N/A',
                                            error: (_,__) => '-',
                                            loading: () => '...',
                                          ),
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.orange.shade800),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                     Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                                      child: const Icon(Icons.flash_on, color: Colors.orange, size: 20),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),

            const SizedBox(height: 20),
            
            // Meter Readings Expandable Section
            if (unitId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Consumer(
                builder: (context, ref, _) {
                  final readingsAsync = ref.watch(electricReadingsProvider(unitId));
                  final lastReadingAsync = ref.watch(latestReadingProvider(unitId));
                  
                  return readingsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (readings) {
                      if (readings.isEmpty) return const SizedBox.shrink();
                      
                      final currentReading = lastReadingAsync.valueOrNull ?? 0.0;
                      
                      return Theme(
                        data: theme.copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.electric_bolt, color: Colors.amber.shade700, size: 20),
                          ),
                          title: Row(
                            children: [
                              Text('Meter Readings', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('${readings.length}', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber.shade800)),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              Text('Current Reading', style: GoogleFonts.outfit(fontSize: 12, color: theme.hintColor)),
                              const SizedBox(width: 8),
                              Text('${currentReading.toStringAsFixed(1)} ⏱', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange)),
                            ],
                          ),
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: readings.length,
                              itemBuilder: (context, index) {
                                final reading = readings[index];
                                final readingValue = reading['reading'] as double;
                                final date = reading['date'] as DateTime;
                                
                                return Padding(
                                  padding: const EdgeInsets.only(left: 16, bottom: 12),
                                  child: Row(
                                    children: [
                                      // Timeline indicator
                                      Column(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: index == 0 ? Colors.green : Colors.grey.shade300,
                                              border: Border.all(color: index == 0 ? Colors.green : Colors.grey.shade400, width: 2),
                                            ),
                                          ),
                                          if (index < readings.length - 1)
                                            Container(width: 2, height: 24, color: Colors.grey.shade300),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      // Reading info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('${readingValue.toStringAsFixed(1)} units', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                                            Text(DateFormat('dd MMM yyyy').format(date), style: GoogleFonts.outfit(fontSize: 12, color: theme.hintColor)),
                                          ],
                                        ),
                                      ),
                                      // Checkmark
                                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Total Outstanding Card
            if (tenancyId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Consumer(
                builder: (context, ref, _) {
                  return ref.watch(rentCyclesForTenancyProvider(tenancyId)).when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (cycles) {
                      final totalOutstanding = cycles
                          .where((c) => c.status != RentStatus.paid)
                          .fold(0.0, (sum, c) => sum + (c.totalDue - c.totalPaid));
                      
                      if (totalOutstanding <= 0) return const SizedBox.shrink();
                      
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange.shade400, Colors.red.shade400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Outstanding', style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                                  Text(
                                    '₹${totalOutstanding.toStringAsFixed(0)}',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // "Bill History" Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bill History',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                   const SizedBox(width: 8),
                   Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddPastRecordDialog(context, ref),
                      icon: const Icon(Icons.history, size: 18, color: Colors.white),
                      label: FittedBox(child: Text('Add Past Record', style: GoogleFonts.outfit(fontWeight: FontWeight.w600))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB), // Blue Brand
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: const Color(0xFF0F172A).withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),


            // List
            if (tenancyId != null) 
            ref.watch(rentCyclesForTenancyProvider(tenancyId)).when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
              error: (e, s) => Center(child: Text('Error: $e')),
              data: (data) {
                final cycles = List<RentCycle>.from(data);
                final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());

                int getPriority(RentCycle c) {
                  if (c.status == RentStatus.paid) return 3;
                  if (c.month.compareTo(currentMonth) < 0) return 0; // Overdue
                  if (c.month == currentMonth) return 1; // Current Due
                  return 2; // Future Due
                }

                cycles.sort((a, b) {
                  final pA = getPriority(a);
                  final pB = getPriority(b);
                  if (pA != pB) return pA.compareTo(pB);
                  return b.month.compareTo(a.month); // Descending Date
                });
                
                if (cycles.isEmpty) return Padding(padding: const EdgeInsets.all(40), child: Text('No history', style: TextStyle(color: theme.textTheme.bodyMedium?.color)));

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: cycles.length,
                  itemBuilder: (context, index) {
                    final cycle = cycles[index];
                    final isPaid = cycle.status == RentStatus.paid;
                    final date = DateTime.parse('${cycle.month}-01');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12), // Reduced margin
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16), // Smaller radius
                        boxShadow: isDark ? [] : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04), 
                            blurRadius: 8, // Reduced blur
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: !isPaid 
                            ? Border.all(color: Colors.red.withValues(alpha: 0.6), width: 1.5)
                            : (isDark ? Border.all(color: Colors.white10) : null),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0), // Reduced padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8), // Smaller icon box
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white12 : Colors.grey[100], 
                                        borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: Icon(Icons.calendar_today, size: 16, color: theme.iconTheme.color), // Smaller icon
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      DateFormat('MMMM yyyy').format(date),
                                      style: GoogleFonts.outfit(
                                        fontSize: 16, // Smaller font
                                        fontWeight: FontWeight.bold,
                                        color: theme.textTheme.titleMedium?.color,
                                      ),
                                    ),
                                  ],
                                ),
                                // Status + Menu
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // Compact chip
                                      decoration: BoxDecoration(
                                        color: isPaid ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        cycle.status.name.toUpperCase(),
                                        style: GoogleFonts.outfit(
                                          color: isPaid ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10, // Smaller font
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    // Menu for Actions
                                    SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: PopupMenuButton<String>(
                                        padding: EdgeInsets.zero,
                                        icon: Icon(Icons.more_vert, size: 18, color: theme.iconTheme.color?.withValues(alpha: 0.5)),
                                        color: theme.cardColor,
                                        onSelected: (value) async {
                                          if (value == 'delete') {
                                             _confirmDeleteBill(context, ref, cycle, tenancyId);
                                          } else if (value == 'print') {
                                             await _handlePrintReceipt(context, ref, cycle, currentTenant);
                                          } else if (value == 'edit') {
                                             _showEditBillDialog(context, ref, cycle);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'print',
                                            child: Row(
                                              children: [
                                                Icon(Icons.print, color: Colors.blue, size: 16),
                                                SizedBox(width: 8),
                                                Text('Print Receipt', style: TextStyle(color: Colors.blue, fontSize: 13)),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit, color: Colors.orange, size: 16),
                                                SizedBox(width: 8),
                                                Text('Edit Bill', style: TextStyle(color: Colors.orange, fontSize: 13)),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete, color: Colors.red, size: 16),
                                                SizedBox(width: 8),
                                                Text('Delete Bill', style: TextStyle(color: Colors.red, fontSize: 13)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.only(left: 44.0), // Aligned with text start
                              child: Text(
                                'Bill #: ${cycle.billNumber ?? "N/A"}',
                                style: GoogleFonts.outfit(fontSize: 11, color: theme.textTheme.bodySmall?.color),
                              ),
                            ),
                            
                            // Electric Split Breakdown
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  // Base Rent Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.home_outlined, size: 14, color: theme.hintColor),
                                          const SizedBox(width: 6),
                                          Text('Base Rent', style: GoogleFonts.outfit(fontSize: 12, color: theme.textTheme.bodyMedium?.color)),
                                        ],
                                      ),
                                      Text('₹${cycle.baseRent.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
                                    ],
                                  ),
                                  
                                  // Electricity Row (only if > 0)
                                  if (cycle.electricAmount > 0) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.electric_bolt, size: 14, color: Colors.amber.shade600),
                                            const SizedBox(width: 6),
                                            Text('Electricity', style: GoogleFonts.outfit(fontSize: 12, color: theme.textTheme.bodyMedium?.color)),
                                          ],
                                        ),
                                        Text('₹${cycle.electricAmount.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.amber.shade700)),
                                      ],
                                    ),
                                  ],
                                  
                                  // Other Charges Row (only if > 0)
                                  if (cycle.otherCharges > 0) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.add_circle_outline, size: 14, color: Colors.blue.shade400),
                                            const SizedBox(width: 6),
                                            Text('Other Charges', style: GoogleFonts.outfit(fontSize: 12, color: theme.textTheme.bodyMedium?.color)),
                                          ],
                                        ),
                                        Text('₹${cycle.otherCharges.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue.shade600)),
                                      ],
                                    ),
                                  ],
                                  
                                  // Late Fee Row (only if > 0)
                                  if (cycle.lateFee > 0) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red.shade400),
                                            const SizedBox(width: 6),
                                            Text('Late Fee', style: GoogleFonts.outfit(fontSize: 12, color: theme.textTheme.bodyMedium?.color)),
                                          ],
                                        ),
                                        Text('₹${cycle.lateFee.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.red.shade600)),
                                      ],
                                    ),
                                  ],
                                  
                                  // Discount Row (only if > 0)
                                  if (cycle.discount > 0) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.discount_outlined, size: 14, color: Colors.green.shade400),
                                            const SizedBox(width: 6),
                                            Text('Discount', style: GoogleFonts.outfit(fontSize: 12, color: theme.textTheme.bodyMedium?.color)),
                                          ],
                                        ),
                                        Text('-₹${cycle.discount.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green.shade600)),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0), // Reduced spacing
                              child: DottedLineSeparator(), 
                            ),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total Due', style: GoogleFonts.outfit(color: theme.textTheme.bodySmall?.color, fontSize: 11)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '₹${cycle.totalDue.toStringAsFixed(0)}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 18, 
                                        fontWeight: FontWeight.bold,
                                        color: !isPaid ? Colors.red : theme.textTheme.bodyLarge?.color, // Red if pending
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Paid', style: GoogleFonts.outfit(color: theme.textTheme.bodySmall?.color, fontSize: 11)),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '₹${cycle.totalPaid.toStringAsFixed(0)}',
                                          style: GoogleFonts.outfit(
                                            fontSize: 18, 
                                            fontWeight: FontWeight.bold,
                                            color: isPaid ? const Color(0xFF2E7D32) : Colors.red,
                                          ),
                                        ),
                                        if (cycle.totalPaid > 0) ...[
                                           const SizedBox(width: 4),
                                           IconButton(
                                             icon: const Icon(Icons.info_outline, size: 18, color: Colors.blue),
                                             onPressed: () => _showPaymentHistory(context, ref, cycle),
                                             tooltip: 'View History',
                                             constraints: const BoxConstraints(),
                                             padding: EdgeInsets.zero,
                                           )
                                        ]
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            // Actions if Pending
                            if(!isPaid) ...[
                               const SizedBox(height: 12), 
                               Row(
                                 children: [
                                   Expanded(
                                     child: OutlinedButton(
                                       onPressed: () => _showChargesSheet(context, cycle, ref, currentTenant),
                                       style: OutlinedButton.styleFrom(
                                          foregroundColor: theme.textTheme.bodyLarge?.color,
                                          side: BorderSide(color: theme.dividerColor),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          minimumSize: Size.zero, 
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                       ),
                                       child: Text('+ Charges', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                                     ),
                                   ),
                                   const SizedBox(width: 8),
                                   Expanded(
                                     child: Container(
                                       decoration: BoxDecoration(
                                         gradient: const LinearGradient(
                                           colors: [Color(0xFFFF5252), Color(0xFF2563EB)], // Red to Sky Blue
                                           begin: Alignment.centerLeft,
                                           end: Alignment.centerRight,
                                         ),
                                         borderRadius: BorderRadius.circular(10),
                                       ),
                                       child: ElevatedButton(
                                         onPressed: () => _showPaymentSheet(context, cycle, ref),
                                         style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Smaller radius
                                            padding: const EdgeInsets.symmetric(vertical: 10), // Reduced internal padding
                                            elevation: 0,
                                            minimumSize: Size.zero, 
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                         ),
                                         child: Text('Record Payment', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                       ),
                                     ),
                                   ),
                                 ], // children
                               ),
                            ], // spread if
                          ], // Column children
                        ),
                      ),
                    );
                  },
                );
              },
            ),
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _confirmMoveOut(BuildContext context, WidgetRef ref, Tenant tenant, String? tenancyId) async {
    if (tenancyId == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No active tenancy found to end.')));
       return;
    }
    double totalDue = 0.0;
    try {
       // We need tenancyId
       final tenancy = await ref.read(activeTenancyProvider(tenant.id).future);
       if (tenancy == null) return; // Already inactive?

      final cycles = await ref.read(rentRepositoryProvider).getRentCyclesForTenancy(tenancy.id);
      for (var c in cycles) {
         if(c.status != RentStatus.paid) {
           totalDue += (c.totalDue - c.totalPaid);
         }
      }
    } catch (e) {
      debugPrint('Error calc balance: $e');
    }

    if (!context.mounted) return;

    showDialog(
      context: context, 
      builder: (dialogContext) => AlertDialog(
        title: const Text('End Tenancy & Move Out'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (totalDue > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3))
                ),
                child: Column(
                  children: [
                    const Text('Outstanding Balance', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('₹${totalDue.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Please settle dues before moving out.', style: TextStyle(fontSize: 12), textAlign: TextAlign.center),
                  ],
                ),
              )
            else
               Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3))
                ),
                child: const Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 28),
                    SizedBox(height: 8),
                    Text('No Dues Pending', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              
            const Text('Are you sure you want to move out this tenant?'),
            const SizedBox(height: 8),
            const Text('• Tenant status will change to "Inactive".', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const Text('• Unit will be marked "Vacant".', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const Text('• Payment history will be preserved.', style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: totalDue > 0 ? Colors.red : Colors.orange, // Red warning if dues
            ),
            onPressed: () async {
              Navigator.pop(dialogContext); // Close Confirmation Dialog
              
              try {
                // Use the OUTER 'context' here, which is the Screen context
                await DialogUtils.runWithLoading(context, () async {
                   // This now calls endTenancy
                   await ref.read(tenantControllerProvider.notifier).endTenancy(tenancyId);
                });
                
                // On success, go back
                if (context.mounted) {
                   Navigator.pop(context); // Return to Tenant List
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tenant Moved Out Successfully')));
                }
              } catch (e) {
                // If it fails (e.g. timeout), show error
                if (context.mounted) {
                   DialogUtils.showErrorDialog(context, title: 'Move Out Error', message: e.toString());
                }
              }
            }, 
            child: Text(totalDue > 0 ? 'Ignore & Move Out' : 'Confirm Move Out', style: const TextStyle(color: Colors.white)),
          )
        ],
      )
    );
  }

  void _showAddPastRecordDialog(BuildContext context, WidgetRef ref) {
    // ... no changes to dialog logic itself, but colors will inherit theme or need dialog theme
    // For  void _showAddPastRecordDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final paidController = TextEditingController(); 
    DateTime selectedMonth = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Past Record'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Record a bill from your manual register.', style: GoogleFonts.outfit(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                   // Allow selecting future dates to ensure current month can be fully selected
                   final d = await showDatePicker(
                     context: context, 
                     firstDate: DateTime(2020), 
                     lastDate: DateTime.now().add(const Duration(days: 365)), 
                     initialDate: selectedMonth
                   );
                   if(d != null) setState(() => selectedMonth = d);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Select Month', border: OutlineInputBorder()),
                  child: Text(DateFormat('MMMM yyyy').format(selectedMonth)),
                ),
              ),
              const SizedBox(height: 12),
              
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Bill Amount (₹)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: paidController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount Paid (Optional)', helperText: 'Leave empty if Unpaid', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final amt = double.tryParse(amountController.text) ?? 0;
                final paid = double.tryParse(paidController.text) ?? 0;
                final monthStr = DateFormat('yyyy-MM').format(selectedMonth);

                if (amt > 0) {
                     if (context.mounted) {
                      Navigator.pop(context); // Close dialog first to avoid multiple overlays
                      
                      try {
                          await DialogUtils.runWithLoading(context, () async {
                            final t = await ref.read(activeTenancyProvider(widget.tenant.id).future);
                            if (t == null) throw Exception("No Active Tenancy");
                            
                            await ref.read(rentControllerProvider.notifier).addPastRentCycle(
                              tenancyId: t.id,
                              ownerId: t.ownerId, 
                              month: monthStr,
                              totalDue: amt,
                              totalPaid: paid,
                              date: DateTime.now(),
                            );
                          });
                        if (context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Record Added Successfully')));
                        }
                      } catch (e) {
                         // Check for specific duplication error string from RentController
                         if (e.toString().contains('already exists')) {
                            // Fetch existing cycle to redirect
                            RentCycle? existingCycle;
                             try {
                                 final t = await ref.read(activeTenancyProvider(widget.tenant.id).future);
                                final cycles = await ref.read(rentRepositoryProvider).getRentCyclesForTenancy(t!.id);
                                existingCycle = cycles.cast<RentCycle?>().firstWhere((c) => c?.month == monthStr, orElse: () => null);
                             } catch (_) {}

                            if (context.mounted && existingCycle != null) {
                                showDialog(
                                  context: context, 
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Bill Already Exists'),
                                    content: Text('A bill for ${DateFormat('MMMM yyyy').format(selectedMonth)} already exists.\n\nDo you want to add this payment (₹$paid) to the existing bill?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          // Open Payment Sheet for the found cycle
                                          _showPaymentSheet(context, existingCycle!, ref);
                                        },
                                        child: const Text('Add Payment'),
                                      )
                                    ],
                                  )
                                );
                            } else {
                               // Fallback if we can't find it (shouldn't happen if error said it exists)
                               if (context.mounted) DialogUtils.showErrorDialog(context, title: 'Error', message: 'Bill exists but could not be loaded.');
                            }
                         } else {
                            if (context.mounted) {
                              DialogUtils.showErrorDialog(context, title: 'Error', message: e.toString());
                            }
                         }
                      }
                    }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount')));
                }
              },
              child: const Text('Save Record'),
            ),
          ],
        ),
      ),
    );
  }

   // --- Deletion Dialogs ---
   
   void _confirmDeleteBill(BuildContext context, WidgetRef ref, RentCycle cycle, String tenancyId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final isMatch = controller.text.trim() == 'DELETE';
          return AlertDialog(
            title: const Text('Delete Information'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Warning: This action is permanent and cannot be undone.',
                          style: GoogleFonts.outfit(color: Colors.red[900], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'To confirm deletion of the bill for ${cycle.month}, please type "DELETE" below:',
                  style: GoogleFonts.outfit(fontSize: 14),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'DELETE',
                  ),
                  onChanged: (val) => setState(() {}),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  disabledBackgroundColor: Colors.red.withValues(alpha: 0.3),
                ),
                onPressed: isMatch ? () async {
                  Navigator.pop(context); // Close dialog
                  try {
                     await DialogUtils.runWithLoading(context, () async {
                        await ref.read(rentControllerProvider.notifier).deleteBill(cycle);
                     });
                     if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bill deleted')));
                     }
                  } catch (e) {
                     if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                     }
                  }
                } : null, // Disable if not matching
                child: const Text('Delete Forever', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showEditBillDialog(BuildContext context, WidgetRef ref, RentCycle cycle) {
    final amountCtrl = TextEditingController(text: cycle.totalDue.toString());
    final noteCtrl = TextEditingController(text: cycle.notes ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Bill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             TextField(
               controller: amountCtrl,
               keyboardType: TextInputType.number,
               decoration: const InputDecoration(labelText: 'Total Due Amount (₹)', border: OutlineInputBorder()),
             ),
             const SizedBox(height: 12),
             TextField(
               controller: noteCtrl,
               decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
               maxLines: 2,
             ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
               final newAmount = double.tryParse(amountCtrl.text);
               if (newAmount == null) return;
               
               await DialogUtils.runWithLoading(context, () async {
                  await ref.read(rentControllerProvider.notifier).updateTotalDue(
                    rentCycleId: cycle.id,
                    newTotalDue: newAmount,
                    notes: noteCtrl.text.trim(),
                  );
               });
               if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Update'),
          )
        ],
      )
    );
  }

  void _showPaymentHistory(BuildContext context, WidgetRef ref, RentCycle cycle) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: theme.scaffoldBackgroundColor,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payment History', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close, color: theme.iconTheme.color)),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: FutureBuilder<List<Payment>>(
                    future: ref.read(rentRepositoryProvider).getPaymentsForRentCycle(cycle.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                      final payments = snapshot.data ?? [];
                      if (payments.isEmpty) return Center(child: Text('No payments found', style: TextStyle(color: theme.textTheme.bodyMedium?.color)));

                      return ListView.builder(
                        itemCount: payments.length,
                        itemBuilder: (context, index) {
                          final p = payments[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            color: theme.cardColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: isDark ? BorderSide(color: Colors.white12) : BorderSide.none),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(Icons.check, color: Colors.green),
                              ),
                              title: Text('₹${p.amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                              subtitle: Text('${DateFormat('dd MMM').format(p.date)} via ${p.method}', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  // Confirm Delete Payment
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Transaction?'),
                                      content: const Text('This will reduce the "Paid" amount for this bill.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                        TextButton(
                                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                                          onPressed: () async {
                                            Navigator.pop(ctx); // Close Alert
                                            
                                            await DialogUtils.runWithLoading(context, () async {
                                               await ref.read(rentControllerProvider.notifier).deletePayment(p.id, cycle.id, cycle.tenancyId);
                                            });
                                            
                                            // Refresh Sheet
                                            setSheetState(() {});
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    )
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Future<void> _handleDownloadStatement(BuildContext context, WidgetRef ref, Tenant tenant) async {
    await DialogUtils.runWithLoading(context, () async {
      try {
        var owner = ref.read(ownerControllerProvider).value;
        if (owner == null) {
          // Attempt to fetch if not loaded
          owner = await ref.read(ownerControllerProvider.future);
        }
        if (owner == null) throw Exception('Owner profile not found. Please go to Settings > Profile to set it up.');
        
        final t = await ref.read(activeTenancyProvider(tenant.id).future);
        if (t == null) throw Exception('No active tenancy found');

        final cyclesAsync = await ref.read(rentRepositoryProvider).getRentCyclesForTenancy(t.id);
        
        final pdfData = await ref.read(pdfServiceProvider).generateStatement(
          tenant: tenant,
          cycles: cyclesAsync,
          owner: owner,
        );

        await Printing.layoutPdf(
          onLayout: (format) => pdfData,
          name: 'Statement_${tenant.name.replaceAll(RegExp(r'[\\/:*?"<>| ]'), '_')}_${DateFormat('MMM_yyyy').format(DateTime.now())}',
        );
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
      }
    });
  }

  void _showPaymentSheet(BuildContext context, RentCycle cycle, WidgetRef ref) {
    final amountController = TextEditingController(text: (cycle.totalDue - cycle.totalPaid).toStringAsFixed(0));
    final refController = TextEditingController();
    final notesController = TextEditingController();

    String selectedMethod = 'Cash';
    DateTime selectedDate = DateTime.now();
    
    // Local state for sheet
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
          child: IgnorePointer(
            ignoring: isSaving, // Block all input while saving
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Record Payment', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                // Amount
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount (₹)',
                    prefixIcon: const Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Date Picker
                InkWell(
                  onTap: () async {
                    final d = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2030), initialDate: selectedDate);
                    if(d != null) setSheetState(() => selectedDate = d);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Payment Date', style: GoogleFonts.outfit(color: Colors.grey[700])),
                        Text(DateFormat('dd MMM yyyy').format(selectedDate), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
  
                // Method Dropdown
                DropdownButtonFormField<String>(
                  initialValue: selectedMethod,
                  decoration: InputDecoration(
                    labelText: 'Payment Method',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['Cash', 'UPI', 'Bank Transfer', 'Cheque'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) => setSheetState(() => selectedMethod = v!),
                ),
                const SizedBox(height: 16),
                
                // Reference ID
                TextField(
                  controller: refController,
                  decoration: InputDecoration(
                    labelText: 'Reference / Transaction ID',
                    hintText: 'e.g. UPI Ref, Cheque No',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
  
                // Notes
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isSaving ? null : () async {
                       final amount = double.tryParse(amountController.text) ?? 0.0;
                       if(amount <= 0) return;
  
                       setSheetState(() => isSaving = true);
                       try {
                         await ref.read(rentControllerProvider.notifier).recordPayment(
                           rentCycleId: cycle.id,
                           tenantId: widget.tenant.id,
                           amount: amount,
                           date: selectedDate,
                           method: selectedMethod,
                           referenceId: refController.text.isEmpty ? null : refController.text,
                           notes: notesController.text.isEmpty ? null : notesController.text,
                         );
                         
                         if (context.mounted) {
                           Navigator.pop(context);
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Recorded')));
                           
                           // Prompt for Review if available
                           final InAppReview inAppReview = InAppReview.instance;
                           if (await inAppReview.isAvailable()) {
                             inAppReview.requestReview();
                           }
                         }
                       } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
                          }
                       } finally {
                          if (context.mounted) {
                             // Only update state if still mounted and not popped
                             try { setSheetState(() => isSaving = false); } catch(_) {}
                          }
                       }
                    },
                    child: isSaving 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save Payment', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChargesSheet(BuildContext context, RentCycle cycle, WidgetRef ref, Tenant tenant) async {
    final prevReadingController = TextEditingController();
    final currReadingController = TextEditingController();
    final rateController = TextEditingController(text: '10'); 
    
    final chargeAmountController = TextEditingController();
    final chargeNoteController = TextEditingController();

    // Determine Pre-fills (Async)
    double? lastReading;
    double? lastRate;
    
    try {
      final t = await ref.read(activeTenancyProvider(tenant.id).future);
      if (t == null) return;
      
      final readingData = await ref.read(rentControllerProvider.notifier).getLastElectricReading(t.unitId);
      if (readingData != null) {
        lastReading = readingData['currentReading'];
        lastRate = readingData['rate'];
      } else {
        // Fallback: If no "Last" reading (e.g. first month), try "Initial Reading"
        final t = await ref.read(activeTenancyProvider(tenant.id).future);
        if (t != null) {
          final initial = await ref.read(initialReadingProvider(t.unitId).future);
          if (initial != null) {
            lastReading = initial;
          }
        }
      }
    } catch (e) {
      debugPrint('Error auto-filling readings: $e');
      // If error (e.g. index missing for "Last" query), try "Initial" query as backup
       try {
          final t = await ref.read(activeTenancyProvider(tenant.id).future);
          if (t != null) {
            final initial = await ref.read(initialReadingProvider(t.unitId).future);
            if(initial != null) lastReading = initial;
          }
       } catch (_) {}
    }

    if (lastReading != null) {
      prevReadingController.text = lastReading.toString();
    }
    if (lastRate != null) {
      rateController.text = lastRate.toString();
    }

    if (!context.mounted) return;

    // Use boolean flag for loading
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => DefaultTabController(
          length: 2,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
            child: IgnorePointer(
              ignoring: isProcessing,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   TabBar(
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    tabs: const [
                      Tab(text: 'Electricity', icon: Icon(Icons.electric_bolt)),
                      Tab(text: 'Other Charges', icon: Icon(Icons.post_add)),
                    ],
                  ),
                  SizedBox(
                    height: 300,
                    child: TabBarView(
                      children: [
                        // Electricity Tab
                        Column(
                          children: [
                            const SizedBox(height: 20),
                            TextField(
                              controller: prevReadingController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Previous Reading', 
                                border: const OutlineInputBorder(),
                                helperText: lastReading != null ? 'Auto-filled from last reading' : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: currReadingController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Current Reading', border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: rateController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Rate per Unit (₹)', border: OutlineInputBorder()),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isProcessing ? null : () async {
                                  final prev = double.tryParse(prevReadingController.text) ?? 0;
                                  final curr = double.tryParse(currReadingController.text) ?? 0;
                                  final rate = double.tryParse(rateController.text) ?? 0;
                                  
                                  if (curr > prev) {
                                    setSheetState(() => isProcessing = true);
                                    try {
                                      await ref.read(rentControllerProvider.notifier).updateRentCycleWithElectric(
                                        rentCycleId: cycle.id,
                                        prevReading: prev,
                                        currentReading: curr,
                                        ratePerUnit: rate,
                                      );
                                      if (context.mounted) Navigator.pop(context);
                                    } catch (e) {
                                       if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                    } finally {
                                       if (context.mounted) try { setSheetState(() => isProcessing = false); } catch(_) {}
                                    }
                                  } else {
                                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Current reading must be greater than Previous')));
                                  }
                                },
                                child: isProcessing ? const CircularProgressIndicator() : const Text('Calculate & Save'),
                              ),
                            )
                          ],
                        ),
                        
                        // Other Charges Tab
                        Column(
                          children: [
                            const SizedBox(height: 20),
                            TextField(
                              controller: chargeAmountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: chargeNoteController,
                              decoration: const InputDecoration(labelText: 'Charge Description (e.g. Maintenance)', border: OutlineInputBorder()),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isProcessing ? null : () async {
                                  final amt = double.tryParse(chargeAmountController.text) ?? 0;
                                  if (amt > 0) {
                                    setSheetState(() => isProcessing = true);
                                    try {
                                      await ref.read(rentControllerProvider.notifier).addOtherCharge(
                                        rentCycleId: cycle.id,
                                        amount: amt,
                                        note: chargeNoteController.text,
                                      );
                                      if (context.mounted) Navigator.pop(context);
                                    } catch (e) {
                                       if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                    } finally {
                                       if (context.mounted) try { setSheetState(() => isProcessing = false); } catch(_) {}
                                    }
                                  }
                                },
                                child: isProcessing ? const CircularProgressIndicator() : const Text('Add Charge'),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePrintReceipt(BuildContext context, WidgetRef ref, RentCycle cycle, Tenant tenant) async {
    await DialogUtils.runWithLoading(context, () async {
      try {
        final houseRepo = ref.read(propertyRepositoryProvider);
        final rentRepo = ref.read(rentRepositoryProvider);
        
        final tenancy = await ref.read(activeTenancyProvider(tenant.id).future);
        if (tenancy == null) throw Exception('Tenancy not found');

        // 1. Fetch House (via Unit check inside HouseRepo or implicitly known? We need House entity)
        // We have tenancy.unitId. 
        final unitDetails = await houseRepo.getUnit(tenancy.unitId);
        if (unitDetails == null) throw Exception('Unit not found');
        
        final house = await houseRepo.getHouse(unitDetails.houseId);
        if (house == null) throw Exception('House not found');
        
        // 3. Fetch Payments
        final payments = await rentRepo.getPaymentsForRentCycle(cycle.id);
        
        // 4. Fetch Readings
        final allReadings = await rentRepo.getElectricReadingsWithDetails(tenancy.unitId);
        
        Map<String, dynamic>? currentReading;
        Map<String, dynamic>? previousReading;
        
        if (allReadings.isNotEmpty) {
           try {
             // Find reading closest to billGeneratedDate
              currentReading = allReadings.cast<Map<String, dynamic>?>().firstWhere((r) {
               final rDate = r!['date'] as DateTime;
               return rDate.isBefore(cycle.billGeneratedDate.add(const Duration(days: 1))); 
             }, orElse: () => null);
             
             if (currentReading != null) {
               final currentIndex = allReadings.indexOf(currentReading!);
               if (currentIndex + 1 < allReadings.length) {
                 previousReading = allReadings[currentIndex + 1];
               }
             }
           } catch (e) {
             // Not found
           }
        }
        
        // 5. Print
        await ref.read(printServiceProvider).printRentReceipt(
          rentCycle: cycle,
          tenant: tenant,
          house: house,
          unit: unitDetails,
          payments: payments,
          currentReading: currentReading,
          previousReading: previousReading,
        );
        
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating receipt: $e')));
        }
      }
    });
  }
}
