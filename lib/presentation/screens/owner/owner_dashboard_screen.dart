import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/tenant.dart';
import '../../../features/rent/domain/entities/rent_cycle.dart';
import '../../../../features/vault/presentation/screens/secure_vault_screen.dart';
import 'package:go_router/go_router.dart';
import 'rent/rent_controller.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'settings/settings_screen.dart'; 
import 'reports/reports_screen.dart'; 
import '../../../core/utils/currency_utils.dart';
import 'tenant/tenant_controller.dart';
import '../../providers/data_providers.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/empty_state_widget.dart';
import 'settings/owner_controller.dart';
import 'package:kirayabook/presentation/screens/notice/notice_controller.dart';
import 'package:kirayabook/presentation/screens/notice/widgets/broadcast_center_sheet.dart';
import '../maintenance/maintenance_controller.dart';
import '../maintenance/maintenance_reports_screen.dart';
import '../../../../domain/entities/maintenance_request.dart';
import '../../widgets/ads/banner_ad_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/voice_assistant_sheet.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _currentIndex = 0;

  /// Lazy-load screens only when selected (prevents Vault biometric on dashboard load)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _DashboardTab(onTabSwitch: (index) => setState(() => _currentIndex = index)),
          const SecureVaultScreen(),
          const ReportsScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            HapticFeedback.selectionClick();
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0,
          indicatorColor: Theme.of(context).colorScheme.primaryContainer,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(icon: const Icon(Icons.dashboard_outlined), selectedIcon: const Icon(Icons.dashboard), label: 'nav.home'.tr()),
            NavigationDestination(icon: const Icon(Icons.lock_person_outlined), selectedIcon: const Icon(Icons.lock_person), label: 'Vault'), // New Vault Tab
            NavigationDestination(icon: const Icon(Icons.bar_chart_outlined), selectedIcon: const Icon(Icons.bar_chart), label: 'nav.reports'.tr()),
            NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: 'nav.settings'.tr()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showVoiceAssistant(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.mic, color: Colors.white),
      ),
    );
  }

  void _showVoiceAssistant(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoiceAssistantSheet(),
    );
  }
}

class _DashboardTab extends ConsumerStatefulWidget {
  final Function(int)? onTabSwitch;
  const _DashboardTab({this.onTabSwitch});

