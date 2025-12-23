import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'package:url_launcher/url_launcher.dart'; // Import for communication
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../../features/rent/domain/entities/rent_cycle.dart';
import '../rent/rent_controller.dart';
import '../../../providers/data_providers.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../../../core/utils/dialog_utils.dart';
import 'package:printing/printing.dart'; // NEW
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
  bool _isDetailsExpanded = false;
  bool _isPropertyExpanded = false;
  bool _isProfileExpanded = false;
  bool _isLegalExpanded = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
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
        title: unitId == null 
          ? const Text('Tenant Details') 
          : Consumer(builder: (context, ref, _) {
              final unitVal = ref.watch(unitDetailsProvider(unitId));
              return unitVal.when(
                data: (unit) => Text(unit?.nameOrNumber ?? 'Unit', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white)),
                loading: () => const Text('Loading...', style: TextStyle(color: Colors.white)),
                error: (_, __) => const Text('Error', style: TextStyle(color: Colors.white)),
              );
            }),
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
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TenantFormScreen(tenant: currentTenant))),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            tooltip: 'Download Statement',
            onPressed: () => _handleDownloadStatement(context, ref, currentTenant),
          ),
          if (tenancyId != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'move_out') _confirmMoveOut(context, ref, currentTenant, tenancyId);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'move_out',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text('Move Out'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildAuraHeader(currentTenant, isDark),
                Positioned(
                  bottom: -30,
                  left: 0,
                  right: 0,
                  child: Consumer(builder: (context, ref, _) {
                    if (tenancyId == null) return const SizedBox.shrink();
                    final cyclesAsync = ref.watch(rentCyclesForTenancyProvider(tenancyId));
                    final totalOutstanding = cyclesAsync.valueOrNull
                      ?.where((c) => c.status != RentStatus.paid)
                      .fold(0.0, (sum, c) => sum + (c.totalDue - c.totalPaid)) ?? 0.0;
                    
                    return _buildGlassmorphicStats(
                      totalOutstanding, 
                      currentTenant.advanceAmount, 
                      isDark
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 80),
            
            // Full Tenant Details Accordion
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text("Full Tenant Details", 
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)
                      ),
                      leading: Icon(Icons.badge_outlined, color: theme.colorScheme.primary),
                      trailing: Icon(
                        _isDetailsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: theme.colorScheme.primary,
                      ),
                      onExpansionChanged: (val) => setState(() => _isDetailsExpanded = val),
                      children: [
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        
                        // Property Details Sub-Section
                        _buildSubExpandableSection(
                          "Property Details", 
                          Icons.apartment, 
                          _isPropertyExpanded,
                          (val) => setState(() => _isPropertyExpanded = val),
                          [
                            Consumer(builder: (context, ref, _) {
                              if (unitId == null) return Text("No property assigned", style: GoogleFonts.outfit(color: theme.hintColor));
                              final unitVal = ref.watch(unitDetailsProvider(unitId));
                              return unitVal.when(
                                data: (unit) => Column(
                                  children: [
                                    if (unit?.houseId != null)
                                      Consumer(builder: (context, ref, _) {
                                        final houseVal = ref.watch(houseDetailsProvider(unit!.houseId));
                                        return houseVal.when(
                                          data: (house) => _buildInfoRow(Icons.business, "Property/Building", house?.name ?? "-", theme),
                                          loading: () => const SizedBox.shrink(),
                                          error: (_, __) => const SizedBox.shrink(),
                                        );
                                      }),
                                    _buildInfoRow(Icons.apartment, "Flat/Unit", unit?.nameOrNumber ?? "-", theme),
                                    _buildInfoRow(Icons.currency_rupee, "Monthly Rent", "₹${unit?.editableRent?.toInt() ?? 0}", theme),
                                    Consumer(builder: (context, ref, _) {
                                      final lastReading = ref.watch(latestReadingProvider(unitId)).valueOrNull ?? 0.0;
                                      return _buildInfoRow(Icons.electric_bolt, "Current Meter Reading", "${lastReading.toStringAsFixed(1)} Units", theme);
                                    }),
                                  ],
                                ),
                                loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
                                error: (_, __) => const Text("Error loading unit"),
                              );
                            }),
                          ],
                          theme
                        ),

                        // Personal Profile Sub-Section
                        _buildSubExpandableSection(
                          "Personal Profile", 
                          Icons.person_outline, 
                          _isProfileExpanded,
                          (val) => setState(() => _isProfileExpanded = val),
                          [
                            _buildInfoRow(Icons.person, "Full Name", currentTenant.name, theme),
                            _buildInfoRow(Icons.phone, "Phone", currentTenant.phone, theme),
                            _buildInfoRow(Icons.cake, "DOB", currentTenant.dob ?? "Not set", theme),
                            _buildInfoRow(Icons.wc, "Gender", currentTenant.gender ?? "Not specified", theme),
                            _buildInfoRow(Icons.group, "Family Members", "${currentTenant.memberCount}", theme),
                            _buildInfoRow(Icons.location_on, "Permanent Address", currentTenant.address ?? "No address provided", theme),
                          ],
                          theme
                        ),

                        // Documentation & Legal Sub-Section
                        _buildSubExpandableSection(
                          "Documentation & Legal", 
                          Icons.gavel_outlined, 
                          _isLegalExpanded,
                          (val) => setState(() => _isLegalExpanded = val),
                          [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Police Verification", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
                                    Text(currentTenant.policeVerification ? "Verified" : "Pending", 
                                      style: GoogleFonts.outfit(color: currentTenant.policeVerification ? Colors.green : Colors.orange, fontSize: 12)
                                    ),
                                  ],
                                ),
                                if (!currentTenant.policeVerification)
                                TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Verification request sent to tenant")));
                                  }, 
                                  child: Text("Request Status", style: GoogleFonts.outfit(fontSize: 12))
                                )
                              ],
                            ),
                            const Divider(height: 32),
                            _buildInfoRow(Icons.badge, "ID Proof (Aadhaar/Voter)", currentTenant.idProof ?? "No ID uploaded", theme),
                            if (currentTenant.idProof != null)
                            _actionButton(Icons.visibility, "View Document", Colors.blue, () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Document view not implemented yet")));
                            }),
                          ],
                          theme
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // History Header
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
                   ElevatedButton.icon(
                    onPressed: () => _showAddPastRecordDialog(context, ref),
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: Text('Add Past', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                
                if (cycles.isEmpty) return Padding(padding: const EdgeInsets.all(40), child: Text('No history', style: GoogleFonts.outfit(color: theme.textTheme.bodyMedium?.color)));

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  itemCount: cycles.length,
                  itemBuilder: (context, index) {
                    final cycle = cycles[index];
                    final isPaid = cycle.status == RentStatus.paid;
                    final date = DateTime.parse('${cycle.month}-01');
                    final statusColor = isPaid ? Colors.green : (cycle.status == RentStatus.partial ? Colors.amber : Colors.red);

                    return IntrinsicHeight(
                      child: Row(
                        children: [
                          // Timeline Stepper
                          Column(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: statusColor,
                                  boxShadow: [BoxShadow(color: statusColor.withOpacity(0.2), blurRadius: 4, spreadRadius: 1)],
                                ),
                              ),
                              if (index < cycles.length - 1)
                                Expanded(child: Container(width: 2, color: theme.dividerColor.withOpacity(0.05))),
                            ],
                          ),
                          const SizedBox(width: 16),
                          // Bill Card
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: statusColor.withOpacity(0.1)),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(DateFormat('MMMM yyyy').format(date), 
                                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)
                                            ),
                                            const SizedBox(height: 2),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(cycle.status.name.toUpperCase(), 
                                                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: Icon(Icons.more_vert, size: 20, color: theme.hintColor),
                                        padding: EdgeInsets.zero,
                                        onSelected: (val) async {
                                          if (val == 'delete') _confirmDeleteBill(context, ref, cycle, tenancyId);
                                          if (val == 'print') await _handlePrintReceipt(context, ref, cycle, currentTenant);
                                          if (val == 'edit') _showEditBillDialog(context, ref, cycle);
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(value: 'print', child: Text("Print Receipt")),
                                          const PopupMenuItem(value: 'edit', child: Text("Edit Bill")),
                                          const PopupMenuItem(value: 'delete', child: Text("Delete Bill", style: TextStyle(color: Colors.red))),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _billInfoItem("Expected", cycle.totalDue, theme),
                                      _billInfoItem("Paid", cycle.totalPaid, theme),
                                      _billInfoItem("Balance", cycle.totalDue - cycle.totalPaid, isPaid ? Colors.grey : Colors.redAccent),
                                    ],
                                  ),
                                  if (!isPaid) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextButton(
                                            onPressed: () => _showChargesSheet(context, cycle, ref, currentTenant),
                                            child: Text("+ Charges", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => _showPaymentSheet(context, cycle, ref),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: theme.colorScheme.primary,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              elevation: 0,
                                            ),
                                            child: Text("Pay", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                decoration: const InputDecoration(labelText: 'Total Bill Amount (₹)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: paidController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
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
               keyboardType: const TextInputType.numberWithOptions(decimal: true),
               inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
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
  
  Future<void> _handleDownloadStatement(BuildContext context, WidgetRef ref, Tenant tenant) async {
    await DialogUtils.runWithLoading(context, () async {
      try {
        var owner = ref.read(ownerControllerProvider).value;
        owner ??= await ref.read(ownerControllerProvider.future);
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
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
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
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
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                              decoration: const InputDecoration(labelText: 'Current Reading', border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: rateController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
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
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
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
               final currentIndex = allReadings.indexOf(currentReading);
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

  Future<void> _handleWhatsApp(String phone, String name) async {
    final message = "Hi $name, this is regarding your rent at KirayaBook.";
    final url = Uri.parse("whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      final webUrl = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(message)}");
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _handleCall(String phone) async {
    final url = Uri.parse("tel:$phone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Widget _buildAuraHeader(Tenant tenant, bool isDark) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
            : [const Color(0xFF2563EB), const Color(0xFF1E40AF)],
        ),
      ),
      child: Stack(
        children: [
          // Aura Glowing Circles
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: const SizedBox.shrink(),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 0),
            child: Column(
              children: [
                Hero(
                  tag: 'tenant_${tenant.id}',
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white12,
                      backgroundImage: tenant.imageBase64 != null 
                        ? MemoryImage(base64Decode(tenant.imageBase64!))
                        : (tenant.imageUrl != null ? NetworkImage(tenant.imageUrl!) : null) as ImageProvider?,
                      child: (tenant.imageBase64 == null && tenant.imageUrl == null) 
                        ? Text(tenant.name[0].toUpperCase(), style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white))
                        : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FittedBox(
                  child: Text(
                    tenant.name,
                    style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone_iphone, size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(tenant.phone, style: GoogleFonts.outfit(color: Colors.white70)),
                    const SizedBox(width: 12),
                    _buildVerificationBadge(tenant),
                  ],
                ),
                if (tenant.email != null && !tenant.isEmailVerified)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: InkWell(
                      onTap: () => _handleResendVerification(tenant),
                      child: Text(
                        'Resend Verification Email',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                _buildQuickActions(tenant),
                const SizedBox(height: 24), // Extra padding to keep above stats card
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(Tenant tenant) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _actionButton(Icons.call, "Call", Colors.green, () => _handleCall(tenant.phone)),
          const SizedBox(width: 8),
          _actionButton(Icons.message, "WhatsApp", const Color(0xFF25D366), () => _handleWhatsApp(tenant.phone, tenant.name)),
          const SizedBox(width: 8),
          _actionButton(Icons.share, "Share", Colors.blue, () {
            Clipboard.setData(ClipboardData(text: "Tenant: ${tenant.name}\nPhone: ${tenant.phone}"));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact info copied')));
          }),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicStats(double outstanding, double deposit, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              _statItem("Outstanding", outstanding, Colors.redAccent, isDark),
              Container(width: 1, height: 40, color: isDark ? Colors.white10 : Colors.black12),
              _statItem("Security Dep.", deposit, Colors.orangeAccent, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, double value, Color color, bool isDark) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54)),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              "₹${NumberFormat('#,##,###').format(value)}",
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubExpandableSection(String title, IconData icon, bool isExpanded, Function(bool) onToggle, List<Widget> children, ThemeData theme) {
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
        leading: Icon(icon, size: 20, color: theme.hintColor),
        trailing: Icon(
          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: theme.hintColor,
        ),
        onExpansionChanged: onToggle,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(54, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.outfit(fontSize: 11, color: theme.hintColor)),
                Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _billInfoItem(String label, double value, dynamic colorOrTheme) {
    final color = colorOrTheme is Color ? colorOrTheme : (colorOrTheme as ThemeData).textTheme.bodyLarge?.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey)),
        FittedBox(
          child: Text("₹${value.toInt()}", 
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: color)
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationBadge(Tenant tenant) {
    final isVerified = tenant.isEmailVerified;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isVerified ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isVerified ? Colors.green : Colors.orange, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.warning_amber_rounded,
            size: 10,
            color: isVerified ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            isVerified ? 'Verified' : 'Unverified',
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isVerified ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleResendVerification(Tenant tenant) async {
    // We need the tenant's password to resend via secondary app login.
    // However, we don't store it. 
    // IF the password was JUST created (e.g. from Add Tenant success dialog), we might have it.
    // In the detail screen, we likely DON'T have it.
    
    // TEMPORARY: Show a dialog explaining how it works or asking for a password if needed.
    // Better: If the owner is the one who created the account, they might have set a default password.
    
    // For now, I'll use a placeholder or check if I can trigger it some other way.
    // Since I can't trigger it without password/admin, I'll inform the user.
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resending verification requires tenant login. This feature is being refined.'))
    );
  }
}
