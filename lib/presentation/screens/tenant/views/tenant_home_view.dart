import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../../features/rent/domain/entities/rent_cycle.dart';
import '../../../providers/data_providers.dart';
import '../../owner/tenant/tenant_controller.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import '../../maintenance/maintenance_controller.dart';
import '../../../../domain/entities/maintenance_request.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../../core/extensions/string_extensions.dart';
import 'package:kirayabook/presentation/screens/notice/notice_controller.dart' hide noticesForHouseProvider;
import '../../../../domain/entities/notice.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../../../widgets/ads/banner_ad_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:printing/printing.dart';

class TenantHomeView extends ConsumerStatefulWidget {
  final Tenant tenant;
  const TenantHomeView({super.key, required this.tenant});

  @override
  ConsumerState<TenantHomeView> createState() => _TenantHomeViewState();
}

class _TenantHomeViewState extends ConsumerState<TenantHomeView> {
  bool _hasShownNoticePopup = false;

  @override
  Widget build(BuildContext context) {
    final rentRepo = ref.watch(rentRepositoryProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final ownerId = widget.tenant.ownerId;
    final tenancyAsync = ref.watch(activeTenancyForTenantAccessProvider(widget.tenant.id, ownerId));
    final ownerAsync = ref.watch(ownerByIdProvider(ownerId));
    final isFreePlan = ownerAsync.valueOrNull?.subscriptionPlan == 'free';
    final tenancy = tenancyAsync.valueOrNull;
    
    final unitId = tenancy?.unitId;
    final unitAsync = unitId != null ? ref.watch(unitDetailsForTenantProvider((unitId: unitId, ownerId: ownerId))) : const AsyncValue.loading();
    final unit = unitAsync.valueOrNull;
    final houseId = unit?.houseId;

    final noticesAsync = ref.watch(noticesForTenantProvider((houseId: houseId ?? '', unitId: unitId, ownerId: ownerId)));
    final unreadNotices = noticesAsync.valueOrNull?.where((n) => !n.readBy.contains(widget.tenant.id.toString())).toList() ?? [];

    // --- SIDE EFFECTS (BADGE & POPUPS) ---
    // Moved out of build flow to prevent UI hangs and multiple calls during rebuilds
    
    // 1. Badge Updates (Handled via ref.listen)
    ref.listen(noticesForTenantProvider((houseId: houseId ?? '', unitId: unitId, ownerId: ownerId)), (previous, next) {
      if (next is AsyncData<List<Notice>>) {
        final unreadCount = next.value.where((n) => !n.readBy.contains(widget.tenant.id.toString())).length;
        AppBadgePlus.updateBadge(unreadCount);
      }
    });

    // 2. Notice Popup (Handled via ref.listen)
    ref.listen(noticesForTenantProvider((houseId: houseId ?? '', unitId: unitId, ownerId: ownerId)), (previous, next) {
      if (!_hasShownNoticePopup && next is AsyncData<List<Notice>>) {
        final unread = next.value.where((n) => !n.readBy.contains(widget.tenant.id.toString())).toList();
        if (unread.isNotEmpty) {
           _hasShownNoticePopup = true; // Mark immediately to prevent double-popups
           WidgetsBinding.instance.addPostFrameCallback((_) {
              _showNoticePopup(unread.first);
              try {
                FlutterRingtonePlayer().playNotification();
              } catch (e) {
                debugPrint('Sound Error: $e');
              }
           });
        }
      }
    });

    final maintenanceAsync = (houseId != null) 
      ? ref.watch(tenantMaintenanceProvider((tenantId: widget.tenant.id.toString(), ownerId: ownerId))) 
      : const AsyncValue.loading();

    // --- REAL-TIME FOREGROUND ALERTS ---

    // 1. Listen for New Notices
    ref.listen(noticesForTenantProvider((houseId: houseId ?? '', unitId: unitId, ownerId: ownerId)), (previous, next) {
      if (next is AsyncData<List<Notice>> && previous is AsyncData<List<Notice>>) {
        final newNotices = next.value.where((n) => 
          !previous.value.any((pn) => pn.id == n.id) &&
          !n.readBy.contains(widget.tenant.id.toString())
        ).toList();

        if (newNotices.isNotEmpty) {
          final n = newNotices.first;
          ref.read(notificationServiceProvider).showLocalNotification(
            id: n.id.hashCode,
            title: 'New Notice: ${n.subject}',
            body: n.message,
            payload: '/tenant/notices',
          );
        }
      }
    });

    // 2. Listen for Maintenance Status Updates
    ref.listen(tenantMaintenanceProvider((tenantId: widget.tenant.id.toString(), ownerId: ownerId)), (previous, next) {
      if (next is AsyncData<List<MaintenanceRequest>> && previous is AsyncData<List<MaintenanceRequest>>) {
        for (var req in next.value) {
          final prevReq = previous.value.firstWhere((p) => p.id == req.id, orElse: () => req);
          if (prevReq.status != req.status) {
             ref.read(notificationServiceProvider).showLocalNotification(
               id: req.id.hashCode,
               title: 'Maintenance Update',
               body: 'Your ${req.category} request is now ${req.status.name.toUpperCase()}',
               payload: '/tenant/maintenance/${req.id}',
             );
          }
        }
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('${'dashboard.welcome'.tr()} ${widget.tenant.name}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
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
            icon: Icon(Icons.logout, color: theme.iconTheme.color),
            tooltip: 'settings.logout'.tr(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'tenant_repair_request',
        onPressed: (houseId != null && unitId != null) ? () => _showMaintenanceDialog(context, houseId, unitId) : null,
        label: Text('tenant.new_request'.tr()),
        icon: const Icon(Icons.build),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: RepaintBoundary(
                        child: Container(
                          width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark 
                                ? [const Color(0xFF1E3A8A), const Color(0xFF2563EB)] 
                                : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)], 
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
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.5), 
                                            shape: BoxShape.circle
                                          ),
                                          child: Icon(
                                            totalDue < 0 ? Icons.stars_rounded : Icons.account_balance_wallet_outlined, 
                                            color: totalDue < 0 ? Colors.greenAccent : (isDark ? Colors.white : theme.colorScheme.primary)
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          totalDue < 0 ? 'tenant.advance_balance'.tr() : 'tenant.total_outstanding'.tr(), 
                                          style: GoogleFonts.outfit(
                                            color: isDark ? (totalDue < 0 ? Colors.greenAccent : Colors.white70) : const Color(0xFF64748B), 
                                            fontSize: 16, 
                                            fontWeight: FontWeight.w500
                                          )
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      '₹${totalDue.abs().toStringAsFixed(0)}',
                                      style: GoogleFonts.outfit(
                                        color: totalDue < 0 ? Colors.greenAccent : (isDark ? Colors.white : theme.colorScheme.primary), 
                                        fontSize: 40, 
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (totalDue <= 0)
                                      Text(
                                        totalDue < 0 ? 'You have credit available! 💎' : 'You are all caught up! 🎉', 
                                        style: GoogleFonts.outfit(
                                          color: isDark ? Colors.greenAccent : const Color(0xFF059669), 
                                          fontWeight: FontWeight.w600
                                        )
                                      ),
                                      
                                    if(showPay) ...[
                                      const SizedBox(height: 24),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                            onPressed: () {
                                              _launchPayment(context, totalDue);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isDark ? Colors.white : theme.colorScheme.primary, 
                                              foregroundColor: isDark ? theme.colorScheme.primary : Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                            ),
                                            child: Text('tenant.pay_now'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  ),
      
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                       decoration: BoxDecoration(color: r.status.color.withValues(alpha: 0.1), shape: BoxShape.circle),
                                       child: Icon(r.category.maintenanceCategoryIcon, color: r.status.color, size: 20),
                                     ),
                                     title: Text(r.category, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                                     subtitle: Text(r.status.label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: r.status.color)),
                                     trailing: Text(DateFormat('dd MMM').format(r.date), style: const TextStyle(fontSize: 12)),
                                     onTap: () => context.push('/tenant/maintenance/${r.id}', extra: r),
                                   ),
                                )),
                                const SizedBox(height: 24),
                             ],
                             
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
                        
                                 return RepaintBoundary(
                                   child: Container(
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
                                         Text('tenant.payment_summary'.tr(), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                                         const SizedBox(height: 16),
                                         Row(
                                           children: [
                                             Expanded(child: _buildSummaryItem('tenant.total_paid'.tr(), totalPaid, Colors.blue, theme)),
                                             Container(width: 1, height: 40, color: theme.dividerColor),
                                             Expanded(child: _buildSummaryItem('reports.cash'.tr(), cashPaid, Colors.orange, theme)),
                                             Container(width: 1, height: 40, color: theme.dividerColor),
                                             Expanded(child: _buildSummaryItem('tenant.online_upi'.tr(), onlinePaid, Colors.green, theme)),
                                           ],
                                         )
                                       ],
                                     ),
                                   ),
                                 );
                              },
                            ),
                        
