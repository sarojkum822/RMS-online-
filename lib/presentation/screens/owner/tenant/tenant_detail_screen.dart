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
                          color: Colors.white.withOpacity(0.1), // Glassy see-through
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
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
                                        color: Colors.white.withOpacity(0.15),
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
                                            color: Colors.amber.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: Colors.amber.withOpacity(0.3)),
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
                              colors: [Colors.greenAccent.withOpacity(0.8), Colors.blueAccent.withOpacity(0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.greenAccent.withOpacity(0.3), blurRadius: 12, spreadRadius: 2),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: const Color(0xFF0F172A), // Match bg
                            child: Text(
                              widget.tenant.name[0].toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
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
                        shadowColor: const Color(0xFF0F172A).withOpacity(0.4),
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
                            color: Colors.black.withOpacity(0.04), 
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
                                    Text(
                                      '₹${cycle.totalPaid.toStringAsFixed(0)}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: isPaid ? const Color(0xFF2E7D32) : Colors.black87,
                                      ),
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
                value: selectedMethod,
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

  void _showChargesSheet(BuildContext context, RentCycle cycle, WidgetRef ref) {
    final prevReadingController = TextEditingController();
    final currReadingController = TextEditingController();
    final rateController = TextEditingController(text: '10'); 
    
    final chargeAmountController = TextEditingController();
    final chargeNoteController = TextEditingController();

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
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Previous Reading', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                         TextField(
                          controller: currReadingController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Current Reading', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                         TextField(
                          controller: rateController,
                          keyboardType: TextInputType.number,
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
                          keyboardType: TextInputType.number,
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
