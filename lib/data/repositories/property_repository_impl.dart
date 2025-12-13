import 'dart:io';
import 'package:flutter/foundation.dart';
 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/house.dart' as domain;
import '../../domain/entities/bhk_template.dart' as domain;
import '../../domain/repositories/i_property_repository.dart';

class PropertyRepositoryImpl implements IPropertyRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PropertyRepositoryImpl(this._firestore) 
      : _auth = FirebaseAuth.instance; // Init

  String? get _uid => _auth.currentUser?.uid;

  // --- Houses ---

  @override
  Future<List<domain.House>> getHouses() async {
    if (_uid == null) return [];
    
    final snapshot = await _firestore.collection('houses')
      .where('ownerId', isEqualTo: _uid)
      .get();
      
    // Filter in Dart to rely only on default ownerId index
    return snapshot.docs
        .where((doc) => doc.data()['isDeleted'] != true)
        .map((doc) => _mapHouse(doc))
        .toList();
  }

  @override
  Future<domain.House?> getHouse(int id) async {
    if (_uid == null) return null;

    final snapshot = await _firestore.collection('houses')
      .where('ownerId', isEqualTo: _uid) // CRITICAL
      .where('id', isEqualTo: id)
      .limit(1)
      .get();
      
    if (snapshot.docs.isEmpty) return null;
    final data = snapshot.docs.first.data();
    if (data['isDeleted'] == true) return null;
    return _mapHouse(snapshot.docs.first);
  }

  @override
  Future<int> createHouse(domain.House house) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');

    final id = DateTime.now().millisecondsSinceEpoch;
    
    final data = {
      'id': id,
      'ownerId': uid,
      'name': house.name,
      'address': house.address,
      'notes': house.notes,
      'imageUrl': house.imageUrl, // Save URL if already exists (e.g. from copy), otherwise null
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
      'isDeleted': false,
    };

    await _firestore.collection('houses').add(data);
    return id;
  }

  @override
  Future<void> updateHouse(domain.House house) async {
    final snapshot = await _firestore.collection('houses')
      .where('ownerId', isEqualTo: _uid)
      .where('id', isEqualTo: house.id)
      .limit(1)
      .get();
      
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'name': house.name,
        'address': house.address,
        'notes': house.notes,
        'imageUrl': house.imageUrl, // Update URL if changed logic exists elsewhere (purely metadata now)
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> deleteHouse(int id) async {
    final batch = _firestore.batch();
    
    // 1. Get House
    final houseSnapshot = await _firestore.collection('houses')
      .where('ownerId', isEqualTo: _uid)
      .where('id', isEqualTo: id)
      .limit(1)
      .get();
      
    if (houseSnapshot.docs.isEmpty) return; // Nothing to delete

    // 2. Soft Delete House
    // 2. Delete House (Hard Delete)
    batch.delete(houseSnapshot.docs.first.reference);
      
    // 3. Get Units
    final unitsSnapshot = await _firestore.collection('units')
      .where('ownerId', isEqualTo: _uid) // Ensure we only touch OUR units
      .where('houseId', isEqualTo: id)
      .get();
      
    // 4. Delete Units (Hard Delete)
    for (final doc in unitsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // 5. Commit
    await batch.commit();
  }

  // --- Units (Unchanged logic, just keeping structure) ---

  @override
  Future<List<domain.Unit>> getAllUnits() async {
    if (_uid == null) return [];
    
    final snapshot = await _firestore.collection('units')
      .where('ownerId', isEqualTo: _uid)
      .where('isDeleted', isEqualTo: false)
      .get();
      
    return snapshot.docs.map((doc) => _mapUnit(doc)).toList();
  }

  @override
  Future<List<domain.Unit>> getUnits(int houseId) async {
    if (_uid == null) return [];

    final snapshot = await _firestore.collection('units')
      .where('ownerId', isEqualTo: _uid) // CRITICAL
      .where('houseId', isEqualTo: houseId)
      .where('isDeleted', isEqualTo: false)
      .get();
      
    return snapshot.docs.map((doc) => _mapUnit(doc)).toList();
  }

  @override
  Future<domain.Unit?> getUnit(int id) async {
     if (_uid == null) return null;

    final snapshot = await _firestore.collection('units')
      .where('ownerId', isEqualTo: _uid) // CRITICAL
      .where('id', isEqualTo: id)
      .limit(1)
      .get();
      
    if (snapshot.docs.isEmpty) return null;
    final data = snapshot.docs.first.data();
    if (data['isDeleted'] == true) return null;
    return _mapUnit(snapshot.docs.first);
  }

  @override
  Future<int> createUnit(domain.Unit unit) async {
     final uid = _uid;
    if (uid == null) throw Exception('User not logged in');
    
    final id = DateTime.now().millisecondsSinceEpoch;
    
    final data = {
      'id': id,
      'ownerId': uid,
      'houseId': unit.houseId,
      'nameOrNumber': unit.nameOrNumber,
      'floor': unit.floor,
      'baseRent': unit.baseRent,
      'defaultDueDay': unit.defaultDueDay,
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
      'isDeleted': false,
      'isOccupied': unit.isOccupied,
      'bhkTemplateId': unit.bhkTemplateId,
      'bhkType': unit.bhkType,
      'editableRent': unit.editableRent,
      'tenantId': unit.tenantId,

      'furnishingStatus': unit.furnishingStatus,
      'carpetArea': unit.carpetArea,
      'parkingSlot': unit.parkingSlot,
      'meterNumber': unit.meterNumber,
    };
    
    await _firestore.collection('units').add(data);
    return id;
  }

  @override
  Future<void> updateUnit(domain.Unit unit) async {
    final snapshot = await _firestore.collection('units')
      .where('ownerId', isEqualTo: _uid)
      .where('id', isEqualTo: unit.id)
      .limit(1)
      .get();
      
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'nameOrNumber': unit.nameOrNumber,
        'floor': unit.floor,
        'baseRent': unit.baseRent,
        'defaultDueDay': unit.defaultDueDay,
        'isOccupied': unit.isOccupied,
        'bhkTemplateId': unit.bhkTemplateId,
        'bhkType': unit.bhkType,
        'editableRent': unit.editableRent,
        'tenantId': unit.tenantId,

        'furnishingStatus': unit.furnishingStatus,
        'carpetArea': unit.carpetArea,
        'parkingSlot': unit.parkingSlot,
        'meterNumber': unit.meterNumber,

        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> updateUnitsBatch(List<domain.Unit> units) async {
    final batch = _firestore.batch();
    
    if (units.isEmpty) return;
    final houseId = units.first.houseId;

    final snapshot = await _firestore.collection('units')
      .where('ownerId', isEqualTo: _uid)
      .where('houseId', isEqualTo: houseId)
      .get();
      
    final Map<int, DocumentReference> idToRefMap = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final internalId = data['id'] as int;
      idToRefMap[internalId] = doc.reference;
    }

    for (final unit in units) {
      final ref = idToRefMap[unit.id];
      if (ref != null) {
        batch.update(ref, {
          'nameOrNumber': unit.nameOrNumber,
          'floor': unit.floor,
          'baseRent': unit.baseRent,
          'defaultDueDay': unit.defaultDueDay,
          'isOccupied': unit.isOccupied,
          'bhkTemplateId': unit.bhkTemplateId,
          'bhkType': unit.bhkType,
          'editableRent': unit.editableRent,
          'tenantId': unit.tenantId,

          'furnishingStatus': unit.furnishingStatus,
          'carpetArea': unit.carpetArea,
          'parkingSlot': unit.parkingSlot,
          'meterNumber': unit.meterNumber,

          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    }

    await batch.commit();
  }

  @override
  Future<void> deleteUnit(int id) async {
     final snapshot = await _firestore.collection('units')
      .where('ownerId', isEqualTo: _uid) // Safety
      .where('id', isEqualTo: id)
      .limit(1)
      .get();
      
    if (snapshot.docs.isNotEmpty) {
      // Hard Delete
      await snapshot.docs.first.reference.delete();
    }
  }

  // --- BHK Templates ---
  
  Future<int> createBhkTemplate(domain.BhkTemplate template) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');
    
    final id = DateTime.now().millisecondsSinceEpoch;
    
    final data = {
      'id': id,
      'ownerId': uid,
      'houseId': template.houseId,
      'bhkType': template.bhkType,
      'defaultRent': template.defaultRent,
      'description': template.description,
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
      'isDeleted': false,
    };
    
    await _firestore.collection('bhkTemplates').add(data);
    return id;
  }
  
  Future<List<domain.BhkTemplate>> getBhkTemplates(int houseId) async {
    if (_uid == null) return [];
    
    final snapshot = await _firestore.collection('bhkTemplates')
      .where('ownerId', isEqualTo: _uid)
      .where('houseId', isEqualTo: houseId)
      .get();
      
    return snapshot.docs
      .where((doc) => doc.data()['isDeleted'] != true)
      .map((doc) => _mapBhkTemplate(doc))
      .toList();
  }

  // --- Mappers ---

  domain.BhkTemplate _mapBhkTemplate(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return domain.BhkTemplate(
      id: data['id'],
      houseId: data['houseId'],
      bhkType: data['bhkType'],
      defaultRent: (data['defaultRent'] as num).toDouble(),
      description: data['description'],
    );
  }

  domain.House _mapHouse(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return domain.House(
      id: data['id'],
      name: data['name'],
      address: data['address'],
      notes: data['notes'],
      imageUrl: data['imageUrl'], 
      unitCount: 0, 
    );
  }

  domain.Unit _mapUnit(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return domain.Unit(
      id: data['id'],
      houseId: data['houseId'],
      nameOrNumber: data['nameOrNumber'],
      floor: data['floor'],
      baseRent: (data['baseRent'] as num).toDouble(),
      
      bhkTemplateId: data['bhkTemplateId'],
      bhkType: data['bhkType'],
      editableRent: (data['editableRent'] as num?)?.toDouble(),
      tenantId: data['tenantId'],

      furnishingStatus: data['furnishingStatus'],
      carpetArea: (data['carpetArea'] as num?)?.toDouble(),
      parkingSlot: data['parkingSlot'],
      meterNumber: data['meterNumber'],
      
      defaultDueDay: data['defaultDueDay'],
      isOccupied: data['isOccupied'] ?? false,
    );
  }
}
