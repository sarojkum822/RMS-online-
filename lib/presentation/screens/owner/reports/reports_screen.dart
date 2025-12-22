import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Added for iOS style widgets
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/rent/domain/entities/rent_cycle.dart';
import 'reports_controller.dart';
import 'reports_data.dart';
import '../settings/owner_controller.dart'; 
import '../../../widgets/skeleton_loader.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/services/pdf_generator_service.dart'; // Import
import '../../../../domain/entities/report_range.dart'; // Import
import 'package:printing/printing.dart'; // Import

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  bool _isExporting = false;
  ReportRange _selectedRange = ReportRange.thisMonth();

  Future<void> _handleExport(ReportsData data) async {
    setState(() => _isExporting = true);
    try {
      final owner = ref.read(ownerControllerProvider).value;
      final ownerName = owner?.name ?? 'Portfolio Owner';
      
      final pdfBytes = await PdfGeneratorService().generateAuditReport(
        ownerName: ownerName,
        data: data,
        range: _selectedRange,
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
    final reportsAsync = ref.watch(reportsControllerProvider(_selectedRange));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final owner = ref.watch(ownerControllerProvider).value;
    final plan = owner?.subscriptionPlan ?? 'free';

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
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 18),
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
            ],
          ),
          
          // 2. Date Range Selector
          SliverToBoxAdapter(
            child: _buildDateRangePicker(isDark, theme),
          ),

          // 3. Content
          SliverToBoxAdapter(
            child: reportsAsync.when(
              data: (data) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Financial Summary Section (Large Card with MoM)
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

                    // Payment Methods Pie Chart (NEW)
                    if (data.paymentMethods.isNotEmpty) ...[
                      _buildGroupedSectionHeader('reports.payment_methods'.tr().toUpperCase()),
                      _buildChartContainer(
                        child: _buildPaymentMethodsPie(data, isDark, theme),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Property Performance (NEW)
                    if (data.propertyPerformance.isNotEmpty) ...[
                      _buildGroupedSectionHeader('PROPERTY PERFORMANCE'),
                      _buildPropertyPerformance(data.propertyPerformance, isDark, theme),
                      const SizedBox(height: 32),
                    ],

                    // Performance Charts
                    _buildGroupedSectionHeader('REVENUE TREND'),
                    _buildChartContainer(
                      child: _buildRevenueBarChart(data, isDark, theme),
                    ),
                    const SizedBox(height: 32),

                    // Expense Trend (NEW)
                    _buildGroupedSectionHeader('EXPENSE TREND'),
                    _buildChartContainer(
                      child: _buildExpenseBarChart(data, isDark, theme),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '₹${CurrencyUtils.formatNumber(data.totalCollected)}', 
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white : const Color(0xFF0F172A), 
                fontSize: 32, 
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              )
            ),
          ),
          // MoM Indicator
          if (data.previousMonthCollected > 0) ...[
            const SizedBox(height: 8),
            Builder(builder: (context) {
              final change = data.totalCollected - data.previousMonthCollected;
              final percentChange = (change / data.previousMonthCollected * 100).abs();
              final isUp = change >= 0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isUp ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUp ? CupertinoIcons.arrow_up : CupertinoIcons.arrow_down,
                      size: 12,
                      color: isUp ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${percentChange.toStringAsFixed(1)}% vs last month',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isUp ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
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
                Expanded(child: _buildMetricColumn('Expected', '₹${CurrencyUtils.formatNumber(data.totalExpected)}', isDark)),
                _buildMetricDivider(isDark),
                Expanded(child: _buildMetricColumn('Pending', '₹${CurrencyUtils.formatNumber(data.totalPending)}', isDark)),
                _buildMetricDivider(isDark),
                Expanded(child: _buildMetricColumn('Expenses', '₹${CurrencyUtils.formatNumber(data.totalExpenses)}', isDark)),
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

  // NEW: Payment Methods Pie Chart
  Widget _buildPaymentMethodsPie(ReportsData data, bool isDark, ThemeData theme) {
    final methods = data.paymentMethods.entries.toList();
    if (methods.isEmpty) {
      return Center(child: Text('No payment data', style: GoogleFonts.outfit(color: Colors.grey)));
    }
    
    final colors = [
      const Color(0xFF2563EB), // Blue - UPI
      const Color(0xFF10B981), // Green - Cash
      const Color(0xFFF59E0B), // Amber - Bank
      const Color(0xFF8B5CF6), // Purple - Cheque
      const Color(0xFF6B7280), // Grey - Other
    ];
    
    IconData getIcon(String method) {
      switch (method.toLowerCase()) {
        case 'upi': return CupertinoIcons.device_phone_portrait;
        case 'cash': return CupertinoIcons.money_dollar;
        case 'bank': case 'bank_transfer': return CupertinoIcons.building_2_fill;
        case 'cheque': return CupertinoIcons.doc_text;
        default: return CupertinoIcons.creditcard;
      }
    }
    
    final total = methods.fold(0.0, (sum, e) => sum + e.value);
    
    return Row(
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 35,
              sections: methods.asMap().entries.map((e) {
                final percentage = total > 0 ? (e.value.value / total * 100) : 0;
                return PieChartSectionData(
                  color: colors[e.key % colors.length],
                  value: e.value.value,
                  title: '${percentage.toStringAsFixed(0)}%',
                  titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  radius: 25,
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: methods.asMap().entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(getIcon(e.value.key), size: 16, color: colors[e.key % colors.length]),
                    const SizedBox(width: 8),
                    Expanded(child: Text(e.value.key.toUpperCase(), style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('₹${CurrencyUtils.formatNumber(e.value.value)}', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: colors[e.key % colors.length])),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // NEW: Property Performance Cards
  Widget _buildPropertyPerformance(List<PropertyRevenue> properties, bool isDark, ThemeData theme) {
    final sorted = List<PropertyRevenue>.from(properties)..sort((a, b) => b.revenue.compareTo(a.revenue));
    
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sorted.length,
        itemBuilder: (context, index) {
          final p = sorted[index];
          final isTop = index == 0;
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isTop ? const Color(0xFF2563EB).withOpacity(0.3) : Colors.transparent),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    if (isTop) ...[
                      const Icon(CupertinoIcons.star_fill, size: 12, color: Color(0xFF2563EB)),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(p.houseName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('₹${CurrencyUtils.formatNumber(p.revenue)}', style: GoogleFonts.outfit(color: const Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // NEW: Expense Bar Chart
  Widget _buildExpenseBarChart(ReportsData data, bool isDark, ThemeData theme) {
    final trend = data.expenseTrend;
    if (trend.isEmpty) {
      return Center(child: Text('No expense data', style: GoogleFonts.outfit(color: Colors.grey)));
    }
    
    final maxY = trend.map((e) => e.collected).fold(0.0, (p, c) => p > c ? p : c) * 1.2;
    
    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: maxY > 0 ? maxY : 10000,
          barGroups: trend.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.collected,
                  color: Colors.red.shade400,
                  width: 12,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY > 0 ? maxY : 10000,
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
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
                  child: Text(trend[val.toInt()].monthLabel, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ),
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }

  Widget _buildDateRangePicker(bool isDark, ThemeData theme) {
    final ranges = [
      ReportRange.thisMonth(),
      ReportRange.lastMonth(),
      ReportRange.last3Months(),
      ReportRange.last6Months(),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reporting Period', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: theme.hintColor)),
                TextButton.icon(
                  onPressed: () => _selectCustomRange(context),
                  icon: const Icon(CupertinoIcons.calendar, size: 14),
                  label: Text('Custom', style: GoogleFonts.outfit(fontSize: 13)),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ...ranges.map((range) {
                  final isSelected = _selectedRange.label == range.label;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(range.label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedRange = range);
                      },
                      backgroundColor: isDark ? Colors.white10 : Colors.white,
                      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                      checkmarkColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? theme.colorScheme.primary : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)))),
                    ),
                  );
                }),
              ],
            ),
          ),
          if (_selectedRange.label != ReportRange.thisMonth().label &&
              _selectedRange.label != ReportRange.lastMonth().label &&
              _selectedRange.label != ReportRange.last3Months().label &&
              _selectedRange.label != ReportRange.last6Months().label)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: Chip(
                label: Text('Custom: ${_selectedRange.label}', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold)),
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                side: BorderSide.none,
                deleteIcon: const Icon(Icons.close, size: 12),
                onDeleted: () => setState(() => _selectedRange = ReportRange.thisMonth()),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _selectCustomRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _selectedRange.start, end: _selectedRange.end),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedRange = ReportRange.custom(picked.start, picked.end);
      });
    }
  }
}
