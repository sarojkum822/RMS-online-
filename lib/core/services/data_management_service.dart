import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../constants/firebase_collections.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class DataManagementService {
  final FirebaseFirestore _firestore;

  DataManagementService(this._firestore);

  /// Resets all data for the given owner ID.
  /// This deletes documents from all major collections where ownerId == uid.
  Future<void> resetAllData(String uid) async {
    // 1. Delete Tenant Auth Accounts FIRST
    try {
      final tenantSnapshot = await _firestore.collection(FirebaseCollections.tenants)
          .where('ownerId', isEqualTo: uid)
          .get();

      for (final doc in tenantSnapshot.docs) {
        final data = doc.data();
        final email = data['email'] as String?;
        final password = data['password'] as String?;
        
        if (email != null && password != null && email.isNotEmpty && password.isNotEmpty) {
           final rawPassword = _decryptPassword(password);
           if (rawPassword != null) {
              await _deleteTenantAuth(email, rawPassword);
           }
        }
      }
    } catch (e) {
//      print('Error cleaning up tenant auth: $e');
      // Continue to delete data anyway
    }

    final collections = [
      // New Collections
      FirebaseCollections.properties, 
      FirebaseCollections.units,
      FirebaseCollections.bhkTemplates,
      FirebaseCollections.tenants,
      FirebaseCollections.contracts, 
      FirebaseCollections.invoices,
      FirebaseCollections.transactions, 
      FirebaseCollections.expenses,
      FirebaseCollections.electricReadings,
      FirebaseCollections.tickets,
      'notices',
      
      // Old Collections (Legacy cleanup)
      'houses',
      'tenancies',
      'rent_cycles',
      'payments',
      'maintenance',
    ];

    for (final collection in collections) {
      try {
        await _deleteCollectionForOwner(collection, uid);
      } catch (e) {
        // Log but continue to try deleting other collections
//        print('Error deleting collection $collection: $e');
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
//        print('Deleted auth for $email');
      } catch (e) {
//        print('Warning: Failed to delete Auth user $email: $e');
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
    
    // Double Check: Verify if any documents remain?
    // Usually not needed if commit succeeds.
  }

  // --- Encryption Helpers (Must match TenantRepositoryImpl) ---
  final _key = encrypt.Key.fromUtf8('KirayaBookProSecretKey32Chars!!'); // 32 chars
  final _iv = encrypt.IV.fromUtf8('KirayaBookProIVx'); // 16 chars

  String? _decryptPassword(String? encryptedPassword) {
    if (encryptedPassword == null || encryptedPassword.isEmpty) return null;
    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      return encrypter.decrypt64(encryptedPassword, iv: _iv);
    } catch (e) {
      // Maybe it wasn't encrypted? Or key mismatch.
      return encryptedPassword;
    }
  }
}

