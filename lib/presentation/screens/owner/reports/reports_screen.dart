import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart'; // NEW: For context.push
import 'reports_controller.dart';
import '../settings/owner_controller.dart'; 
import '../expense/expense_screens.dart'; 
import '../../../widgets/skeleton_loader.dart';
import '../../../widgets/fade_in_up.dart';
import 'package:easy_localization/easy_localization.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final textColorPrimary = theme.textTheme.titleLarge?.color;
    final textColorSecondary = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('reports.title'.tr(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textColorPrimary)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.iconTheme.color),
            onPressed: () => ref.invalidate(reportsControllerProvider),
          )
        ],
      ),
      body: Builder(
        builder: (context) {
          final owner = ref.watch(ownerControllerProvider).value;
          final plan = owner?.subscriptionPlan ?? 'free';

          if (plan == 'free') {
            return Center(
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
            );
          }

          return reportsAsync.when(
            data: (data) => SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
               // 1. Financial Overview (Gradient - Keeps White Text)
               FadeInUp(
                 delay: const Duration(milliseconds: 100),
                 child: Container(
                   padding: const EdgeInsets.all(24),
                   decoration: BoxDecoration(
                     gradient: const LinearGradient(
                       begin: Alignment.topLeft, 
                       end: Alignment.bottomRight,
                       colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                     ),
                     borderRadius: BorderRadius.circular(24),
                     boxShadow: [
                       BoxShadow(
                         color: const Color(0xFF2563EB).withOpacity(0.3), 
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
                           Text(
                             'reports.financial_overview'.tr(), 
                             style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w600),
                           ),
                           Container(
                             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                             decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                             child: Text('reports.this_month'.tr(), style: GoogleFonts.outfit(color: Colors.white, fontSize: 10)),
                           )
                         ],
                       ),
                       const SizedBox(height: 24),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           _buildStat(context, 'reports.collected'.tr(), data.totalCollected, const Color(0xFF69F0AE)), 
                           Container(width: 1, height: 40, color: Colors.white12),
                           _buildStat(context, 'reports.pending'.tr(), data.totalPending, const Color(0xFFFFAB40)), 
                           Container(width: 1, height: 40, color: Colors.white12),
                           _buildStat(context, 'reports.total'.tr(), data.totalExpected, Colors.white),
                         ],
                       ),
                     ],
                   ),
                 ),
               ),
               
               const SizedBox(height: 24),
                
                // 1.5 Expenses & Net Profit
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseListScreen())),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: isDark ? Border.all(color: Colors.white10) : null,
                              boxShadow: isDark ? [] : [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('reports.expenses'.tr(), style: GoogleFonts.outfit(color: textColorSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
                                    Icon(Icons.arrow_forward_ios, size: 12, color: textColorSecondary),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('₹${data.totalExpenses.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: isDark ? Border.all(color: Colors.white10) : null,
                            boxShadow: isDark ? [] : [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('reports.net_profit'.tr(), style: GoogleFonts.outfit(color: textColorSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('₹${data.netProfit.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF00C853))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

               const SizedBox(height: 32),

               // 2. Revenue Trend
               FadeInUp(
                 delay: const Duration(milliseconds: 300),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text('reports.revenue_trend'.tr(), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColorPrimary)),
                     const SizedBox(height: 16),
                      RepaintBoundary(
                        child: Container(
                         height: 300,
                         padding: const EdgeInsets.all(24),
                         decoration: BoxDecoration(
                           color: theme.cardColor,
                           borderRadius: BorderRadius.circular(24),
                           border: isDark ? Border.all(color: Colors.white10) : null,
                           boxShadow: isDark ? [] : [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                         ),
                         child: BarChart(
                         BarChartData(
                           alignment: BarChartAlignment.spaceAround,
                           maxY: data.revenueTrend.map((e) => e.collected + e.pending).fold(0.0, (p, c) => p > c ? p : c) * 1.2,
                           barTouchData: BarTouchData(
                             touchTooltipData: BarTouchTooltipData(
                               getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final stats = data.revenueTrend[group.x.toInt()];
                                  return BarTooltipItem(
                                    '${stats.monthLabel}\n',
                                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    children: [
                                      TextSpan(
                                        text: '₹${stats.collected.toStringAsFixed(0)}',
                                        style: const TextStyle(color: Color(0xFF69F0AE), fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  );
                               },
                             ),
                           ),
                           titlesData: FlTitlesData(
                             show: true,
                             bottomTitles: AxisTitles(
                               sideTitles: SideTitles(
                                 showTitles: true,
                                 getTitlesWidget: (double value, TitleMeta meta) {
                                   if (value.toInt() >= 0 && value.toInt() < data.revenueTrend.length) {
                                     return Padding(
                                       padding: const EdgeInsets.only(top: 8.0),
                                       child: Text(
                                         data.revenueTrend[value.toInt()].monthLabel,
                                         style: GoogleFonts.outfit(color: textColorSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                                       ),
                                     );
                                   }
                                   return const SizedBox.shrink();
                                 },
                                 reservedSize: 30,
                               ),
                             ),
                             leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                             topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                             rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                           ),
                           gridData: const FlGridData(show: false),
                           borderData: FlBorderData(show: false),
                           barGroups: data.revenueTrend.asMap().entries.map((e) {
                             final index = e.key;
                             final stats = e.value;
                             return BarChartGroupData(
                               x: index,
                               barRods: [
                                 BarChartRodData(
                                   toY: stats.collected,
                                   gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF60A5FA)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                                   width: 16,
                                   borderRadius: BorderRadius.circular(4),
                                   backDrawRodData: BackgroundBarChartRodData(
                                     show: true,
                                     toY: (stats.collected + stats.pending) == 0 ? 10 : (stats.collected + stats.pending), 
                                     color: isDark ? Colors.grey[800] : Colors.grey[100],
                                   ),
                                 ),
                               ],
                             );
                           }).toList(),
                         ),
                       ),
                      ),
                     ),
                   ],
                 ),
               ),

               const SizedBox(height: 32),
               
               // 3. Occupancy Chart
               FadeInUp(
                 delay: const Duration(milliseconds: 400),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text('reports.occupancy_rate'.tr(), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColorPrimary)),
                     const SizedBox(height: 16),
                      RepaintBoundary(
                        child: Container(
                         padding: const EdgeInsets.all(24),
                         decoration: BoxDecoration(
                           color: theme.cardColor,
                           borderRadius: BorderRadius.circular(24),
                           border: isDark ? Border.all(color: Colors.white10) : null,
                           boxShadow: isDark ? [] : [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                         ),
                         child: Row(
                         children: [
                           SizedBox(
                             height: 160,
                             width: 160,
                             child: Stack(
                               children: [
                                 PieChart(
                                   PieChartData(
                                     sectionsSpace: 0,
                                     centerSpaceRadius: 60,
                                     sections: [
                                       PieChartSectionData(color: const Color(0xFF2563EB), value: data.occupiedUnits.toDouble(), title: '', radius: 20),
                                       PieChartSectionData(color: isDark ? Colors.grey[800] : Colors.grey[200], value: data.vacantUnits.toDouble(), title: '', radius: 15),
                                     ],
                                   ),
                                 ),
                                 Center(
                                   child: Column(
                                     mainAxisSize: MainAxisSize.min,
                                     children: [
                                       Text('${(data.totalUnits > 0 ? (data.occupiedUnits / data.totalUnits * 100) : 0).toStringAsFixed(0)}%', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.blue[300] : const Color(0xFF1E3A8A))),
                                       Text('reports.occupancy_rate'.tr(), style: GoogleFonts.outfit(fontSize: 10, color: textColorSecondary)),
                                     ],
                                   ),
                                 ),
                               ],
                             ),
                           ),
                           const SizedBox(width: 40),
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 _buildLegendItem(color: const Color(0xFF2563EB), label: 'reports.occupied'.tr(), value: '${data.occupiedUnits} Units', theme: theme),
                                 const SizedBox(height: 16),
                                 _buildLegendItem(color: isDark ? Colors.grey[600]! : Colors.grey[400]!, label: 'reports.vacant'.tr(), value: '${data.vacantUnits} Units', theme: theme),
                                 const SizedBox(height: 24),
                                 Text('${'reports.total_units'.tr()}: ${data.totalUnits}', style: GoogleFonts.outfit(color: textColorSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                               ],
                             ),
                           ),
                         ],
                       ),
                     ),
                    ),
                   ],
                 ),
               ), 
               const SizedBox(height: 32),

                // 3.5 Payment Methods
                if (data.paymentMethods.isNotEmpty) ...[
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('reports.payment_methods'.tr(), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColorPrimary)),
                        const SizedBox(height: 16),
                        Container(
                          height: 200,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20), border: isDark ? Border.all(color: Colors.white10) : null, boxShadow: isDark ? [] : [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)]),
                          child: Row(
                             children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: PieChart(
                                    PieChartData(
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 40,
                                      sections: data.paymentMethods.entries.map((e) {
                                         final index = data.paymentMethods.keys.toList().indexOf(e.key);
                                          final color = [const Color(0xFF2563EB), const Color(0xFF00C853), const Color(0xFFFFAB40), const Color(0xFF60A5FA)][index % 4];
                                         return PieChartSectionData(color: color, value: e.value, title: '${(e.value / (data.totalCollected > 0 ? data.totalCollected : 1) * 100).toInt()}%', radius: 40, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold));
                                      }).toList(),
                                    )
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: data.paymentMethods.entries.map((e) {
                                       final index = data.paymentMethods.keys.toList().indexOf(e.key);
                                       final color = [const Color(0xFF2563EB), const Color(0xFF00C853), const Color(0xFFFFAB40), const Color(0xFF60A5FA)][index % 4];
                                       return Padding(
                                         padding: const EdgeInsets.symmetric(vertical: 4),
                                         child: Row(
                                           children: [
                                             CircleAvatar(radius: 4, backgroundColor: color),
                                             const SizedBox(width: 8),
                                             Expanded(child: Text(e.key, style: GoogleFonts.outfit(color: textColorSecondary, fontSize: 12))),
                                             Text('₹${e.value.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: textColorPrimary)),
                                           ],
                                         ),
                                       );
                                    }).toList(),
                                  ),
                                )
                             ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],

                // 3.6 Top Defaulters
                if (data.topDefaulters.isNotEmpty) ...[
                   FadeInUp(
                     delay: const Duration(milliseconds: 600),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text('reports.top_defaulters'.tr(), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColorPrimary)),
                         const SizedBox(height: 16),
                         SizedBox(
                           height: 140,
                           child: ListView.separated(
                             scrollDirection: Axis.horizontal,
                             itemCount: data.topDefaulters.length,
                             separatorBuilder: (_,__) => const SizedBox(width: 12),
                             itemBuilder: (context, index) {
                               final d = data.topDefaulters[index];
                               return Container(
                                 width: 140,
                                 padding: const EdgeInsets.all(16),
                                 decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red.withOpacity(0.1))),
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     CircleAvatar(radius: 20, backgroundColor: Colors.red.withOpacity(0.1), child: Text(d.name.isNotEmpty ? d.name[0] : '?', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                                     const Spacer(),
                                      Text(d.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textColorPrimary)),
                                     Text('Due: ₹${d.amount.toStringAsFixed(0)}', style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.bold)),
                                   ],
                                 ),
                               );
                             },
                           ),
                         ),
                         const SizedBox(height: 32),
                       ],
                     ),
                   ),
                ],
                
               // 4. Styled Recent Activity
               FadeInUp(
                 delay: const Duration(milliseconds: 700),
                 child: Column(
                   children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text('reports.recent_activity'.tr(), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColorPrimary)),
                         Text('reports.view_all'.tr(), style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB))),
                       ],
                     ),
                     const SizedBox(height: 16),
                     
                     if(data.recentPayments.isEmpty)
                       Center(
                         child: Padding(
                           padding: const EdgeInsets.symmetric(vertical: 40), 
                           child: Text('reports.no_activity'.tr(), style: GoogleFonts.outfit(color: textColorSecondary)),
                         ),
                       ),
                       
                     ListView.separated(
                       shrinkWrap: true,
                       physics: const NeverScrollableScrollPhysics(),
                       itemCount: data.recentPayments.length,
                       separatorBuilder: (context, index) => const SizedBox(height: 12),
                       itemBuilder: (context, index) {
                         final p = data.recentPayments[index];
                         return Container(
                           decoration: BoxDecoration(
                             color: theme.cardColor, 
                             borderRadius: BorderRadius.circular(16),
                             border: isDark ? Border.all(color: Colors.white10) : null,
                             boxShadow: isDark ? [] : [BoxShadow(color: Colors.grey.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
                           ),
                           child: ListTile(
                             contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                             leading: Container(
                               padding: const EdgeInsets.all(10),
                               decoration: BoxDecoration(
                                 color: const Color(0xFF69F0AE).withOpacity(0.15),
                                 shape: BoxShape.circle,
                               ),
                               child: const Icon(Icons.arrow_downward_rounded, color: Color(0xFF00C853), size: 20),
                             ),
                             title: Text(
                               'reports.payment_received'.tr(), 
                               style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15, color: textColorPrimary),
                             ),
                             subtitle: Padding(
                               padding: const EdgeInsets.only(top: 4),
                               child: Text(
                                 DateFormat('dd MMM, hh:mm a').format(p.date), 
                                 style: GoogleFonts.outfit(fontSize: 12, color: textColorSecondary),
                               ),
                             ),
                             trailing: Text(
                               '+₹${p.amount.toStringAsFixed(0)}', 
                               style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF00C853), fontSize: 16),
                             ),
                           ),
                         );
                       },
                     ),
                   ],
                 ),
               ),
               const SizedBox(height: 40),
            ],
          ),
        ),
        error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: theme.colorScheme.error))),
        loading: () => const ReportsSkeleton(),
        );
      },
    ),
  );
  }

  Widget _buildStat(BuildContext context, String label, double value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        Text('₹${value.toStringAsFixed(0)}', style: GoogleFonts.outfit(color: valueColor, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String label, required String value, required ThemeData theme}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.outfit(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 12)),
            Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: theme.textTheme.bodyLarge?.color)),
          ],
        )
      ],
    );
  }
}
