import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../../domain/entities/rent_cycle.dart';
import '../../../../core/services/user_session_service.dart';
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
            onPressed: () async {
              await ref.read(userSessionServiceProvider).clearSession();
              if (context.mounted) context.go('/');
            }, 
            icon: const Icon(Icons.logout, color: Colors.black)
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800), // Constraint for Tablets/Web
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sticky Due Card
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD3E4FF), Color(0xFFE5DEFF)], // Pastel Blue to Purple
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
                            child: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(width: 12),
                          Text('Total Outstanding', style: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      FutureBuilder<List<RentCycle>>(
                        future: rentRepo.getRentCyclesForTenant(tenant.id),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Text('Loading...', style: TextStyle(color: Colors.black54));
                          final cycles = snapshot.data!;
                          final totalDue = cycles.fold(0.0, (sum, c) => sum + (c.totalDue - c.totalPaid));
                           
                           final showPay = totalDue > 0;
            
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${totalDue.toStringAsFixed(0)}',
                                style: GoogleFonts.outfit(color: const Color(0xFF0F172A), fontSize: 40, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              if (totalDue == 0)
                                Text('You are all caught up! 🎉', style: GoogleFonts.outfit(color: const Color(0xFF059669), fontWeight: FontWeight.w600)),
                                
                              if(showPay) ...[
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Online Payment Coming Soon!')));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1E293B), // Dark Slate
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: const Text('Pay Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ]
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Payment Summary Card
                      FutureBuilder<List<Payment>>( 
                        future: ref.read(rentRepositoryProvider).getPaymentsByTenantAccess(tenant.id, tenant.ownerId),
                        builder: (context, snapshot) {
                           if (!snapshot.hasData) return const SizedBox();
                           final payments = snapshot.data!;
                           final totalPaid = payments.fold(0.0, (sum, p) => sum + p.amount);
                           final cashPaid = payments.where((p) => p.method.toLowerCase().contains('cash')).fold(0.0, (sum, p) => sum + p.amount);
                           final onlinePaid = payments.where((p) => !p.method.toLowerCase().contains('cash')).fold(0.0, (sum, p) => sum + p.amount);
                  
                           if (totalPaid == 0) return const SizedBox();
                  
                           return Container(
                             width: double.infinity,
                             padding: const EdgeInsets.all(20),
                             decoration: BoxDecoration(
                               color: Colors.white,
                               borderRadius: BorderRadius.circular(20),
                               boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                             ),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text('Lifetime Payment Summary', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                                 const SizedBox(height: 16),
                                 Row(
                                   children: [
                                     Expanded(child: _buildSummaryItem('Total Paid', totalPaid, Colors.blue)),
                                     Container(width: 1, height: 40, color: Colors.grey[200]),
                                     Expanded(child: _buildSummaryItem('Cash', cashPaid, Colors.orange)),
                                     Container(width: 1, height: 40, color: Colors.grey[200]),
                                     Expanded(child: _buildSummaryItem('Online/UPI', onlinePaid, Colors.green)),
                                   ],
                                 )
                               ],
                             ),
                           );
                        },
                      ),
                  
                      const SizedBox(height: 24),
                      Text('Your Bills', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                       
                      // List of Bills
                      FutureBuilder<List<RentCycle>>(
                          future: rentRepo.getRentCyclesByTenantAccess(tenant.id, tenant.ownerId),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                            if (!snapshot.hasData) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                            final cycles = snapshot.data!;
                            if (cycles.isEmpty) return const Center(child: Text('No bills found.'));
                            
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
                                    onTap: () => _showBillDetails(context, c, ref), // Show Details
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBillDetails(BuildContext context, RentCycle c, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: ListView(
              controller: scrollController,
              children: [
                 Text('Bill Details', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                 const SizedBox(height: 8),
                 Text('Month: ${c.month}', style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey)),
                 const SizedBox(height: 16),
                 const Divider(),
                 const SizedBox(height: 16),
                 
                 _buildRow('Base Rent', c.baseRent),
                 if(c.electricAmount > 0) _buildRow('Electricity', c.electricAmount),
                 if(c.otherCharges > 0) _buildRow('Other Charges', c.otherCharges),
                 if(c.discount > 0) _buildRow('Discount', c.discount, isNegative: true),
                 
                 const SizedBox(height: 16),
                 const Divider(),
                 const SizedBox(height: 16),

                 _buildRow('Total Due', c.totalDue, isBold: true),
                 _buildRow('Paid Amount', c.totalPaid, color: Colors.green),
                 _buildRow('Balance Due', c.totalDue - c.totalPaid, isBold: true, color: (c.totalDue - c.totalPaid) > 0 ? Colors.red : Colors.green),

                const SizedBox(height: 24),
                // Payment History Section
                Text('Payment History', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                FutureBuilder<List<Payment>>( 
                  future: ref.read(rentRepositoryProvider).getPaymentsForRentCycle(c.id),
                  builder: (context, snapshot) {
                     if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                     final payments = snapshot.data!;
                     if (payments.isEmpty) return Text('No payments recorded.', style: GoogleFonts.outfit(color: Colors.grey));

                     return Column(
                       children: payments.map((p) => Container(
                         margin: const EdgeInsets.only(bottom: 8),
                         padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(
                           color: Colors.grey[50],
                           borderRadius: BorderRadius.circular(12),
                           border: Border.all(color: Colors.grey[200]!)
                         ),
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(DateFormat('dd MMM yyyy').format(p.date), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                                 Text(p.method, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600])),
                               ],
                             ),
                             Text('₹${p.amount.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.green)),
                           ],
                         ),
                       )).toList(),
                     );
                  },
                ),
                
                const SizedBox(height: 20),
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
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text('₹${amount.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
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
