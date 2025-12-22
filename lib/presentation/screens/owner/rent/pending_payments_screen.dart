import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../features/rent/domain/entities/rent_cycle.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../providers/data_providers.dart'; // Fixed import path
import '../rent/rent_controller.dart';
import '../tenant/tenant_controller.dart';
import '../../../widgets/empty_state_widget.dart';

class PendingPaymentsScreen extends ConsumerStatefulWidget {
  const PendingPaymentsScreen({super.key});

  @override
  ConsumerState<PendingPaymentsScreen> createState() => _PendingPaymentsScreenState();
}

class _PendingPaymentsScreenState extends ConsumerState<PendingPaymentsScreen> {

  Future<void> _sendReminder(Tenant tenant, RentCycle cycle, String currencySymbol) async {
    final monthStr = DateFormat('MMMM yyyy').format(cycle.billPeriodStart ?? cycle.billGeneratedDate);
    final amountStr = '$currencySymbol${cycle.totalDue.toStringAsFixed(0)}';
    
    // Secure Message Generation
    // We construct the message programmatically to ensure details are correct.
    // While we cannot prevent the user from editing it in WhatsApp before sending,
    // we provide a strict template.
    // TODO: Include a secure payment link from Owner Profile if available.
    
    final message = '''
🔐 *Payment Reminder*
------------------------
Hi ${tenant.name},

Your rent for *$monthStr* is pending.

Amount Due: *$amountStr*
Due Date: ${DateFormat('dd MMM yyyy').format(cycle.dueDate ?? cycle.billGeneratedDate)}

*Please pay securely using the agreed method.*
(Verify the payee name before transferring)

Thank you!
------------------------
''';

    try {
       String phone = tenant.phone.replaceAll(RegExp(r'\D'), '');
       if (phone.length == 10) phone = '91$phone'; // Default to India if no code
       
       final url = Uri.parse("whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}");
       if (await canLaunchUrl(url)) {
         await launchUrl(url, mode: LaunchMode.externalApplication);
       } else {
          // Fallback
          await Share.share(message);
       }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open WhatsApp: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final rentAsync = ref.watch(rentControllerProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Pending Payments', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: rentAsync.when(
        data: (cycles) {
           // Filter for Pending only
           final pendingCycles = cycles.where((c) => c.status.name != 'paid').toList();
           
           if (pendingCycles.isEmpty) {
             return Center(child: EmptyStateWidget(title: 'All Clear!', subtitle: 'No pending payments found.', icon: Icons.check_circle_outline));
           }
           
           // Sort by Date (Oldest First - High Priority)
           pendingCycles.sort((a, b) {
              final dateA = a.billPeriodStart ?? a.billGeneratedDate;
              final dateB = b.billPeriodStart ?? b.billGeneratedDate;
              return dateA.compareTo(dateB);
           });

           // We need tenant details. Assuming allTenanciesProvider and tenantControllerProvider are available.
           final tenanciesAsync = ref.watch(allTenanciesProvider);
           final tenantsAsync = ref.watch(tenantControllerProvider);

           return tenanciesAsync.when(
             data: (tenancies) {
               return tenantsAsync.when(
                 data: (tenants) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: pendingCycles.length,
                      itemBuilder: (context, index) {
                        final cycle = pendingCycles[index];
                        // Join Logic
                        final tenancy = tenancies.where((t) => t.id == cycle.tenancyId).firstOrNull;
                        final tenant = tenants.where((t) => t.id == tenancy?.tenantId).firstOrNull;
                        
                        if (tenant == null) return const SizedBox.shrink(); // Should not happen
                        
                        // Calculate if "Overdue" (Late)
                        final now = DateTime.now();
                        final currentMonthStart = DateTime(now.year, now.month, 1);
                        final cycleDate = cycle.billPeriodStart ?? cycle.billGeneratedDate;
                        final isLate = cycleDate.isBefore(currentMonthStart);
                        
                        return _buildPaymentCard(context, cycle, tenant, isLate);
                      },
                    );
                 },
                 loading: () => const Center(child: CircularProgressIndicator()),
                 error: (e, s) => Center(child: Text('Error loading tenants: $e')),
               );
             },
             loading: () => const Center(child: CircularProgressIndicator()),
             error: (e, s) => Center(child: Text('Error loading tenancies: $e')),
           );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, RentCycle cycle, Tenant tenant, bool isLate) {
    final theme = Theme.of(context);
    final currencySymbol = CurrencyUtils.getSymbol('INR'); // TODO: Get from Owner Prefs
    
    return Dismissible(
      key: Key(cycle.id),
      direction: DismissDirection.startToEnd, // Swipe right to call
      confirmDismiss: (direction) async {
        // Launch phone dialer
        final phone = tenant.phone.replaceAll(RegExp(r'\D'), '');
        final url = Uri.parse('tel:$phone');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not launch dialer')),
            );
          }
        }
        return false; // Don't dismiss the card
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            const Icon(Icons.phone, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text('Call ${tenant.name.split(' ').first}', 
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
          border: Border.all(
            color: isLate ? Colors.red.withValues(alpha: 0.3) : Colors.transparent,
          )
        ),
        child: Column(
          children: [
            Row(
               children: [
                  // Avatar
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: isLate ? Colors.red.withValues(alpha: 0.1) : theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tenant.name[0].toUpperCase(),
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: isLate ? Colors.red : theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(tenant.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                         Text(
                           DateFormat('MMMM yyyy').format(cycle.billPeriodStart ?? cycle.billGeneratedDate),
                           style: GoogleFonts.outfit(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6), fontSize: 13),
                         ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$currencySymbol${cycle.totalDue.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
                      if (isLate)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                          child: Text('Overdue', style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                    ],
                  )
               ],
            ),
            const SizedBox(height: 16),
            // Remind Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _sendReminder(tenant, cycle, currencySymbol),
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: Text('Send Secure Reminder', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
