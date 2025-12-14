import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tenant_controller.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../providers/data_providers.dart';
import '../../../../domain/entities/house.dart'; // For Unit
import 'tenant_detail_screen.dart';
import '../../../../core/utils/dialog_utils.dart';

class TenantListScreen extends ConsumerWidget {
  const TenantListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantsAsync = ref.watch(tenantControllerProvider);
    final allUnitsAsync = ref.watch(allUnitsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Tenants', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.iconTheme,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/owner/tenants/add'),
        label: Text('Add Tenant', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white)),
        icon: const Icon(Icons.person_add, color: Colors.white),
        backgroundColor: theme.colorScheme.primary, // Brand Color
        elevation: 4,
      ),
      body: tenantsAsync.when(
        data: (tenants) {
          if (tenants.isEmpty) {
            return Center(
               child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_alt_outlined, size: 64, color: theme.disabledColor),
                  const SizedBox(height: 16),
                  Text(
                    'No tenants found',
                    style: GoogleFonts.outfit(fontSize: 18, color: theme.disabledColor),
                  ),
                ],
              ),
            );
          }
          
          return allUnitsAsync.when(
            data: (units) {
               return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: tenants.length,
                itemBuilder: (context, index) {
                  final tenant = tenants[index];
                  // Find Unit Name
                  final unit = units.firstWhere((u) => u.id == tenant.unitId, orElse: () => Unit(id: -1, houseId: 0, nameOrNumber: 'Unknown', baseRent: 0, defaultDueDay: 1));
                  final unitDisplay = unit.id == -1 ? 'ID: ${tenant.unitId}' : unit.nameOrNumber;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: isDark ? Border.all(color: Colors.white10) : Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                      boxShadow: isDark ? [] : [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: isDark ? 0.2 : 0.5),
                        backgroundImage: tenant.imageUrl != null ? NetworkImage(tenant.imageUrl!) : null,
                        child: tenant.imageUrl == null ? Text(
                          tenant.name.substring(0, 1).toUpperCase(),
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                        ) : null,
                      ),
                      title: Text(
                        tenant.name,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
                      ),
                      subtitle: Text(
                        '${tenant.phone} • Unit: $unitDisplay',
                        style: GoogleFonts.outfit(fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: tenant.status == TenantStatus.active 
                                  ? Colors.green.withValues(alpha: 0.1) 
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tenant.status == TenantStatus.active ? 'Active' : 'Inactive',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: tenant.status == TenantStatus.active ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                          PopupMenuButton(
                            icon: Icon(Icons.more_vert, color: theme.iconTheme.color?.withValues(alpha: 0.5)),
                            color: theme.cardColor,
                            itemBuilder: (context) => [
                               PopupMenuItem(
                                child: Text('Delete', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                                onTap: () {
                                   DialogUtils.runWithLoading(context, () async {
                                      await ref.read(tenantControllerProvider.notifier).deleteTenant(tenant.id);
                                   });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                         Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TenantDetailScreen(tenant: tenant),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error loading units: $e', style: TextStyle(color: theme.textTheme.bodyMedium?.color))),
          );
        },
        error: (e, st) => Center(child: Text('Error: $e', style: TextStyle(color: theme.textTheme.bodyMedium?.color))),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
