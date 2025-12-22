import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../../domain/entities/house.dart';
import '../../../providers/data_providers.dart';
import '../../owner/tenant/tenant_controller.dart';
import 'package:go_router/go_router.dart';

class TenantProfileDocsView extends ConsumerWidget {
  final Tenant tenant;
  const TenantProfileDocsView({super.key, required this.tenant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ownerId = tenant.ownerId;
    
    final tenancyAsync = ref.watch(activeTenancyForTenantAccessProvider(tenant.id, ownerId));
    final tenancy = tenancyAsync.valueOrNull;
    
    final unitId = tenancy?.unitId;
    final unitAsync = unitId != null ? ref.watch(unitDetailsForTenantProvider((unitId: unitId, ownerId: ownerId))) : const AsyncValue<Unit>.loading();
    final unit = unitAsync.valueOrNull;
    
    final houseId = unit?.houseId;
    final houseAsync = houseId != null ? ref.watch(houseDetailsForTenantProvider((houseId: houseId, ownerId: ownerId))) : const AsyncValue<House>.loading();
    final house = houseAsync.valueOrNull;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Account & Property', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(userSessionServiceProvider).clearSession();
              if (context.mounted) context.go('/');
            }, 
            icon: const Icon(Icons.logout)
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Profile Header
            _buildProfileHeader(context),
            
            const SizedBox(height: 32),

            // Property Card
            if (house != null && unit != null) _buildPropertyCard(context, house, unit),

            const SizedBox(height: 24),

            // Lease Summary Card
            if (tenancy != null) _buildLeaseCard(context, tenancy),

            const SizedBox(height: 24),

            // Documents Section
            _buildDocumentSection(context),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Text(
            tenant.name[0].toUpperCase(),
            style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
          ),
        ),
        const SizedBox(height: 16),
        Text(tenant.name, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(tenant.phone, style: GoogleFonts.outfit(color: theme.textTheme.bodySmall?.color)),
        if (tenant.email != null) Text(tenant.email!, style: GoogleFonts.outfit(color: theme.textTheme.bodySmall?.color)),
      ],
    );
  }

  Widget _buildPropertyCard(BuildContext context, House house, Unit unit) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => context.push('/tenant/house-info', extra: {
        'tenant': tenant,
        'house': house,
        'unit': unit,
      }),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.home_work_rounded, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Text('Currently Rented At', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            Text(house.name, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(house.address, style: GoogleFonts.outfit(color: theme.textTheme.bodyMedium?.color)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Unit: ${unit.nameOrNumber}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaseCard(BuildContext context, dynamic tenancy) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lease Summary', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildInfoRow('Move-in Date', DateFormat('dd MMM yyyy').format(tenancy.startDate)),
          const Divider(height: 24),
          _buildInfoRow('Monthly Rent', '₹${tenancy.agreedRent.toStringAsFixed(0)}'),
          const Divider(height: 24),
          _buildInfoRow('Security Deposit', '₹${tenancy.securityDeposit.toStringAsFixed(0)}'),
        ],
      ),
    );
  }

  Widget _buildDocumentSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Digital Vault', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildDocumentTile(context, 'Lease Agreement', 'Digital copy of your rental contract', Icons.description_rounded, Colors.blue),
        const SizedBox(height: 8),
        _buildDocumentTile(context, 'House Rules', 'Policies and guidelines for residency', Icons.gavel_rounded, Colors.orange),
        const SizedBox(height: 8),
        _buildDocumentTile(context, 'ID Proofs', 'Uploaded identity documentation', Icons.badge_rounded, Colors.green),
      ],
    );
  }

  Widget _buildDocumentTile(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: theme.cardColor,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          context.push('/tenant/document-viewer', extra: {
            'title': title,
            'content': 'This is a sample digital copy of your $title. In a real scenario, this would be a PDF or the actual contract text stored in the database.',
          });
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
