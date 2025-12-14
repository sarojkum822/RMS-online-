import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/tenant.dart';
import '../../../domain/entities/rent_cycle.dart';
import 'house/house_list_screen.dart';
import 'tenant/tenant_list_screen.dart';
import 'tenant/tenant_list_screen.dart';
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
    final rentAsync = ref.watch(rentControllerProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: null,
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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Welcome back,',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    'Property Manager',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.headlineLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats Cards
                    statsAsync.when(
                      data: (stats) => Column(
                        children: [
                          // Main Blue Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Monthly Collected',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.trending_up, color: Colors.white, size: 20),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  '₹${stats.thisMonthCollected.toStringAsFixed(0)}',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '+12% from last month',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Row of Secondary Cards
                          Row(
                            children: [
                              Expanded(child: _buildDetailCard(
                                context, 
                                'Total Revenue', 
                                '₹${stats.totalCollected.toStringAsFixed(0)}', 
                                Icons.currency_rupee, // Changed from attach_money for Indian context if needed, but user mockup had $ or Rs. I'll use rupee per value.
                                Colors.blue.shade50,
                                theme.colorScheme.primary
                              )),
                              const SizedBox(width: 16),
                              Expanded(child: _buildDetailCard(
                                context, 
                                'Pending', 
                                '₹${stats.totalPending.toStringAsFixed(0)}', 
                                Icons.access_time, 
                                const Color(0xFFFFF7ED), // Orange 50
                                const Color(0xFFEA580C)  // Orange 600
                              )),
                            ],
                          ),
                        ],
                      ),
                      loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                      error: (e, _) => Text('Error: $e'),
                    ),

                    const SizedBox(height: 40),

                    // Quick Actions (Clean Icons)
                    Text(
                      'Quick Actions',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildQuickAction(context, Icons.person_add_alt_1_outlined, 'Add Tenant', () => context.push('/owner/tenants/add'))),
                        const SizedBox(width: 8),
                        Expanded(child: _buildQuickAction(context, Icons.add_home_work_outlined, 'Add Property', () => context.push('/owner/houses/add'))),
                        const SizedBox(width: 8),
                        Expanded(child: _buildQuickAction(context, Icons.receipt_long_outlined, 'Add Expense', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())))),
                        const SizedBox(width: 8),
                        Expanded(child: _buildQuickAction(context, Icons.analytics_outlined, 'Reports', () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const ReportsScreen())))),
                      ],
                    ),

                    const SizedBox(height: 40),
                    
                    // Activity Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rent Activity',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text('View All', style: GoogleFonts.outfit(color: theme.colorScheme.primary)),
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
                                Text('All caught up!', style: GoogleFonts.outfit(color: theme.disabledColor)),
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
                            
                            // Helper to share via WhatsApp
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
                                 // Clean phone number: remove non-digits
                                 String phone = tenant.phone.replaceAll(RegExp(r'\D'), '');
                                 // Assume Indian number if 10 digits
                                 if (phone.length == 10) {
                                   phone = '91$phone';
                                 }
                                 
                                 final url = Uri.parse("whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}");
                                 if (await canLaunchUrl(url)) {
                                   await launchUrl(url, mode: LaunchMode.externalApplication);
                                 } else {
                                    // Fallback if generic check fails (common on Android 11+ or Emulators)
                                    // Launch standard share sheet
                                    if(context.mounted) {
                                       ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp not detected. Opening options...'), duration: Duration(seconds: 2)));
                                    }
                                    await Share.share(message);
                                 }
                              } catch (e) {
                                 if(context.mounted) {
                                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch WhatsApp: $e')));
                                 }
                              }
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: isPastDue 
                                    ? Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3), width: 1)
                                    : (isDark ? Border.all(color: Colors.white12) : null),
                                boxShadow: isDark || isPastDue ? [] : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Simple Status Dot
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: isPaid ? Colors.green : (isPastDue ? theme.colorScheme.error : Colors.orange),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tenant.name, 
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w600, 
                                            fontSize: 16,
                                            color: theme.textTheme.bodyLarge?.color
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Show Month regardless of status, but color it red if overdue
                                        Row(
                                          children: [
                                            Text(
                                              DateFormat('MMMM yyyy').format(cycleDate),
                                              style: GoogleFonts.outfit(
                                                fontSize: 12, 
                                                color: isPastDue ? theme.colorScheme.error : theme.textTheme.bodySmall?.color,
                                                fontWeight: isPastDue ? FontWeight.bold : FontWeight.normal
                                              ),
                                            ),
                                            if (c.electricAmount > 0) ...[
                                              Container(
                                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                                width: 4, height: 4, 
                                                decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle)
                                              ),
                                              Text(
                                                'Elec: ₹${c.electricAmount.toStringAsFixed(0)}',
                                                style: GoogleFonts.outfit(fontSize: 11, color: theme.textTheme.bodySmall?.color),
                                              )
                                            ]
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₹${c.totalDue.toStringAsFixed(0)}',
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold, 
                                          fontSize: 16, 
                                          color: isPastDue ? theme.colorScheme.error : theme.textTheme.bodyLarge?.color
                                        ),
                                      ),
                                      const SizedBox(height: 8), // More space
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            isPaid ? 'Paid' : (isPastDue ? 'Overdue' : 'Due'),
                                            style: GoogleFonts.outfit(
                                               fontSize: 12,
                                               fontWeight: FontWeight.w500,
                                               color: isPaid ? Colors.green : (isPastDue ? theme.colorScheme.error : Colors.orange)
                                            ),
                                          ),
                                          if (!isPaid) ...[
                                             const SizedBox(width: 12),
                                             InkWell(
                                               onTap: () => _shareRentDetails(tenant, c),
                                               borderRadius: BorderRadius.circular(20),
                                               child: Container(
                                                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                 decoration: BoxDecoration(
                                                   color: const Color(0xFF25D366), // WhatsApp Green
                                                   borderRadius: BorderRadius.circular(20),
                                                 ),
                                                 child: Row(
                                                   mainAxisSize: MainAxisSize.min,
                                                   children: [
                                                     const Icon(Icons.share, size: 14, color: Colors.white),
                                                     const SizedBox(width: 4),
                                                     Text('Share', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                                                   ],
                                                 ),
                                               ),
                                             )
                                          ]
                                        ],
                                      ),
                                    ],
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

  Widget _buildDetailCard(BuildContext context, String title, String value, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
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

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
               color: theme.cardColor, // Card background
               shape: BoxShape.circle,
               border: theme.brightness == Brightness.dark ? Border.all(color: Colors.white10) : null,
               boxShadow: theme.brightness == Brightness.dark ? [] : [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0,4))
               ],
             ),
             child: Icon(icon, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodyMedium?.color,
              height: 1.2
            ),
          ),
        ],
      ),
    );
  }
}


