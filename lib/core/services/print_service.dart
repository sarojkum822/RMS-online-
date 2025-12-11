import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/datasources/local/database.dart';
import 'package:intl/intl.dart';

class PrintService {
  final AppDatabase _db;

  PrintService(this._db);

  Future<void> printBackupData() async {
    final pdf = pw.Document();
    
    // 1. Fetch Data
    final tenants = await _db.select(_db.tenants).get();
    final rentCycles = await _db.select(_db.rentCycles).get();
    final payments = await _db.select(_db.payments).get();
    
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
                t.isActive ? 'ACTIVE' : 'INACTIVE'
              ]).toList(),
            ),
            pw.SizedBox(height: 20),
            
            // Rent History Section
            pw.Header(level: 1, text: 'Rent History (${rentCycles.length})'),
            pw.Table.fromTextArray(
              context: context,
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              headers: ['Bill #', 'Month', 'Tenant ID', 'Due', 'Paid', 'Status'],
              data: rentCycles.map((r) {
                const statuses = ['Pending', 'Partial', 'Paid', 'Overdue'];
                final statusStr = (r.status >= 0 && r.status < statuses.length) 
                    ? statuses[r.status] 
                    : 'Unknown';
                return [
                  r.billNumber ?? '-',
                  r.month,
                  r.tenantId.toString(),
                  r.totalDue.toStringAsFixed(0),
                  r.totalPaid.toStringAsFixed(0),
                  statusStr
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
}
