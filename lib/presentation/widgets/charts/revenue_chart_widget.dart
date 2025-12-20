import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class RevenueChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyData;
  final bool isDark;

  const RevenueChartWidget({
    super.key,
    required this.monthlyData,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (monthlyData.isEmpty) {
      return Center(child: Text("No data available", style: GoogleFonts.outfit(color: Colors.grey)));
    }

    double maxY = 0;
    for (var m in monthlyData) {
      if (m['amount'] > maxY) maxY = m['amount'];
    }
    // Add 20% buffer to Y-axis
    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 10000;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
             getTooltipColor: (group) => isDark ? Colors.white : Colors.black, // Updated
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '₹${rod.toY.toStringAsFixed(0)}',
                GoogleFonts.outfit(
                  color: isDark ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= monthlyData.length) return const SizedBox.shrink();
                
                final dateStr = monthlyData[index]['month']; // YYYY-MM
                final date = DateTime.parse('$dateStr-01');
                final label = DateFormat('MMM').format(date);
                
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    label,
                    style: GoogleFonts.outfit(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark ? Colors.white10 : Colors.black12,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: monthlyData.asMap().entries.map((entry) {
          final index = entry.key;
          final amount = (entry.value['amount'] as num).toDouble();
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: amount,
                color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), // Blue 400/600
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                ),
                gradient: LinearGradient(
                   begin: Alignment.bottomCenter,
                   end: Alignment.topCenter,
                   colors: isDark 
                     ? [const Color(0xFF1E3A8A), const Color(0xFF60A5FA)] 
                     : [const Color(0xFF2563EB), const Color(0xFF93C5FD)],
                )
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
