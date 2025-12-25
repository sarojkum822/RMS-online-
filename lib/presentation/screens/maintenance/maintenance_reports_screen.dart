import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/maintenance_request.dart';
import 'maintenance_controller.dart';
import 'package:kirayabook/presentation/providers/data_providers.dart';
import 'widgets/add_maintenance_sheet.dart' as widgets;
import '../../widgets/empty_state_widget.dart';
import '../../widgets/skeleton_loader.dart';

class MaintenanceReportsScreen extends ConsumerStatefulWidget {
  const MaintenanceReportsScreen({super.key});

  @override
  ConsumerState<MaintenanceReportsScreen> createState() => _MaintenanceReportsScreenState();
}

class _MaintenanceReportsScreenState extends ConsumerState<MaintenanceReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userSessionServiceProvider).currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('Error: No session')));
    
    final requestsAsync = ref.watch(ownerMaintenanceProvider(user.uid));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Maintenance Requests', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: requestsAsync.when(
        data: (allRequests) {
           final pending = allRequests.where((r) => r.status != MaintenanceStatus.completed && r.status != MaintenanceStatus.rejected).toList();
           final completed = allRequests.where((r) => r.status == MaintenanceStatus.completed || r.status == MaintenanceStatus.rejected).toList();

           return TabBarView(
             controller: _tabController,
             children: [
               _buildRequestList(pending, theme, isDark, isPending: true),
               _buildRequestList(completed, theme, isDark, isPending: false),
             ],
           );
        },
        loading: () => const SkeletonList(),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context, 
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => const widgets.AddMaintenanceSheet()
          );
        },
        label: Text('New Request', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.primary,
        elevation: 4,
      ),
    );
  }

  Widget _buildRequestList(List<MaintenanceRequest> list, ThemeData theme, bool isDark, {required bool isPending}) {
    if (list.isEmpty) {
      return EmptyStateWidget(
        title: isPending ? 'No Open Requests' : 'No Completed History',
        subtitle: isPending 
            ? 'Everything is running smoothly! No pending maintenance issues.' 
            : 'No resolved maintenance requests found in history.',
        icon: isPending ? Icons.check_circle_outline : Icons.history_toggle_off,
        buttonText: isPending ? 'Create Request' : null,
        onButtonPressed: isPending ? () {
           showModalBottomSheet(
            context: context, 
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => const widgets.AddMaintenanceSheet()
          );
        } : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _MaintenanceRequestCard(request: list[index], isPending: isPending);
      },
    );
  }

}

class _MaintenanceRequestCard extends ConsumerWidget {
  final MaintenanceRequest request;
  final bool isPending;

  const _MaintenanceRequestCard({required this.request, required this.isPending});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Logic for Badges
    final statusColor = _getStatusColor(request.status);
    final statusText = _getStatusText(request.status);
    
    // Priority Logic (Mocked based on category/status for now as purely UI request)
    final priority = _inferPriority(request.category);
    final priorityColor = _getPriorityColor(priority);
    
