import 'package:flutter/material.dart';
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
import '../../../../domain/entities/tenant.dart';
import '../../../../domain/repositories/i_rent_repository.dart'; // For DashboardStats

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
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
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
          'RentPilot Pro',
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
                          colors: [Color(0xFF1E3A8A), Color(0xFF7E22CE)], // Deep Blue to Purple
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7E22CE).withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          )
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
                                     style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                                   ),
                                   const SizedBox(height: 4),
                                   Text(
                                     '₹${stats.thisMonthCollected.toStringAsFixed(0)}',
                                     style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                                   ),
                                 ],
                               ),
                               Container(
                                 padding: const EdgeInsets.all(12),
                                 decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(16),
                                 ),
                                 child: const Icon(Icons.wallet, color: Colors.white, size: 28),
                               )
                             ],
                           ),
                           const SizedBox(height: 24),
                           // Progress Bar
                           ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (stats.thisMonthCollected + stats.totalPending) > 0 
                                       ? stats.thisMonthCollected / (stats.thisMonthCollected + stats.totalPending) 
                                       : 0,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF69F0AE)), // Green Accent
                                minHeight: 6,
                              ),
                           ),
                           const SizedBox(height: 24),
                           
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               _buildMiniStat('Pending', '₹${stats.totalPending.toStringAsFixed(0)}', Colors.orangeAccent),
                               Container(width: 1, height: 30, color: Colors.white12),
                               _buildMiniStat('Revenue (Total)', '₹${stats.totalCollected.toStringAsFixed(0)}', Colors.white),
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
                    childAspectRatio: 0.85,
                    children: [
                      _buildQuickAction(context, Icons.person_add, 'Add\nTenant', () => context.push('/owner/tenants/add'), Colors.blue),
                      _buildQuickAction(context, Icons.add_home_work, 'Add\nProperty', () => context.push('/owner/houses/add'), Colors.orange),
                      // Mock navigation for now as explicit routes might not be set up for Expenses/Reports direct add
                      _buildQuickAction(context, Icons.receipt_long, 'Add\nExpense', () {}, Colors.red), 
                      _buildQuickAction(context, Icons.analytics, 'View\nReports', () async {
                         await ref.read(rentControllerProvider.notifier).generateRentForCurrentMonth();
                         // setState(() {}); // Optional: Only if needed to rebuild locally, typically provider updates listeners
                      }, Colors.purple), 
                    ],
                  ),

                  const SizedBox(height: 32),
                  
                  // Activity Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'This Month\'s Rent',
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
              final tenantsAsync = ref.watch(tenantControllerProvider);
              
              return tenantsAsync.when(
                data: (tenants) {
                  // 1. Join Tenant Name
                  // 2. Sort: Pending first
                  final sortedCycles = List.of(cycles);
                  sortedCycles.sort((a, b) {
                     if (a.status.name == 'pending' && b.status.name != 'pending') return -1;
                     if (a.status.name != 'pending' && b.status.name == 'pending') return 1;
                     return 0;
                  });

                  if (sortedCycles.isEmpty) {
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
                          final c = sortedCycles[index];
                          final isPaid = c.status.name == 'paid';
                          final tenant = tenants.firstWhere((t) => t.id == c.tenantId, orElse: () => Tenant(id: -1, houseId: 0, unitId: 0, tenantCode: '', name: 'Unknown', phone: '', startDate: DateTime.now(), status: TenantStatus.active));
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.05),
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
                                    color: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
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
                                        // Use generic whatsapp url scheme
                                        final url = Uri.parse('https://wa.me/${tenant.phone}?text=${Uri.encodeComponent(message)}');
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url, mode: LaunchMode.externalApplication);
                                        } else {
                                           if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp')));
                                          }
                                        }
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                        childCount: sortedCycles.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))),
                error: (e, _) => SliverToBoxAdapter(child: SizedBox.shrink()),
              ); 
            },
            error: (e, st) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
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
        Text(label.toUpperCase(), style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.outfit(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double value;
  final double total;
  final List<Color> gradientColors; // Changed from single Color
  final IconData icon;
  final bool isTotal;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.total,
    required this.gradientColors,
    required this.icon,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    // Progress calculation
    final progress = total > 0 ? value / total : 0.0;
    
    return Container(
      width: double.infinity, // Full width for vertical stack
      // height: 140, // Removed fixed height to allow content to dictate size
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.3), // Colored shadow
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween, // Removed
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          
          const SizedBox(height: 16), // Added spacing since spaceBetween is removed

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${value.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
               if (!isTotal)
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(10),
                ),
               if (isTotal)
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   decoration: BoxDecoration(
                     color: Colors.white.withOpacity(0.2),
                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: Text(
                     'Lifetime',
                     style: GoogleFonts.outfit(fontSize: 10, color: Colors.white),
                   ),
                 )
            ],
          ),
        ],
      ),
    );
  }
}
