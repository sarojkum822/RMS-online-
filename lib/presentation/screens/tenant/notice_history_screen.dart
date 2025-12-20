import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/tenant.dart';
import '../../../domain/entities/notice.dart';
import '../notice/notice_controller.dart';
import '../../../../core/extensions/string_extensions.dart';

class NoticeHistoryScreen extends ConsumerWidget {
  final Tenant tenant;
  final List<Notice> notices;

  const NoticeHistoryScreen({
    super.key,
    required this.tenant,
    required this.notices,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Sort notices by date desc
    final sortedNotices = List<Notice>.from(notices)..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Notice Board', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: sortedNotices.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.campaign_outlined, size: 64, color: theme.dividerColor),
                   const SizedBox(height: 16),
                   Text('No notices yet.', style: GoogleFonts.outfit(color: theme.textTheme.bodySmall?.color)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: sortedNotices.length,
              itemBuilder: (context, index) {
                final n = sortedNotices[index];
                final isRead = n.readBy.contains(tenant.id.toString());

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: isDark ? const BorderSide(color: Colors.white10) : BorderSide.none,
                  ),
                  elevation: 0,
                  color: isRead 
                    ? (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey[50])
                    : (isDark ? Colors.orange.withValues(alpha: 0.05) : Colors.orange.withValues(alpha: 0.02)),
                  child: InkWell(
                    onTap: () => _showNoticeDetail(context, ref, n),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isRead ? Colors.grey.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isRead ? 'READ' : 'NEW',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isRead ? Colors.grey : Colors.orange,
                                  ),
                                ),
                              ),
                              Text(
                                DateFormat('dd MMM yyyy').format(n.date),
                                style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            n.subject.capitalize(),
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: isRead ? FontWeight.bold : FontWeight.w900,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            n.message.capitalize(),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: theme.textTheme.bodyMedium?.color,
                              height: 1.5,
                            ),
                          ),
                          if (!isRead) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Tap to read full message',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showNoticeDetail(BuildContext context, WidgetRef ref, Notice notice) {
    if (!notice.readBy.contains(tenant.id.toString())) {
      ref.read(noticeControllerProvider.notifier).markAsRead(notice.id, tenant.id.toString(), notice.ownerId);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(notice.subject.capitalize(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Text(
            notice.message.capitalize(),
            style: GoogleFonts.outfit(height: 1.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
