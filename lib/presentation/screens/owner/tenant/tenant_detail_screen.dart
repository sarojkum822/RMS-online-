import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../../domain/entities/rent_cycle.dart';
import '../rent/rent_controller.dart';
import '../../../providers/data_providers.dart';
import '../../../widgets/dotted_line_separator.dart';
import 'package:in_app_review/in_app_review.dart';

class TenantDetailScreen extends ConsumerStatefulWidget {
  final Tenant tenant;

  const TenantDetailScreen({super.key, required this.tenant});

  @override
  ConsumerState<TenantDetailScreen> createState() => _TenantDetailScreenState();
}

class _TenantDetailScreenState extends ConsumerState<TenantDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final rentRepo = ref.watch(rentRepositoryProvider);

    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = (screenHeight * 0.45).clamp(300.0, 420.0); // Responsive height with limits

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), 
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: Text(widget.tenant.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Dark Gradient Header with Glass Card
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 1. Deep Blue Gradient Background
                Container(
                  height: headerHeight, 
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                         Color(0xFF0F172A), // Dark Navy/Black
                         Color(0xFF1E3A8A), // Deep Blue
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),
                
                // 2. Glassmorphism Profile Card
                Positioned(
                  top: headerHeight * 0.28, // Responsive positioning
                  left: 20,
                  right: 20,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      // The Card Content
                      Container(
                        margin: const EdgeInsets.only(top: 30), // Reduced top margin for better fit
                        padding: const EdgeInsets.fromLTRB(20, 50, 20, 24), // Top padding for Avatar
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1), // Glassy see-through
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.tenant.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Info Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Unit
                                Consumer(
                                  builder: (context, ref, child) {
                                    final unitValue = ref.watch(unitDetailsProvider(widget.tenant.unitId));
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        unitValue.when(
                                          data: (u) => 'Flat No- ${u?.nameOrNumber ?? 'N/A'}, Floor - ${u?.floor ?? '-'}',
                                          error: (e, _) => 'Unit ID: ${widget.tenant.unitId}', 
                                          loading: () => 'Loading...'
                                        ),
                                        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                const Text('•', style: TextStyle(color: Colors.white30)),
                                const SizedBox(width: 8),
                                // Clickable Phone
                                InkWell(
                                  onTap: () {
                                     Clipboard.setData(ClipboardData(text: widget.tenant.phone));
                                     ScaffoldMessenger.of(context).showSnackBar(
                                       const SnackBar(content: Text('Phone copied'), duration: Duration(seconds: 1)),
                                     );
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(Icons.phone, size: 14, color: Colors.greenAccent),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.tenant.phone,
                                        style: GoogleFonts.outfit(fontSize: 14, color: Colors.greenAccent),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            Consumer(
                              builder: (context, ref, child) {
                                final initialReadingValue = ref.watch(initialReadingProvider(widget.tenant.unitId));
                                return initialReadingValue.when(
                                  data: (reading) => reading != null 
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.flash_on, size: 14, color: Colors.amber),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Initial Reading: $reading',
                                                style: GoogleFonts.outfit(color: Colors.amberAccent, fontSize: 13, fontWeight: FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                  error: (_, __) => const SizedBox.shrink(),
                                  loading: () => const SizedBox.shrink(),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            const Divider(color: Colors.white24, height: 1),
                            const SizedBox(height: 12),
                            
                            // Stats / Extra info placeholders
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    const Icon(Icons.verified, color: Colors.blueAccent, size: 20),
                                    const SizedBox(height: 4),
                                    Text('Verified', style: GoogleFonts.outfit(color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Icon(Icons.history, color: Colors.orangeAccent, size: 20),
                                    const SizedBox(height: 4),
                                    Text('Since 2023', style: GoogleFonts.outfit(color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Floating Avatar with Ring
                      Positioned(
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.greenAccent.withValues(alpha: 0.8), Colors.blueAccent.withValues(alpha: 0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 2),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: const Color(0xFF0F172A), 
                            backgroundImage: widget.tenant.imageUrl != null ? NetworkImage(widget.tenant.imageUrl!) : null,
                            child: widget.tenant.imageUrl == null ? Text(
                              widget.tenant.name[0].toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ) : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60), // Increased spacing as requested

            // "Bill History" Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0), // Added vertical margin
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bill History',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                   const SizedBox(width: 8),
                   Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddPastRecordDialog(context, ref),
                      icon: const Icon(Icons.history, size: 18, color: Colors.white),
                      label: FittedBox(child: Text('Add Past Record', style: GoogleFonts.outfit(fontWeight: FontWeight.w600))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A), // Dark Navy
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: const Color(0xFF0F172A).withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),

            // List
            ref.watch(rentCyclesForTenantProvider(widget.tenant.id)).when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
              error: (e, s) => Center(child: Text('Error: $e')),
              data: (data) {
                final cycles = List<RentCycle>.from(data)..sort((a,b) => b.month.compareTo(a.month));
                
                if (cycles.isEmpty) return const Padding(padding: EdgeInsets.all(40), child: Text('No history'));

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: cycles.length,
                  itemBuilder: (context, index) {
                    final cycle = cycles[index];
                    final isPaid = cycle.status == RentStatus.paid;
                    final date = DateTime.parse('${cycle.month}-01');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04), 
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100], 
                                        borderRadius: BorderRadius.circular(12)
                                      ),
                                      child: const Icon(Icons.calendar_today, size: 20, color: Colors.black87),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      DateFormat('MMMM yyyy').format(date),
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                // Status + Menu
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isPaid ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        cycle.status.name.toUpperCase(),
                                        style: GoogleFonts.outfit(
                                          color: isPaid ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Menu for Actions (Delete)
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                           _confirmDeleteBill(context, ref, cycle);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, color: Colors.red, size: 20),
                                              SizedBox(width: 8),
                                              Text('Delete Bill', style: TextStyle(color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 54.0), // Align with text
                              child: Text(
                                'Bill #: ${cycle.billNumber ?? "N/A"}',
                                style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[500]),
                              ),
                            ),
                            
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.0),
                              child: DottedLineSeparator(), 
                            ),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total Due', style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${cycle.totalDue.toStringAsFixed(0)}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Paid', style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '₹${cycle.totalPaid.toStringAsFixed(0)}',
                                          style: GoogleFonts.outfit(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: isPaid ? const Color(0xFF2E7D32) : Colors.black87,
                                          ),
                                        ),
                                        if (cycle.totalPaid > 0) ...[
                                           const SizedBox(width: 4),
                                           IconButton(
                                             icon: const Icon(Icons.info_outline, size: 18, color: Colors.blue),
                                             onPressed: () => _showPaymentHistory(context, ref, cycle),
                                             tooltip: 'View History',
                                             constraints: const BoxConstraints(),
                                             padding: EdgeInsets.zero,
                                           )
                                        ]
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            // Actions if Pending
                            if(!isPaid) ...[
                               const SizedBox(height: 20),
                               Row(
                                 children: [
                                   Expanded(
                                     child: OutlinedButton(
                                       onPressed: () => _showChargesSheet(context, cycle, ref),
                                       style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(0xFF0F172A),
                                          side: const BorderSide(color: Color(0xFF0F172A)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                       ),
                                       child: Text('+ Charges', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                                     ),
                                   ),
                                   const SizedBox(width: 12),
                                   Expanded(
                                     child: ElevatedButton(
                                       onPressed: () => _showPaymentSheet(context, cycle, ref),
                                       style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF0F172A),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          elevation: 2,
                                       ),
                                       child: Text('Record Payment', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                                     ),
                                   ),
                                 ],
                               )
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showAddPastRecordDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final paidController = TextEditingController(); 
    DateTime selectedMonth = DateTime.now().subtract(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Past Record'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Record a bill from your manual register.', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 16),
              
              InkWell(
                onTap: () async {
                   final d = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime.now(), initialDate: selectedMonth);
                   if(d != null) setState(() => selectedMonth = d);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Select Month', border: OutlineInputBorder()),
                  child: Text(DateFormat('MMMM yyyy').format(selectedMonth)),
                ),
              ),
              const SizedBox(height: 12),
              
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Bill Amount (₹)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: paidController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount Paid (Optional)', helperText: 'Leave empty if Unpaid', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final amt = double.tryParse(amountController.text) ?? 0;
                final paid = double.tryParse(paidController.text) ?? 0;
                if (amt > 0) {
                  await ref.read(rentControllerProvider.notifier).addPastRentCycle(
                    tenantId: widget.tenant.id,
                    month: DateFormat('yyyy-MM').format(selectedMonth),
                    totalDue: amt,
                    totalPaid: paid,
                    date: DateTime.now(),
                  );
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Save Record'),
            ),
          ],
        ),
      ),
    );
  }

  // --- Deletion Dialogs ---

  void _confirmDeleteBill(BuildContext context, WidgetRef ref, RentCycle cycle) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final isMatch = controller.text.trim() == 'DELETE';
          return AlertDialog(
            title: const Text('Delete Information'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Warning: This action is permanent and cannot be undone.',
                          style: GoogleFonts.outfit(color: Colors.red[900], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'To confirm deletion of the bill for ${cycle.month}, please type "DELETE" below:',
                  style: GoogleFonts.outfit(fontSize: 14),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'DELETE',
                  ),
                  onChanged: (val) => setState(() {}),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  disabledBackgroundColor: Colors.red.withValues(alpha: 0.3),
                ),
                onPressed: isMatch ? () async {
                  Navigator.pop(context); // Close dialog
                  try {
                     await ref.read(rentControllerProvider.notifier).deleteBill(cycle.id, widget.tenant.id);
                     if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bill deleted')));
                     }
                  } catch (e) {
                     if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                     }
                  }
                } : null, // Disable if not matching
                child: const Text('Delete Forever', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showPaymentHistory(BuildContext context, WidgetRef ref, RentCycle cycle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payment History', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: FutureBuilder<List<Payment>>(
                    future: ref.read(rentRepositoryProvider).getPaymentsForRentCycle(cycle.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                      final payments = snapshot.data ?? [];
                      if (payments.isEmpty) return const Center(child: Text('No payments found'));

                      return ListView.builder(
                        itemCount: payments.length,
                        itemBuilder: (context, index) {
                          final p = payments[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            color: Colors.grey[50],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(Icons.check, color: Colors.green),
                              ),
                              title: Text('₹${p.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${DateFormat('dd MMM').format(p.date)} via ${p.method}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  // Confirm Delete Payment
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Transaction?'),
                                      content: const Text('This will reduce the "Paid" amount for this bill.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                        TextButton(
                                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                                          onPressed: () async {
                                            Navigator.pop(ctx); // Close Alert
                                            
                                            await ref.read(rentControllerProvider.notifier).deletePayment(p.id, cycle.id, widget.tenant.id);
                                            
                                            // Refresh Sheet
                                            setSheetState(() {});
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    )
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  void _showPaymentSheet(BuildContext context, RentCycle cycle, WidgetRef ref) {
    final amountController = TextEditingController(text: (cycle.totalDue - cycle.totalPaid).toStringAsFixed(0));
    final refController = TextEditingController();
    final notesController = TextEditingController();
    String selectedMethod = 'Cash';
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Record Payment', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              // Amount
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount (₹)',
                  prefixIcon: const Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              
              // Date Picker
              InkWell(
                onTap: () async {
                  final d = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2030), initialDate: selectedDate);
                  if(d != null) setSheetState(() => selectedDate = d);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Payment Date', style: GoogleFonts.outfit(color: Colors.grey[700])),
                      Text(DateFormat('dd MMM yyyy').format(selectedDate), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Method Dropdown
              DropdownButtonFormField<String>(
                initialValue: selectedMethod,
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ['Cash', 'UPI', 'Bank Transfer', 'Cheque'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setSheetState(() => selectedMethod = v!),
              ),
              const SizedBox(height: 16),
              
              // Reference ID
              TextField(
                controller: refController,
                decoration: InputDecoration(
                  labelText: 'Reference / Transaction ID',
                  hintText: 'e.g. UPI Ref, Cheque No',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00897B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                     final amount = double.tryParse(amountController.text) ?? 0.0;
                     if(amount <= 0) return;

                     await ref.read(rentControllerProvider.notifier).recordPayment(
                       rentCycleId: cycle.id,
                       tenantId: cycle.tenantId,
                       amount: amount,
                       date: selectedDate,
                       method: selectedMethod,
                       referenceId: refController.text.isEmpty ? null : refController.text,
                       notes: notesController.text.isEmpty ? null : notesController.text,
                     );
                     
                     if (context.mounted) {
                       Navigator.pop(context);
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Recorded')));
                       
                       // Prompt for Review if available
                       final InAppReview inAppReview = InAppReview.instance;
                       if (await inAppReview.isAvailable()) {
                         inAppReview.requestReview();
                       }
                     }
                  },
                  child: const Text('Save Payment', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showChargesSheet(BuildContext context, RentCycle cycle, WidgetRef ref) async {
    final prevReadingController = TextEditingController();
    final currReadingController = TextEditingController();
    final rateController = TextEditingController(text: '10'); 
    
    final chargeAmountController = TextEditingController();
    final chargeNoteController = TextEditingController();

    // Determine Pre-fills (Async)
    double? lastReading;
    double? lastRate;
    
    try {
      // Note: RentCycle doesn't have unitId, Tenant has unitId.
      final tenant = widget.tenant; // Since we are on TenantDetailScreen, we have the tenant.
      
      final readingData = await ref.read(rentControllerProvider.notifier).getLastElectricReading(tenant.unitId);
      if (readingData != null) {
        lastReading = readingData['currentReading'];
        lastRate = readingData['rate'];
      } else {
        // Fallback: If no "Last" reading (e.g. first month), try "Initial Reading"
        // This handles cases where only 1 reading exists (the initial one) and maybe the desc-sort query failed or returned nothing?
        // Actually, logic says Last Reading SHOULD return the initial one if it's the only one.
        // But let's be explicit to satisfy user request "previous reading should become initial reading".
        final initial = await ref.read(initialReadingProvider(tenant.unitId).future);
        if (initial != null) {
          lastReading = initial;
        }
      }
    } catch (e) {
      debugPrint('Error auto-filling readings: $e');
      // If error (e.g. index missing for "Last" query), try "Initial" query as backup
      try {
         final initial = await ref.read(initialReadingProvider(widget.tenant.unitId).future);
         if(initial != null) lastReading = initial;
      } catch (_) {}
    }

    if (lastReading != null) {
      prevReadingController.text = lastReading.toString();
    }
    if (lastRate != null) {
      rateController.text = lastRate.toString();
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DefaultTabController(
        length: 2,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TabBar(
                labelColor: Colors.teal,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.teal,
                tabs: [
                  Tab(text: 'Electricity', icon: Icon(Icons.electric_bolt)),
                  Tab(text: 'Other Charges', icon: Icon(Icons.post_add)),
                ],
              ),
              SizedBox(
                height: 300,
                child: TabBarView(
                  children: [
                    // Electricity Tab
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        TextField(
                          controller: prevReadingController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Previous Reading', 
                            border: const OutlineInputBorder(),
                            helperText: lastReading != null ? 'Auto-filled from last reading' : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                         TextField(
                          controller: currReadingController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Current Reading', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                         TextField(
                          controller: rateController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Rate per Unit (₹)', border: OutlineInputBorder()),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final prev = double.tryParse(prevReadingController.text) ?? 0;
                              final curr = double.tryParse(currReadingController.text) ?? 0;
                              final rate = double.tryParse(rateController.text) ?? 0;
                              
                              if (curr > prev) {
                                await ref.read(rentControllerProvider.notifier).updateRentCycleWithElectric(
                                  rentCycleId: cycle.id,
                                  prevReading: prev,
                                  currentReading: curr,
                                  ratePerUnit: rate,
                                );
                                if (context.mounted) Navigator.pop(context);
                                setState(() {});
                              }
                            },
                            child: const Text('Calculate & Save'),
                          ),
                        )
                      ],
                    ),
                    
                    // Other Charges Tab
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        TextField(
                          controller: chargeAmountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder()),
                        ),
                         const SizedBox(height: 12),
                         TextField(
                          controller: chargeNoteController,
                          decoration: const InputDecoration(labelText: 'Charge Description (e.g. Maintenance)', border: OutlineInputBorder()),
                        ),
                        const Spacer(),
                         SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final amt = double.tryParse(chargeAmountController.text) ?? 0;
                              if (amt > 0) {
                                await ref.read(rentControllerProvider.notifier).addOtherCharge(
                                  rentCycleId: cycle.id,
                                  amount: amt,
                                  note: chargeNoteController.text,
                                );
                                if (context.mounted) Navigator.pop(context);
                                setState(() {});
                              }
                            },
                            child: const Text('Add Charge'),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
