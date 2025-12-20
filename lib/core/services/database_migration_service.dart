
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../constants/firebase_collections.dart';

class DatabaseMigrationService {
  final FirebaseFirestore _firestore;

  DatabaseMigrationService(this._firestore);

  /// Checks if migration is needed by looking for documents in old collections
  /// and absence of documents in new collections.
  Future<bool> checkIfMigrationNeeded(String userId) async {
    try {
      // Check if 'tenancies' exists (Old)
      final oldTenancies = await _firestore.collection('tenancies')
          .where('ownerId', isEqualTo: userId)
          .limit(1)
          .get();

      // Check if 'contracts' exists (New)
      final newContracts = await _firestore.collection(FirebaseCollections.contracts)
          .where('ownerId', isEqualTo: userId)
          .limit(1)
          .get();

      // If we have old data but no new data, we need migration
      if (oldTenancies.docs.isNotEmpty && newContracts.docs.isEmpty) {
        return true;
      }

      // Check RentCycles -> Invoices
      final oldRent = await _firestore.collection('rent_cycles')
          .where('ownerId', isEqualTo: userId)
          .limit(1)
          .get();
      
      final newInvoices = await _firestore.collection(FirebaseCollections.invoices)
          .where('ownerId', isEqualTo: userId)
          .limit(1)
          .get();

      if (oldRent.docs.isNotEmpty && newInvoices.docs.isEmpty) {
        return true;
      }
      
      // Check Houses -> Properties
      final oldHouses = await _firestore.collection('houses')
          .where('ownerId', isEqualTo: userId)
          .limit(1)
          .get();
          
      final newProperties = await _firestore.collection(FirebaseCollections.properties)
          .where('ownerId', isEqualTo: userId)
          .limit(1)
          .get();

       if (oldHouses.docs.isNotEmpty && newProperties.docs.isEmpty) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error checking migration status: $e');
      return false;
    }
  }

  Future<void> performMigration(String userId, Function(String) onProgress) async {
    try {
      // 1. Houses -> Properties
      onProgress('Migrating Properties...');
      await _migrateCollectionBatched(userId, 'houses', FirebaseCollections.properties);

      // 2. Tenancies -> Contracts
      onProgress('Migrating Contracts...');
      await _migrateCollectionBatched(userId, 'tenancies', FirebaseCollections.contracts);

      // 3. RentCycles -> Invoices
      onProgress('Migrating Invoices...');
      await _migrateCollectionBatched(userId, 'rent_cycles', FirebaseCollections.invoices);

      // 4. Payments -> Transactions
      onProgress('Migrating Transactions...');
      await _migrateCollectionBatched(userId, 'payments', FirebaseCollections.transactions);

      // 5. Maintenance -> Tickets
      onProgress('Migrating Tickets...');
      await _migrateCollectionBatched(userId, 'maintenance', FirebaseCollections.tickets);

      onProgress('Migration Complete!');

    } catch (e) {
      debugPrint('Migration Error: $e');
      throw Exception('Migration failed: $e');
    }
  }

  Future<void> _migrateCollectionBatched(String userId, String oldColl, String newColl) async {
    final snapshot = await _firestore.collection(oldColl)
        .where('ownerId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) return;

    WriteBatch batch = _firestore.batch();
    int operationCount = 0;
    const int batchLimit = 450;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      
      // 1. Copy to New
      batch.set(_firestore.collection(newColl).doc(doc.id), data);
      operationCount++;

      // 2. Delete from Old
      batch.delete(doc.reference);
      operationCount++;

      if (operationCount >= batchLimit) {
        await batch.commit();
        batch = _firestore.batch(); // Reset batch
        operationCount = 0;
      }
    }

    // Commit remaining
    if (operationCount > 0) {
      await batch.commit();
    }
  }
}
