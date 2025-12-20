import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../../domain/entities/maintenance_request.dart';
import '../../../../features/rent/domain/entities/rent_cycle.dart';
import '../../../providers/data_providers.dart';
import '../../maintenance/maintenance_controller.dart';
import '../../owner/tenant/tenant_controller.dart';
import '../../owner/house/house_controller.dart';
import 'package:go_router/go_router.dart';

class TenantServicesView extends ConsumerWidget {
  final Tenant tenant;
  const TenantServicesView({super.key, required this.tenant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ownerId = tenant.ownerId;
    
    // Find Tenancy/House/Unit for requests
    final tenancyAsync = ref.watch(activeTenancyForTenantAccessProvider(tenant.id, ownerId));
    final tenancy = tenancyAsync.valueOrNull;
    
    final unitId = tenancy?.unitId;
    final unitAsync = unitId != null ? ref.watch(unitDetailsForTenantProvider((unitId: unitId, ownerId: ownerId))) : const AsyncValue.loading();
    final unit = unitAsync.valueOrNull;
    final houseId = unit?.houseId;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Services & Repairs', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Utility Usage Section
            const SizedBox(height: 20),
            Text('Utility Usage (Electricity)', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (tenancy != null) 
              _buildUtilityChart(context, ref, tenancy.id, ownerId),

            const SizedBox(height: 32),

            // Maintenance Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Repair Requests', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: (houseId != null && unitId != null) ? () => _showNewRequestDialog(context, ref, houseId, unitId) : null,
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                  label: const Text('New Request'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMaintenanceList(context, ref),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildUtilityChart(BuildContext context, WidgetRef ref, String tenancyId, String ownerId) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ref.read(rentRepositoryProvider).getElectricReadingsForTenant(tenancyId, ownerId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
        final readings = snapshot.data!;
        if (readings.isEmpty) return _buildEmptyCard('No reading data available.');

        // Sort by date (oldest first for chart)
        readings.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
        final recentReadings = readings.length > 6 ? readings.sublist(readings.length - 6) : readings;

        return Container(
          height: 250,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: isDark ? Border.all(color: Colors.white10) : Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                 children: [
                   const Icon(Icons.flash_on_rounded, color: Colors.amber, size: 16),
                   const SizedBox(width: 8),
                   Text('Meter Readings', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: theme.textTheme.bodySmall?.color)),
                 ],
               ),
               const SizedBox(height: 20),
               Expanded(
                 child: BarChart(
                   BarChartData(
                     alignment: BarChartAlignment.spaceAround,
                     maxY: recentReadings.map((c) => (c['reading'] as double) > 0 ? (c['reading'] as double) : 100.0).reduce((a, b) => a > b ? a : b) * 1.2,
                     barTouchData: BarTouchData(
                       touchTooltipData: BarTouchTooltipData(
                         getTooltipColor: (_) => Colors.blueAccent,
                         getTooltipItem: (group, groupIndex, rod, rodIndex) {
                           return BarTooltipItem(
                             '${rod.toY.toStringAsFixed(0)} kWh',
                             const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                             if (value.toInt() >= 0 && value.toInt() < recentReadings.length) {
                               final date = recentReadings[value.toInt()]['date'] as DateTime;
                               return Padding(
                                 padding: const EdgeInsets.only(top: 8.0),
                                 child: Text(DateFormat('MMM').format(date), style: const TextStyle(fontSize: 10)),
                               );
                             }
                             return const SizedBox();
                           },
                         ),
                       ),
                       leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                       topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                       rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                     ),
                     gridData: const FlGridData(show: false),
                     borderData: FlBorderData(show: false),
                     barGroups: List.generate(recentReadings.length, (i) {
                       return BarChartGroupData(
                         x: i,
                         barRods: [
                           BarChartRodData(
                             toY: (recentReadings[i]['reading'] as double) > 0 ? (recentReadings[i]['reading'] as double) : 0,
                             color: theme.colorScheme.primary,
                             width: 16,
                             borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                           ),
                         ],
                       );
                     }),
                   ),
                 ),
               ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMaintenanceList(BuildContext context, WidgetRef ref) {
    final ownerId = tenant.ownerId;
    final maintenanceAsync = ref.watch(tenantMaintenanceProvider((tenantId: tenant.id.toString(), ownerId: ownerId)));
    
    return maintenanceAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error loading requests: $e')),
      data: (requests) {
        if (requests.isEmpty) {
          return _buildEmptyCard('No active repair requests.');
        }

        // Sort by date desc
        final sorted = List<MaintenanceRequest>.from(requests)..sort((a,b) => b.date.compareTo(a.date));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sorted.length,
          itemBuilder: (context, index) {
            final r = sorted[index];
            return _buildRequestTile(context, r);
          },
        );
      },
    );
  }

  Widget _buildRequestTile(BuildContext context, MaintenanceRequest r) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark ? const BorderSide(color: Colors.white10) : BorderSide.none,
      ),
      elevation: 0,
      color: theme.cardColor,
      child: ListTile(
        onTap: () => context.push('/tenant/maintenance/${r.id}', extra: r),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getStatusColor(r.status).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(_getCategoryIcon(r.category), color: _getStatusColor(r.status), size: 20),
        ),
        title: Text(r.category, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        subtitle: Text(
          DateFormat('dd MMM yyyy').format(r.date),
          style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(r.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            r.status.name.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(r.status)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.grey),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showNewRequestDialog(BuildContext context, WidgetRef ref, String houseId, String unitId) {
    final descController = TextEditingController();
    String category = 'Plumbing';
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Request Repair', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: ['Plumbing', 'Electrical', 'Appliance', 'Carpentry', 'Other']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => category = v!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'What is the issue?', border: OutlineInputBorder(), hintText: 'Example: Tap is leaking in kitchen...'),
                maxLines: 4,
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                 if (descController.text.isEmpty) return;
                 Navigator.pop(ctx);
                 await ref.read(maintenanceControllerProvider.notifier).submitRequest(
                   ownerId: tenant.ownerId,
                   houseId: houseId,
                   unitId: unitId,
                   tenantId: tenant.id.toString(),
                   category: category,
                   description: descController.text,
                 );
                 if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request Submitted Successfullly!')));
              },
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Submit Request'),
            )
          ],
        ),
      )
    );
  }


  IconData _getCategoryIcon(String cat) {
    if (cat.contains('Plumb')) return Icons.water_drop;
    if (cat.contains('Electr')) return Icons.electric_bolt;
    if (cat.contains('Appliance')) return Icons.kitchen;
    if (cat.contains('Carpentry')) return Icons.chair;
    return Icons.build;
  }

  Color _getStatusColor(MaintenanceStatus status) {
    switch(status) {
      case MaintenanceStatus.pending: return Colors.orange;
      case MaintenanceStatus.inProgress: return Colors.blue;
      case MaintenanceStatus.completed: return Colors.green;
      case MaintenanceStatus.rejected: return Colors.red;
    }
  }
}