    // Icon Logic
    final statusIcon = _getStatusIcon(request.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
             color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
             blurRadius: 10,
             offset: const Offset(0, 4)
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Title + Status Icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _capitalize(request.category) + (request.description.length > 20 ? ' Issue' : ''), // Title derivation
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              Icon(statusIcon, color: statusColor, size: 20),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 2. Description
          Text(
            request.description,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 12),
          
          // 3. Image (Thumbnail if exists)
          if (request.photoUrl != null && request.photoUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  request.photoUrl!,
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (c,e,s) => const SizedBox(),
                ),
              ),
            ),
            
          // 4. Badges Row
          Row(
            children: [
              // Status Badge
              if (request.status != MaintenanceStatus.pending) ...[
                 _Badge(text: statusText, color: statusColor, textColor: Colors.white),
                 const SizedBox(width: 8),
              ] else ...[
                 _Badge(text: 'Open', color: Colors.blue, textColor: Colors.white),
                 const SizedBox(width: 8),
              ],
              
              // Priority Badge
              _Badge(text: priority, color: priorityColor, textColor: Colors.white),
              const SizedBox(width: 8),
              
              // Category Badge (Outlined)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Text(
                  _capitalize(request.category),
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 5. Metadata (Date & Assigned)
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: theme.hintColor),
              const SizedBox(width: 6),
              Text(
                'Created: ${DateFormat('d MMM yyyy').format(request.date)}',
                style: GoogleFonts.outfit(fontSize: 12, color: theme.hintColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: theme.hintColor),
              const SizedBox(width: 6),
              Text(
                'Assigned to caretaker', // Placeholder/Static for now as requested
                style: GoogleFonts.outfit(fontSize: 12, color: theme.hintColor),
              ),
            ],
          ),

          const SizedBox(height: 16),
          
          // 6. Action Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Show Quick Actions Bottom Sheet
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (ctx) => _MaintenanceActionSheet(request: request, ref: ref),
                );
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: BorderSide(color: theme.dividerColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('View Details', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
            ),
          ),
        ],
      ),
    );
  }

  // Helpers
  String _capitalize(String s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '';

  Color _getStatusColor(MaintenanceStatus status) {
     switch(status) {
       case MaintenanceStatus.pending: return const Color(0xFF3B82F6); // Blue (Open)
       case MaintenanceStatus.inProgress: return const Color(0xFFFACC15); // Yellow (In Progress)
       case MaintenanceStatus.completed: return const Color(0xFF22C55E); // Green (Resolved)
       case MaintenanceStatus.rejected: return const Color(0xFFEF4444); // Red
     }
  }
  
  String _getStatusText(MaintenanceStatus status) {
     switch(status) {
       case MaintenanceStatus.pending: return 'Open';
       case MaintenanceStatus.inProgress: return 'In Progress';
       case MaintenanceStatus.completed: return 'Resolved';
       case MaintenanceStatus.rejected: return 'Rejected';
     }
  }

  IconData _getStatusIcon(MaintenanceStatus status) {
     switch(status) {
       case MaintenanceStatus.pending: return Icons.info_outline;
       case MaintenanceStatus.inProgress: return Icons.access_time; // Clock
       case MaintenanceStatus.completed: return Icons.check_circle_outline; 
       case MaintenanceStatus.rejected: return Icons.cancel_outlined;
     }
  }

  String _inferPriority(String category) {
    final c = category.toLowerCase();
    if (c.contains('plumb') || c.contains('electr') || c.contains('leak')) return 'High';
    if (c.contains('appliance') || c.contains('ac')) return 'Medium';
    return 'Low';
  }

  Color _getPriorityColor(String priority) {
    switch(priority) {
      case 'High': return const Color(0xFFEA580C); // Orange-600
      case 'Medium': return const Color(0xFFF59E0B); // Amber-500
      default: return const Color(0xFF6B7280); // Grey
    }
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const _Badge({required this.text, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _MaintenanceActionSheet extends StatelessWidget {
  final MaintenanceRequest request;
  final WidgetRef ref;

  const _MaintenanceActionSheet({required this.request, required this.ref});
  
  @override
  Widget build(BuildContext context) {
    return Container(
       padding: const EdgeInsets.all(24),
       child: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
            Text('Update Request', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (request.status != MaintenanceStatus.inProgress && request.status != MaintenanceStatus.completed)
              ListTile(
                 leading: const Icon(Icons.play_arrow, color: Colors.blue),
                 title: const Text('Mark In Progress'),
                 onTap: () {
                    Navigator.pop(context);
                    ref.read(maintenanceControllerProvider.notifier).updateStatus(request.id, request.ownerId, MaintenanceStatus.inProgress);
                 },
              ),
            if (request.status != MaintenanceStatus.completed)
              ListTile(
                 leading: const Icon(Icons.check_circle, color: Colors.green),
                 title: const Text('Mark as Resolved'),
                 onTap: () {
                    Navigator.pop(context);
                    _showResolveDialog(context, request, ref);
                 },
              ),
              
             ListTile(
                 leading: const Icon(Icons.close),
                 title: const Text('Cancel'),
                 onTap: () => Navigator.pop(context),
              ),
         ],
       ),
    );
  }
  
  void _showResolveDialog(BuildContext context, MaintenanceRequest r, WidgetRef ref) {
    final costController = TextEditingController();
    final noteController = TextEditingController();
    
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as Resolved'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: costController, decoration: const InputDecoration(labelText: 'Repair Cost (₹)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: noteController, decoration: const InputDecoration(labelText: 'Resolution Notes', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
               final cost = double.tryParse(costController.text);
               Navigator.pop(ctx);
               ref.read(maintenanceControllerProvider.notifier).updateStatus(r.id, r.ownerId, MaintenanceStatus.completed, cost: cost, notes: noteController.text);
            },
            child: const Text('Complete'),
          )
        ],
      )
    );
  }
}

