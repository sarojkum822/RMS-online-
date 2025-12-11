import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../../domain/entities/rent_cycle.dart';

import '../../providers/data_providers.dart';

class TenantDashboardScreen extends ConsumerWidget {
  final Tenant tenant; // Logged in tenant

  const TenantDashboardScreen({super.key, required this.tenant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rentRepo = ref.watch(rentRepositoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Welcome, ${tenant.name}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: (){
              context.go('/'); // Logout
            }, 
            icon: const Icon(Icons.logout, color: Colors.black)
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Due Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1976D2)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Outstanding', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  FutureBuilder<List<RentCycle>>(
                    future: rentRepo.getRentCyclesForTenant(tenant.id),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Text('...', style: TextStyle(color: Colors.white));
                      final cycles = snapshot.data!;
                      final totalDue = cycles.fold(0.0, (sum, c) => sum + (c.totalDue - c.totalPaid));
                       
                       // Only show Pay button if there is due
                       final showPay = totalDue > 0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${totalDue.toStringAsFixed(0)}',
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          if(showPay) ...[
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Online Payment Coming Soon!')));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF0D47A1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Pay Now'),
                            ),
                          ]
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Your Bills', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
             
            // List of Bills
            FutureBuilder<List<RentCycle>>(
                future: rentRepo.getRentCyclesForTenant(tenant.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator());
                  final cycles = snapshot.data!;
                  
                  // Sort by month desc
                  cycles.sort((a,b) => b.month.compareTo(a.month));

                  if(cycles.isEmpty) return const Padding(padding: EdgeInsets.only(top: 20), child: Text('No bills found.'));

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: cycles.length,
                    itemBuilder: (context, index) {
                      final c = cycles[index];
                      final isPaid = c.status == RentStatus.paid;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                        color: Colors.white,
                        child: InkWell(
                          onTap: () => _showBillDetails(context, c), // Show Details
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(
                                  isPaid ? Icons.check_circle : Icons.pending,
                                  color: isPaid ? Colors.green : Colors.orange,
                                  size: 32,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(DateFormat('MMMM yyyy').format(DateTime.parse('${c.month}-01')), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text('Bill: ${c.billNumber ?? 'N/A'}', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('₹${c.totalDue.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                                    if(isPaid)
                                      Text('PAID', style: GoogleFonts.outfit(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold))
                                    else
                                      Text('Due: ₹${(c.totalDue - c.totalPaid).toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
             )
          ],
        ),
      ),
    );
  }

  void _showBillDetails(BuildContext context, RentCycle c) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bill Details', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Month: ${DateFormat('MMMM yyyy').format(DateTime.parse('${c.month}-01'))}', style: GoogleFonts.outfit(color: Colors.grey)),
            const Divider(height: 32),
            
            _buildRow('Base Rent', c.baseRent),
            if(c.electricAmount > 0) _buildRow('Electricity', c.electricAmount),
            if(c.otherCharges > 0) _buildRow('Other Charges', c.otherCharges),
            if(c.discount > 0) _buildRow('Discount', -c.discount, isNegative: true),
            
            const Divider(height: 24),
            _buildRow('Total Due', c.totalDue, isBold: true),
            _buildRow('Paid Amount', c.totalPaid, color: Colors.green),
            const SizedBox(height: 8),
            _buildRow('Balance Due', c.totalDue - c.totalPaid, isBold: true, color: (c.totalDue - c.totalPaid) > 0 ? Colors.red : Colors.green),

            const SizedBox(height: 24),
            if(c.notes != null && c.notes!.isNotEmpty)
               Container(
                 width: double.infinity,
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                 child: Text('Notes:\n${c.notes}', style: GoogleFonts.outfit(fontSize: 12)),
               ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, double amount, {bool isBold = false, Color? color, bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 16)),
          Text(
            '${isNegative ? "- " : ""}₹${amount.toStringAsFixed(0)}', 
            style: GoogleFonts.outfit(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal, 
              fontSize: 16,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
