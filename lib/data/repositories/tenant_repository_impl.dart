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

class TenantRepositoryImpl implements ITenantRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  TenantRepositoryImpl(this._firestore) 
      : _auth = FirebaseAuth.instance,
        _storage = FirebaseStorage.instance;

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

  // --- Encryption Helpers ---
  final _key = encrypt.Key.fromUtf8('RentPilotProSecretKey32CharsLong'); 
  final _iv = encrypt.IV.fromUtf8('RentPilotProIV16'); 

  String? _encryptPassword(String? password) {
    if (password == null || password.isEmpty) return null;
    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      return encrypter.encrypt(password, iv: _iv).base64;
    } catch (e) {
      debugPrint('Encryption Error: $e');
      return password; 
    }
  }

  String? _decryptPassword(String? encryptedPassword) {
    if (encryptedPassword == null || encryptedPassword.isEmpty) return null;
    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      return encrypter.decrypt64(encryptedPassword, iv: _iv);
    } catch (e) {
      return encryptedPassword;
    }
  }


  @override
  Stream<List<domain.Tenant>> getAllTenants() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    
    return _firestore.collection('tenants')
        .where('ownerId', isEqualTo: uid)
        .where('isDeleted', isEqualTo: false)
        .snapshots() // Stream!
        .map((snapshot) => snapshot.docs.map((doc) => _mapToDomain(doc)).toList());
  }

  @override
  Future<domain.Tenant?> getTenant(String id) async { // String ID
    if (_uid == null) return null;

    final snapshot = await _firestore.collection('tenants')
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
        .get()
        .timeout(const Duration(seconds: 10));
        
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
        .get()
        .timeout(const Duration(seconds: 10));

    if (duplicateSnapshot.docs.isNotEmpty) {
      throw Exception('A tenant with this email already exists.');
    }
    
    if (duplicateSnapshot.docs.isNotEmpty) {
      throw Exception('A tenant with this email already exists.');
    }
    
    // NEW: Use UUID for ID
    final id = const Uuid().v4();

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
      'password': _encryptPassword(tenant.password), 
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
      'isDeleted': false,
    };

    await _firestore.collection('tenants').doc(id).set(data).timeout(const Duration(seconds: 10)); // Use set with ID
    return id; // Return String UUID
  }

  // NEW: Create Tenancy
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

      await _firestore.collection('tenancies').doc(tenancy.id).set(data).timeout(const Duration(seconds: 10));
      return tenancy.id;
  }
  
  @override
  Future<void> endTenancy(String tenancyId) async {
     await _firestore.collection('tenancies').doc(tenancyId).update({
        'status': TenancyStatus.ended.index,
        'endDate': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
     });
  }

  @override
  Future<void> updateTenant(domain.Tenant tenant, {File? imageFile}) async {
    if (_uid == null) return;

    final snapshot = await _firestore.collection('tenants')
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
        'isActive': tenant.status == domain.TenantStatus.active,
        'agreedRent': tenant.agreedRent,
        'password': _encryptPassword(tenant.password), 
        'lastUpdated': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 10));
    }
  }

  @override
  Future<void> deleteTenant(String id) async { // String ID
    if (_uid == null) return;

    final docRef = _firestore.collection('tenants').doc(id); // Direct doc ref

    // Check ownership first
    final snap = await docRef.get();
    if(snap.exists && snap.data()?['ownerId'] == _uid) {
       await docRef.delete();
       // Also delete/close tenancies? For now, we leave them or cascade manually
    }
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

      final snapshot = await _firestore.collection('tenants')
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
      id: data['id'] ?? doc.id, // Use string ID
      tenantCode: data['tenantCode'],
      name: data['name'],
      phone: data['phone'],
      email: data['email'],
      isActive: data['isActive'] ?? true, // Bool
      password: _decryptPassword(data['password'] as String?), 
      imageUrl: data['imageUrl'] as String?,
      imageBase64: data['imageBase64'] as String?, 
      authId: data['authId'] as String?, 
      ownerId: data['ownerId'] as String? ?? '', 
    );
  }
}
