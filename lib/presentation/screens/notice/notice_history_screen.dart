import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/notice.dart';
import '../../../../domain/entities/tenant.dart';
import 'notice_controller.dart';
import 'notice_detail_screen.dart'; // Import
import '../owner/tenant/tenant_controller.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../../core/extensions/string_extensions.dart';

class NoticeHistoryScreen extends ConsumerWidget {
  final String houseId;
  final String ownerId;

  const NoticeHistoryScreen({
    super.key,
    required this.houseId,
    required this.ownerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(noticesForHouseProvider((houseId: houseId, ownerId: ownerId)));
    // Fetch all tenants for owner to map IDs to Names. 
    final tenantsAsync = ref.watch(tenantControllerProvider); 
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Notice Announcements', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)), // Matches Figma Header
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: noticesAsync.when(
        data: (notices) {
          if (notices.isEmpty) {
            return Center(child: Text('No active notices.', style: TextStyle(color: theme.textTheme.bodyMedium?.color)));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: notices.length,
            separatorBuilder: (ctx, i) => SizedBox(height: 16),
            itemBuilder: (context, index) {
              final notice = notices[index];
              return _NoticeCard(
                 notice: notice, 
                 tenantsAsync: tenantsAsync,
                 onTap: () async {
                    // Navigate to Details
                    // We need to pass valid data
                    if (tenantsAsync.hasValue) {
                       final shouldDelete = await Navigator.push<bool>(
                         context,
                         MaterialPageRoute(builder: (_) => NoticeDetailScreen(notice: notice, allTenants: tenantsAsync.value!)),
                       );
                       
                       if (shouldDelete == true) {
                          if (context.mounted) {
                            DialogUtils.runWithLoading(context, () async {
                              await ref.read(noticeControllerProvider.notifier).deleteNotice(notice.id, notice.ownerId);
                            });
                          }
                       }
                    } else {
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Loading tenant data... please wait.')));
                    }
                 }
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final Notice notice;
  final AsyncValue<List<Tenant>> tenantsAsync;
  final VoidCallback onTap;

  const _NoticeCard({required this.notice, required this.tenantsAsync, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final readCount = notice.readBy.length;
    final totalTenantsForHouse = tenantsAsync.valueOrNull?.length ?? 0; // Simplified for now since filtering by House requires async join

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
          boxShadow: [
             BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: Offset(0, 4))
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(notice.subject.capitalize(), maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold))),
                SizedBox(width: 8),
                _buildPriorityChip(notice.priority),
              ],
            ),
            const SizedBox(height: 8),
            Text(notice.message.capitalize(), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8), fontSize: 13, height: 1.5)),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text(DateFormat('MMM dd, yyyy').format(notice.date), style: TextStyle(fontSize: 12, color: Colors.grey)),
                Spacer(),
                Icon(Icons.visibility_outlined, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text('$readCount/$totalTenantsForHouse', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.chevron_right, size: 18, color: Colors.grey.withValues(alpha: 0.5)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high': color = Colors.red; break;
      case 'medium': color = Colors.orange; break;
      case 'low': color = Colors.green; break;
      default: color = Colors.blue;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(priority.toLowerCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
