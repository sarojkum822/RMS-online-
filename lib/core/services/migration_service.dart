import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'data_integrity_validator.dart';
import 'data_management_service.dart';

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
    
    await _restoreCollection('houses', data['houses'], currentUid);
    await _restoreCollection('units', data['units'], currentUid);
    await _restoreCollection('tenants', data['tenants'], currentUid);
    await _restoreCollection('rent_cycles', data['rentCycles'], currentUid);
    await _restoreCollection('payments', data['payments'], currentUid);
    await _restoreCollection('expenses', data['expenses'], currentUid);
    await _restoreCollection('electric_readings', data['electricReadings'], currentUid);
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
      
      if (collectionPath == 'rent_cycles') {
          // Reconstruct ID logic from RentRepository logic
          final docId = '${map['tenantId']}_${map['month']}';
          ref = _firestore.collection(collectionPath).doc(docId);
      } else if (collectionPath == 'houses' || collectionPath == 'units' || collectionPath == 'tenants' || collectionPath == 'expenses' || collectionPath == 'payments' || collectionPath == 'electric_readings') {
         // These use auto-generated IDs or specific ID logic?
         // Repos usually allow Firestore to generate ID or use 'id' field?
         // Actually, most Repos in this project use `.add()` which generates random ID.
         // BUT they store an internal 'id' (int).
         // If we restore, we lose the original Firestore DocID unless we backed it up.
         // Our backup `_fetchCollection` just dumped data().
         // Issue: updates will fail if we don't know the Doc ID.
         // FIX: We should have backed up Doc ID.
         // Too late to change Export schema if we had old backups, but we are designing NEW system.
         // SO: I should update Export to include DocID.
         // BUT wait, Repos query by 'id' field mostly?
         // Let's check RentRepository: `where('id', isEqualTo: id)`.
         // So Firestore Doc ID doesn't matter for logic, mostly.
         // EXCEPT for `rent_cycles` which uses a specific Doc ID to prevent duplicates.
         // AND `createRentCycle` uses `.doc(docId).set()`.
         
         if (collectionPath == 'rent_cycles') {
             // Already handled
             final docId = '${map['tenantId']}_${map['month']}';
             ref = _firestore.collection(collectionPath).doc(docId);
         } else {
             // For others, generate new Doc ID
             ref = _firestore.collection(collectionPath).doc();
         }
      } else {
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
