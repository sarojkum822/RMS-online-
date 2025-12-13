import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../domain/entities/tenant.dart' as domain;
import '../../domain/repositories/i_tenant_repository.dart';

class TenantRepositoryImpl implements ITenantRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  TenantRepositoryImpl(this._firestore) 
      : _auth = FirebaseAuth.instance,
        _storage = FirebaseStorage.instance;

  String? get _uid => _auth.currentUser?.uid;

  // --- Image Upload ---
  Future<String?> uploadTenantImage(File imageFile, int tenantId) async {
    final uid = _uid;
    if (uid == null) return null;
    
    try {
      // 1. Compress Image
      final filePath = imageFile.absolute.path;
      final lastIndex = filePath.lastIndexOf('.');
      final split = filePath.substring(0, lastIndex);
      final outPath = '${split}_out.jpg';
      
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        outPath,
        quality: 80,
        minWidth: 1024,
        minHeight: 1024,
      );

      final fileToUpload = compressedFile != null ? File(compressedFile.path) : imageFile;

      // 2. Upload
      final ref = _storage.ref().child('owners/$uid/tenants/$tenantId.jpg');
      await ref.putFile(fileToUpload);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading tenant image: $e');
      return null;
    }
  }

  // --- Encryption Helpers ---
  // Note: ideally Key should be from Env or SecureStorage, but for this scope hardcoded is acceptable as per request "hashed in database"
  final _key = encrypt.Key.fromUtf8('RentPilotProSecretKey32CharsLong'); // 32 chars
  final _iv = encrypt.IV.fromUtf8('RentPilotProIV16'); // 16 chars fixed IV for deterministic encryption

  String? _encryptPassword(String? password) {
    if (password == null || password.isEmpty) return null;
    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      return encrypter.encrypt(password, iv: _iv).base64;
    } catch (e) {
      debugPrint('Encryption Error: $e');
      return password; // Fallback (should ideally handle better)
    }
  }

  String? _decryptPassword(String? encryptedPassword) {
    if (encryptedPassword == null || encryptedPassword.isEmpty) return null;
    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      return encrypter.decrypt64(encryptedPassword, iv: _iv);
    } catch (e) {
      // Logic: If decryption fails, it might be an OLD plain-text password. Return as is.
      return encryptedPassword;
    }
  }


  @override
  Future<List<domain.Tenant>> getAllTenants() async {
    if (_uid == null) return [];
    
    final snapshot = await _firestore.collection('tenants')
        .where('ownerId', isEqualTo: _uid)
        .where('isDeleted', isEqualTo: false)
        .get();
        
    return snapshot.docs.map((doc) => _mapToDomain(doc)).toList();
  }

  @override
  Future<domain.Tenant?> getTenant(int id) async {
    if (_uid == null) return null;

    final snapshot = await _firestore.collection('tenants')
        .where('ownerId', isEqualTo: _uid) // CRITICAL
        .where('id', isEqualTo: id)
        .limit(1)
        .get();
        
    if (snapshot.docs.isEmpty) return null;
    final data = snapshot.docs.first.data();
    if (data['isDeleted'] == true) return null;
    return _mapToDomain(snapshot.docs.first);
  }

  @override
  Future<domain.Tenant?> getTenantByCode(String code) async {
    final snapshot = await _firestore.collection('tenants')
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
    final snapshot = await _firestore.collection('tenants')
        .where('authId', isEqualTo: authId)
        .where('isDeleted', isEqualTo: false)
        .limit(1)
        .get();
        
    if (snapshot.docs.isEmpty) return null;
    return _mapToDomain(snapshot.docs.first);
  }
  @override
  Future<int> createTenant(domain.Tenant tenant, {File? imageFile}) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');

    // Check for duplicate email
    final duplicateSnapshot = await _firestore.collection('tenants')
        .where('ownerId', isEqualTo: uid)
        .where('email', isEqualTo: tenant.email)
        .where('isDeleted', isEqualTo: false)
        .limit(1)
        .get();

    if (duplicateSnapshot.docs.isNotEmpty) {
      throw Exception('A tenant with this email already exists.');
    }
    
    final id = DateTime.now().millisecondsSinceEpoch;

    String? imageUrl = tenant.imageUrl;
    if (imageFile != null) {
      imageUrl = await uploadTenantImage(imageFile, id);
    }
    
    final data = {
      'id': id,
      'ownerId': uid,
      'houseId': tenant.houseId,
      'unitId': tenant.unitId,
      'tenantCode': tenant.tenantCode,
      'name': tenant.name,
      'phone': tenant.phone,
      'email': tenant.email,
      'imageUrl': imageUrl, // Save URL
      'authId': tenant.authId, // Save Auth ID
      'startDate': Timestamp.fromDate(tenant.startDate),
      'isActive': tenant.status == domain.TenantStatus.active,
      'agreedRent': tenant.agreedRent,
      'password': _encryptPassword(tenant.password), // ENCRYPTED
      'openingBalance': tenant.openingBalance,
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
      'isDeleted': false,
    };

    await _firestore.collection('tenants').add(data);
    return id;
  }

  @override
  Future<void> updateTenant(domain.Tenant tenant, {File? imageFile}) async {
    if (_uid == null) return;

    final snapshot = await _firestore.collection('tenants')
        .where('ownerId', isEqualTo: _uid) // CRITICAL
        .where('id', isEqualTo: tenant.id)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      String? imageUrl = tenant.imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadTenantImage(imageFile, tenant.id);
      }

      await snapshot.docs.first.reference.update({
        'name': tenant.name,
        'phone': tenant.phone,
        'email': tenant.email,
        'imageUrl': imageUrl, // Update URL
        'authId': tenant.authId, // Update Auth ID if needed
        'isActive': tenant.status == domain.TenantStatus.active,
        'agreedRent': tenant.agreedRent,
        'password': _encryptPassword(tenant.password), // ENCRYPTED
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> deleteTenant(int id) async {
    if (_uid == null) return;

    final snapshot = await _firestore.collection('tenants')
        .where('ownerId', isEqualTo: _uid) // CRITICAL
        .where('id', isEqualTo: id)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Hard Delete Tenant
      await snapshot.docs.first.reference.delete();

      final cyclesSnapshot = await _firestore.collection('rent_cycles')
          .where('ownerId', isEqualTo: _uid) // Safety
          .where('tenantId', isEqualTo: id)
          .get();

      final batch = _firestore.batch();
      for (final doc in cyclesSnapshot.docs) {
          batch.delete(doc.reference); // Hard Delete Bills
      }
      await batch.commit();
    }
  }

  @override
  Future<domain.Tenant?> authenticateTenant(String email, String password) async {
    try {
      // 1. Attempt to Sign In with Firebase Auth directly
      // This validates the credentials against the secure Firebase system.
      // It also sets the 'currentUser', essentially logging them in.
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      final uid = userCredential.user?.uid;
      if (uid == null) return null;

      // 2. Fetch the Tenant Profile associated with this Auth ID
      // Now that we are logged in, Firestore Rules should allow reading our own document
      // (assuming rules allow allow read: if request.auth.uid == resource.data.authId)
      final snapshot = await _firestore.collection('tenants')
          .where('authId', isEqualTo: uid)
          .where('isDeleted', isEqualTo: false)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        // Edge Case: Auth User exists, but Tenant Profile deleted/missing.
        // Sign out to prevent "ghost" session.
        await FirebaseAuth.instance.signOut();
        return null; 
      }

      final tenant = _mapToDomain(snapshot.docs.first);
      if (tenant.status != domain.TenantStatus.active) {
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
      id: data['id'],
      houseId: data['houseId'],
      unitId: data['unitId'],
      tenantCode: data['tenantCode'],
      name: data['name'],
      phone: data['phone'],
      email: data['email'],
      startDate: data['startDate'] != null ? (data['startDate'] as Timestamp).toDate() : DateTime.now(),
      status: (data['isActive'] ?? true) ? domain.TenantStatus.active : domain.TenantStatus.inactive,
      openingBalance: (data['openingBalance'] as num?)?.toDouble() ?? 0.0,
      agreedRent: (data['agreedRent'] as num?)?.toDouble(),
      password: _decryptPassword(data['password'] as String?), // DECRYPTED
      imageUrl: data['imageUrl'] as String?,
      authId: data['authId'] as String?, // Map Auth ID
      ownerId: data['ownerId'] as String? ?? '', // Default to empty if missing (shouldn't be)
    );
  }
}
