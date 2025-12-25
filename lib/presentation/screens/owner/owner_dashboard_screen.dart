import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
// NEW
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/tenant.dart';
import '../../../features/rent/domain/entities/rent_cycle.dart';
import '../../../domain/repositories/i_rent_repository.dart'; // Added for DashboardStats

import 'package:go_router/go_router.dart';
import 'rent/rent_controller.dart';
import 'house/house_controller.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'settings/settings_screen.dart'; 
import 'reports/reports_screen.dart'; 
import '../../../core/utils/currency_utils.dart';
import 'tenant/tenant_controller.dart';
// For DashboardStats
import '../../providers/data_providers.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/empty_state_widget.dart';
import 'settings/owner_controller.dart';
import 'package:kirayabook/presentation/screens/notice/notice_controller.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../maintenance/maintenance_controller.dart';
import '../maintenance/maintenance_reports_screen.dart';
import '../../../../domain/entities/maintenance_request.dart';
import '../../widgets/ads/banner_ad_widget.dart';
// NEW
// NEW
// For ImageFilter

import 'package:easy_localization/easy_localization.dart'; // NEW

import 'package:kirayabook/features/ai_helper/providers/ai_helper_providers.dart';
import 'portfolio/portfolio_management_screen.dart';
import 'tenant/tenant_list_screen.dart'; // NEW
import 'expense/expense_screens.dart'; // NEW

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _DashboardTab(onTabSwitch: (index) => setState(() => _currentIndex = index)),
          const TenantListScreen(), // Tenants Tab
          const PortfolioManagementScreen(), // Properties Tab
          const ExpenseListScreen(), // Expenses Tab
          const ReportsScreen(), // Reports Tab
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
            NavigationDestination(icon: const Icon(Icons.people_outline), selectedIcon: const Icon(Icons.people), label: 'Tenants'),
            NavigationDestination(icon: const Icon(Icons.home_work_outlined), selectedIcon: const Icon(Icons.home_work), label: 'Properties'),
            NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), selectedIcon: const Icon(Icons.receipt_long), label: 'Expenses'),
            NavigationDestination(icon: const Icon(Icons.bar_chart_outlined), selectedIcon: const Icon(Icons.bar_chart), label: 'nav.reports'.tr()),
          ],
        ),
      ),
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
  DashboardStats? _cachedStats; // Local cache to prevent flashing
  
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final session = ref.read(userSessionServiceProvider);
      final user = session.currentUser;
      
       ref.read(rentControllerProvider.notifier).generateRentForCurrentMonth();
       
       if (user != null) {
          ref.read(noticeControllerProvider.notifier).cleanupOldNotices(user.uid);
       }
    });
  }

  @override
  Widget build(BuildContext context) {
    final rentAsync = ref.watch(rentControllerProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    
    // Optimistic UI: Keep showing old stats while refreshing
    if (statsAsync.hasValue) {
      _cachedStats = statsAsync.value;
    }
    
    final ownerAsync = ref.watch(ownerControllerProvider);
    final currencySymbol = CurrencyUtils.getSymbol(ownerAsync.value?.currency);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Watch Maintenance Requests for Popup/Badge
    final user = ref.watch(userSessionServiceProvider).currentUser;
    final maintenanceAsync = user != null ? ref.watch(ownerMaintenanceProvider(user.uid)) : const AsyncValue<List<MaintenanceRequest>>.loading();
    final pendingMaintenanceCount = maintenanceAsync.valueOrNull?.where((r) => r.status == MaintenanceStatus.pending).length ?? 0;

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
    
    final totalProperties = unitsAsync.valueOrNull?.length ?? 0;
    final occupiedCount = tenantsAsync.valueOrNull?.where((t) => t.isActive).length ?? 0;
    
    // Use cached stats if available to prevent 0.0 flash
    final displayStats = _cachedStats ?? statsAsync.valueOrNull;
    final collected = displayStats?.thisMonthCollected ?? 0.0;
    final pending = displayStats?.totalPending ?? 0.0;
    
    // --- Owner Plan Check for Ads ---
    final ownerSessionAsync = user != null ? ref.watch(ownerByIdProvider(user.uid)) : const AsyncValue<dynamic>.loading();
    final ownerPlan = ownerSessionAsync.valueOrNull?.subscriptionPlan;
    final showAds = ownerPlan == 'free'; // Only Free users see ads. Loading or Premium hides them.
    
    // ----------------------------------------------------

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Dashboard', 
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold, 
            fontSize: 28, 
            color: theme.textTheme.titleLarge?.color,
            letterSpacing: -0.5,
          )
        ),
        centerTitle: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          // Search Icon
          IconButton(
            icon: Icon(Icons.search_rounded, color: theme.textTheme.bodyMedium?.color),
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Implement Search or navigate to SearchScreen
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Search coming soon!')));
            },
          ),
          // Notification Icon with Badge
          Badge(
            label: Text('$pendingMaintenanceCount'),
            isLabelVisible: pendingMaintenanceCount > 0,
            offset: const Offset(-4, 4),
            child: IconButton(
              icon: Icon(Icons.notifications_none_rounded, color: theme.textTheme.bodyMedium?.color),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MaintenanceReportsScreen()));
              },
            ),
          ),
          const SizedBox(width: 8),
          // Functional Profile Icon
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/owner/settings');
            }, // Navigate to Settings Screen Directly
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
             // r2 is void/future depending on implementation, rent controller usually updates state. 
             // If generateRent returns Future, we wait. If not, we assume it kicks off.
             // Actually rentControllerProvider is a generic provider? 
             // Let's just refresh the provider itself to be safe if it's a stream/future.
             // But it is likely a Notifier. We called generateRentForCurrentMonth() in InitState.
             // Let's just await a small delay or the futures we have.
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
                  
                     // --- Urgent Alerts Section ---
                     Builder(
                       builder: (context) {
                         final overdueCount = rentAsync.valueOrNull?.where((c) {
                           final date = c.billPeriodStart ?? c.billGeneratedDate;
                           final now = DateTime.now();
                           final currentMonthStart = DateTime(now.year, now.month, 1);
                           return c.status.name != 'paid' && date.isBefore(currentMonthStart);
                         }).length ?? 0;
                         
                         if (overdueCount == 0 && pendingMaintenanceCount == 0) return const SizedBox.shrink();
                         
                         return Padding(
                           padding: const EdgeInsets.only(bottom: 24),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text('Urgent Alerts', 
                                 style: GoogleFonts.outfit(
                                   fontSize: 16, 
                                   fontWeight: FontWeight.bold,
                                   color: theme.colorScheme.error,
                                 )
                               ),
                               const SizedBox(height: 12),
                               if (overdueCount > 0)
                                 _buildAlertTile(
                                   context, 
                                   '$overdueCount Overdue Payments', 
                                   Icons.receipt_long_rounded, 
                                   Colors.red,
                                   () => context.push('/owner/rent/pending')
                                 ),
                               if (pendingMaintenanceCount > 0) ...[
                                 const SizedBox(height: 8),
                                 _buildAlertTile(
                                   context, 
                                   '$pendingMaintenanceCount Maintenance Requests', 
                                   Icons.handyman_rounded, 
                                   Colors.orange,
                                   () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MaintenanceReportsScreen()))
                                 ),
                               ],
                             ],
                           ),
                         );
                       },
                     ),

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
                         
                         return Container(
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
                                 ],
                               ),
                               const SizedBox(height: 12),
                               SizedBox(
                                 width: double.infinity,
                                 child: ElevatedButton(
                                   onPressed: () {
                                     // TODO: Implement bulk reminders or upgrade prompt
                                     if (ownerPlan == 'free') {
                                       context.push('/owner/settings/subscription');
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
                                       const Icon(Icons.lock_outline, size: 16),
                                       const SizedBox(width: 8),
                                       Text('Unlock Bulk Reminders', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                                     ],
                                   ),
                                 ),
                               ),
                             ],
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
                                      // Calculate overdue/arrears
                                      final rentCycles = rentAsync.valueOrNull ?? [];
                                      final now = DateTime.now();
                                      final currentMonthStart = DateTime(now.year, now.month, 1);
                                      
                                      // Logic: Unpaid AND BillStart < CurrentMonthStart (Arrears)
                                      final overdueCount = rentCycles.where((c) {
                                        final date = c.billPeriodStart ?? c.billGeneratedDate;
                                        return c.status.name != 'paid' && date.isBefore(currentMonthStart);
                                      }).length;

                                      final allCards = [
                                         if (ownerPlan == 'power') _buildStatGridCard(theme, Icons.home_outlined, '$totalProperties', 'Total Properties', null),
                                         if (ownerPlan == 'power') _buildStatGridCard(theme, Icons.people_outline, '$occupiedCount', 'Occupied', null),
                                         _buildStatGridCard(theme, Icons.currency_rupee, '$currencySymbol${CurrencyUtils.formatNumber(collected)}', 'Collected This Month', const Color(0xFF22C55E)),
                                         if (ownerPlan == 'power') 
                                            _buildStatGridCard(
                                               theme, 
                                               Icons.error_outline, 
                                               '$currencySymbol${CurrencyUtils.formatNumber(pending)}', 
                                               'Pending Payments', 
                                               const Color(0xFFF59E0B),
                                               badgeCount: overdueCount,
                                               onTap: () => context.push('/owner/rent/pending')
                                            ),
                                      ];

                                      // If only 1 card (Free/Basic plans), show full width
                                      if (allCards.length == 1) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 24),
                                          child: SizedBox(
                                            height: 120,
                                            child: allCards.first,
                                          ),
                                        );
                                      }

                                      return SingleChildScrollView(
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
                                      );
                                  }
                              ),
                        
                        // 2. Quick Actions Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Quick Actions', 
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 22, 
                                  fontWeight: FontWeight.bold, 
                                  color: theme.textTheme.titleLarge?.color,
                                  letterSpacing: -0.5
                                )
                              ),
                              const SizedBox(height: 16),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  children: [
                                    _buildCompactAction(context, 'Add Property', Icons.add_business_rounded, theme.colorScheme.primary, () {
                                      HapticFeedback.lightImpact();
                                      context.push('/owner/houses/add');
                                    }),
                                    const SizedBox(width: 12),
                                    _buildCompactAction(context, 'Add Tenant', Icons.person_add_rounded, const Color(0xFF10B981), () {
                                      HapticFeedback.lightImpact();
                                      context.push('/owner/tenants/add');
                                    }),
                                    const SizedBox(width: 12),
                                    _buildCompactAction(context, 'Expenses', Icons.receipt_long_rounded, const Color(0xFFF59E0B), () {
                                      HapticFeedback.lightImpact();
                                      context.push('/owner/expenses');
                                    }),
                                    const SizedBox(width: 12),
                                    _buildCompactAction(context, 'Broadcast', Icons.campaign_rounded, const Color(0xFFEA580C), () {
                                      HapticFeedback.lightImpact();
                                      _showGlobalBroadcastDialog(context);
                                    }),
                                  ],
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

                      // Tenant Activity Section
                      if (tenantsAsync.valueOrNull?.where((t) => t.isActive).isNotEmpty ?? false) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tenant Activity',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.titleLarge?.color,
                                letterSpacing: -0.5,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push('/owner/tenants'),
                              child: Text('View All', 
                                style: GoogleFonts.outfit(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600
                                )
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...tenantsAsync.valueOrNull!.where((t) => t.isActive).take(3).map((tenant) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Slidable(
                            key: ValueKey(tenant.id),
                            startActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              extentRatio: 0.2,
                              children: [
                                SlidableAction(
                                  onPressed: (context) async {
                                    String phone = tenant.phone.replaceAll(RegExp(r'\D'), '');
                                    final url = Uri.parse("whatsapp://send?phone=$phone");
                                    if (await canLaunchUrl(url)) await launchUrl(url);
                                  },
                                  backgroundColor: const Color(0xFF25D366),
                                  foregroundColor: Colors.white,
                                  icon: Icons.chat_bubble_outline_rounded,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ],
                            ),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              extentRatio: 0.5,
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                     context.push('/owner/tenants/${tenant.id}', extra: tenant);
                                  },
                                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.8),
                                  foregroundColor: Colors.white,
                                  icon: Icons.person_outline,
                                  label: 'Details',
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                SlidableAction(
                                  onPressed: (context) async {
                                    final url = Uri.parse("tel:${tenant.phone}");
                                    if (await canLaunchUrl(url)) await launchUrl(url);
                                  },
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  icon: Icons.phone_outlined,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    child: Text(
                                      tenant.name.trim().isNotEmpty ? tenant.name.trim()[0].toUpperCase() : '?',
                                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(tenant.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Text(tenant.phone, style: GoogleFonts.outfit(fontSize: 13, color: theme.hintColor)),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right_rounded, color: theme.hintColor.withValues(alpha: 0.5)),
                                ],
                              ),
                            ),
                          ),
                        )),
                        const SizedBox(height: 24),
                      ],

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
                          onPressed: () {},
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
                final tenantsAsync = ref.watch(tenantControllerProvider);
                return tenantsAsync.when(
                  data: (tenants) {
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

                    // RentCycles use tenancyId, so we need to filter based on tenancies
                    final tenanciesAsync = ref.watch(allTenanciesProvider);
                    final tenancies = tenanciesAsync.valueOrNull ?? [];
                    final validCycles = sortedCycles.where((cycle) {
                      final tenancy = tenancies.where((t) => t.id == cycle.tenancyId).firstOrNull;
                      if (tenancy == null) return false;
                      return tenants.any((t) => t.id == tenancy.tenantId);
                    }).toList();

                    if (validCycles.isEmpty) {
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
                            final c = validCycles[index];
                            final isPaid = c.status.name == 'paid';
                            final cycleDate = c.billPeriodStart ?? c.billGeneratedDate;
                            final isPastDue = !isPaid && cycleDate.isBefore(currentMonthStart);
                            // Find tenancy first, then tenant
                            final tenancy = tenancies.where((t) => t.id == c.tenancyId).firstOrNull;
                            final tenant = tenants.firstWhere((t) => t.id == tenancy?.tenantId, orElse: () => tenants.first);
                            
                            // Color Logic
                            final statusColor = isPaid 
                                ? const Color(0xFF10B981) // Green
                                : (isPastDue ? const Color(0xFFEF4444) : const Color(0xFFF59E0B)); // Red or Amber
                            
                            final bgGradient = isDark 
                                ? LinearGradient(colors: [theme.cardColor, theme.cardColor.withValues(alpha: 0.8)])
                                : LinearGradient(colors: [Colors.white, Colors.grey.shade50]);

                            // Initial Avatar
                            final initials = tenant.name.trim().split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase();

                            // Helper for WhatsApp (Keep logic same, UI different)
                             void shareRentDetails(Tenant tenant, RentCycle c) async {
                                  final monthStr = DateFormat('MMMM yyyy').format(c.billPeriodStart ?? c.billGeneratedDate);
                                  
                                  // Use AIService to generate the message
                                  final aiService = ref.read(aiServiceProvider);
                                  final message = await aiService.generateRentReminder(
                                    tenantName: tenant.name,
                                    amountDue: c.totalDue,
                                    dueDate: monthStr,
                                  );

                                  try {
                                     String phone = tenant.phone.replaceAll(RegExp(r'\D'), '');
                                     if (phone.length == 10) phone = '91$phone';
                                     final url = Uri.parse("whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}");
                                     if (await canLaunchUrl(url)) {
                                       await launchUrl(url, mode: LaunchMode.externalApplication);
                                     } else {
                                        if(context.mounted) {
                                           ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp not detected. Opening options...'), duration: Duration(seconds: 2)));
                                        }
                                        await Share.share(message);
                                     }
                                  } catch (e) {
                                     if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch WhatsApp: $e')));
                                  }
                                }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Slidable(
                                key: ValueKey(c.id),
                                startActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  extentRatio: 0.25,
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) => shareRentDetails(tenant, c),
                                      backgroundColor: const Color(0xFF25D366),
                                      foregroundColor: Colors.white,
                                      icon: Icons.chat_bubble_outline_rounded,
                                      label: 'Remind',
                                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                                    ),
                                  ],
                                ),
                                endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  extentRatio: 0.5,
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) {
                                        if (tenancy != null) {
                                           context.push('/owner/tenants/${tenancy.tenantId}', extra: tenant);
                                        }
                                      },
                                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.8),
                                      foregroundColor: Colors.white,
                                      icon: Icons.analytics_outlined,
                                      label: 'Details',
                                    ),
                                    SlidableAction(
                                      onPressed: (context) async {
                                         final url = Uri.parse("tel:${tenant.phone}");
                                         if (await canLaunchUrl(url)) await launchUrl(url);
                                      },
                                      backgroundColor: theme.colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      icon: Icons.phone_outlined,
                                      label: 'Call',
                                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                                    ),
                                  ],
                                ),
                                child: Container(
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
                                      onTap: () {
                                        // TODO: Open cycle details or record payment
                                      },
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
                                                initials,
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
                                                    tenant.name,
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
                                                    
                                                    // Share Button (Only if not paid)
                                                    if (!isPaid) ...[
                                                      const SizedBox(width: 8),
                                                      InkWell(
                                                        onTap: () => shareRentDetails(tenant, c),
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
                                ),
                              ),
                            );
                          },
                          childCount: validCycles.length,
                        ),
                      ),
                    );
                  },
                  loading: () => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: List.generate(3, (index) => const SkeletonCard()),
                      ),
                    ),
                  ),
                  error: (e, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
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

  Widget _buildDetailCard(BuildContext context, String title, String value, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, // Glass base
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.05), // Subtle blue tint shadow
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  // --- New Helper Widgets ---

  Widget _buildStatGridCard(ThemeData theme, IconData icon, String value, String label, Color? color, {int badgeCount = 0, VoidCallback? onTap}) {
     final isDark = theme.brightness == Brightness.dark;
     final accentColor = color ?? theme.colorScheme.primary;
     
     return InkWell(
       onTap: () {
         if (onTap != null) {
           HapticFeedback.selectionClick();
           onTap();
         }
       },
       borderRadius: BorderRadius.circular(24),
       child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
           color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
           borderRadius: BorderRadius.circular(24),
           border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
           boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.3) : accentColor.withValues(alpha: 0.06), 
                blurRadius: 15, 
                offset: const Offset(0, 6)
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
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     color: accentColor.withValues(alpha: 0.1),
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: Icon(icon, size: 20, color: accentColor),
                 ),
                 if (badgeCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red, 
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$badgeCount', 
                        style: GoogleFonts.outfit(
                          color: Colors.white, 
                          fontSize: 11, 
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
                        fontSize: 20, 
                        fontWeight: FontWeight.bold, 
                        color: theme.textTheme.bodyLarge?.color,
                        letterSpacing: -0.5
                      )
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(label, 
                     style: GoogleFonts.outfit(
                       fontSize: 12, 
                       color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                       fontWeight: FontWeight.w600
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

  Widget _buildAlertTile(BuildContext context, String message, IconData icon, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? color.withValues(alpha: 0.9) : color.withValues(alpha: 0.8),
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData? icon, bool isPrimary, VoidCallback onTap) {
      final theme = Theme.of(context);
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isPrimary ? theme.colorScheme.primary : theme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: isPrimary ? null : Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
               if(icon != null) ...[
                 Icon(icon, size: 16, color: isPrimary ? Colors.white : theme.textTheme.bodyLarge?.color),
                 const SizedBox(width: 8),
               ],
               Text(label, style: GoogleFonts.outfit(
                 color: isPrimary ? Colors.white : theme.textTheme.bodyLarge?.color,
                 fontWeight: FontWeight.w500,
                 fontSize: 13
               ))
            ],
          ),
        ),
      );
  }

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

  Widget _buildQuickActionCard(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label, 
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold, 
                    fontSize: 13,
                    color: theme.textTheme.bodyLarge?.color
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
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

  void _showUpgradePrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.amber.shade700),
            const SizedBox(width: 8),
            const Text('Pro Feature'),
          ],
        ),
        content: const Text('This feature is available for Pro and Power users. Upgrade to unlock!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Later')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/owner/settings/subscription');
            },
            child: const Text('Upgrade Now'),
          ),
        ],
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
            child: const Text('View All')
          )
        ],
      )
    );
  }

  void _showGlobalBroadcastDialog(BuildContext context) {
    final titleController = TextEditingController();
    final msgController = TextEditingController();
    String selectedPriority = 'medium';
    String? selectedHouseId;
    bool isLoading = false;

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
            final housesAsync = ref.watch(houseControllerProvider);

            return Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                margin: const EdgeInsets.only(bottom: 40),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor.withValues(alpha: 0.98),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 2),
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
                            Text(
                              'Broadcast Notice',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.titleLarge?.color
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        housesAsync.when(
                          data: (houses) {
                            return DropdownButtonFormField<String>(
                              hint: const Text('Select Target House'),
                              value: selectedHouseId,
                              decoration: InputDecoration(
                                labelText: 'Target Property',
                                filled: true,
                                fillColor: theme.scaffoldBackgroundColor,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              items: [
                                const DropdownMenuItem(value: 'all', child: Text('All Properties (Broadcast)')),
                                ...houses.map((h) => DropdownMenuItem(value: h.id, child: Text(h.name))),
                              ],
                              onChanged: (val) => setDialogState(() => selectedHouseId = val),
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (_,__) => const Text('Error loading properties'),
                        ),
                        
                        const SizedBox(height: 16),

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
                                onPressed: (isLoading || selectedHouseId == null) ? null : () async {
                                  if (titleController.text.isNotEmpty && msgController.text.isNotEmpty) {
                                     setDialogState(() => isLoading = true);
                                     
                                     final user = ref.read(userSessionServiceProvider).currentUser;
                                     if (user == null) {
                                       Navigator.pop(ctx);
                                       return;
                                     }
                                     
                                     try {
                                        if (selectedHouseId == 'all') {
                                           // Broadcast to ALL houses
                                           final houses = ref.read(houseControllerProvider).value ?? [];
                                           for (final house in houses) {
                                              await ref.read(noticeControllerProvider.notifier).sendNotice(
                                                houseId: house.id,
                                                ownerId: user.uid,
                                                subject: titleController.text.trim(),
                                                message: msgController.text.trim(),
                                                priority: selectedPriority,
                                              );
                                           }
                                        } else {
                                          // Single House
                                          await ref.read(noticeControllerProvider.notifier).sendNotice(
                                            houseId: selectedHouseId!,
                                            ownerId: user.uid,
                                            subject: titleController.text.trim(),
                                            message: msgController.text.trim(),
                                            priority: selectedPriority,
                                          );
                                        }
                                        
                                        if (context.mounted) {
                                          Navigator.pop(ctx);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Notice Broadcasted Successfully!'), backgroundColor: Colors.green)
                                          );
                                        }
                                     } catch (e) {
                                        setDialogState(() => isLoading = false);
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
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
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
}

