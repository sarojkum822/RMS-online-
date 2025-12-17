import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // NEW
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/tenant.dart';
import '../../../features/rent/domain/entities/rent_cycle.dart';
import 'house/house_list_screen.dart';
import 'tenant/tenant_list_screen.dart';
import 'tenant/tenant_list_screen.dart';
import 'package:go_router/go_router.dart';
import 'rent/rent_controller.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import '../../../../core/theme/app_theme.dart';
import 'settings/settings_screen.dart'; 
import 'reports/reports_screen.dart'; 
import 'tenant/tenant_controller.dart';
// For DashboardStats
import '../../providers/data_providers.dart';
import '../../widgets/skeleton_loader.dart';
import 'package:rentpilotpro/presentation/screens/notice/notice_controller.dart';
import '../maintenance/maintenance_controller.dart';
import '../maintenance/maintenance_reports_screen.dart';
import '../../../../domain/entities/maintenance_request.dart';
import '../../widgets/ads/banner_ad_widget.dart';

import 'package:easy_localization/easy_localization.dart'; // NEW

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _DashboardTab(),      // 0
    const HouseListScreen(),    // 1
    const TenantListScreen(),   // 2
    const ReportsScreen(),      // 3
    const SettingsScreen(),     // 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
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
            NavigationDestination(icon: const Icon(Icons.home_work_outlined), selectedIcon: const Icon(Icons.home_work), label: 'nav.properties'.tr()),
            NavigationDestination(icon: const Icon(Icons.people_outline), selectedIcon: const Icon(Icons.people), label: 'nav.tenants'.tr()),
            NavigationDestination(icon: const Icon(Icons.bar_chart_outlined), selectedIcon: const Icon(Icons.bar_chart), label: 'nav.reports'.tr()),
            NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: 'nav.settings'.tr()),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends ConsumerStatefulWidget {
  const _DashboardTab();

  @override
  ConsumerState<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<_DashboardTab> {
  bool _hasShownMaintenancePopup = false;
  bool _showLoadingAnimation = true; // Force animation on start
  
  @override
  void initState() {
    super.initState();
    // Ensure animation runs for at least 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showLoadingAnimation = false);
      }
    });

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
    final occupiedCount = tenantsAsync.valueOrNull?.where((t) => t.status.name == 'active').length ?? 0;
    
    final collected = statsAsync.valueOrNull?.thisMonthCollected ?? 0.0;
    final pending = statsAsync.valueOrNull?.totalPending ?? 0.0;
    
    // ----------------------------------------------------

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Dashboard', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 24, color: theme.textTheme.bodyLarge?.color)),
        centerTitle: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: theme.textTheme.bodyMedium?.color),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          Container(
             margin: const EdgeInsets.only(right: 20),
             padding: const EdgeInsets.all(8),
             decoration: BoxDecoration(
               color: theme.colorScheme.primary,
               shape: BoxShape.circle,
             ),
             child: const Icon(Icons.person, color: Colors.white, size: 20),
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
                  
                   // 0. Total Revenue Card (Lifetime)
                   Container(
                     width: double.infinity,
                     padding: const EdgeInsets.all(24),
                     decoration: BoxDecoration(
                        color: Colors.black, // Dark card for contrast
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
                        boxShadow: [
                           BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))
                        ]
                     ),
                     child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text('Total Revenue', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                           const SizedBox(height: 8),
                           Builder(
                             builder: (context) {
                               final total = statsAsync.valueOrNull?.totalCollected ?? 0.0;
                               
                               return FittedBox( // Added FittedBox
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                     children: [
                                       Text('₹ ', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                                       AnimatedFlipCounter(
                                         value: total,
                                         fractionDigits: 0,
                                         duration: const Duration(milliseconds: 1500),
                                         curve: Curves.easeOutExpo,
                                         textStyle: GoogleFonts.outfit(
                                           fontSize: 32,
                                           fontWeight: FontWeight.bold,
                                           color: Colors.white,
                                         ),
                                       ),
                                     ],
                                   ),
                                );
                             }
                           ),
                           const SizedBox(height: 12),
                           Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                 color: Colors.white.withOpacity(0.15),
                                 borderRadius: BorderRadius.circular(20)
                              ),
                              child: Text('Lifetime Earnings', style: GoogleFonts.outfit(color: Colors.white, fontSize: 12)),
                           )
                        ],
                     ),
                   ),
                   const SizedBox(height: 24),
                  
                    // New Combined Dashboard Layout
                    Column(
                      children: [
                        // 1. Top Grid (4 Cards)
                        // 1. Top Grid (4 Cards)
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.6, // Adjust for card shape
                          padding: const EdgeInsets.only(bottom: 24),
                          children: [
                             _buildStatGridCard(theme, Icons.home_outlined, '$totalProperties', 'Total Properties', null),
                             _buildStatGridCard(theme, Icons.people_outline, '$occupiedCount', 'Occupied', null),
                             _buildStatGridCard(theme, Icons.currency_rupee, collected >= 1000 ? '${(collected/1000).toStringAsFixed(1)}k' : collected.toStringAsFixed(0), 'Collected This Month', const Color(0xFF22C55E)),
                             _buildStatGridCard(theme, Icons.error_outline, pending >= 1000 ? '${(pending/1000).toStringAsFixed(1)}k' : pending.toStringAsFixed(0), 'Pending Payments', const Color(0xFFF59E0B)),
                          ],
                        ),
                        
                        // 2. Action Buttons Row
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildActionButton(context, 'Add Property', Icons.add, true, () => context.push('/owner/houses/add')),
                              const SizedBox(width: 8),

                              _buildActionButton(context, 'Send Reminders', null, false, () {}),
                              const SizedBox(width: 8),
                              _buildActionButton(context, 'Manage Subscription', null, false, () => context.push('/owner/settings/subscription')),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // 3. Tabs (Visual Only for now as requested by UI)
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? theme.scaffoldBackgroundColor : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: isDark ? Border.all(color: Colors.white10) : null,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                       BoxShadow(
                                          color: isDark ? Colors.transparent : Colors.black.withOpacity(0.05),
                                          blurRadius: 4
                                       )
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                     'Overview', 
                                     style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 13,
                                        color: theme.textTheme.bodyLarge?.color
                                     )
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(child: Text('Properties ($totalProperties)', style: GoogleFonts.outfit(color: theme.hintColor, fontSize: 13))), 
                              ),
                              Expanded(
                                child: Center(child: Text('Payments', style: GoogleFonts.outfit(color: theme.hintColor, fontSize: 13))),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),

                        // 4. Monthly Revenue Overview (The card I made before)
                        statsAsync.when(
                          data: (stats) {
                            final totalMonthlyDue = stats.thisMonthCollected + stats.thisMonthPending;
                            final collectionRate = totalMonthlyDue > 0 ? (stats.thisMonthCollected / totalMonthlyDue) : 0.0;
                            final pending = stats.thisMonthPending;
                            final collected = stats.thisMonthCollected;

                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Monthly Revenue Overview',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Total Monthly Rent
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible( // Added Flexible
                                        child: Text(
                                          'Total Monthly Rent',
                                          style: GoogleFonts.outfit(fontSize: 15, color: Colors.grey.shade600),
                                          overflow: TextOverflow.ellipsis, // Ellipsis
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      FittedBox( // Added FittedBox
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '₹${totalMonthlyDue.toStringAsFixed(0)}',
                                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Collected
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Collected This Month',
                                          style: GoogleFonts.outfit(fontSize: 15, color: Colors.grey.shade600),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '₹${collected.toStringAsFixed(0)}',
                                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF22C55E)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Pending
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Pending Collection',
                                          style: GoogleFonts.outfit(fontSize: 15, color: Colors.grey.shade600),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '₹${pending.toStringAsFixed(0)}',
                                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  const Divider(),
                                  const SizedBox(height: 12),
                                  
                                  // Rate
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Collection Rate',
                                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${(collectionRate * 100).toStringAsFixed(0)}%',
                                        style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                          loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                          error: (e, _) => Text('Error: $e'),
                        ),
                      ],
                    ),
                  ],
                ),
                  ),
                ),

                // Premium Ad Placement (Full Width)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: BannerAdWidget(),
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
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text('dashboard.view_all'.tr(), style: GoogleFonts.outfit(color: theme.colorScheme.primary)),
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

                    final validCycles = sortedCycles.where((cycle) {
                      return tenants.any((t) => t.id == cycle.tenantId);
                    }).toList();

                    if (validCycles.isEmpty) {
                       return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Column(
                              children: [
                                Icon(Icons.check_circle_outline, size: 60, color: theme.disabledColor),
                                const SizedBox(height: 16),
                                Text('dashboard.all_caught_up'.tr(), style: GoogleFonts.outfit(color: theme.disabledColor)),
                              ],
                            ),
                          ),
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
                            final tenant = tenants.firstWhere((t) => t.id == c.tenantId);
                            
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
                             void _shareRentDetails(Tenant tenant, RentCycle c) async {
                                  final monthStr = DateFormat('MMMM yyyy').format(c.billPeriodStart ?? c.billGeneratedDate);
                                  final message = '''
Dear ${tenant.name},

Hope you are having a good day! 🌟

This is a gentle reminder regarding the rent for *$monthStr*.

*Bill Details:*
• Rent: ₹${c.baseRent.toStringAsFixed(0)}
${c.electricAmount > 0 ? '• Electricity: ₹${c.electricAmount.toStringAsFixed(0)}\n' : ''}${c.otherCharges > 0 ? '• Other Charges: ₹${c.otherCharges.toStringAsFixed(0)}\n' : ''}
*Total Payable: ₹${c.totalDue.toStringAsFixed(0)}*

Please arrange to pay at your earliest convenience.

Thank you!
''';
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

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                gradient: bgGradient,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: isPastDue ? statusColor.withValues(alpha: 0.3) : (isDark ? Colors.white12 : Colors.transparent),
                                  width: 1
                                )
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
                                                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
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
                                                      '₹${c.electricAmount.toInt()}',
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
                                              '₹${c.totalDue.toStringAsFixed(0)}',
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
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.05), // Subtle blue tint shadow
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.6),
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
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
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

  Widget _buildStatGridCard(ThemeData theme, IconData icon, String value, String label, Color? valueColor) {
     final isDark = theme.brightness == Brightness.dark;
     return Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 4, offset: const Offset(0, 2))
          ],
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
            Align(
              alignment: Alignment.topLeft,
              child: Icon(icon, size: 24, color: theme.hintColor),
            ),
            Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end, // Push to bottom
              children: [
                 Flexible(
                   child: FittedBox(
                     fit: BoxFit.scaleDown,
                     alignment: Alignment.centerLeft,
                     child: Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: valueColor ?? theme.textTheme.bodyLarge?.color)),
                   ),
                 ),
                 Text(label, 
                    style: GoogleFonts.outfit(fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis
                 ),
              ],
            ),
          )
         ],
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

  // --- Old Helpers (Keeping if needed or refactoring) ---
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
}

