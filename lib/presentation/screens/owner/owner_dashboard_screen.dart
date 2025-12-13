import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'house/house_list_screen.dart';
import 'tenant/tenant_list_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'rent/rent_controller.dart';
import '../../../../core/theme/app_theme.dart';
import 'settings/settings_screen.dart'; 
import 'reports/reports_screen.dart'; 
import 'tenant/tenant_controller.dart';
// For DashboardStats
import 'expense/expense_screens.dart';
import '../../widgets/skeleton_loader.dart';

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
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: AppTheme.primaryContainer,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.home_work_outlined), selectedIcon: Icon(Icons.home_work), label: 'Properties'),
            NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Tenants'),
            NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Reports'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
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
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rentControllerProvider.notifier).generateRentForCurrentMonth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rentAsync = ref.watch(rentControllerProvider); // For List
    final statsAsync = ref.watch(dashboardStatsProvider); // For Summary Cards

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Overview', // Changed from "This Month"
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Summary Cards (Async Stats)
                  statsAsync.when(
                    data: (stats) => Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF3F0FF), Color(0xFFE5DEFF), Color(0xFFD3E4FF)], // Ultra-soft Pastel Mesh
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(32), // More rounded (iOS style)
                        border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5), // Glass Border
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF97A7C3).withValues(alpha: 0.15), // Soft grey-blue shadow
                            blurRadius: 40,
                            spreadRadius: -10,
                            offset: const Offset(0, 20),
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.8),
                            blurRadius: 20,
                            offset: const Offset(-5, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text(
                                     'Collected (This Month)',
                                     style: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600), // Slate 500
                                   ),
                                   const SizedBox(height: 8),
                                   Text(
                                     '₹${stats.thisMonthCollected.toStringAsFixed(0)}',
                                     style: GoogleFonts.outfit(color: const Color(0xFF0F172A), fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: -1.0), // Slate 900, Bigger
                                   ),
                                 ],
                               ),
                               Container(
                                 padding: const EdgeInsets.all(16),
                                 decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                                    ]
                                 ),
                                 child: const Icon(Icons.wallet, color: Color(0xFF6366F1), size: 28), // Indigo Icon
                               )
                             ],
                           ),
                           const SizedBox(height: 28),
                           // Progress Bar
                           ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: (stats.thisMonthCollected + stats.totalPending) > 0 
                                       ? stats.thisMonthCollected / (stats.thisMonthCollected + stats.totalPending) 
                                       : 0,
                                backgroundColor: Colors.white,
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)), // Indigo Accent
                                minHeight: 12, // Thicker ios style
                              ),
                           ),
                           const SizedBox(height: 28),
                           
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               _buildMiniStat('Pending', '₹${stats.totalPending.toStringAsFixed(0)}', const Color(0xFFEF4444)), // Red for pending
                               Container(width: 1, height: 40, color: const Color(0xFFCBD5E1)), // Slate 300 Divider
                               _buildMiniStat('Revenue (Total)', '₹${stats.totalCollected.toStringAsFixed(0)}', const Color(0xFF0F172A)), // Slate 900
                             ],
                           ),
                        ],
                      ),
                    ),
                    loading: () => const SizedBox(
                      height: 240, 
                      child: Center(child: CircularProgressIndicator())
                    ),
                    error: (e, _) => SizedBox(
                      height: 100, 
                      child: Text('Error loading stats: $e', style: const TextStyle(color: Colors.red))
                    ),
                  ), // End of when

                  const SizedBox(height: 32), // Added spacing

                  // Quick Actions Grid
                  Text(
                    'Quick Actions',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4, // 4 items in a row
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75,
                    children: [
                      _buildQuickAction(context, Icons.person_add, 'Add\nTenant', () => context.push('/owner/tenants/add'), Colors.blue),
                      _buildQuickAction(context, Icons.add_home_work, 'Add\nProperty', () => context.push('/owner/houses/add'), Colors.orange),
                      _buildQuickAction(context, Icons.receipt_long, 'Add\nExpense', () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
                      }, Colors.red), 
                      _buildQuickAction(context, Icons.analytics, 'View\nReports', () {
                         // Push Reports Screen with iOS-style transition
                         Navigator.push(context, CupertinoPageRoute(builder: (_) => const ReportsScreen()));
                      }, Colors.purple), 
                    ],
                  ),

                  const SizedBox(height: 32),
                  
                  // Activity Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rent Activity',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('View All', style: GoogleFonts.outfit(color: AppTheme.primary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // List (Rent List)
          rentAsync.when(
            data: (cycles) {
              // Ensure we have fresh tenants whenever the rent list changes (e.g. after adding new one)
              final tenantsAsync = ref.watch(tenantControllerProvider);
              
              return tenantsAsync.when(
                data: (tenants) {
                  // 1. Sort: Pending first
                  final sortedCycles = List.of(cycles);
                  sortedCycles.sort((a, b) {
                     if (a.status.name == 'pending' && b.status.name != 'pending') return -1;
                     if (a.status.name != 'pending' && b.status.name == 'pending') return 1;
                     return 0;
                  });

                  // 2. Filter out orphaned cycles (where tenant has been deleted)
                  // This fixes the "Unknown" issue by hiding bills for tenants that don't exist anymore.
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
                              Icon(Icons.check_circle_outline, size: 60, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text('All caught up!', style: GoogleFonts.outfit(color: Colors.grey[500])),
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
                          // We know tenant exists because of the filter above
                          final tenant = tenants.firstWhere((t) => t.id == c.tenantId);
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Icon
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isPaid ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isPaid ? Icons.check : Icons.access_time_rounded,
                                    color: isPaid ? Colors.green : Colors.orange,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // Name & Date
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tenant.name, 
                                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Due: ${c.dueDate.toString().split(' ')[0]}',
                                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Amount & Status Card
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${c.totalDue.toStringAsFixed(0)}',
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isPaid ? const Color(0xFFC8E6C9) : const Color(0xFFFFCC80), // Light Green / Orange
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isPaid ? 'PAID' : 'PENDING',
                                        style: GoogleFonts.outfit(
                                          fontSize: 10, 
                                          fontWeight: FontWeight.bold,
                                          color: isPaid ? Colors.green[800] : Colors.orange[900],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                
                                // WhatsApp Action
                                if (!isPaid)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: IconButton(
                                      icon: const Icon(Icons.send, color: Colors.green),
                                      onPressed: () async {
                                        final message = 'Hello ${tenant.name}, your rent of ₹${c.totalDue.toStringAsFixed(0)} is pending. Please pay soon.';
                                        final encodedMessage = Uri.encodeComponent(message);
                                        
                                        // Format Phone Number
                                        String phone = tenant.phone.trim().replaceAll(RegExp(r'[^0-9+]'), '');
                                        if (!phone.startsWith('+')) {
                                          if (phone.length == 10) {
                                            phone = '+91$phone'; // Default to India
                                          } else {
                                            phone = '+$phone'; // Hope for the best if not 10 digits
                                          }
                                        }
                                        
                                        // 1. Try Native App Scheme
                                        final nativeUrl = Uri.parse('whatsapp://send?phone=$phone&text=$encodedMessage');
                                        
                                        // 2. Fallback Web URL
                                        final webUrl = Uri.parse('https://wa.me/$phone?text=$encodedMessage');

                                        try {
                                          if (await canLaunchUrl(nativeUrl)) {
                                            await launchUrl(nativeUrl);
                                          } else if (await canLaunchUrl(webUrl)) {
                                            await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                                          } else {
                                            if (context.mounted) {
                                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp. Is it installed?')));
                                            }
                                          }
                                        } catch (e) {
                                           if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error launching WhatsApp: $e')));
                                           }
                                        }
                                      },
                                    ),
                                  ),
                              ],
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
          
           const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)), // Slate 500
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.outfit(color: color, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
      ],
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08), // Lighter background
              borderRadius: BorderRadius.circular(20), // More rounded
              border: Border.all(color: color.withValues(alpha: 0.1), width: 1), // Subtle border
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              height: 1.2
            ),
          ),
        ],
      ),
    );
  }
}


