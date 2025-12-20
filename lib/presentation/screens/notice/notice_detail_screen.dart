import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/notice.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../../core/extensions/string_extensions.dart';
import 'notice_controller.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../providers/data_providers.dart';

class NoticeDetailScreen extends ConsumerWidget {
  final Notice notice;
  final List<Tenant> allTenants;

  const NoticeDetailScreen({
    super.key, 
    required this.notice, 
    required this.allTenants
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Fetch necessary data to map House -> Units -> Tenancies -> Tenants
    final unitsAsync = ref.watch(allUnitsProvider);
    final tenanciesAsync = ref.watch(tenantRepositoryProvider).getAllTenancies(); // Stream

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Notice Details', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.iconTheme,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Notice?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );

              if (confirm == true) {
                 if(context.mounted) {
                   await DialogUtils.runWithLoading(context, () async {
                      await ref.read(noticeControllerProvider.notifier).deleteNotice(notice.id, notice.ownerId);
                   });
                   if(context.mounted) Navigator.pop(context);
                 }
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notice.subject.capitalize(),
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
                        ),
                      ),
                      _buildPriorityTag(notice.priority),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    notice.message.capitalize(),
                    style: TextStyle(fontSize: 14, height: 1.5, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMMM dd, yyyy at hh:mm a').format(notice.date),
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      )
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Logic to calculate Stats
            // We need to wait for units and tenancies to properly filter "houseTenants"
            // If checking ALL tenants passed in, we filter those who are in this house.
            
            // Using StreamBuilder/Consumer logic inline for stats:
            Builder(
              builder: (context) {
                 final unitsState = unitsAsync.valueOrNull ?? [];
                 final tenanciesStream = ref.watch(StreamProvider((ref) => ref.watch(tenantRepositoryProvider).getAllTenancies()));
                 
                 return tenanciesStream.when(
                   data: (tenancies) {
                      // 1. Get UnitIDs in this House
                      final unitIds = unitsState.where((u) => u.houseId == notice.houseId).map((u) => u.id).toSet();
                      
                      // 2. Get Active Tenancies in these Units
                      final activeTenancies = tenancies.where((t) => unitIds.contains(t.unitId) && t.status.name == 'active').toList();
                      
                      // 3. Get TenantIDs
                      final houseTenantIds = activeTenancies.map((t) => t.tenantId).toSet();
                      
                      // 4. Filter passed 'allTenants'
                      final houseTenants = allTenants.where((t) => houseTenantIds.contains(t.id)).toList();
                      
                      final seenTenants = houseTenants.where((t) => notice.readBy.contains(t.id.toString())).toList();
                      final notSeenTenants = houseTenants.where((t) => !notice.readBy.contains(t.id.toString())).toList();
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildStatCard(context, 'Seen', seenTenants.length, Colors.green, Icons.visibility_outlined)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildStatCard(context, 'Not Seen', notSeenTenants.length, Colors.redAccent, Icons.visibility_off_outlined)),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          
                          Text(
                            'Seen by ${seenTenants.length} tenants',
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color),
                          ),
                          const SizedBox(height: 16),
                          
                          if (seenTenants.isEmpty)
                            const Padding(
                               padding: EdgeInsets.symmetric(vertical: 20),
                               child: Center(child: Text('No views yet.', style: TextStyle(color: Colors.grey))),
                            )
                          else
                            ...seenTenants.map((t) {
                              final readTime = notice.readAt[t.id]; 
                              String timeStr = 'Date Unknown';
                              if (readTime != null) {
                                 timeStr = DateFormat('MMM dd\nhh:mm a').format(readTime);
                              }
                              
                              // Find Unit Number
                              final tenancy = activeTenancies.firstWhere((at) => at.tenantId == t.id);
                              final unit = unitsState.firstWhere((u) => u.id == tenancy.unitId, orElse: () => unitsState.first); // Fallback safe
                              final unitName = unit.nameOrNumber;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: _getColorForName(t.name).withValues(alpha: 0.2),
                                      child: Text(t.name.substring(0, 1).toUpperCase(), style: TextStyle(color: _getColorForName(t.name), fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(t.name, style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                                          Text('Unit $unitName', style: const TextStyle(fontSize: 12, color: Colors.grey)), 
                                        ],
                                      ),
                                    ),
                                    Text(timeStr, textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              );
                            }),
                        ],
                      );
                   },
                   loading: () => const Center(child: CircularProgressIndicator()),
                   error: (e, s) => Text('Error loading stats: $e'),
                 );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityTag(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high': color = Colors.red; break;
      case 'medium': color = Colors.orange; break;
      case 'low': color = Colors.green; break;
      default: color = Colors.blue;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text('$count', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color))
        ],
      ),
    );
  }

  Color _getColorForName(String name) {
    final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];
    return colors[name.length % colors.length];
  }
}
