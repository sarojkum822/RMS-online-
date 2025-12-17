import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class DataManagementService {
  final FirebaseFirestore _firestore;

  DataManagementService(this._firestore);

  /// Resets all data for the given owner ID.
  /// This deletes documents from all major collections where ownerId == uid.
  Future<void> resetAllData(String uid) async {
    // 1. Delete Tenant Auth Accounts FIRST
    try {
      final tenantSnapshot = await _firestore.collection('tenants')
          .where('ownerId', isEqualTo: uid)
          .get();

      for (final doc in tenantSnapshot.docs) {
        final data = doc.data();
        final email = data['email'] as String?;
        final password = data['password'] as String?;
        
        if (email != null && password != null && email.isNotEmpty && password.isNotEmpty) {
           await _deleteTenantAuth(email, password);
        }
      }
    } catch (e) {
      print('Error cleaning up tenant auth: $e');
      // Continue to delete data anyway
    }

    final collections = [
      'houses', 
      'units',
      'bhkTemplates',
      'tenants',
      'rent_cycles',
      'payments',
      'expenses',
      'electric_readings',
      'maintenance',
      'notices',
    ];

    for (final collection in collections) {
      try {
        await _deleteCollectionForOwner(collection, uid);
      } catch (e) {
        // Log but continue to try deleting other collections
        print('Error deleting collection $collection: $e');
      }
    }
  }

  Future<void> _deleteTenantAuth(String email, String password) async {
      FirebaseApp app;
      try {
        app = Firebase.app('secondary');
      } catch (_) {
        app = await Firebase.initializeApp(name: 'secondary', options: Firebase.app().options);
      }
      final auth = FirebaseAuth.instanceFor(app: app);
      
      try {
        await auth.signInWithEmailAndPassword(email: email, password: password);
        await auth.currentUser?.delete(); 
        print('Deleted auth for $email');
      } catch (e) {
        print('Warning: Failed to delete Auth user $email: $e');
      } finally {
         try { await auth.signOut(); } catch (_) {}
      }
  }

  Future<void> _deleteCollectionForOwner(String collectionPath, String uid) async {
    // Query all docs for this owner
    final snapshot = await _firestore.collection(collectionPath)
        .where('ownerId', isEqualTo: uid)
        .get();

    if (snapshot.docs.isEmpty) return;

    // Delete in batches of 500
    WriteBatch batch = _firestore.batch();
    int count = 0;
    int totalDeleted = 0;

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
      count++;
      totalDeleted++;

      if (count >= 400) { // Commit every 400 to be safe
        await batch.commit();
        batch = _firestore.batch();
        count = 0;
      }
    }

    if (count > 0) {
      await batch.commit();
    }
    
    // Double Check: Verify if any documents remain?
    // Usually not needed if commit succeeds.
  }
}
