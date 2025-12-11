import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tenant_controller.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../providers/data_providers.dart';
import '../../../../domain/entities/house.dart'; // For Unit
import 'tenant_detail_screen.dart';

class TenantListScreen extends ConsumerWidget {
  const TenantListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantsAsync = ref.watch(tenantControllerProvider);
    final allUnitsAsync = ref.watch(allUnitsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('My Tenants', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/owner/tenants/add'),
        label: Text('Add Tenant', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        icon: const Icon(Icons.person_add),
        backgroundColor: const Color(0xFF0288D1), // Light Blue for Tenants
        elevation: 4,
      ),
      body: tenantsAsync.when(
        data: (tenants) {
          if (tenants.isEmpty) {
            return Center(
               child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_alt_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No tenants found',
                    style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey[500]),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFE1F5FE),
                        child: Text(
                          tenant.name.substring(0, 1).toUpperCase(),
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF0288D1)),
                        ),
                      ),
                      title: Text(
                        tenant.name,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${tenant.phone} • Unit: $unitDisplay',
                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[500]),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: tenant.status == TenantStatus.active ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
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
            error: (e, _) => Center(child: Text('Error loading units: $e')),
          );
        },
        error: (e, st) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
