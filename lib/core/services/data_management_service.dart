import 'package:cloud_firestore/cloud_firestore.dart';

class DataManagementService {
  final FirebaseFirestore _firestore;

  DataManagementService(this._firestore);

  /// Resets all data for the given owner ID.
  /// This deletes documents from all major collections where ownerId == uid.
  Future<void> resetAllData(String uid) async {
    final collections = [
      'houses', // Was 'properties' which caused Permission Denied
      'units',
      'tenants',
      'rent_cycles',
      'payments',
      'expenses',
      'electric_readings',
    ];

    // Batching is limited to 500 ops.
    // Since we might have more, we'll do it in chunks or just parallel deletes.
    // Safest and simplest for "Reset" is iterating and deleting.
    
    for (final collection in collections) {
      await _deleteCollectionForOwner(collection, uid);
    }
  }

  Future<void> _deleteCollectionForOwner(String collectionPath, String uid) async {
    // Query all docs for this owner
    // Note: This relies on 'ownerId' field being present and indexed if large.
    final snapshot = await _firestore.collection(collectionPath)
        .where('ownerId', isEqualTo: uid)
        .get();

    if (snapshot.docs.isEmpty) return;

    // Delete in batches of 500
    WriteBatch batch = _firestore.batch();
    int count = 0;

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
      count++;

      if (count >= 400) { // Commit every 400 to be safe
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
