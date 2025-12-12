import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'reports_controller.dart';
import '../expense/expense_screens.dart'; // Import Expense Screens
import '../../../widgets/skeleton_loader.dart';
import '../../../widgets/fade_in_up.dart';


class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Reports & Analytics', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () => ref.invalidate(reportsControllerProvider),
          )
        ],
      ),
      body: reportsAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // 1. Premium Financial Overview Card
               FadeInUp(
                 delay: const Duration(milliseconds: 100),
                 child: Container(
                   padding: const EdgeInsets.all(24),
                   decoration: BoxDecoration(
                     gradient: const LinearGradient(
                       begin: Alignment.topLeft, 
                       end: Alignment.bottomRight,
                       colors: [Color(0xFF1E3A8A), Color(0xFF7E22CE)], // Deep Blue to Purple
                     ),
                     borderRadius: BorderRadius.circular(24),
                     boxShadow: [
                       BoxShadow(
                         color: const Color(0xFF7E22CE).withValues(alpha: 0.3), 
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
                             'Financial Overview', 
                             style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.9), fontSize: 16, fontWeight: FontWeight.w600),
                           ),
                           Container(
                             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                             decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                             child: Text('This Month', style: GoogleFonts.outfit(color: Colors.white, fontSize: 10)),
                           )
                         ],
                       ),
                       const SizedBox(height: 24),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           _buildStat(context, 'Collected', data.totalCollected, const Color(0xFF69F0AE)), // Green Accent
                           Container(width: 1, height: 40, color: Colors.white12),
                           _buildStat(context, 'Pending', data.totalPending, const Color(0xFFFFAB40)), // Orange Accent
                           Container(width: 1, height: 40, color: Colors.white12),
                           _buildStat(context, 'Total', data.totalExpected, Colors.white),
                         ],
                       ),
                     ],
                   ),
                 ),
               ),
               
               const SizedBox(height: 24),
                
                // 1.5 Expenses & Net Profit Row
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
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Expenses', style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold)),
                                    const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('NET PROFIT', style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold)),
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

               // 2. Revenue Trend Chart (New)
               FadeInUp(
                 delay: const Duration(milliseconds: 300),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text('Revenue Trend (6 Months)', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                     const SizedBox(height: 16),
                      RepaintBoundary(
                        child: Container(
                         height: 300,
                         padding: const EdgeInsets.all(24),
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(24),
                           boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))], // Better Perf
                         ),
                         child: BarChart(
                         BarChartData(
                           alignment: BarChartAlignment.spaceAround,
                           maxY: data.revenueTrend.map((e) => e.collected + e.pending).fold(0.0, (p, c) => p > c ? p : c) * 1.2, // dynamic max Y
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
                                         style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold),
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
                                   gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF7E22CE)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                                   width: 16,
                                   borderRadius: BorderRadius.circular(4),
                                   backDrawRodData: BackgroundBarChartRodData(
                                     show: true,
                                     toY: (stats.collected + stats.pending) == 0 ? 10 : (stats.collected + stats.pending), // Show at least a small bar if 0 to indicate month exists
                                     color: Colors.grey[100],
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
                     Text('Occupancy Rate', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                     const SizedBox(height: 16),
                      RepaintBoundary(
                        child: Container(
                         padding: const EdgeInsets.all(24),
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(24),
                           boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
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
                                       PieChartSectionData(color: Colors.grey[200], value: data.vacantUnits.toDouble(), title: '', radius: 15),
                                     ],
                                   ),
                                 ),
                                 Center(
                                   child: Column(
                                     mainAxisSize: MainAxisSize.min,
                                     children: [
                                       Text('${(data.totalUnits > 0 ? (data.occupiedUnits / data.totalUnits * 100) : 0).toStringAsFixed(0)}%', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
                                       Text('Occupancy', style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey[500])),
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
                                 _buildLegendItem(color: const Color(0xFF2563EB), label: 'Occupied', value: '${data.occupiedUnits} Units'),
                                 const SizedBox(height: 16),
                                 _buildLegendItem(color: Colors.grey[400]!, label: 'Vacant', value: '${data.vacantUnits} Units'),
                                 const SizedBox(height: 24),
                                 Text('Total Units: ${data.totalUnits}', style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600)),
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
                        Text('Payment Methods (This Month)', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 16),
                        Container(
                          height: 200,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10)]),
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
                                         final color = [const Color(0xFF2563EB), const Color(0xFF00C853), const Color(0xFFFFAB40), const Color(0xFF7E22CE)][index % 4];
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
                                       final color = [const Color(0xFF2563EB), const Color(0xFF00C853), const Color(0xFFFFAB40), const Color(0xFF7E22CE)][index % 4];
                                       return Padding(
                                         padding: const EdgeInsets.symmetric(vertical: 4),
                                         child: Row(
                                           children: [
                                             CircleAvatar(radius: 4, backgroundColor: color),
                                             const SizedBox(width: 8),
                                             Expanded(child: Text(e.key, style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 12))),
                                             Text('₹${e.value.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
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
                         Text('Top Defaulters', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
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
                                 decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red.withValues(alpha: 0.1))),
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     CircleAvatar(radius: 20, backgroundColor: Colors.red[50], child: Text(d.name.isNotEmpty ? d.name[0] : '?', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                                     const Spacer(),
                                     Text(d.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
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
                         Text('Recent Activity', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                         Text('View All', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB))),
                       ],
                     ),
                     const SizedBox(height: 16),
                     
                     if(data.recentPayments.isEmpty)
                       Center(
                         child: Padding(
                           padding: const EdgeInsets.symmetric(vertical: 40), 
                           child: Text('No recent activity', style: GoogleFonts.outfit(color: Colors.grey[400])),
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
                             color: Colors.white, 
                             borderRadius: BorderRadius.circular(16),
                             boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 2))],
                           ),
                           child: ListTile(
                             contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                             leading: Container(
                               padding: const EdgeInsets.all(10),
                               decoration: BoxDecoration(
                                 color: const Color(0xFF69F0AE).withValues(alpha: 0.15),
                                 shape: BoxShape.circle,
                               ),
                               child: const Icon(Icons.arrow_downward_rounded, color: Color(0xFF00C853), size: 20),
                             ),
                             title: Text(
                               'Payment Received', 
                               style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
                             ),
                             subtitle: Padding(
                               padding: const EdgeInsets.only(top: 4),
                               child: Text(
                                 DateFormat('dd MMM, hh:mm a').format(p.date), 
                                 style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[500]),
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
        error: (e, _) => Center(child: Text('Error: $e')),
        loading: () => const ReportsSkeleton(), // Replaced Loader
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

  Widget _buildLegendItem({required Color color, required String label, required String value}) {
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
            Text(label, style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 12)),
            Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        )
      ],
    );
  }
}
