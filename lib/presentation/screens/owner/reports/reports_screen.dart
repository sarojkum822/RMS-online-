import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Added for iOS style widgets
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/rent/domain/entities/rent_cycle.dart';
import 'reports_controller.dart';
import '../settings/owner_controller.dart'; 
import '../../../widgets/skeleton_loader.dart';
import '../../../providers/data_providers.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/services/pdf_generator_service.dart'; // Import
import 'package:printing/printing.dart'; // Import
import '../../maintenance/maintenance_controller.dart';
import '../../maintenance/maintenance_reports_screen.dart';
import '../../../../domain/entities/maintenance_request.dart';
import 'package:flutter/services.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  bool _isExporting = false;

  Future<void> _handleExport(ReportsData data) async {
    setState(() => _isExporting = true);
    try {
      final owner = ref.read(ownerControllerProvider).value;
      final ownerName = owner?.name ?? 'Portfolio Owner';
      
      final pdfBytes = await PdfGeneratorService().generateAuditReport(
        ownerName: ownerName,
        data: data,
      );

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'KirayaBook_Audit_${DateFormat('MMM_yyyy').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportsControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final ownerAsync = ref.watch(ownerControllerProvider);
    final currencySymbol = CurrencyUtils.getSymbol(ownerAsync.value?.currency);

    // Watch Maintenance Requests for Badge
    final user = ref.watch(userSessionServiceProvider).currentUser;
    final maintenanceAsync = user != null ? ref.watch(ownerMaintenanceProvider(user.uid)) : const AsyncValue<List<MaintenanceRequest>>.loading();
    final pendingMaintenanceCount = maintenanceAsync.valueOrNull?.where((r) => r.status == MaintenanceStatus.pending).length ?? 0;

    final owner = ownerAsync.value; // Re-derive owner from ownerAsync
    final plan = owner?.subscriptionPlan ?? 'free'; // Re-derive plan from owner

    if (plan == 'free') {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF000000) : Colors.white,
        appBar: AppBar(
          title: Text('reports.title'.tr(), 
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold, 
              fontSize: 24,
              color: theme.textTheme.titleLarge?.color
            )
          ),
          backgroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          iconTheme: theme.iconTheme,
        ),
        body: Center(
          child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
                Icon(Icons.lock_outline, size: 64, color: theme.disabledColor),
                const SizedBox(height: 16),
                Text(
                  'Premium Feature',
                  style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)
                ),
                const SizedBox(height: 8),
                Text(
                  'Upgrade to Pro to access detailed reports.',
                  style: GoogleFonts.outfit(color: theme.hintColor),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)
                  ),
                  onPressed: () => context.push('/owner/settings/subscription'), 
                  child: const Text('Upgrade Now'),
                )
             ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7), // iOS Background Colors
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Premium iOS App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: isDark ? Colors.black : Colors.white,
            centerTitle: false,
            title: Text(
              'reports.title'.tr(),
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            actions: [
              if (_isExporting)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: CupertinoActivityIndicator(),
                )
              else
                reportsAsync.when(
                  data: (data) => IconButton(
                    icon: const Icon(CupertinoIcons.share, size: 18),
                    onPressed: () => _handleExport(data),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
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
                },
                child: Container(
                   margin: const EdgeInsets.only(right: 20, left: 8),
                   padding: const EdgeInsets.all(6),
                   decoration: BoxDecoration(
                     color: theme.colorScheme.primary,
                     shape: BoxShape.circle,
                   ),
                   child: const Icon(Icons.person, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),

          // 2. Content
          SliverToBoxAdapter(
            child: reportsAsync.when(
              data: (data) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Financial Summary Section (Large Card)
                    _buildFinancialCarousel(data, isDark, theme),
                    const SizedBox(height: 24),

                    // Navigation to Expenses (Grouped Tile)
                    _buildGroupedSectionHeader('OPERATIONS'),
                    _buildGroupedTile(
                      label: 'reports.expenses'.tr(),
                      value: '₹${CurrencyUtils.formatNumber(data.totalExpenses)}',
                      icon: CupertinoIcons.minus_circle_fill,
                      iconColor: Colors.red,
                      onTap: () => context.push('/owner/expenses'),
                    ),
                    _buildGroupedTile(
                      label: 'reports.net_profit'.tr(),
                      value: '₹${CurrencyUtils.formatNumber(data.netProfit)}',
                      icon: CupertinoIcons.checkmark_circle_fill,
                      iconColor: Colors.green,
                      isLast: true,
                    ),
                    const SizedBox(height: 32),

                    // Performance Charts
                    _buildGroupedSectionHeader('REVENUE TREND'),
                    _buildChartContainer(
                      child: _buildRevenueBarChart(data, isDark, theme),
                    ),
                    const SizedBox(height: 32),

                    _buildGroupedSectionHeader('OCCUPANCY HEALTH'),
                    _buildChartContainer(
                      child: _buildOccupancyPie(data, isDark, theme),
                    ),
                    const SizedBox(height: 32),

                    // Top Defaulters (Horizontal Scroll)
                    if (data.topDefaulters.isNotEmpty) ...[
                      _buildGroupedSectionHeader('URGENT PENDINGS'),
                      _buildDefaultersList(data.topDefaulters, isDark, theme),
                      const SizedBox(height: 32),
                    ],

                    // Recent Activity (Grouped List)
                    _buildGroupedSectionHeader('RECENT ACTIVITY'),
                    _buildRecentActivityList(data.recentPayments, isDark, theme),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
              loading: () => const ReportsSkeleton(),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildGroupedTile({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: isLast 
            ? const BorderRadius.vertical(bottom: Radius.circular(12)) 
            : (onTap != null ? const BorderRadius.vertical(top: Radius.circular(12)) : BorderRadius.zero), // Adjusted for single item or first item
          border: isLast ? null : Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05))),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.normal)),
            const Spacer(),
            Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(CupertinoIcons.chevron_right, size: 14, color: Colors.grey),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCarousel(ReportsData data, bool isDark, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.graph_square_fill, color: Color(0xFF2563EB), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'CURRENT MONTHLY CASHFLOW', 
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white54 : const Color(0xFF64748B), 
                  fontSize: 11, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                )
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '₹${CurrencyUtils.formatNumber(data.totalCollected)}', 
            style: GoogleFonts.outfit(
              color: isDark ? Colors.white : const Color(0xFF0F172A), 
              fontSize: 32, 
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            )
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricColumn('Expected', '₹${CurrencyUtils.formatNumber(data.totalExpected)}', isDark),
                _buildMetricDivider(isDark),
                _buildMetricColumn('Pending', '₹${CurrencyUtils.formatNumber(data.totalPending)}', isDark),
                _buildMetricDivider(isDark),
                _buildMetricColumn('Expenses', '₹${CurrencyUtils.formatNumber(data.totalExpenses)}', isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricDivider(bool isDark) {
    return Container(
      height: 30,
      width: 1,
      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
    );
  }

  Widget _buildMetricColumn(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label, 
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white38 : Colors.grey.shade600, 
            fontSize: 10, 
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          )
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value, 
            style: GoogleFonts.outfit(
              color: isDark ? Colors.white : const Color(0xFF0F172A), 
              fontSize: 12, 
              fontWeight: FontWeight.bold
            )
          ),
        ),
      ],
    );
  }

  Widget _buildChartContainer({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _buildRevenueBarChart(ReportsData data, bool isDark, ThemeData theme) {
    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: data.revenueTrend.map((e) => e.collected + e.pending).fold(0.0, (p, c) => p > c ? p : c) * 1.2,
          barGroups: data.revenueTrend.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.collected,
                  color: const Color(0xFF2563EB),
                  width: 12,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: e.value.collected + e.value.pending,
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withOpacity(0.03),
                  ),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, _) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(data.revenueTrend[val.toInt()].monthLabel, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ),
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildOccupancyPie(ReportsData data, bool isDark, ThemeData theme) {
    return Row(
      children: [
        SizedBox(
          height: 90,
          width: 90,
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(color: const Color(0xFF2563EB), value: data.occupiedUnits.toDouble(), title: '', radius: 10),
                PieChartSectionData(color: isDark ? Colors.white10 : Colors.black12, value: data.vacantUnits.toDouble(), title: '', radius: 10),
              ],
            ),
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegend('Occupied', '${data.occupiedUnits}', const Color(0xFF2563EB)),
              const SizedBox(height: 8),
              _buildLegend('Vacant', '${data.vacantUnits}', Colors.grey),
              const Divider(height: 20),
              Text('${(data.totalUnits > 0 ? (data.occupiedUnits/data.totalUnits*100) : 0).toStringAsFixed(0)}% OCCUPANCY', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(String label, String value, Color color) {
    return Row(
      children: [
        CircleAvatar(radius: 3, backgroundColor: color),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDefaultersList(List<TenantDue> defaulters, bool isDark, ThemeData theme) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: defaulters.length,
        itemBuilder: (context, index) {
          final d = defaulters[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(d.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
                const SizedBox(height: 4),
                Text('₹${CurrencyUtils.formatNumber(d.amount)} due', style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentActivityList(List<Payment> payments, bool isDark, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: payments.length,
        separatorBuilder: (_, __) => Divider(height: 1, indent: 56, color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
        itemBuilder: (context, index) {
          final p = payments[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.1),
              child: const Icon(CupertinoIcons.arrow_down, color: Colors.green, size: 18),
            ),
            title: Text('Payment Received', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.normal)),
            subtitle: Text(DateFormat('dd MMM').format(p.date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
            trailing: Text('+₹${CurrencyUtils.formatNumber(p.amount)}', style: GoogleFonts.outfit(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
          );
        },
      ),
    );
  }
}
