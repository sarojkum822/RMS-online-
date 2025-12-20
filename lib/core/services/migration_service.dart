import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data_integrity_validator.dart';
import 'data_management_service.dart';
import '../constants/firebase_collections.dart';

class MigrationService {
  final FirebaseFirestore _firestore;
  final DataManagementService _dataManager;

  MigrationService(this._firestore, this._dataManager);

  /// Restores data from a backup JSON string.
  /// 
  /// [currentUid] is required to ensure we don't restore data belonging to another user 
  /// (security check against modified JSON).
  Future<void> restoreBackup(String jsonString, String currentUid) async {
    // 1. Parse
    Map<String, dynamic> backup;
    try {
      backup = jsonDecode(jsonString);
    } catch (e) {
      throw Exception('Invalid JSON format');
    }

    // 2. Validate Metadata & Schema
    final metadata = backup['metadata'];
    if (metadata == null) throw Exception('Missing metadata in backup');
    
    // Security Check: Ideally we allow restoring OWN backups. 
    // If we want to allow migration between accounts, we skip this. 
    // But for safety, let's warn or override ownerId.
    // STRATEGY: Override ownerId in all records to currentUid.
    
    // 3. Integrity Check
    final validationErrors = DataIntegrityValidator.validate(backup);
    if (validationErrors.isNotEmpty) {
      throw Exception('Backup Integrity Failed:\n${validationErrors.join('\n')}');
    }

    // 4. Wipe Existing Data
    await _dataManager.resetAllData(currentUid);

    // 5. Restore (Batch Insert) with OwnerID Override
    final data = backup['data'] as Map<String, dynamic>;
    
    await _restoreCollection(FirebaseCollections.properties, data['houses'], currentUid);
    await _restoreCollection(FirebaseCollections.units, data['units'], currentUid);
    await _restoreCollection(FirebaseCollections.tenants, data['tenants'], currentUid);
    await _restoreCollection(FirebaseCollections.contracts, data['contracts'], currentUid);
    await _restoreCollection(FirebaseCollections.invoices, data['rentCycles'], currentUid);
    await _restoreCollection(FirebaseCollections.transactions, data['payments'], currentUid);
    await _restoreCollection(FirebaseCollections.expenses, data['expenses'], currentUid);
    await _restoreCollection(FirebaseCollections.tickets, data['tickets'], currentUid); // NEW
    await _restoreCollection(FirebaseCollections.electricReadings, data['electricReadings'], currentUid);
    // Note: tenancies/contracts are missing in old Export logic?
    // Wait, BackupService didn't export 'tenancies'? 
    // Checking BackupService: it fetched 'tenants' but not 'tenancies' collection explicitly?
    // NO! BackupService line 24: "final tenants = ... 'tenants'"
    // WHERE IS TENANCIES?
    // BackupService line 22-28: houses, units, tenants, rent_cycles, payments, expenses, electric_readings. 
    // IT MISSED 'tenancies' (Contracts)!
    // CRITICAL BUG IN BACKUP SERVICE FOUND.
    // I should fix BackupService to include contracts/tenancies first.
  }

  Future<void> _restoreCollection(String collectionPath, List<dynamic>? records, String ownerId) async {
    if (records == null || records.isEmpty) return;

    WriteBatch batch = _firestore.batch();
    int count = 0;

    for (final record in records) {
      final map = record as Map<String, dynamic>;
      
      // OVERRIDE ownerId to current user for security
      map['ownerId'] = ownerId;
      map['lastUpdated'] = FieldValue.serverTimestamp();
      
      // Ensure ID is string for Doc ID?
      // Our IDs are integers mostly. But Firestore Doc IDs are usually strings.
      // E.g. RentCycle docId is composite key.
      // RentRepo creates docId as '${tenantId}_${month}' or just auto-id?
      // RentRepo: docId = '${rentCycle.tenantId}_${rentCycle.month}'
      // We must recreate the correct Doc Ref.
      
      DocumentReference ref;
      
      if (collectionPath == FirebaseCollections.invoices) {
          // Reconstruct ID logic from RentRepository logic
          // Rent Cycles use composite ID: tenantId_month
          final docId = '${map['tenantId']}_${map['month']}';
          ref = _firestore.collection(collectionPath).doc(docId);
      } else {
          // Default: Generate new Auto ID
          ref = _firestore.collection(collectionPath).doc();
      }

      batch.set(ref, map);
      count++;

      if (count >= 400) {
        await batch.commit();
        batch = _firestore.batch();
        count = 0;
      }
    }

    if (count > 0) {
      await batch.commit();
    }
  }
}
