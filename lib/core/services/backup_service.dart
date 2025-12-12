import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_saver/file_saver.dart';
import '../../data/datasources/local/database.dart';

class BackupService {
  final AppDatabase _db;

  BackupService(this._db);

  Future<void> exportData({bool share = true}) async {
    // 1. Fetch all data
    final owners = await _db.select(_db.owners).get();
    final houses = await _db.select(_db.houses).get();
    final units = await _db.select(_db.units).get();
    final tenants = await _db.select(_db.tenants).get();
    final rentCycles = await _db.select(_db.rentCycles).get();
    final payments = await _db.select(_db.payments).get();
    final electricReadings = await _db.select(_db.electricReadings).get();
    final expenses = await _db.select(_db.expenses).get();

    // 2. Convert to JSON Map
    final data = {
      'metadata': {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
      },
      'owners': owners.map((row) => row.toJson()).toList(),
      'houses': houses.map((row) => row.toJson()).toList(),
      'units': units.map((row) => row.toJson()).toList(),
      'tenants': tenants.map((row) => row.toJson()).toList(),
      'rentCycles': rentCycles.map((row) => row.toJson()).toList(),
      'payments': payments.map((row) => row.toJson()).toList(),
      'electricReadings': electricReadings.map((row) => row.toJson()).toList(),
      'expenses': expenses.map((row) => row.toJson()).toList(),
    };

    // 3. Serialize
    final jsonString = jsonEncode(data);
    final bytes = utf8.encode(jsonString);

    if (share) {
      // 4. Write to File & Share
      final dir = await getTemporaryDirectory();
      final fileName = 'rentpilot_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(jsonString);

      // 5. Share
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        text: 'RentPilot Pro Backup',
      );
    } else {
      // 4. Save to Device
      final fileName = 'rentpilot_backup_${DateTime.now().millisecondsSinceEpoch}';
      await FileSaver.instance.saveFile(
        name: '$fileName.json',
        bytes: bytes,
        mimeType: MimeType.json,
      );
    }
  }

  Future<void> restoreData(File file) async {
    final jsonString = await file.readAsString();
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    await _db.transaction(() async {
      // 1. Clear all tables
      await _db.delete(_db.expenses).go();
      await _db.delete(_db.payments).go();
      await _db.delete(_db.rentCycles).go();
      await _db.delete(_db.electricReadings).go(); // Order matters if FKs exist
      await _db.delete(_db.tenants).go();
      await _db.delete(_db.units).go();
      await _db.delete(_db.houses).go();
      await _db.delete(_db.owners).go();

      // 2. Insert Data
      // Helper to safely parse and insert
      if (data['owners'] != null) {
        for (var item in data['owners']) {
          await _db.into(_db.owners).insert(Owner.fromJson(item));
        }
      }
      
      if (data['houses'] != null) {
        for (var item in data['houses']) {
          await _db.into(_db.houses).insert(House.fromJson(item));
        }
      }

      if (data['units'] != null) {
        for (var item in data['units']) {
          await _db.into(_db.units).insert(Unit.fromJson(item));
        }
      }

      if (data['tenants'] != null) {
        for (var item in data['tenants']) {
          await _db.into(_db.tenants).insert(Tenant.fromJson(item));
        }
      }
      
      if (data['rentCycles'] != null) {
        for (var item in data['rentCycles']) {
           await _db.into(_db.rentCycles).insert(RentCycle.fromJson(item));
        }
      }
      
      if (data['payments'] != null) {
        for (var item in data['payments']) {
           await _db.into(_db.payments).insert(Payment.fromJson(item));
        }
      }
      
      if (data['electricReadings'] != null) {
        for (var item in data['electricReadings']) {
           await _db.into(_db.electricReadings).insert(ElectricReading.fromJson(item));
        }
      }
      
      if (data['expenses'] != null) {
        for (var item in data['expenses']) {
           await _db.into(_db.expenses).insert(Expense.fromJson(item));
        }
      }
    });
  }
}
