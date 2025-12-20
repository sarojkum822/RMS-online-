import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/entities/owner.dart';
import '../../features/rent/domain/entities/rent_cycle.dart';
import '../../domain/entities/tenant.dart';

class PdfService {
  Future<Uint8List> generateStatement({
    required Tenant tenant,
    required List<RentCycle> cycles,
    required Owner owner,
  }) async {
    final pdf = pw.Document();

    // Sort cycles by date (Oldest first)
    final sortedCycles = List<RentCycle>.from(cycles);
    sortedCycles.sort((a, b) {
      final dateA = a.billPeriodStart ?? a.billGeneratedDate;
      final dateB = b.billPeriodStart ?? b.billGeneratedDate;
      return dateA.compareTo(dateB);
    });

    // Calculate totals
    double totalDue = 0;
    double totalPaid = 0;
    
      final tableData = <Map<String, dynamic>>[];
    double runningBalance = 0;

    for (var cycle in sortedCycles) {
      totalDue += cycle.totalDue;
      totalPaid += cycle.totalPaid;
      
      final currentDue = cycle.totalDue;
      final currentPaid = cycle.totalPaid;
      final balance = currentDue - currentPaid;
      runningBalance += balance;

      final dateStr = DateFormat('MMM yyyy').format(cycle.billPeriodStart ?? cycle.billGeneratedDate);
      
      // Determine if this row should be highlighted (Red)
      // Logic: Highlight if strictly NO payment made (currentPaid == 0)
      final isUnpaid = currentPaid == 0;
      
      tableData.add({
        'values': [
          dateStr,
          '${owner.currency} ${currentDue.toStringAsFixed(0)}',
          '${owner.currency} ${currentPaid.toStringAsFixed(0)}',
          '${owner.currency} ${runningBalance.toStringAsFixed(0)}',
        ],
        'isUnpaid': isUnpaid,
      });
    }
    
    final outstanding = totalDue - totalPaid;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(owner),
            pw.SizedBox(height: 20),
            _buildTitle(),
            pw.SizedBox(height: 20),
            _buildInfoRecipients(tenant, owner),
            pw.SizedBox(height: 30),
            _buildSummary(owner.currency, totalDue, totalPaid, outstanding),
            pw.SizedBox(height: 30),
            _buildTable(tableData),
            pw.SizedBox(height: 40),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(Owner owner) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          owner.name.toUpperCase(),
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 20,
            color: PdfColors.blueGrey900,
          ),
        ),
        pw.Text(
          'KirayaBook Pro',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 12,
            color: PdfColors.grey500,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTitle() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 2)),
      ),
      child: pw.Text(
        'STATEMENT OF ARREARS',
        style: pw.TextStyle(
          fontSize: 24,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue800,
        ),
      ),
    );
  }

  pw.Widget _buildInfoRecipients(Tenant tenant, Owner owner) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('TO:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
            pw.SizedBox(height: 4),
            pw.Text(tenant.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            pw.Text(tenant.phone),
            pw.Text('Tenant ID: ${tenant.tenantCode}'),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('DATE:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
            pw.SizedBox(height: 4),
            pw.Text(DateFormat('dd MMM yyyy').format(DateTime.now())),
          ],
        ),
      ],
    );
  }
  
  pw.Widget _buildSummary(String currency, double totalDue, double totalPaid, double outstanding) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('TOTAL BILLED', '$currency ${totalDue.toStringAsFixed(0)}', PdfColors.black),
          _buildSummaryItem('TOTAL PAID', '$currency ${totalPaid.toStringAsFixed(0)}', PdfColors.green700),
          _buildSummaryItem('OUTSTANDING', '$currency ${outstanding.toStringAsFixed(0)}', PdfColors.red700, isBold: true),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryItem(String label, String value, PdfColor color, {bool isBold = false}) {
    return pw.Column(
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTable(List<Map<String, dynamic>> data) {
    return pw.Table(
      border: null,
      children: [
        // Header Row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue700),
          children: ['Month', 'Amount Due', 'Amount Paid', 'Balance']
              .map((text) => pw.Container(
                    padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    alignment: text == 'Month' ? pw.Alignment.centerLeft : pw.Alignment.centerRight,
                    child: pw.Text(
                      text,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                    ),
                  ))
              .toList(),
        ),
        // Data Rows
        ...data.map((row) {
          final isUnpaid = row['isUnpaid'] as bool;
          final values = row['values'] as List<String>;
          final textColor = isUnpaid ? PdfColors.red700 : PdfColors.black;
          
          return pw.TableRow(
            decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
            children: [
              // Month
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(values[0], style: pw.TextStyle(color: textColor)),
              ),
              // Due
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                alignment: pw.Alignment.centerRight,
                child: pw.Text(values[1], style: pw.TextStyle(color: textColor)),
              ),
              // Paid
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                alignment: pw.Alignment.centerRight,
                child: pw.Text(values[2], style: pw.TextStyle(color: textColor, fontWeight: isUnpaid ? pw.FontWeight.bold : null)),
              ),
               // Balance
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                alignment: pw.Alignment.centerRight,
                child: pw.Text(values[3], style: pw.TextStyle(color: textColor, fontWeight: isUnpaid ? pw.FontWeight.bold : null)),
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 10),
        pw.Text(
          'Generated by KirayaBook Pro app',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
        ),
        pw.Text(
           'Professional Rent Management for Owners',
           style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey400),
        ),
      ],
    );
  }
}
