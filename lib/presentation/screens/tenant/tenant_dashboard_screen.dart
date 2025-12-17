import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../../domain/entities/tenancy.dart'; // Import Tenancy
import '../../../../features/rent/domain/entities/rent_cycle.dart';

import '../../providers/data_providers.dart';
import '../../owner/tenant/tenant_controller.dart'; // Import for activeTenancyProvider
import '../../owner/house/house_controller.dart'; // Import for House/Unit providers

import 'package:app_badge_plus/app_badge_plus.dart';
import '../maintenance/maintenance_controller.dart';
import '../../../../domain/entities/maintenance_request.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../../core/extensions/string_extensions.dart';
import 'package:rentpilotpro/presentation/screens/notice/notice_controller.dart';
import '../../../../domain/entities/notice.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../../widgets/ads/banner_ad_widget.dart';

class TenantDashboardScreen extends ConsumerStatefulWidget {
  final Tenant tenant; 

  const TenantDashboardScreen({super.key, required this.tenant});
  
  @override
  ConsumerState<TenantDashboardScreen> createState() => _TenantDashboardScreenState();
}

class _TenantDashboardScreenState extends ConsumerState<TenantDashboardScreen> {
  bool _hasShownNoticePopup = false;
  
  @override
  Widget build(BuildContext context) {
    // ... (Existing watches)
    final rentRepo = ref.watch(rentRepositoryProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Logic for Popup & Badge
    // Needs House ID. We must find Tenancy -> Unit -> House first.
    final tenancyAsync = ref.watch(activeTenancyProvider(widget.tenant.id));
    final tenancy = tenancyAsync.valueOrNull;
    
    // Derived IDs
    final unitId = tenancy?.unitId;
    final ownerId = widget.tenant.ownerId; // Owner ID is trusted from Tenant Profile
    
    // Helper to fetch keys
    final unitAsync = unitId != null ? ref.watch(unitDetailsProvider(unitId)) : const AsyncValue.loading();
    final unit = unitAsync.valueOrNull;
    final houseId = unit?.houseId;

    // Now Valid Collections
    final noticesAsync = houseId != null ? ref.watch(noticesForHouseProvider((houseId: houseId, ownerId: ownerId))) : const AsyncValue.loading();
    final unreadNotices = noticesAsync.valueOrNull?.where((n) => !n.readBy.contains(widget.tenant.id.toString())).toList() ?? [];

    if (noticesAsync.hasValue) {
       AppBadgePlus.updateBadge(unreadNotices.length);
       if (unreadNotices.isEmpty) AppBadgePlus.updateBadge(0);
    }
    
    if (unreadNotices.isNotEmpty && !_hasShownNoticePopup) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
          _showNoticePopup(unreadNotices.first);
           try {
            FlutterRingtonePlayer().playNotification();
          } catch (e) {
            debugPrint('Sound Error: $e');
          }
          setState(() => _hasShownNoticePopup = true);
       });
    }

    // Maintenance Requests
    final maintenanceAsync = (houseId != null) 
      ? ref.watch(tenantMaintenanceProvider((tenantId: widget.tenant.id.toString(), ownerId: ownerId))) 
      : const AsyncValue.loading();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Welcome, ${widget.tenant.name}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          // Notice Icon with Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => _showNoticesList(noticesAsync.valueOrNull ?? []),
              ),
              if (unreadNotices.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text('${unreadNotices.length}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: () async {
              await ref.read(userSessionServiceProvider).clearSession();
              if (context.mounted) context.go('/');
            }, 
            icon: Icon(Icons.logout, color: theme.iconTheme.color)
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'tenant_repair_request',
        onPressed: (houseId != null && unitId != null) ? () => _showMaintenanceDialog(context, houseId, unitId) : null,
        label: const Text('Request Repair'),
        icon: const Icon(Icons.build),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800), // Constraint for Tablets/Web
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sticky Due Card
                    // ... (Same as before)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark 
                                ? [const Color(0xFF1E3A8A), const Color(0xFF2563EB)] // Deep Blue to Vibrant Blue
                                : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)], // Blue 50 to Blue 100
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.white.withValues(alpha: 0.6), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black26 : const Color(0xFF6366F1).withValues(alpha: 0.15), 
                              blurRadius: 20, 
                              offset: const Offset(0, 10)
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.5), 
                                    shape: BoxShape.circle
                                  ),
                                  child: Icon(Icons.account_balance_wallet_outlined, color: isDark ? Colors.white : theme.colorScheme.primary),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Total Outstanding', 
                                  style: GoogleFonts.outfit(
                                    color: isDark ? Colors.white70 : const Color(0xFF64748B), 
                                    fontSize: 16, 
                                    fontWeight: FontWeight.w500
                                  )
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            if (tenancy?.id != null)
                            StreamBuilder<List<RentCycle>>(
                              stream: rentRepo.watchRentCyclesByTenancyAccess(tenancy!.id, ownerId),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return Text('Loading...', style: TextStyle(color: theme.textTheme.bodyMedium?.color));
                                final cycles = snapshot.data!;
                                final totalDue = cycles.fold(0.0, (sum, c) => sum + (c.totalDue - c.totalPaid));
                                final showPay = totalDue > 0;
                  
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '₹${totalDue.toStringAsFixed(0)}',
                                      style: GoogleFonts.outfit(
                                        color: isDark ? Colors.white : theme.colorScheme.primary, 
                                        fontSize: 40, 
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (totalDue == 0)
                                      Text('You are all caught up! 🎉', style: GoogleFonts.outfit(color: isDark ? Colors.greenAccent : const Color(0xFF059669), fontWeight: FontWeight.w600)),
                                      
                                    if(showPay) ...[
                                      const SizedBox(height: 24),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Online Payment Coming Soon!')));
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isDark ? Colors.white : theme.colorScheme.primary, 
                                            foregroundColor: isDark ? theme.colorScheme.primary : Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          ),
                                          child: const Text('Pay Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ]
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
      
                    // Scrollable Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Active Maintenance Requests
                             if (maintenanceAsync.hasValue && maintenanceAsync.value!.isNotEmpty) ...[
                                Text('Maintenance Requests', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                                const SizedBox(height: 12),
                                ...maintenanceAsync.value!.take(3).map((r) => Card(
                                   margin: const EdgeInsets.only(bottom: 8),
                                   color: theme.cardColor,
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: isDark ? const BorderSide(color: Colors.white12) : BorderSide.none),
                                   child: ListTile(
                                     leading: Container(
                                       padding: const EdgeInsets.all(8),
                                       decoration: BoxDecoration(color: _getStatusColor(r.status).withOpacity(0.1), shape: BoxShape.circle),
                                       child: Icon(_getCategoryIcon(r.category), color: _getStatusColor(r.status), size: 20),
                                     ),
                                     title: Text(r.category, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                                     subtitle: Text(r.status.name.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(r.status))),
                                     trailing: Text(DateFormat('dd MMM').format(r.date), style: const TextStyle(fontSize: 12)),
                                     onTap: () => _showRequestDetails(context, r),
                                   ),
                                )),
                                const SizedBox(height: 24),
                             ],
                             
                            // Payment Summary Card
                            // ... (Same as before)
                            if (tenancy?.id != null)
                            StreamBuilder<List<Payment>>( 
                              stream: ref.read(rentRepositoryProvider).watchPaymentsByTenancyAccess(tenancy!.id, ownerId),
                              builder: (context, snapshot) {
                                 if (!snapshot.hasData) return const SizedBox();
                                 final payments = snapshot.data!;
                                 final totalPaid = payments.fold(0.0, (sum, p) => sum + p.amount);
                                 final cashPaid = payments.where((p) => p.method.toLowerCase().contains('cash')).fold(0.0, (sum, p) => sum + p.amount);
                                 final onlinePaid = payments.where((p) => !p.method.toLowerCase().contains('cash')).fold(0.0, (sum, p) => sum + p.amount);
                        
                                 if (totalPaid == 0) return const SizedBox();
                        
                                 return Container(
                                   width: double.infinity,
                                   padding: const EdgeInsets.all(20),
                                   decoration: BoxDecoration(
                                     color: theme.cardColor,
                                     borderRadius: BorderRadius.circular(20),
                                     boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                                     border: isDark ? Border.all(color: Colors.white10) : null,
                                   ),
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Text('Lifetime Payment Summary', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                                       const SizedBox(height: 16),
                                       Row(
                                         children: [
                                           Expanded(child: _buildSummaryItem('Total Paid', totalPaid, Colors.blue, theme)),
                                           Container(width: 1, height: 40, color: theme.dividerColor),
                                           Expanded(child: _buildSummaryItem('Cash', cashPaid, Colors.orange, theme)),
                                           Container(width: 1, height: 40, color: theme.dividerColor),
                                           Expanded(child: _buildSummaryItem('Online/UPI', onlinePaid, Colors.green, theme)),
                                         ],
                                       )
                                     ],
                                   ),
                                 );
                              },
                            ),
                        
                            const SizedBox(height: 24),
                            Text('Your Bills', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                             
                            // List of Bills (Same as before)
                            if (tenancy?.id != null)
                            StreamBuilder<List<RentCycle>>(
                                stream: rentRepo.watchRentCyclesByTenancyAccess(tenancy!.id, ownerId),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: theme.colorScheme.error)));
                                  if (!snapshot.hasData) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                                  final cycles = snapshot.data!;
                                  if (cycles.isEmpty) return Center(child: Text('No bills found.', style: TextStyle(color: theme.textTheme.bodyMedium?.color)));
                                  
                                  // Sort by month desc
                                  cycles.sort((a,b) => b.month.compareTo(a.month));
                        
                                  if(cycles.isEmpty) return Padding(padding: const EdgeInsets.only(top: 20), child: Text('No bills found.', style: TextStyle(color: theme.textTheme.bodyMedium?.color)));
                        
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.only(top: 10),
                                    itemCount: cycles.length,
                                    itemBuilder: (context, index) {
                                      final c = cycles[index];
                                      final isPaid = c.status == RentStatus.paid;
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: isDark ? const BorderSide(color: Colors.white10) : BorderSide.none),
                                        elevation: 0,
                                        color: theme.cardColor,
                                        child: InkWell(
                                          onTap: () => _showBillDetails(context, c, ref, houseId, unitId), // Show Details
                                          borderRadius: BorderRadius.circular(16),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isPaid ? Icons.check_circle : Icons.pending,
                                                  color: isPaid ? Colors.green : Colors.orange,
                                                  size: 32,
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(DateFormat('MMMM yyyy').format(DateTime.parse('${c.month}-01')), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textTheme.bodyLarge?.color)),
                                                      Text('Bill: ${c.billNumber ?? 'N/A'}', style: GoogleFonts.outfit(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text('₹${c.totalDue.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textTheme.bodyLarge?.color)),
                                                    if(isPaid)
                                                      Text('PAID', style: GoogleFonts.outfit(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold))
                                                    else
                                                      Text('Due: ₹${(c.totalDue - c.totalPaid).toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                                const SizedBox(width: 8),
                                                Icon(Icons.chevron_right, color: theme.iconTheme.color?.withValues(alpha: 0.5), size: 20),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                             )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Ad Footer
          const BannerAdWidget(),
        ],
      ),
    );
  }

  // ... (Existing Notice, Bill methods same)

  void _showMaintenanceDialog(BuildContext context, String houseId, String unitId) {
    final descController = TextEditingController();
    String category = 'Plumbing';
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Request Repair'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: category,
                isExpanded: true,
                items: ['Plumbing', 'Electrical', 'Appliance', 'Other']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => category = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 3,
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                 if (descController.text.isEmpty) return;
                 Navigator.pop(ctx);
                 await DialogUtils.runWithLoading(context, () async {
                    await ref.read(maintenanceControllerProvider.notifier).submitRequest(
                      ownerId: widget.tenant.ownerId,
                      houseId: houseId,
                      unitId: unitId,
                      tenantId: widget.tenant.id.toString(),
                      category: category,
                      description: descController.text,
                    );
                 });
                 if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request Submitted')));
              },
              child: const Text('Submit'),
            )
          ],
        ),
      )
    );
  }

  void _showRequestDetails(BuildContext context, MaintenanceRequest r) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${r.category} Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text('Status: ${r.status.name.toUpperCase()}', style: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(r.status))),
             const SizedBox(height: 12),
             Text(r.description),
             if (r.resolutionNotes != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                Text('Resolution Note:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(r.resolutionNotes!)
             ]
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      )
    );
  }

  IconData _getCategoryIcon(String cat) {
    if (cat.contains('Plumb')) return Icons.water_drop;
    if (cat.contains('Electr')) return Icons.electric_bolt;
    if (cat.contains('Appliance')) return Icons.kitchen;
    return Icons.build;
  }

  Color _getStatusColor(MaintenanceStatus status) {
    switch(status) {
      case MaintenanceStatus.pending: return Colors.orange;
      case MaintenanceStatus.inProgress: return Colors.blue;
      case MaintenanceStatus.completed: return Colors.green;
      case MaintenanceStatus.rejected: return Colors.red;
    }
  }

  // Same existing methods below...
  void _showNoticePopup(Notice notice) {
    // ...
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(children: [Icon(Icons.campaign, color: Colors.orange), SizedBox(width:8), Expanded(child: Text(notice.subject.capitalize()))]),
        content: Text(notice.message.capitalize()),
        actions: [
          ElevatedButton(
            onPressed: () {
               ref.read(noticeControllerProvider.notifier).markAsRead(notice.id, widget.tenant.id.toString());
               Navigator.pop(ctx);
            },
            child: Text('Mark as Read'),
          )
        ],
      )
    );
  }

  void _showNoticesList(List<Notice> notices) {
    // ...
    showModalBottomSheet(
      context: context, 
      builder: (ctx) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Notice Board', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            if (notices.isEmpty) Text('No notices found.'),
            Expanded(
              child: ListView.builder(
                itemCount: notices.length,
                itemBuilder: (context, index) {
                   final n = notices[index];
                   final isRead = n.readBy.contains(widget.tenant.id.toString());
                   return ListTile(
                     leading: Icon(Icons.campaign, color: isRead ? Colors.grey : Colors.orange),
                     title: Text(n.subject.capitalize(), style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                     subtitle: Text(n.message.capitalize(), maxLines: 2, overflow: TextOverflow.ellipsis),
                     trailing: Text(DateFormat('dd MMM').format(n.date), style: TextStyle(fontSize: 12)),
                     onTap: () {
                        if (!isRead) {
                           ref.read(noticeControllerProvider.notifier).markAsRead(n.id, widget.tenant.id.toString());
                        }
                        showDialog(context: context, builder: (_) => AlertDialog(title: Text(n.subject.capitalize()), content: Text(n.message.capitalize())));
                     },
                   );
                },
              ),
            )
          ],
        ),
      )
    );
  }

  void _showBillDetails(BuildContext context, RentCycle c, WidgetRef ref, String? houseId, String? unitId) {
    // ... (Existing implementation)
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: theme.scaffoldBackgroundColor,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              border: isDark ? Border.all(color: Colors.white12) : null,
            ),
            child: ListView(
              controller: scrollController,
              children: [
                 Text('Bill Details', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                 const SizedBox(height: 8),
                 Text('Month: ${c.month}', style: GoogleFonts.outfit(fontSize: 14, color: theme.textTheme.bodySmall?.color)),
                 const SizedBox(height: 16),
                 const Divider(),
                 const SizedBox(height: 16),
                 
                 _buildRow('Base Rent', c.baseRent, theme),
                 if(c.electricAmount > 0) _buildRow('Electricity', c.electricAmount, theme),
                 if(c.otherCharges > 0) _buildRow('Other Charges', c.otherCharges, theme),
                 if(c.discount > 0) _buildRow('Discount', c.discount, theme, isNegative: true),
                 
                 const SizedBox(height: 16),
                 Center(
                   child: OutlinedButton.icon(
                     onPressed: (houseId != null && unitId != null) ? () => _handleDownloadReceipt(context, ref, c, houseId, unitId) : null,
                     icon: const Icon(Icons.download, size: 18),
                     label: const Text('Download Receipt'),
                     style: OutlinedButton.styleFrom(
                       foregroundColor: theme.textTheme.bodyLarge?.color,
                       side: BorderSide(color: theme.dividerColor),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                     ),
                   ),
                 ),
                 
                 const SizedBox(height: 16),
                 const Divider(),
                 const SizedBox(height: 16),

                 _buildRow('Total Due', c.totalDue, theme, isBold: true),
                 _buildRow('Paid Amount', c.totalPaid, theme, color: Colors.green),
                 _buildRow('Balance Due', c.totalDue - c.totalPaid, theme, isBold: true, color: (c.totalDue - c.totalPaid) > 0 ? Colors.red : Colors.green),

                const SizedBox(height: 24),
                // Payment History Section
                Text('Payment History', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                const SizedBox(height: 12),
                FutureBuilder<List<Payment>>( 
                  future: ref.read(rentRepositoryProvider).getPaymentsForRentCycle(c.id),
                  builder: (context, snapshot) {
                     if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                     final payments = snapshot.data!;
                     if (payments.isEmpty) return Text('No payments recorded.', style: GoogleFonts.outfit(color: theme.textTheme.bodyMedium?.color));

                     return Column(
                       children: payments.map((p) => Container(
                         margin: const EdgeInsets.only(bottom: 8),
                         padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(
                           color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
                           borderRadius: BorderRadius.circular(12),
                           border: Border.all(color: theme.dividerColor)
                         ),
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(DateFormat('dd MMM yyyy').format(p.date), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                                 Text(p.method, style: GoogleFonts.outfit(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
                               ],
                             ),
                             Text('₹${p.amount.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.green)),
                           ],
                         ),
                       )).toList(),
                     );
                  },
                ),
                
                const SizedBox(height: 20),
                if(c.notes != null && c.notes!.isNotEmpty)
                   Container(
                     width: double.infinity,
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                     child: Text('Notes:\n${c.notes}', style: GoogleFonts.outfit(fontSize: 12, color: theme.textTheme.bodyMedium?.color)),
                   ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
        const SizedBox(height: 4),
        Text('₹${amount.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildRow(String label, double amount, ThemeData theme, {bool isBold = false, Color? color, bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 16, color: theme.textTheme.bodyLarge?.color)),
          Text(
            '${isNegative ? "- " : ""}₹${amount.toStringAsFixed(0)}', 
            style: GoogleFonts.outfit(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal, 
              fontSize: 16,
              color: color ?? theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _handleDownloadReceipt(BuildContext context, WidgetRef ref, RentCycle cycle, String houseId, String unitId) async {
    // Show Loading
    showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator()));
    
    try {
      final houseRepo = ref.read(propertyRepositoryProvider);
      final rentRepo = ref.read(rentRepositoryProvider);
      
      // 1. Fetch House (Tenant Access)
      final house = await houseRepo.getHouseForTenant(houseId, widget.tenant.ownerId); 
      if (house == null) throw Exception('House details not found');
      
      // 2. Fetch Unit (Tenant Access)
      final unit = await houseRepo.getUnitForTenant(unitId, widget.tenant.ownerId); 
      if (unit == null) throw Exception('Unit details not found');

      // 3. Fetch Payments (Tenant Access)
      final payments = await rentRepo.getPaymentsForRentCycleForTenant(cycle.id, widget.tenant.ownerId); 
      
      // 4. Fetch Readings (Tenant Access)
      final allReadings = await rentRepo.getElectricReadingsForTenant(unitId, widget.tenant.ownerId); 
      
      Map<String, dynamic>? currentReading;
      Map<String, dynamic>? previousReading;
        
      if (allReadings.isNotEmpty) {
         try {
           // Find reading closest to billGeneratedDate
           currentReading = allReadings.firstWhere((r) {
             final rDate = r['date'] as DateTime;
             return rDate.isBefore(cycle.billGeneratedDate.add(const Duration(days: 1))); 
           });
           
           final currentIndex = allReadings.indexOf(currentReading);
           if (currentIndex + 1 < allReadings.length) {
             previousReading = allReadings[currentIndex + 1];
           }
         } catch (e) {
           // Not found
         }
      }

      // 5. Generate PDF
      if (context.mounted) Navigator.pop(context); // Close Loading
      
      await ref.read(printServiceProvider).printRentReceipt(
        rentCycle: cycle,
        tenant: widget.tenant, // Updated to widget.tenant
        house: house,
        unit: unit,
        payments: payments,
        currentReading: currentReading,
        previousReading: previousReading,
      );

    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close Loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
