import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../../features/rent/domain/entities/rent_cycle.dart';
import '../../../providers/data_providers.dart';
import '../../owner/tenant/tenant_controller.dart';

class TenantPaymentsView extends StatefulWidget {
  final Tenant tenant;
  const TenantPaymentsView({super.key, required this.tenant});

  @override
  State<TenantPaymentsView> createState() => _TenantPaymentsViewState();
}

class _TenantPaymentsViewState extends State<TenantPaymentsView> {
  String _filterMethod = 'All';

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final ownerId = widget.tenant.ownerId;
        
        final tenancyAsync = ref.watch(activeTenancyForTenantAccessProvider(widget.tenant.id, ownerId));
        final tenancy = tenancyAsync.valueOrNull;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text('tenant.payment_history'.tr(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            elevation: 0,
          ),
          body: tenancy == null 
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Summary Header
                  _buildSummaryHeader(context, ref, tenancy.id, ownerId),
                  
                  // Transactions Label
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        Text('tenant.all_transactions'.tr(), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        PopupMenuButton<String>(
                          initialValue: _filterMethod,
                          onSelected: (v) => setState(() => _filterMethod = v),
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'All', child: Text('tenant.all_methods'.tr())),
                            PopupMenuItem(value: 'Cash', child: Text('reports.cash'.tr())),
                            PopupMenuItem(value: 'Online', child: Text('tenant.online_upi'.tr())),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.filter_list_rounded, color: theme.colorScheme.primary, size: 16),
                                const SizedBox(width: 4),
                                Text(_filterMethod, style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Transactions List
                  Expanded(
                    child: StreamBuilder<List<Payment>>(
                      stream: ref.read(rentRepositoryProvider).watchPaymentsByTenancyAccess(tenancy.id, ownerId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        var payments = snapshot.data ?? [];
                        
                        if (_filterMethod != 'All') {
                          payments = payments.where((p) {
                            if (_filterMethod == 'Cash') return p.method.toLowerCase().contains('cash');
                            return !p.method.toLowerCase().contains('cash');
                          }).toList();
                        }

                        if (payments.isEmpty) {
                          return _buildEmptyState(context);
                        }

                        // Sort by date desc
                        payments.sort((a, b) => b.date.compareTo(a.date));

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: payments.length,
                          itemBuilder: (context, index) {
                            final p = payments[index];
                            return _buildPaymentTile(context, ref, p);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
        );
      },
    );
  }

  Widget _buildSummaryHeader(BuildContext context, WidgetRef ref, String tenancyId, String ownerId) {
    final theme = Theme.of(context);

    return StreamBuilder<List<Payment>>(
      stream: ref.read(rentRepositoryProvider).watchPaymentsByTenancyAccess(tenancyId, ownerId),
      builder: (context, snapshot) {
        final payments = snapshot.data ?? [];
        final totalPaid = payments.fold(0.0, (sum, p) => sum + p.amount);
        
        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'tenant.total_paid'.tr(),
                style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.8), fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '₹${totalPaid.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatItem('tenant.all_transactions'.tr(), '${payments.length}', Colors.white),
                  const SizedBox(width: 32),
                  _buildStatItem('reports.collected'.tr(), '${payments.length}', Colors.white),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: GoogleFonts.outfit(color: color.withValues(alpha: 0.7), fontSize: 12)),
      ],
    );
  }

  Widget _buildPaymentTile(BuildContext context, WidgetRef ref, Payment p) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCash = p.method.toLowerCase().contains('cash');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark ? const BorderSide(color: Colors.white10) : BorderSide.none,
      ),
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black12,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isCash ? Colors.orange : Colors.green).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCash ? Icons.money_rounded : Icons.payments_rounded,
            color: isCash ? Colors.orange : Colors.green,
          ),
        ),
        title: Text(
          p.method,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          DateFormat('dd MMM yyyy • hh:mm a').format(p.date),
          style: GoogleFonts.outfit(fontSize: 12, color: theme.textTheme.bodySmall?.color),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '₹${p.amount.toStringAsFixed(0)}',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.download_rounded, size: 20),
              onPressed: () => _downloadReceipt(context, ref, p),
              tooltip: 'tenant.download_receipt'.tr(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 64, color: theme.dividerColor),
          const SizedBox(height: 16),
          Text('tenant.no_payments'.tr(), style: GoogleFonts.outfit(fontSize: 18, color: theme.textTheme.bodySmall?.color)),
        ],
      ),
    );
  }

  Future<void> _downloadReceipt(BuildContext context, WidgetRef ref, Payment payment) async {
    // Show Loading
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (c) => const Center(child: CircularProgressIndicator())
    );
    
    try {
      final rentRepo = ref.read(rentRepositoryProvider);
      final houseRepo = ref.read(propertyRepositoryProvider);
      final pdfService = ref.read(pdfGeneratorServiceProvider);
      
      // 1. Fetch the cycle this payment belongs to
      final cycles = await rentRepo.getRentCyclesByTenancyAccess(payment.tenancyId, widget.tenant.ownerId);
      final cycle = cycles.firstWhere((c) => c.id == payment.rentCycleId);
      
      // 2. Fetch dependencies for PDF
      final tenancy = await ref.read(tenantRepositoryProvider).getTenancyForAccess(payment.tenancyId, widget.tenant.ownerId);
      if (tenancy == null) throw Exception('Tenancy not found');
      
      final unit = await houseRepo.getUnitForTenant(tenancy.unitId, widget.tenant.ownerId);
      if (unit == null) throw Exception('Unit details not found');
      
      final house = await houseRepo.getHouseForTenant(unit.houseId, widget.tenant.ownerId);
      final owner = await ref.read(ownerByIdProvider(widget.tenant.ownerId).future);
      
      if (house == null) throw Exception('Property details not found');

      // 3. Generate PDF
      final pdfBytes = await pdfService.generateRentReceipt(
        tenantName: widget.tenant.name,
        ownerName: owner?.name ?? 'Landlord',
        propertyAddress: '${house.name}, ${house.address}, Unit: ${unit.nameOrNumber}',
        amount: payment.amount,
        date: payment.date,
        paymentMethod: payment.method,
        receiptNumber: 'RCP-${payment.id.substring(0, 6).toUpperCase()}',
        currencySymbol: owner?.currency == 'INR' ? '₹' : (owner?.currency ?? '₹'),
      );

      if (context.mounted) Navigator.pop(context); // Close Loading

      // 4. Share/Print
      await Printing.sharePdf(bytes: pdfBytes, filename: 'Receipt_${DateFormat('dd_MMM').format(payment.date)}.pdf');

    } catch (e) {
      debugPrint('Error generating receipt: $e');
      if (context.mounted) {
        Navigator.pop(context); // Close Loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
