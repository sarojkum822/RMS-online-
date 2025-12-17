import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PrintService {
  PrintService();

  Future<void> printBackupData({
    required List<dynamic> tenants, 
    required List<dynamic> rentCycles, 
    required List<dynamic> payments,
  }) async {
    final pdf = pw.Document();
    
    // 2. Build PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('RentPilot Pro Backup', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())),
                ]
              )
            ),
            pw.SizedBox(height: 20),
            
            // Tenants Section
            pw.Header(level: 1, text: 'Tenants (${tenants.length})'),
            pw.Table.fromTextArray(
              context: context,
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              headers: ['Name', 'Phone', 'Unit', 'Status'],
              data: tenants.map((t) => [
                t.name,
                t.phone,
                t.unitId.toString(),
                t.status.toString().split('.').last.toUpperCase()
              ]).toList(),
            ),
            pw.SizedBox(height: 20),
            
            // Rent History Section
            pw.Header(level: 1, text: 'Rent History (${rentCycles.length})'),
            pw.Table.fromTextArray(
              context: context,
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              headers: ['Bill #', 'Month', 'Electric', 'Due', 'Paid', 'Status'],
              data: rentCycles.map((r) {
                return [
                  r.billNumber ?? '-',
                  r.month,
                  r.electricAmount.toStringAsFixed(0),
                  r.totalDue.toStringAsFixed(0),
                  r.totalPaid.toStringAsFixed(0),
                  r.status.toString().split('.').last
                ];
              }).toList(),
            ),
             pw.SizedBox(height: 20),
            
            // Payments Section
            pw.Header(level: 1, text: 'Payments (${payments.length})'),
            pw.Table.fromTextArray(
              context: context,
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              headers: ['Date', 'Amount', 'Tenant ID', 'Method', 'Ref'],
              data: payments.map((p) => [
                DateFormat('yyyy-MM-dd').format(p.date),
                p.amount.toStringAsFixed(0),
                p.tenantId.toString(),
                p.method,
                p.referenceId ?? '-'
              ]).toList(),
            ),
          ];
        },
      ),
    );

    // 3. Print / Share
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'RentPilot_Backup_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
  Future<void> printRentReceipt({
    required dynamic rentCycle, // RentCycle
    required dynamic tenant, // Tenant
    required dynamic house, // House
    required dynamic unit, // Unit
    List<dynamic> payments = const [], // List<Payment>
    dynamic previousReading, // ElectricReading?
    dynamic currentReading, // ElectricReading?
  }) async {
    final pdf = pw.Document();
    
    // Font Loading with Fallback
    pw.Font font;
    pw.Font boldFont;
    pw.Font rupeeFont;

    try {
      font = await PdfGoogleFonts.outfitRegular();
      boldFont = await PdfGoogleFonts.outfitBold();
      rupeeFont = await PdfGoogleFonts.hindRegular();
    } catch (e) {
      // Fallback for offline usage
      font = pw.Font.courier();
      boldFont = pw.Font.courierBold();
      rupeeFont = pw.Font.courier(); // Standard font might not have Rupee, but prevents crash
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40), 
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                   // ... (Header content unchanged mostly, maybe spacing)
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(house.name, style: pw.TextStyle(font: boldFont, fontSize: 26, color: PdfColors.blue900)),
                      pw.SizedBox(height: 4),
                      pw.Text(house.address, style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('RENT RECEIPT', style: pw.TextStyle(font: boldFont, fontSize: 20, color: PdfColors.black)),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue50,
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          'Date: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
                          style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.blue900),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // TENANT DETAILS
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                         pw.Container(width: 4, height: 18, color: PdfColors.blue700),
                         pw.SizedBox(width: 10),
                         pw.Text('Tenant Details', style: pw.TextStyle(font: boldFont, fontSize: 16)),
                      ],
                    ),
                    pw.SizedBox(height: 16),
                    pw.Row(
                      children: [
                        pw.Expanded(child: _buildInfoRow('Name', tenant.name, font, boldFont)),
                        pw.Expanded(child: _buildInfoRow('Unit', unit.nameOrNumber, font, boldFont)),
                      ],
                    ),
                    pw.SizedBox(height: 12),
                     pw.Row(
                      children: [
                        pw.Expanded(child: _buildInfoRow('Phone', tenant.phone, font, boldFont)),
                        pw.Expanded(child: _buildInfoRow('Month', rentCycle.month, font, boldFont)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // RENT BREAKDOWN
              pw.Text('Rent Breakdown', style: pw.TextStyle(font: boldFont, fontSize: 16)),
              pw.SizedBox(height: 12),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: pw.BoxDecoration(
                   color: PdfColors.grey50,
                   borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Base Rent', style: pw.TextStyle(font: font, fontSize: 14)),
                    pw.Text(NumberFormat.currency(symbol: '₹').format(rentCycle.baseRent), style: pw.TextStyle(font: rupeeFont, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              
              if (rentCycle.otherCharges > 0) ...[
                 pw.SizedBox(height: 8),
                 pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Other Charges', style: pw.TextStyle(font: font, fontSize: 14)),
                      pw.Text(NumberFormat.currency(symbol: '₹').format(rentCycle.otherCharges), style: pw.TextStyle(font: rupeeFont, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
              ],
              
              pw.SizedBox(height: 30),

              // ELECTRIC BILL SECTION
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue200),
                  borderRadius: pw.BorderRadius.circular(12),
                  color: PdfColors.blue50,
                ),
                child: pw.Column(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue200)),
                      ),
                      child: pw.Row(
                        children: [
                           pw.Icon(const pw.IconData(0xe3b7), color: PdfColors.blue800, size: 18),
                           pw.SizedBox(width: 10),
                           pw.Text('Electric Bill Section', style: pw.TextStyle(font: boldFont, color: PdfColors.blue900, fontSize: 14)),
                        ],
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(20),
                      child: pw.Column(
                        children: [
                          if (previousReading != null && currentReading != null) ...[
                             _buildElectricRow('Previous Reading', '${previousReading['reading']} units', font),
                             _buildElectricRow('Current Reading', '${currentReading['reading']} units', font),
                             _buildElectricRow('Consumed', '${(currentReading['reading'] - previousReading['reading']).toStringAsFixed(1)} units', font),
                          ] else ...[
                             _buildElectricRow('Consumed Units', 'N/A', font),
                          ],
                          pw.Divider(color: PdfColors.blue200, height: 24),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Total Electric Cost', style: pw.TextStyle(font: boldFont, color: PdfColors.black, fontSize: 14)),
                              pw.Text(NumberFormat.currency(symbol: '₹').format(rentCycle.electricAmount), style: pw.TextStyle(font: rupeeFont, fontWeight: pw.FontWeight.bold, color: PdfColors.black, fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 30),

              // PAYMENT INFO
              if (payments.isNotEmpty) ...[
                 pw.Text('Payment History', style: pw.TextStyle(font: boldFont, fontSize: 16)),
                 pw.SizedBox(height: 12),
                 ...payments.map((p) => pw.Container(
                   padding: const pw.EdgeInsets.symmetric(vertical: 8),
                   decoration: const pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))
                   ),
                   child: pw.Row(
                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                     children: [
                       pw.Text('Paid via ${p.method} on ${DateFormat('MMM dd').format(p.date)}', style: pw.TextStyle(font: font, color: PdfColors.grey700)),
                       pw.Text(NumberFormat.currency(symbol: '₹').format(p.amount), style: pw.TextStyle(font: rupeeFont, fontWeight: pw.FontWeight.bold, color: PdfColors.green700)),
                     ],
                   )
                 )),
                 pw.SizedBox(height: 20),
              ],

              pw.Spacer(),
              
              // FOOTER
              pw.Container(
                padding: const pw.EdgeInsets.all(24),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Total Amount Paid', style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey700)),
                        pw.SizedBox(height: 8),
                        pw.Text(NumberFormat.currency(symbol: '₹').format(rentCycle.totalPaid), style: pw.TextStyle(font: rupeeFont, fontSize: 28, color: PdfColors.green800, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.Column(
                      children: [
                         pw.Container(
                           width: 120,
                           height: 40,
                            // Placeholder for signature
                           child: pw.CustomPaint(
                             painter: (canvas, size) {
                               canvas.setColor(PdfColors.black);
                               canvas.setLineWidth(1.0);
                               // Draw a fake signature curve
                               canvas.moveTo(10, size.y - 10);
                               canvas.curveTo(size.x / 3, size.y - 30, size.x * 2 / 3, size.y, size.x - 10, size.y - 20);
                               canvas.strokePath();
                               
                               // Line below
                               canvas.drawLine(0, size.y, size.x, size.y);
                             },
                           ),
                         ),
                         pw.SizedBox(height: 4),
                         pw.Text('Owner Signature', style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Receipt_${rentCycle.month}_${tenant.name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')}.pdf',
    );
  }

  pw.Widget _buildInfoRow(String label, String value, pw.Font labelFont, pw.Font valueFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(font: labelFont, fontSize: 10, color: PdfColors.grey600)),
        pw.Text(value, style: pw.TextStyle(font: valueFont, fontSize: 12, color: PdfColors.black)),
      ],
    );
  }

  pw.Widget _buildElectricRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.black)),
        ],
      ),
    );
  }
}


