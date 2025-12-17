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
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('owners').doc(user.uid).get();
    if (!doc.exists) return null;

    return _mapSnapshotToOwner(doc);
  }

  @override
  Future<void> saveOwner(Owner owner) async {
    final user = _auth.currentUser;
    if (user == null) return;
    // Ensure we use the Auth UID as the document ID
    await _firestore.collection('owners').doc(user.uid).set(_mapOwnerToMap(owner));
  }

  @override
  Future<void> updateOwner(Owner owner) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('owners').doc(user.uid).update(_mapOwnerToMap(owner));
  }

  Owner _mapSnapshotToOwner(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Owner(
      id: 0, // ID is less relevant in Firestore-only, but keeping for compatibility
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      firestoreId: doc.id,
      currency: data['currency'] ?? 'INR',
      timezone: data['timezone'],
      subscriptionPlan: data['subscriptionPlan'] ?? 'free', // NEW
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> _mapOwnerToMap(Owner owner) {
    return {
      'name': owner.name,
      'email': owner.email,
      'phone': owner.phone,
      'currency': owner.currency,
      'subscriptionPlan': owner.subscriptionPlan, // NEW
      'timezone': owner.timezone,
      'createdAt': owner.createdAt != null ? Timestamp.fromDate(owner.createdAt!) : FieldValue.serverTimestamp(),
      'firestoreId': _auth.currentUser?.uid, // Redundant but consistent
    };
  }
}
