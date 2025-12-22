import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/extensions/maintenance_extensions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kirayabook/presentation/providers/data_providers.dart';
import '../../../domain/entities/maintenance_request.dart';

class MaintenanceDetailScreen extends ConsumerWidget {
  final MaintenanceRequest request;

  const MaintenanceDetailScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('tenant.maintenance_details'.tr(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: request.status.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: request.status.color.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Icon(request.category.maintenanceCategoryIcon, color: request.status.color, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    request.status.label.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: request.status.color,
                    ),
                  ),
                  Text(
                    'Submitted on ${DateFormat('dd MMM yyyy').format(request.date)}',
                    style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Timeline
            Text('tenant.status_timeline'.tr(), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildTimeline(theme),

            const SizedBox(height: 32),

            _buildSection(
              theme,
              'tenant.issue_description_label'.tr(),
              request.description,
              Icons.description_outlined,
            ),

            if (request.resolutionNotes != null && request.resolutionNotes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSection(
                theme,
                'tenant.owner_resolution'.tr(),
                request.resolutionNotes!,
                Icons.check_circle_outline_rounded,
                color: Colors.green,
              ),
            ],

            const SizedBox(height: 40),
            
            // Support Action
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () async {
                   final owner = await ref.read(ownerByIdProvider(request.ownerId).future);
                   if (owner?.phone != null) {
                      final uri = Uri.parse('tel:${owner!.phone}');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                   } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Owner contact not available')));
                      }
                   }
                },
                icon: const Icon(Icons.call_outlined),
                label: Text('tenant.contact_owner'.tr()),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(ThemeData theme) {
    final statuses = MaintenanceStatus.values;
    final currentIndex = statuses.indexOf(request.status);

    return Column(
      children: List.generate(statuses.length, (index) {
        final s = statuses[index];
        final isCompleted = index <= currentIndex;
        final isLast = index == statuses.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted ? s.color : theme.dividerColor,
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted 
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted ? s.color : theme.dividerColor,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.label,
                    style: GoogleFonts.outfit(
                      fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                      color: isCompleted ? theme.textTheme.bodyLarge?.color : theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.description,
                    style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content, IconData icon, {Color? color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color ?? theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: GoogleFonts.outfit(color: theme.textTheme.bodyMedium?.color, height: 1.5)),
        ],
      ),
    );
  }
}