                            const SizedBox(height: 24),
                            Text('tenant.recent_bills'.tr(), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                             
                            if (tenancy?.id != null)
                            StreamBuilder<List<RentCycle>>(
                                stream: rentRepo.watchRentCyclesByTenancyAccess(tenancy!.id, ownerId),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: theme.colorScheme.error)));
                                  if (!snapshot.hasData) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                                  final cycles = snapshot.data!;
                                  if (cycles.isEmpty) return Center(child: Text('No bills found.', style: TextStyle(color: theme.textTheme.bodyMedium?.color)));
                                  
                                  cycles.sort((a,b) => b.month.compareTo(a.month));
                        
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.only(top: 10),
                                    itemCount: cycles.take(5).length,
                                    itemBuilder: (context, index) {
                                      final c = cycles[index];
                                      final isPaid = c.status == RentStatus.paid;
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: isDark ? const BorderSide(color: Colors.white10) : BorderSide.none),
                                        elevation: 0,
                                        color: theme.cardColor,
                                        child: InkWell(
                                          onTap: () => _showBillDetails(context, c, ref, houseId, unitId),
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
                             ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isFreePlan)
          const BannerAdWidget(),
        ],
      ),
    );
  }

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

  void _showNoticePopup(Notice notice) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(children: [Icon(Icons.campaign, color: Colors.orange), const SizedBox(width:8), Expanded(child: Text(notice.subject.capitalize()))]),
        content: Text(notice.message.capitalize()),
        actions: [
          ElevatedButton(
            onPressed: () {
               ref.read(noticeControllerProvider.notifier).markAsRead(notice.id, widget.tenant.id.toString(), notice.ownerId);
               Navigator.pop(ctx);
            },
            child: const Text('Mark as Read'),
          )
        ],
      )
    );
  }

  void _showNoticesList(List<Notice> notices) {
    context.push('/tenant/notices', extra: {
      'tenant': widget.tenant,
      'notices': notices,
    });
  }

  void _showBillDetails(BuildContext context, RentCycle c, WidgetRef ref, String? houseId, String? unitId) {
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

  Future<void> _launchPayment(BuildContext context, double amount) async {
    final ownerId = widget.tenant.ownerId;
    final owner = await ref.read(ownerByIdProvider(ownerId).future);

    if (owner?.upiId == null || owner!.upiId!.isEmpty) {
       if (context.mounted) {
         showDialog(
           context: context,
           builder: (context) => AlertDialog(
             title: const Text('Payment Not Setup'),
             content: const Text('The owner has not set up online payments (UPI) yet. Please contact them directly.'),
             actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
           ),
         );
       }
       return;
    }

    final uri = Uri.parse(
      'upi://pay?pa=${owner.upiId}&pn=${Uri.encodeComponent(owner.name)}&am=$amount&cu=${owner.currency}&tn=Rent Payment'
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication); 
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch payment app: $e')));
      }
    }
  }

  Future<void> _handleDownloadReceipt(BuildContext context, WidgetRef ref, RentCycle cycle, String houseId, String unitId) async {
    showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator()));
    
    try {
      final houseRepo = ref.read(propertyRepositoryProvider);
      final rentRepo = ref.read(rentRepositoryProvider);
      final pdfService = ref.read(pdfGeneratorServiceProvider);
      
      final house = await houseRepo.getHouseForTenant(houseId, widget.tenant.ownerId); 
      if (house == null) throw Exception('House details not found');
      
      final unit = await houseRepo.getUnitForTenant(unitId, widget.tenant.ownerId); 
      if (unit == null) throw Exception('Unit details not found');

      final payments = await rentRepo.getPaymentsForRentCycleForTenant(cycle.id, widget.tenant.ownerId); 
      
      final owner = await ref.read(ownerByIdProvider(widget.tenant.ownerId).future);
      final ownerName = owner?.name ?? 'Landlord';
      final currency = owner?.currency ?? '₹';
      
      final pdfBytes = await pdfService.generateRentReceipt(
        tenantName: widget.tenant.name,
        ownerName: ownerName,
        propertyAddress: '${house.name}, ${house.address}, Unit: ${unit.nameOrNumber}',
        amount: cycle.totalPaid,
        date: DateTime.now(),
        paymentMethod: payments.isNotEmpty ? payments.map((p) => p.method).toSet().join(', ') : 'Mixed',
        receiptNumber: cycle.billNumber ?? cycle.id.substring(0, 8).toUpperCase(),
        currencySymbol: currency == 'INR' ? '₹' : currency,
      );

      if (context.mounted) Navigator.pop(context);

      await Printing.sharePdf(bytes: pdfBytes, filename: 'Receipt_${cycle.month}.pdf');

    } catch (e) {
      debugPrint('Error generating receipt: $e');
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
