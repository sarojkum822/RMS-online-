import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/maintenance_request.dart';

class MaintenanceDetailScreen extends StatelessWidget {
  final MaintenanceRequest request;

  const MaintenanceDetailScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Repair Details', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
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
                color: _getStatusColor(request.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _getStatusColor(request.status).withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Icon(_getCategoryIcon(request.category), color: _getStatusColor(request.status), size: 40),
                  const SizedBox(height: 12),
                  Text(
                    request.status.name.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(request.status),
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
            Text('Status Timeline', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildTimeline(theme),

            const SizedBox(height: 32),

            // Description Section
            _buildSection(
              theme,
              'Issue Description',
              request.description,
              Icons.description_outlined,
            ),

            if (request.resolutionNotes != null && request.resolutionNotes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSection(
                theme,
                'Owner Resolution',
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
                onPressed: () {
                   // Placeholder for contact owner
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact feature coming soon!')));
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: const Text('Contact Owner about this request'),
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
                    color: isCompleted ? _getStatusColor(s) : theme.dividerColor,
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
                    color: isCompleted ? _getStatusColor(s) : theme.dividerColor,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStatusLabel(s),
                    style: GoogleFonts.outfit(
                      fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                      color: isCompleted ? theme.textTheme.bodyLarge?.color : theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStatusDescription(s),
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

  IconData _getCategoryIcon(String cat) {
    if (cat.contains('Plumb')) return Icons.water_drop;
    if (cat.contains('Electr')) return Icons.electric_bolt;
    if (cat.contains('Appliance')) return Icons.kitchen;
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

  String _getStatusLabel(MaintenanceStatus s) {
    switch(s) {
      case MaintenanceStatus.pending: return 'Request Received';
      case MaintenanceStatus.inProgress: return 'In Progress';
      case MaintenanceStatus.completed: return 'Resolved';
      case MaintenanceStatus.rejected: return 'Rejected / Closed';
    }
  }

  String _getStatusDescription(MaintenanceStatus s) {
    switch(s) {
      case MaintenanceStatus.pending: return 'The owner has been notified of your request.';
      case MaintenanceStatus.inProgress: return 'A technician or contractor has been assigned.';
      case MaintenanceStatus.completed: return 'The issue has been marked as fixed.';
      case MaintenanceStatus.rejected: return 'The request could not be fulfilled at this time.';
    }
  }
}
