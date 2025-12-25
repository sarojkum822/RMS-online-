import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../house/house_list_screen.dart';
import '../house/house_controller.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../providers/data_providers.dart';
import '../../maintenance/maintenance_controller.dart';
import '../../maintenance/maintenance_reports_screen.dart';
import '../../../../domain/entities/maintenance_request.dart';
import 'package:flutter/services.dart';

class PortfolioManagementScreen extends ConsumerWidget {
  const PortfolioManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Watch Maintenance Requests for Badge
    final user = ref.watch(userSessionServiceProvider).currentUser;
    final maintenanceAsync = user != null ? ref.watch(ownerMaintenanceProvider(user.uid)) : const AsyncValue<List<MaintenanceRequest>>.loading();
    final pendingMaintenanceCount = maintenanceAsync.valueOrNull?.where((r) => r.status == MaintenanceStatus.pending).length ?? 0;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Portfolio', 
           overflow: TextOverflow.ellipsis,
           style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 26, color: theme.textTheme.titleLarge?.color)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Notification Icon with Badge
          Badge(
            label: Text('$pendingMaintenanceCount'),
            isLabelVisible: pendingMaintenanceCount > 0,
            offset: const Offset(-4, 4),
            child: IconButton(
              icon: Icon(Icons.notifications_none_rounded, color: theme.textTheme.bodyMedium?.color),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MaintenanceReportsScreen()));
              },
            ),
          ),
          const SizedBox(width: 8),
          // Functional Profile Icon
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/owner/settings');
            },
            child: Container(
               margin: const EdgeInsets.only(right: 20),
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(
                 color: theme.colorScheme.primary,
                 shape: BoxShape.circle,
               ),
               child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: const HouseListPanel(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          context.push('/owner/houses/add');
        },
        label: Text(
          'Add Property', 
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)
        ),
        icon: const Icon(
          Icons.add_business_rounded, 
          color: Colors.white
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }
}

// House List Panel Implementation
class HouseListPanel extends ConsumerWidget {
  const HouseListPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final housesAsync = ref.watch(houseControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return housesAsync.when(
      data: (houses) {
        if (houses.isEmpty) {
          return Center(
            child: EmptyStateWidget(
              title: 'properties.empty_title'.tr(),
              subtitle: 'properties.empty_subtitle'.tr(),
              icon: Icons.home_work_outlined,
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: houses.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: ModernPropertyCard(house: houses[index], isDark: isDark, theme: theme, ref: ref),
            );
          },
        );
      },
      error: (e, st) => Center(child: Text('Error: $e')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
