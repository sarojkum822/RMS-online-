import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../features/rent/domain/entities/rent_cycle.dart';
import '../../../widgets/dotted_line_separator.dart';

class CompactBillHistoryCard extends StatelessWidget {
  final RentCycle cycle;
  final bool isPaid;
  final bool isDark;
  final VoidCallback onPrint;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onHistory;
  final VoidCallback onAddCharges;
  final VoidCallback onRecordPayment;

  const CompactBillHistoryCard({
    super.key,
    required this.cycle,
    required this.isPaid,
    required this.isDark,
    required this.onPrint,
    required this.onEdit,
    required this.onDelete,
    required this.onHistory,
    required this.onAddCharges,
    required this.onRecordPayment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateTime.parse('${cycle.month}-01');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
        border: !isPaid
            ? Border.all(color: Colors.red.withValues(alpha: 0.6), width: 1.5)
            : (isDark ? Border.all(color: Colors.white10) : null),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          // Leading: Calendar Icon
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white12 : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.calendar_today, size: 20, color: theme.iconTheme.color),
          ),
          // Title: Month & Year
          title: Text(
            DateFormat('MMMM yyyy').format(date),
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleMedium?.color,
            ),
          ),
          // Subtitle: Meter Reading / Electricity info
          subtitle: cycle.electricAmount > 0
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(Icons.electric_bolt, size: 14, color: Colors.amber.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Elec: ₹${cycle.electricAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          // Trailing: Amount & Status
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   Text(
                      '₹${cycle.totalDue.toStringAsFixed(0)}',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: !isPaid ? Colors.red : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPaid ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        cycle.status.name.toUpperCase(),
                        style: GoogleFonts.outfit(
                          color: isPaid ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00),
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down, color: theme.hintColor), // Default expansion arrow is usually added by ExpansionTile, but we can customize or let it be. 
              // Actually ExpansionTile adds a trailing icon by default unless trailing is set. 
              // Since I set trailing, I must add the icon manually if I want it, or rely on internal state to rotate it, which is hard here.
              // Better approach: Don't set trailing in ExpansionTile if I want the default rotation animation. 
              // But I want the Amount/Status there. 
              // So I will just leave the static arrow or no arrow. 
              // Let's use `controlAffinity: ListTileControlAffinity.trailing` (default) effectively replacing the arrow. 
              // I will leave out the arrow to save space, or just a small one.
            ],
          ),
          children: [
            const Divider(height: 1),
             const SizedBox(height: 12),
            
            // Full Details View (The "Expanded" content)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bill Details', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Bill #: ${cycle.billNumber ?? "N/A"}', style: GoogleFonts.outfit(fontSize: 12, color: theme.hintColor)),
                        ],
                     ),
                     // Action Buttons Row (Print, Edit, Delete)
                     Row(
                       children: [
                         _buildIconButton(Icons.print, Colors.blue, 'Print', onPrint),
                         _buildIconButton(Icons.edit, Colors.orange, 'Edit', onEdit),
                         _buildIconButton(Icons.delete, Colors.red, 'Delete', onDelete),
                       ],
                     ),
                   ],
                 ),
                 
                 const SizedBox(height: 12),
                 
                 // Breakdown Container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                         _buildBreakdownRow(theme, 'Base Rent', cycle.baseRent, Icons.home_outlined),
                        if (cycle.electricAmount > 0)
                          _buildBreakdownRow(theme, 'Electricity', cycle.electricAmount, Icons.electric_bolt, color: Colors.amber.shade700),
                        if (cycle.otherCharges > 0)
                          _buildBreakdownRow(theme, 'Other Charges', cycle.otherCharges, Icons.add_circle_outline, color: Colors.blue.shade600),
                        if (cycle.lateFee > 0)
                          _buildBreakdownRow(theme, 'Late Fee', cycle.lateFee, Icons.warning_amber_rounded, color: Colors.red.shade600),
                        if (cycle.discount > 0)
                          _buildBreakdownRow(theme, 'Discount', -cycle.discount, Icons.discount_outlined, color: Colors.green.shade600),
                      ],
                    ),
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: DottedLineSeparator(),
                  ),
                  
                  // Total & Paid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Due', style: GoogleFonts.outfit(color: theme.textTheme.bodySmall?.color, fontSize: 11)),
                          Text(
                            '₹${cycle.totalDue.toStringAsFixed(0)}',
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: !isPaid ? Colors.red : theme.textTheme.bodyLarge?.color),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Paid', style: GoogleFonts.outfit(color: theme.textTheme.bodySmall?.color, fontSize: 11)),
                          Row(
                            children: [
                              Text(
                                '₹${cycle.totalPaid.toStringAsFixed(0)}',
                                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isPaid ? const Color(0xFF2E7D32) : Colors.red),
                              ),
                              if (cycle.totalPaid > 0) ...[
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: onHistory,
                                  child: const Icon(Icons.info_outline, size: 18, color: Colors.blue),
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  if (!isPaid) ...[
                     const SizedBox(height: 16),
                     Row(
                       children: [
                         Expanded(
                           child: OutlinedButton(
                             onPressed: onAddCharges,
                             style: OutlinedButton.styleFrom(
                                foregroundColor: theme.textTheme.bodyLarge?.color,
                                side: BorderSide(color: theme.dividerColor),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                             ),
                             child: Text('+ Charges', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                           ),
                         ),
                         const SizedBox(width: 12),
                         Expanded(
                           child: Container(
                             decoration: BoxDecoration(
                               gradient: const LinearGradient(
                                 colors: [Color(0xFFFF5252), Color(0xFF2563EB)],
                                 begin: Alignment.centerLeft,
                                 end: Alignment.centerRight,
                               ),
                               borderRadius: BorderRadius.circular(10),
                             ),
                             child: ElevatedButton(
                               onPressed: onRecordPayment,
                               style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                               ),
                               child: Text('Record Payment', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                             ),
                           ),
                         ),
                       ],
                     ),
                  ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, String tooltip, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: color, size: 20),
      tooltip: tooltip,
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildBreakdownRow(ThemeData theme, String label, double amount, IconData icon,  {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color ?? theme.hintColor),
              const SizedBox(width: 6),
              Text(label, style: GoogleFonts.outfit(fontSize: 12, color: theme.textTheme.bodyMedium?.color)),
            ],
          ),
          Text(
            amount < 0 ? '-₹${amount.abs().toStringAsFixed(0)}' : '₹${amount.toStringAsFixed(0)}', 
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: color ?? theme.textTheme.bodyLarge?.color)
          ),
        ],
      ),
    );
  }
}
