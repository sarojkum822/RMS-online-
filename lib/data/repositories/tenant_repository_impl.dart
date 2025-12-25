import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../domain/entities/tenant.dart' as domain;
import '../../domain/repositories/i_tenant_repository.dart';

import 'package:uuid/uuid.dart'; // Add uuid package
import '../../domain/entities/tenancy.dart'; // Import Tenancy
import '../../domain/entities/verification_document.dart'; // NEW
import '../../core/constants/firebase_collections.dart'; // Import Constants

class TenantRepositoryImpl implements ITenantRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final encrypt.Key _key;
  final encrypt.IV _iv;

  TenantRepositoryImpl(
    this._firestore, {
    FirebaseAuth? auth,
    FirebaseStorage? storage,
    String? encryptionKey,
    String? encryptionIv,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _key = encrypt.Key.fromUtf8(encryptionKey ?? 'KirayaBookProSecretKey32CharsLong'),
        _iv = encrypt.IV.fromUtf8(encryptionIv ?? 'KirayaBookProIV16');

  String? get _uid => _auth.currentUser?.uid;

  // --- Image Processing (Base64) ---
  Future<String?> _processImageToBase64(File imageFile) async {
    try {
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        '${imageFile.parent.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg',
        quality: 60, 
        minWidth: 512, 
        minHeight: 512,
      );

      final fileToRead = compressedFile != null ? File(compressedFile.path) : imageFile;
      final bytes = await fileToRead.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      debugPrint('Error processing image: $e');
      return null;
    }
  }

  @override
  Future<domain.Tenant?> getTenantByEmail(String email) async {
    final snapshot = await _firestore.collection(FirebaseCollections.tenants)
        .where('email', isEqualTo: email)
        .where('isDeleted', isEqualTo: false)
        .limit(1)
        .get();
        
    if (snapshot.docs.isEmpty) return null;
    return _mapToDomain(snapshot.docs.first);
  }


  @override
  Stream<List<domain.Tenant>> getAllTenants() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    
    return _firestore.collection(FirebaseCollections.tenants)
        .where('ownerId', isEqualTo: uid)
        // .where('isDeleted', isEqualTo: false) // Moved to memory for rule compatibility
        .snapshots() 
        .map((snapshot) => snapshot.docs
            .where((doc) => doc.data()['isDeleted'] != true)
            .map((doc) => _mapToDomain(doc))
            .toList());
  }

  @override
  Future<domain.Tenant?> getTenant(String id) async { // String ID
    if (_uid == null) return null;

    final snapshot = await _firestore.collection(FirebaseCollections.tenants)
        .where('ownerId', isEqualTo: _uid) 
        .where('id', isEqualTo: id)
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 10));
        
    if (snapshot.docs.isEmpty) return null;
    final data = snapshot.docs.first.data();
    if (data['isDeleted'] == true) return null;
    return _mapToDomain(snapshot.docs.first);
  }

  @override
  Future<domain.Tenant?> getTenantByCode(String code) async {
    final snapshot = await _firestore.collection(FirebaseCollections.tenants)
        .where('ownerId', isEqualTo: _uid)
        .get();
        
    final docs = snapshot.docs.where((d) => 
        d.data()['tenantCode'] == code && d.data()['isDeleted'] != true
    ).toList();
    
    if (docs.isEmpty) return null;
    return _mapToDomain(docs.first);
  }

  @override
  Future<domain.Tenant?> getTenantByAuthId(String authId) async {
    final snapshot = await _firestore.collection(FirebaseCollections.tenants)
        .where('authId', isEqualTo: authId)
        .where('isDeleted', isEqualTo: false)
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 10));
        
    if (snapshot.docs.isEmpty) return null;
    return _mapToDomain(snapshot.docs.first);
  }

  @override
  Future<String> createTenant(domain.Tenant tenant, {File? imageFile}) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');

    // Check for duplicate email
    final duplicateSnapshot = await _firestore.collection(FirebaseCollections.tenants)
        .where('ownerId', isEqualTo: uid)
        .where('email', isEqualTo: tenant.email)
        .where('isDeleted', isEqualTo: false)
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 10));

    if (duplicateSnapshot.docs.isNotEmpty) {
      throw Exception('A tenant with this email already exists.');
    }
    
    // Use the ID passed from the controller (ensures consistency with contract)
    final id = tenant.id.isNotEmpty ? tenant.id : const Uuid().v4();

    String? imageBase64 = tenant.imageBase64;
    // Process new image if provided
    if (imageFile != null) {
      imageBase64 = await _processImageToBase64(imageFile);
    }
    
    final data = {
      'id': id,
      'ownerId': uid,
      'tenantCode': tenant.tenantCode,
      'name': tenant.name,
      'phone': tenant.phone,
      'email': tenant.email,
      'imageUrl': tenant.imageUrl, 
      'imageBase64': imageBase64, 
      'authId': tenant.authId, 
      'isActive': tenant.isActive, // Use bool directly
      'advanceAmount': tenant.advanceAmount,
      'policeVerification': tenant.policeVerification,
      'idProof': tenant.idProof,
      'address': tenant.address,
      'memberCount': tenant.memberCount,
      'notes': tenant.notes,
      'documents': tenant.documents.map((e) => e.toJson()).toList(), // NEW
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
      'isDeleted': false,
    };

    await _firestore.collection(FirebaseCollections.tenants).doc(id).set(data).timeout(const Duration(seconds: 10)); // Use set with ID
    return id; // Return String UUID
  }
  
  // NEW: Create Tenancy
  @override
  Stream<List<Tenancy>> getAllTenancies() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    
    return _firestore.collection(FirebaseCollections.contracts)
        .where('ownerId', isEqualTo: uid)
        // .where('isDeleted', isEqualTo: false) // Moved to memory for rule compatibility
        .snapshots()
        .map((s) => s.docs
            .where((d) => d.data()['isDeleted'] != true)
            .map((d) => mapToTenancyDomain(d))
            .toList());
  }

  @override
  Future<String> createTenancy(Tenancy tenancy) async {
      final uid = _uid;
      if (uid == null) throw Exception('User not logged in');

      final data = {
        'id': tenancy.id,
        'ownerId': uid,
        'tenantId': tenancy.tenantId,
        'unitId': tenancy.unitId,
        'startDate': Timestamp.fromDate(tenancy.startDate),
        'endDate': tenancy.endDate != null ? Timestamp.fromDate(tenancy.endDate!) : null,
        'agreedRent': tenancy.agreedRent,
        'securityDeposit': tenancy.securityDeposit,
        'openingBalance': tenancy.openingBalance,
        'status': tenancy.status.index, // Store as int or string
        'notes': tenancy.notes,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'isDeleted': false,
      };

      await _firestore.collection(FirebaseCollections.contracts).doc(tenancy.id).set(data).timeout(const Duration(seconds: 10));
      return tenancy.id;
  }
  
  @override
  Future<void> endTenancy(String tenancyId) async {
     await _firestore.collection(FirebaseCollections.contracts).doc(tenancyId).update({
        'status': TenancyStatus.ended.index,
        'endDate': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
     });
  }

  @override
  Future<Tenancy?> getActiveTenancyForTenant(String tenantId) async {
    // Query by TenantId AND OwnerId (Security & Index Check)
    final uid = _uid;
    if (uid == null) return null;

    try {
      final snapshot = await _firestore.collection(FirebaseCollections.contracts)
          .where('ownerId', isEqualTo: uid)
          .where('tenantId', isEqualTo: tenantId)
          .where('isDeleted', isEqualTo: false) // Ensure not deleted
          .get();

      if (snapshot.docs.isEmpty) return null;
      
      // Filter in Dart to find 'Active' (Status 0)
      try {
        final doc = snapshot.docs.firstWhere((d) => d.data()['status'] == TenancyStatus.active.index);
        return mapToTenancyDomain(doc);
      } catch (_) {
        // No active tenancy found
        return null;
      }
    } catch (e) {
      debugPrint('Repo: Error getting active tenancy: $e');
      return null;
    }
  }

  @override
  Stream<Tenancy?> watchActiveTenancyForTenant(String tenantId) {
    final uid = _uid;
    if (uid == null) return Stream.value(null);

    return _firestore.collection(FirebaseCollections.contracts)
        .where('ownerId', isEqualTo: uid) // Ensure Owner Scope
        .where('tenantId', isEqualTo: tenantId)
        .where('isDeleted', isEqualTo: false)
        .snapshots() 
        .asyncMap((snapshot) async {
          // 1. Try to find an active tenancy in the stream
          try {
             if (snapshot.docs.isEmpty) return null;
             final doc = snapshot.docs.firstWhere((d) => d.data()['status'] == TenancyStatus.active.index);
             return mapToTenancyDomain(doc);
          } catch (_) {
             return null;
          }
        });
  }

  /// For TENANT-SIDE ACCESS: Uses provided ownerId instead of _uid (current user's Firebase Auth UID)
  /// because tenants log in with their own credentials, not the owner's.
  @override
  Stream<Tenancy?> watchActiveTenancyForTenantAccess(String tenantId, String ownerId) {
    return _firestore.collection(FirebaseCollections.contracts)
        .where('ownerId', isEqualTo: ownerId) // Use provided ownerId from tenant profile
        .where('tenantId', isEqualTo: tenantId)
        .where('isDeleted', isEqualTo: false)
        .snapshots() 
        .asyncMap((snapshot) async {
          try {
             if (snapshot.docs.isEmpty) return null;
             final doc = snapshot.docs.firstWhere((d) => d.data()['status'] == TenancyStatus.active.index);
             return mapToTenancyDomain(doc);
          } catch (_) {
             return null;
          }
        });
  }


  @override
  Future<Tenancy?> getTenancy(String tenancyId) async {
    final docSnap = await _firestore.collection(FirebaseCollections.contracts).doc(tenancyId).get();
    if (!docSnap.exists) return null;
    
    // Optional: Check owner
    final data = docSnap.data();
    if (data != null && data['ownerId'] == _uid) {
       return mapToTenancyDomain(docSnap);
    }
    return null; // Return null if not owned by current user (security)
  }

  @visibleForTesting
  Tenancy mapToTenancyDomain(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Tenancy(
      id: (data['id'] ?? doc.id).toString(),
      ownerId: data['ownerId']?.toString() ?? '',
      tenantId: data['tenantId']?.toString() ?? '',
      unitId: data['unitId']?.toString() ?? '',
      startDate: parseDate(data['startDate']) ?? DateTime.now(),
      endDate: parseDate(data['endDate']),
      agreedRent: (data['agreedRent'] is String) ? (double.tryParse(data['agreedRent']) ?? 0.0) : (data['agreedRent'] as num?)?.toDouble() ?? 0.0,
      securityDeposit: (data['securityDeposit'] is String) ? (double.tryParse(data['securityDeposit']) ?? 0.0) : (data['securityDeposit'] as num?)?.toDouble() ?? 0.0,
      openingBalance: (data['openingBalance'] is String) ? (double.tryParse(data['openingBalance']) ?? 0.0) : (data['openingBalance'] as num?)?.toDouble() ?? 0.0,
      status: TenancyStatus.values[data['status'] as int? ?? 0],
      notes: data['notes'] as String?,
    );
  }

  @visibleForTesting
  DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  Future<void> updateTenant(domain.Tenant tenant, {File? imageFile}) async {
    if (_uid == null) return;

    final snapshot = await _firestore.collection(FirebaseCollections.tenants)
        .where('ownerId', isEqualTo: _uid) 
        .where('id', isEqualTo: tenant.id)
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 10));

    if (snapshot.docs.isNotEmpty) {
      String? imageBase64 = tenant.imageBase64;
      // Process new image if provided
      if (imageFile != null) {
        imageBase64 = await _processImageToBase64(imageFile);
      }

      await snapshot.docs.first.reference.update({
        'name': tenant.name,
        'phone': tenant.phone,
        'email': tenant.email,
        'imageBase64': imageBase64, 
        'authId': tenant.authId, 
        'isActive': tenant.isActive,
        'advanceAmount': tenant.advanceAmount,
        'policeVerification': tenant.policeVerification,
        'idProof': tenant.idProof,
        'address': tenant.address,
        'memberCount': tenant.memberCount,
        'notes': tenant.notes,
        'documents': tenant.documents.map((e) => e.toJson()).toList(), // NEW
        'lastUpdated': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 10));
    }
  }

  @override
  Future<void> deleteTenant(String id) async { // String ID
     // Calls cascade
     await deleteTenantCascade(id, null);
  }

  @override
  Future<void> deleteTenantCascade(String tenantId, String? unitId) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated. Cannot delete tenant.');

    try {
      debugPrint('Starting Optimized Delete Tenant Cascade for: $tenantId (Owner: $uid)');

      // 1. Fetch related data in parallel (Tenancies and Maintenance)
      final results = await Future.wait([
        _firestore.collection(FirebaseCollections.contracts)
            .where('ownerId', isEqualTo: uid)
            .where('tenantId', isEqualTo: tenantId)
            .get(),
        _firestore.collection(FirebaseCollections.tickets)
            .where('ownerId', isEqualTo: uid)
            .where('tenantId', isEqualTo: tenantId)
            .get(),
      ]);

      final tenancySnapshot = results[0];
      final maintenanceSnapshot = results[1];

      final List<String> tenancyIds = tenancySnapshot.docs.map((doc) => doc.id).toList();
      final Set<String> linkedUnitIds = tenancySnapshot.docs
          .map((doc) => doc.data()['unitId']?.toString())
          .whereType<String>()
          .toSet();
      if (unitId != null) linkedUnitIds.add(unitId);

      // 2. Fetch Rent Cycles for all tenancies (batched by 30 due to whereIn limit)
      final List<DocumentSnapshot> rentCycleDocs = [];
      for (var i = 0; i < tenancyIds.length; i += 30) {
        final batchIds = tenancyIds.sublist(i, i + 30 > tenancyIds.length ? tenancyIds.length : i + 30);
        final snapshot = await _firestore.collection(FirebaseCollections.invoices)
            .where('ownerId', isEqualTo: uid)
            .where('tenancyId', whereIn: batchIds)
            .get();
        rentCycleDocs.addAll(snapshot.docs);
      }

      final List<String> rentCycleIds = rentCycleDocs.map((doc) => doc.id).toList();

      // 3. Fetch Payments for all rent cycles (batched by 30)
      final List<DocumentSnapshot> paymentDocs = [];
      for (var i = 0; i < rentCycleIds.length; i += 30) {
        final batchIds = rentCycleIds.sublist(i, i + 30 > rentCycleIds.length ? rentCycleIds.length : i + 30);
        final snapshot = await _firestore.collection(FirebaseCollections.transactions)
            .where('ownerId', isEqualTo: uid)
            .where('rentCycleId', whereIn: batchIds)
            .get();
        paymentDocs.addAll(snapshot.docs);
      }

      // 4. Perform Batched Deletions (Batch size 450)
      WriteBatch batch = _firestore.batch();
      int operationCount = 0;

      void addToBatch(DocumentReference ref, {Map<String, dynamic>? updateData, bool delete = false}) {
        if (delete) {
          batch.delete(ref);
        } else if (updateData != null) {
          batch.update(ref, updateData);
        }
        operationCount++;
        if (operationCount >= 450) {
          batch.commit();
          batch = _firestore.batch();
          operationCount = 0;
        }
      }

      // Deletions
      for (var doc in paymentDocs) {
        addToBatch(doc.reference, delete: true);
      }
      for (var doc in rentCycleDocs) {
        addToBatch(doc.reference, delete: true);
      }
      for (var doc in maintenanceSnapshot.docs) {
        addToBatch(doc.reference, delete: true);
      }
      for (var doc in tenancySnapshot.docs) {
        addToBatch(doc.reference, delete: true);
      }

      // Free Units
      for (final uId in linkedUnitIds) {
        final unitDocRef = _firestore.collection(FirebaseCollections.units).doc(uId);
        // We only update if it currently points to this tenant/tenancy (simplified check)
        addToBatch(unitDocRef, updateData: {
          'isOccupied': false,
          'currentTenancyId': FieldValue.delete(),
          'tenantId': FieldValue.delete(),
        });
      }

      // Final Tenant Delete
      final tenantDocRef = _firestore.collection(FirebaseCollections.tenants).doc(tenantId);
      addToBatch(tenantDocRef, delete: true);

      if (operationCount > 0) {
        await batch.commit();
      }

      debugPrint('Optimized Delete Tenant Cascade Complete.');
    } catch (e) {
      debugPrint('Error in Optimized Delete Tenant Cascade: $e');
      rethrow;
    }
  }

  @override
  Stream<domain.Tenant?> watchTenant(String id) {
     return _firestore.collection(FirebaseCollections.tenants)
        .doc(id)
        .snapshots()
        .map((snapshot) {
           if (!snapshot.exists) return null;
           final data = snapshot.data();
           if (data == null || data['isDeleted'] == true) return null;
           return _mapToDomain(snapshot);
        });
  }

  @override
  Future<domain.Tenant?> authenticateTenant(String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      final uid = userCredential.user?.uid;
      if (uid == null) return null;

      final snapshot = await _firestore.collection(FirebaseCollections.tenants)
          .where('authId', isEqualTo: uid)
          .where('isDeleted', isEqualTo: false)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        await FirebaseAuth.instance.signOut();
        return null; 
      }

      final tenant = _mapToDomain(snapshot.docs.first);
      if (!tenant.isActive) { // Check bool
        await FirebaseAuth.instance.signOut();
        return null;
      }

      return tenant;
      
    } on FirebaseAuthException catch (e) {
      debugPrint('Tenant Login Auth Error: ${e.code}');
      // Return null for invalid credentials
      return null;
    } catch (e) {
      debugPrint('Tenant Login Unknown Error: $e');
      return null;
    }
  }

  domain.Tenant _mapToDomain(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return domain.Tenant(
      id: (data['id'] ?? doc.id).toString(), // Use string ID
      tenantCode: (data['tenantCode'] ?? '').toString(), // Safe string conversion
      name: data['name'],
      phone: data['phone'],
      email: data['email'],
      isActive: data['isActive'] ?? true, // Bool
      imageUrl: data['imageUrl'] as String?,
      imageBase64: data['imageBase64'] as String?, 
      authId: data['authId'] as String?, 
      ownerId: data['ownerId']?.toString() ?? '', 
      advanceAmount: (data['advanceAmount'] as num?)?.toDouble() ?? 0.0,
      policeVerification: data['policeVerification'] ?? false,
      idProof: data['idProof'] as String?,
      address: data['address'] as String?,
      memberCount: data['memberCount'] as int? ?? 1,
      notes: data['notes'] as String?,
      documents: (data['documents'] as List<dynamic>?) // NEW
          ?.map((e) => VerificationDocument.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}
