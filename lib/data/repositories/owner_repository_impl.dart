import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/i_owner_repository.dart';
import '../../domain/entities/owner.dart';

class OwnerRepositoryImpl implements IOwnerRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  OwnerRepositoryImpl(this._firestore) : _auth = FirebaseAuth.instance;

  @override
  Future<Owner?> getOwner() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('owners').doc(user.uid).get().timeout(const Duration(seconds: 10));
      if (!doc.exists) return null;

      return _mapSnapshotToOwner(doc);
    } catch (e) {
      print('Error getting owner: $e');
      return null;
    }
  }

  /// Get owner by ID - for tenant-side access to owner's subscription plan
  @override
  Future<Owner?> getOwnerById(String ownerId) async {
    try {
      final doc = await _firestore.collection('owners').doc(ownerId).get().timeout(const Duration(seconds: 10));
      if (!doc.exists) return null;
      return _mapSnapshotToOwner(doc);
    } catch (e) {
      print('Error getting owner by ID: $e');
      return null;
    }
  }

  /// Check if an email is registered as an owner (for tenant email uniqueness)
  Future<bool> isEmailRegisteredAsOwner(String email) async {
    try {
      final snapshot = await _firestore
          .collection('owners')
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking owner email: $e');
      return false; // Fail-safe: allow if we can't check
    }
  }

  /// Check if a phone number is registered as an owner (for global phone uniqueness)
  Future<bool> isPhoneRegisteredAsOwner(String phone) async {
    try {
      final normalizedPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
      final snapshot = await _firestore
          .collection('owners')
          .where('phone', isEqualTo: normalizedPhone)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking owner phone: $e');
      return false; // Fail-safe: allow if we can't check
    }
  }


  @override
  Future<void> saveOwner(Owner owner) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      // Ensure we use the Auth UID as the document ID
      await _firestore.collection('owners').doc(user.uid).set(_mapOwnerToMap(owner));
    } catch (e) {
      print('Error saving owner: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateOwner(Owner owner) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      // Only update allowed fields to prevent permission-denied errors
      // Firestore rules forbid updating subscriptionPlan, createdAt, etc.
      final updateData = {
        'name': owner.name,
        'email': owner.email,
        'phone': owner.phone,
        'currency': owner.currency, 
        'timezone': owner.timezone,
        'upiId': owner.upiId, // NEW
        // 'subscriptionPlan': owner.subscriptionPlan, // EXCLUDED
        // 'createdAt': ... // EXCLUDED
      };
      
      await _firestore.collection('owners').doc(user.uid).update(updateData);
    } catch (e) {
      print('Error updating owner: $e');
      rethrow;
    }
  }

  Owner _mapSnapshotToOwner(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Owner(
      id: 0, 
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      firestoreId: doc.id,
      currency: data['currency'] ?? 'INR',
      timezone: data['timezone'],
      upiId: data['upiId'], // NEW
      subscriptionPlan: data['subscriptionPlan'] ?? 'free',
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> _mapOwnerToMap(Owner owner) {
    return {
      'name': owner.name,
      'email': owner.email,
      'phone': owner.phone,
      'currency': owner.currency,
      'timezone': owner.timezone,
      'upiId': owner.upiId, // NEW
      'subscriptionPlan': owner.subscriptionPlan, 
      'createdAt': owner.createdAt != null ? Timestamp.fromDate(owner.createdAt!) : FieldValue.serverTimestamp(),
      'firestoreId': _auth.currentUser?.uid, 
    };
  }
}