  @override
  ConsumerState<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<_DashboardTab> {
  bool _hasShownMaintenancePopup = false;
  static bool _isGeneratingRent = false; // Static flag to throttle across tab switches
  
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final session = ref.read(userSessionServiceProvider);
      final user = session.currentUser;
      
      // Throttle rent generation
      if (!_isGeneratingRent) {
        _isGeneratingRent = true;
        try {
          await ref.read(rentControllerProvider.notifier).generateRentForCurrentMonth();
        } finally {
          // Delay resetting the flag to prevent rapid re-triggering during navigation
          Future.delayed(const Duration(minutes: 5), () => _isGeneratingRent = false);
        }
      }
       
       if (user != null) {
          ref.read(noticeControllerProvider.notifier).cleanupOldNotices(user.uid);
       }
    });
  }

  void _shareRentDetails(Tenant tenant, RentCycle c) async {
    final monthStr = DateFormat('MMMM yyyy').format(c.billPeriodStart ?? c.billGeneratedDate);
    final message = '''
Dear ${tenant.name},

Hope you are having a good day! 🌟

This is a gentle reminder regarding the rent for *$monthStr*.

*Bill Details:*
• Rent: ₹${c.baseRent.toStringAsFixed(0)}
• Electricity: ${c.electricAmount > 0 ? '₹${c.electricAmount.toStringAsFixed(0)}' : 'Not calculated yet'}
${c.otherCharges > 0 ? '• Other Charges: ₹${c.otherCharges.toStringAsFixed(0)}\n' : ''}
*Total Payable: ₹${c.totalDue.toStringAsFixed(0)}*

Please arrange to pay at your earliest convenience.

Thank you!
''';
    try {
      // 1. App Push Notification (FCM) removed as per user request

      // 2. Open WhatsApp (Manual)
      String phone = tenant.phone.replaceAll(RegExp(r'\D'), '');
      if (phone.length == 10) phone = '91$phone';
      final url = Uri.parse("whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}");
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp not detected. Opening options...'), duration: Duration(seconds: 2)));
        }
        await Share.share(message);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch WhatsApp: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final rentAsync = ref.watch(rentControllerProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final ownerAsync = ref.watch(ownerControllerProvider);
    final currencySymbol = CurrencyUtils.getSymbol(ownerAsync.value?.currency);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Watch Maintenance Requests for Popup/Badge
    final user = ref.read(userSessionServiceProvider).currentUser;
    final maintenanceAsync = user != null ? ref.watch(ownerMaintenanceProvider(user.uid)) : const AsyncValue<List<MaintenanceRequest>>.loading();
    final pendingMaintenanceCount = maintenanceAsync.valueOrNull?.where((r) => r.status == MaintenanceStatus.pending).length ?? 0;

    // --- REAL-TIME FOREGROUND ALERTS ---
    if (user != null) {
      ref.listen(ownerMaintenanceProvider(user.uid), (previous, next) {
        if (next is AsyncData<List<MaintenanceRequest>> && previous is AsyncData<List<MaintenanceRequest>>) {
           final newRequests = next.value.where((r) => 
             !previous.value.any((pr) => pr.id == r.id) && 
             r.status == MaintenanceStatus.pending
           ).toList();

           if (newRequests.isNotEmpty) {
             final req = newRequests.first;
             ref.read(notificationServiceProvider).showLocalNotification(
               id: req.id.hashCode,
               title: 'New Maintenance Request',
               body: '${req.category} request for unit ${req.unitId}',
               payload: '/maintenance',
             );
           }
        }
      });
    }

    // Show Popup for Pending Maintenance
    if (pendingMaintenanceCount > 0 && !_hasShownMaintenancePopup) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
          _showMaintenancePopup(pendingMaintenanceCount);
          setState(() => _hasShownMaintenancePopup = true);
       });
    }

    // --- Metrics for Dashboard (Moved to build scope) ---
    final unitsAsync = ref.watch(allUnitsProvider);
    final tenantsAsync = ref.watch(tenantControllerProvider);
    final tenanciesAsync = ref.watch(allTenanciesProvider);
    
    final totalProperties = unitsAsync.valueOrNull?.length ?? 0;
    final occupiedCount = tenantsAsync.valueOrNull?.where((t) => t.isActive).length ?? 0;
    
    final collected = statsAsync.valueOrNull?.thisMonthCollected ?? 0.0;
    final pending = statsAsync.valueOrNull?.totalPending ?? 0.0;
    
    // --- Owner Plan Check for Ads ---
    final ownerSessionAsync = user != null ? ref.watch(ownerByIdProvider(user.uid)) : const AsyncValue<dynamic>.loading();
    final ownerPlan = ownerSessionAsync.valueOrNull?.subscriptionPlan;
    final showAds = ownerPlan == 'free'; // Only Free users see ads. Loading or Premium hides them.
    
    // ----------------------------------------------------

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Dashboard', 
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold, 
            fontSize: 32, 
            color: theme.textTheme.titleLarge?.color,
            letterSpacing: -0.5,
          )
        ),
        centerTitle: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          // Notification Icon with Badge
          Badge(
            label: Text('$pendingMaintenanceCount'),
            isLabelVisible: pendingMaintenanceCount > 0,
            offset: const Offset(-4, 4),
            child: IconButton(
              icon: Icon(Icons.notifications_none_rounded, color: theme.textTheme.bodyMedium?.color),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MaintenanceReportsScreen()));
              },
            ),
          ),
          const SizedBox(width: 8),
          // Functional Profile Icon
          GestureDetector(
            onTap: () => widget.onTabSwitch?.call(3), // Navigate to Settings
            child: Container(
               margin: const EdgeInsets.only(right: 20),
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(
                 color: theme.colorScheme.primary,
                 shape: BoxShape.circle,
               ),
               child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
           // Reload all dashboard data
           final user = ref.read(userSessionServiceProvider).currentUser;
           
           // Trigger refreshes
           final r1 = ref.refresh(dashboardStatsProvider.future);
           final r2 = ref.read(rentControllerProvider.notifier).generateRentForCurrentMonth(); // This refreshes rent
           final r3 = ref.refresh(allUnitsProvider.future);
           final r4 = ref.refresh(tenantControllerProvider.future);
           
           Future<void>? r5;
           if (user != null) {
              r5 = ref.refresh(ownerMaintenanceProvider(user.uid).future);
           }
           
           // Wait for all to complete
           await Future.wait([
             r1, 
             r2, 
             r3, 
             r4, 
             if(r5 != null) r5
           ]);
           
           // Also explicit refresh of rent list if it's a separate provider or derived.
           // rentControllerProvider is the one providing the list. Refresing it:
           // ref.invalidate(rentControllerProvider); // This might cause a loading state.
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Ensure scroll even if content is short
          slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                     // 0. Total Revenue Card (Lifetime) - Hide for Free plan
                     if (ownerPlan != 'free')
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                           color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                           borderRadius: BorderRadius.circular(24),
                           border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                           boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.black45 : const Color(0xFF2563EB).withValues(alpha: 0.04), 
                                blurRadius: 20, 
                                offset: const Offset(0, 8)
                              )
                           ]
                        ),
                        child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                              Text('Total Revenue', 
                                style: GoogleFonts.outfit(
                                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6), 
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500
                                )
                              ),
                              const SizedBox(height: 8),
                             Builder(
                               builder: (context) {
                                 final total = statsAsync.valueOrNull?.totalCollected ?? 0.0;
                                 
                                 return FittedBox( // Added FittedBox
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                       children: [
                                         Text('$currencySymbol ', 
                                          style: GoogleFonts.outfit(
                                            fontSize: 32, 
                                            fontWeight: FontWeight.bold, 
                                            color: theme.textTheme.bodyLarge?.color,
                                            letterSpacing: -1,
                                          )
                                         ),
                                         AnimatedFlipCounter(
                                           value: total,
                                           fractionDigits: 0,
                                           thousandSeparator: ',',
                                           duration: const Duration(milliseconds: 1500),
                                           curve: Curves.easeOutExpo,
                                           textStyle: GoogleFonts.outfit(
                                             fontSize: 36,
                                             fontWeight: FontWeight.bold,
                                             color: theme.textTheme.bodyLarge?.color,
                                             letterSpacing: -1,
                                           ),
                                         ),
                                       ],
                                     ),
                                  );
                               }
                             ),
                             const SizedBox(height: 12),
                              Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                 decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                                 ),
                                 child: Row(
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                     const Icon(Icons.trending_up, size: 14, color: Colors.green),
                                     const SizedBox(width: 4),
                                     Text('Lifetime Earnings', 
                                       style: GoogleFonts.outfit(
                                         color: Colors.green, 
                                         fontSize: 12, 
                                         fontWeight: FontWeight.bold
                                       )
                                     ),
                                   ],
                                 ),
                              )
                          ],
                       ),
                     ),
                     if (ownerPlan != 'free')
                     const SizedBox(height: 24),
                     
                     // Late Tenants Alert Banner
                     Builder(
                       builder: (context) {
                         // Calculate late tenants from rent cycles
                         final rentCycles = rentAsync.valueOrNull ?? [];
                         final now = DateTime.now();
                         final currentMonthStart = DateTime(now.year, now.month, 1);
                         
                         // Find overdue cycles (not paid and from previous months)
                         final lateCycles = rentCycles.where((c) {
                           final cycleDate = c.billPeriodStart ?? c.billGeneratedDate;
                           return c.status.name != 'paid' && cycleDate.isBefore(currentMonthStart);
                         }).toList();
                         
                         if (lateCycles.isEmpty) return const SizedBox.shrink();
                         
                         // Get unique tenant count and total amount
                         final lateAmount = lateCycles.fold(0.0, (sum, c) => sum + (c.totalDue - c.totalPaid));
                         final lateTenantIds = lateCycles.map((c) => c.tenancyId).toSet();
                         final lateTenantCount = lateTenantIds.length;
                         
                         return GestureDetector(
                           onTap: () => context.push('/owner/rent/pending'),
                           child: Container(
                           width: double.infinity,
                           margin: const EdgeInsets.only(bottom: 16),
                           padding: const EdgeInsets.all(16),
                           decoration: BoxDecoration(
                             gradient: LinearGradient(
                               colors: [Colors.red.shade600, Colors.red.shade700],
                               begin: Alignment.topLeft,
                               end: Alignment.bottomRight,
                             ),
                             borderRadius: BorderRadius.circular(16),
                             boxShadow: [
                               BoxShadow(
                                 color: Colors.red.withValues(alpha: 0.3),
                                 blurRadius: 12,
                                 offset: const Offset(0, 4),
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
                                       color: Colors.white.withValues(alpha: 0.2),
                                       borderRadius: BorderRadius.circular(8),
                                     ),
                                     child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                                   ),
                                   const SizedBox(width: 12),
                                   Expanded(
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         Text(
                                           '$lateTenantCount Tenant${lateTenantCount > 1 ? 's are' : ' is'} Late',
                                           style: GoogleFonts.outfit(
                                             color: Colors.white,
                                             fontSize: 16,
                                             fontWeight: FontWeight.bold,
                                           ),
                                         ),
                                         Text(
                                           'Send reminders to collect $currencySymbol${CurrencyUtils.formatNumber(lateAmount)}',
                                           style: GoogleFonts.outfit(
                                             color: Colors.white.withValues(alpha: 0.9),
                                             fontSize: 13,
                                           ),
                                         ),
                                       ],
                                     ),
                                   ),
                                   // Arrow indicator for tap
                                   const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 24),
                                 ],
                               ),
                               const SizedBox(height: 12),
                               SizedBox(
                                 width: double.infinity,
                                 child: ElevatedButton(
                                   onPressed: () async {
                                     if (ownerPlan == 'free') {
                                       context.push('/owner/settings/subscription');
                                     } else {
                                       // BULK REMINDERS for Power/Pro
                                       for (final cycle in lateCycles) {
                                         final tenancy = tenanciesAsync.valueOrNull?.where((t) => t.id == cycle.tenancyId).firstOrNull;
                                         final tenant = tenantsAsync.valueOrNull?.where((t) => t.id == tenancy?.tenantId).firstOrNull;
                                         if (tenant != null) {
                                           _shareRentDetails(tenant, cycle);
                                           // Small delay to prevent OS/WhatsApp from choking
                                           await Future.delayed(const Duration(milliseconds: 300));
                                         }
                                       }
                                     }
                                   },
                                   style: ElevatedButton.styleFrom(
                                     backgroundColor: Colors.white.withValues(alpha: 0.15),
                                     foregroundColor: Colors.white,
                                     elevation: 0,
                                     padding: const EdgeInsets.symmetric(vertical: 12),
                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                   ),
                                   child: Row(
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     children: [
                                       Icon(ownerPlan == 'free' ? Icons.lock_outline : Icons.campaign_rounded, size: 16),
                                       const SizedBox(width: 8),
                                       Text(ownerPlan == 'free' ? 'Unlock Bulk Reminders' : 'Send Bulk Reminders', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                                     ],
                                   ),
                                 ),
                               ),
                             ],
                           ),
                         ),
                         );
                       },
                     ),
                    
                      // New Combined Dashboard Layout
                      Column(
                        children: [
                          // 1. Top Grid (4 Cards)
                              Builder(
                                  builder: (context) {
                                      // Calculate arrears check
                                      final allCards = [
                                         _buildStatGridCard(
                                           theme, 
                                           Icons.home_outlined, 
                                           '$totalProperties', 
                                           'Total Properties', 
                                           null,
                                           onTap: () => context.push('/owner/portfolio')
                                         ),
                                         _buildStatGridCard(
                                           theme, 
                                           Icons.people_outline, 
                                           '$occupiedCount', 
                                           'Occupied', 
                                           null,
                                           onTap: () => context.push('/owner/portfolio')
                                         ),
                                         _buildStatGridCard(
                                           theme, 
                                           Icons.currency_rupee, 
                                           '$currencySymbol${CurrencyUtils.formatNumber(collected)}', 
                                           'Collected', 
                                           const Color(0xFF22C55E)
                                         ),
                                         if (ownerPlan != 'free' || pending > 0) 
                                            Builder(
                                              builder: (ctx) {
                                                final cycles = rentAsync.valueOrNull ?? [];
                                                final tenancies = ref.watch(allTenanciesProvider).valueOrNull ?? [];
                                                final tenants = ref.watch(tenantControllerProvider).valueOrNull ?? [];
                                                
                                                final Map<String, double> duesByTenant = {};
                                                final Set<String> pendingTenantIds = {};

                                                for (final c in cycles.where((c) => c.status.name != 'paid' && !c.isDeleted)) {
                                                  final tcy = tenancies.where((t) => t.id == c.tenancyId).firstOrNull;
                                                  if (tcy != null) {
                                                      pendingTenantIds.add(tcy.tenantId);
                                                      duesByTenant[tcy.tenantId] = (duesByTenant[tcy.tenantId] ?? 0) + (c.totalDue - c.totalPaid);
                                                  }
                                                }
                                                
                                                final pendingTenantsList = tenants.where((t) => pendingTenantIds.contains(t.id)).toList();

                                                return _buildStatGridCard(
                                                   theme, 
                                                   Icons.error_outline, 
                                                   '$currencySymbol${CurrencyUtils.formatNumber(pending)}', 
                                                   'Pending', 
                                                   const Color(0xFFF59E0B),
                                                   badgeCount: pendingTenantsList.length,
                                                   onTap: () => _showPendingDetailsBottomSheet(context, pendingTenantsList, duesByTenant, currencySymbol)
                                                );
                                              }
                                            ),
                                      ];

                                      return RepaintBoundary(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          physics: const BouncingScrollPhysics(),
                                          padding: const EdgeInsets.only(bottom: 24),
                                          child: Row(
                                            children: allCards.map((card) => Padding(
                                              padding: const EdgeInsets.only(right: 12),
                                              child: SizedBox(
                                                width: 160,
                                                height: 120,
                                                child: card,
                                              ),
                                            )).toList(),
                                          ),
                                        ),
                                      );
                                  }
                              ),

                        // Portfolio Management Entry (Fixes user confusion)
                        _buildPortfolioHeroCard(context, theme, totalProperties, occupiedCount, isDark),
                        const SizedBox(height: 32),
                        
                        // 2. Quick Actions Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Shortcuts', 
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 22, 
                                  fontWeight: FontWeight.bold, 
                                  color: theme.textTheme.titleLarge?.color,
                                  letterSpacing: -0.5
                                )
                              ),
                              const SizedBox(height: 16),
                              RepaintBoundary(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          physics: const BouncingScrollPhysics(),
                                          child: Row(
                                            children: [
                                              _buildCompactAction(context, 'Broadcast', Icons.campaign_rounded, Colors.orange, () => _showGlobalBroadcastDialog(context, ref)),
                                              const SizedBox(width: 12),
                                              _buildCompactAction(context, 'Record Expense', Icons.receipt_long_rounded, const Color(0xFFF59E0B), () => context.push('/owner/expenses/add')),
                                              const SizedBox(width: 12),
                                              _buildCompactAction(context, 'Maintenance', Icons.build_circle_rounded, const Color(0xFFEF4444), () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const MaintenanceReportsScreen()))),
                                              const SizedBox(width: 12),
                                              _buildCompactAction(context, 'Secure Vault', Icons.lock_person_rounded, const Color(0xFF6366F1), () => widget.onTabSwitch?.call(1)),
                                              const SizedBox(width: 12),
                                              _buildCompactAction(context, 'Reports', Icons.bar_chart_rounded, const Color(0xFF10B981), () => widget.onTabSwitch?.call(2)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        
                        const SizedBox(height: 32),

                        // Removed Monthly Revenue Overview for cleaner UI (belongs in Reports)
                      ],
                    ),
                  ],
                ),
              ),
            ),

                // Premium Ad Placement (Full Width) - Only for free/pro users
                if (showAds)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: const BannerAdWidget(),
                  ),
                ),

                // Activity Header Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                      const SizedBox(height: 8),

                      // Activity Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'dashboard.rent_activity'.tr(),
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleLarge?.color,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/owner/rent/pending'),
                          child: Text('dashboard.view_all'.tr(), 
                            style: GoogleFonts.outfit(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600
                            )
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Rent List
            rentAsync.when(
              data: (cycles) {
                // Get tenants - use empty list if loading or error
                final tenants = ref.watch(tenantControllerProvider).valueOrNull ?? [];
                final tenancies = tenanciesAsync.valueOrNull ?? [];
                
                // Sort Logic
                final sortedCycles = List.of(cycles);
                final now = DateTime.now();
                final currentMonthStart = DateTime(now.year, now.month, 1);

                sortedCycles.sort((a, b) {
                   final aIsPending = a.status.name != 'paid';
                   final bIsPending = b.status.name != 'paid';
                   if (aIsPending && !bIsPending) return -1;
                   if (!aIsPending && bIsPending) return 1;
                   if (aIsPending && bIsPending) {
                      final dateA = a.billPeriodStart ?? a.billGeneratedDate;
                      final dateB = b.billPeriodStart ?? b.billGeneratedDate;
                      return dateA.compareTo(dateB);
                   }
                   final dateA = a.billPeriodStart ?? a.billGeneratedDate;
                   final dateB = b.billPeriodStart ?? b.billGeneratedDate;
                   return dateB.compareTo(dateA);
                });

                // Show ALL cycles, not just those with matched tenants
                // If tenant not found, use fallback info
                if (sortedCycles.isEmpty) {
                   return SliverToBoxAdapter(
                    child: EmptyStateWidget(
                      title: 'All Caught Up!',
                      subtitle: 'No pending rent payments or active bills.',
                      icon: Icons.check_circle_outline,
                    ),
                  );
                }
                
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final c = sortedCycles[index];
                        final isPaid = c.status.name == 'paid';
                        final cycleDate = c.billPeriodStart ?? c.billGeneratedDate;
                        final isPastDue = !isPaid && cycleDate.isBefore(currentMonthStart);
                        
                        // Find tenancy first, then tenant (with fallback)
                        final tenancy = tenancies.where((t) => t.id == c.tenancyId).firstOrNull;
                        final tenant = tenants.where((t) => t.id == tenancy?.tenantId).firstOrNull;
                        
                        // Fallback name if tenant not found
                        final tenantName = tenant?.name ?? 'Tenant';
                        final initials = tenantName.trim().split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase();
                        
                        // Color Logic
                        final statusColor = isPaid 
                            ? const Color(0xFF10B981) // Green
                            : (isPastDue ? const Color(0xFFEF4444) : const Color(0xFFF59E0B)); // Red or Amber


                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {}, // Can open detail
                              borderRadius: BorderRadius.circular(24),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
                                  children: [
                                    // 1. Avatar
                                    Container(
                                      width: 50, height: 50,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        initials.isNotEmpty ? initials : '?',
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    // 2. Info Column
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tenantName,
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              color: theme.textTheme.bodyLarge?.color,
                                            ),
                                            maxLines: 1, overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                DateFormat('MMM yyyy').format(cycleDate),
                                                style: GoogleFonts.outfit(
                                                  fontSize: 13,
                                                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              if (c.electricAmount > 0) ...[
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                                  child: Icon(Icons.circle, size: 4, color: theme.disabledColor),
                                                ),
                                                Icon(Icons.electric_bolt_rounded, size: 12, color: theme.colorScheme.tertiary),
                                                const SizedBox(width: 2),
                                                Text(
                                                  '$currencySymbol${c.electricAmount.toInt()}',
                                                  style: GoogleFonts.outfit(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                                                )
                                              ]
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // 3. Amount & Status Column
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                          Text(
                                          '$currencySymbol${c.totalDue.toStringAsFixed(0)}',
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 18,
                                            color: theme.textTheme.bodyLarge?.color,
                                            letterSpacing: -0.5
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Status Badge
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: statusColor.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                isPaid ? 'dashboard.paid'.tr() : (isPastDue ? 'dashboard.overdue'.tr() : 'dashboard.due'.tr()),
                                                style: GoogleFonts.outfit(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: statusColor,
                                                ),
                                              ),
                                            ),
                                            
                                            // Share Button (Only if not paid and tenant has phone)
                                            if (!isPaid && tenant != null) ...[
                                              const SizedBox(width: 8),
                                              InkWell(
                                                onTap: () => _shareRentDetails(tenant, c),
                                                borderRadius: BorderRadius.circular(12),
                                                child: Container(
                                                  padding: const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF25D366).withValues(alpha: 0.1), // WhatsApp Light
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.2)),
                                                  ),
                                                  child: const Icon(Icons.share_outlined, size: 14, color: Color(0xFF25D366)), // WhatsApp Color
                                                ),
                                              )
                                            ]
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: sortedCycles.length,
                    ),
                  ),
                );
              },
              error: (e, st) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
              loading: () => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                     children: List.generate(3, (index) => const SkeletonCard()),
                  ),
                ),
              ),
            ),
            

            
             const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
             
              // Spacer to avoid FAB overlap
             const SliverToBoxAdapter(
               child: SizedBox(height: 80),
             ),
          ],
        ),
      ),
    );
  }

  // --- New Helper Widgets ---

  Widget _buildStatGridCard(ThemeData theme, IconData icon, String value, String label, Color? color, {int badgeCount = 0, VoidCallback? onTap}) {
     final isDark = theme.brightness == Brightness.dark;
     final accentColor = color ?? theme.colorScheme.primary;
     
     return InkWell(
       onTap: onTap,
       borderRadius: BorderRadius.circular(20),
       child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
           color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
           borderRadius: BorderRadius.circular(20),
           border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
           boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black45 : accentColor.withValues(alpha: 0.04), 
                blurRadius: 10, 
                offset: const Offset(0, 4)
              )
           ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Container(
                   padding: const EdgeInsets.all(6),
                   decoration: BoxDecoration(
                     color: accentColor.withValues(alpha: 0.1),
                     shape: BoxShape.circle,
                   ),
                   child: Icon(icon, size: 16, color: accentColor),
                 ),
                 if (badgeCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red, 
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('$badgeCount', 
                        style: GoogleFonts.outfit(
                          color: Colors.white, 
                          fontSize: 10, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                    )
               ],
             ),
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(value, 
                      style: GoogleFonts.outfit(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        color: theme.textTheme.bodyLarge?.color,
                        letterSpacing: -0.5
                      )
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(label, 
                     style: GoogleFonts.outfit(
                       fontSize: 10, 
                       color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                       fontWeight: FontWeight.w500
                     ),
                     maxLines: 1, 
                     overflow: TextOverflow.ellipsis
                  ),
               ],
             )
          ],
        ),
       ),
      );
  }

    void _showGlobalBroadcastDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BroadcastCenterSheet(),
    );
  }


  // Legacy broadcast code removed - using BroadcastCenterSheet instead.
  Widget _buildCompactAction(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 130, // Fixed width for consistent horizontal row
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black45 : color.withValues(alpha: 0.03), 
                blurRadius: 10, 
                offset: const Offset(0, 4)
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                label, 
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold, 
                  fontSize: 13,
                  color: theme.textTheme.bodyLarge?.color
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildPortfolioHeroCard(BuildContext context, ThemeData theme, int propertyCount, int tenantCount, bool isDark) {
    return InkWell(
      onTap: () => context.push('/owner/portfolio'),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: isDark ? Colors.white10 : theme.colorScheme.primary.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black45 : theme.colorScheme.primary.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.business_center_rounded, color: theme.colorScheme.primary, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                     'Manage Portfolio',
                     style: GoogleFonts.outfit(
                       color: theme.textTheme.titleLarge?.color, 
                       fontSize: 18, 
                       fontWeight: FontWeight.bold
                     ),
                   ),
                   const SizedBox(height: 4),
                   Text(
                     '$propertyCount Properties • $tenantCount Tenants',
                     style: GoogleFonts.outfit(
                       color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6), 
                       fontSize: 13,
                       fontWeight: FontWeight.w500
                     ),
                   ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: theme.colorScheme.primary.withValues(alpha: 0.5), size: 16),
          ],
        ),
      ),
    );
  }

  void _showPendingDetailsBottomSheet(BuildContext context, List<Tenant> tenants, Map<String, double> dues, String currency) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pending Payments', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('${tenants.length} tenants outstanding', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: tenants.isEmpty 
              ? Center(child: Text('No pending payments!', style: GoogleFonts.outfit(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: tenants.length,
                  itemBuilder: (context, index) {
                    final tenant = tenants[index];
                    final amount = dues[tenant.id] ?? 0.0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: Text(tenant.name.isNotEmpty ? tenant.name[0].toUpperCase() : '?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tenant.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('Total Due: $currency${CurrencyUtils.formatNumber(amount)}', style: GoogleFonts.outfit(color: Colors.red.shade400, fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                               // Find latest pending cycle for this tenant
                               final cycles = ref.read(rentControllerProvider).valueOrNull ?? [];
                               final tenancies = ref.read(allTenanciesProvider).valueOrNull ?? [];
                               final tenancy = tenancies.where((t) => t.tenantId == tenant.id).firstOrNull;
                               final pendingCycle = cycles.where((c) => c.tenancyId == tenancy?.id && c.status.name != 'paid').firstOrNull;
                               
                               if (pendingCycle != null) {
                                  _shareRentDetails(tenant, pendingCycle);
                               }
                            },
                            child: Text('Notify', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final cycles = ref.read(rentControllerProvider).valueOrNull ?? [];
                    final tenancies = ref.read(allTenanciesProvider).valueOrNull ?? [];
                    
                    for (final tenant in tenants) {
                      final tenancy = tenancies.where((t) => t.tenantId == tenant.id).firstOrNull;
                      final pendingCycle = cycles.where((c) => c.tenancyId == tenancy?.id && c.status.name != 'paid').firstOrNull;
                      
                      if (pendingCycle != null) {
                        _shareRentDetails(tenant, pendingCycle);
                        // Delay to allow user to handle WhatsApp sequential opening
                        await Future.delayed(const Duration(milliseconds: 500));
                      }
                    }
                  },
                  icon: const Icon(Icons.notifications_active_outlined, color: Colors.white),
                  label: const Text('Notify All Tenants', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showMaintenancePopup(int count) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Requests'),
        content: Text('You have $count pending maintenance requests.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
               Navigator.pop(ctx);
               Navigator.push(context, CupertinoPageRoute(builder: (_) => const MaintenanceReportsScreen()));
            },
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }
}
