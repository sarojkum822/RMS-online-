import 'dart:io';
import 'package:flutter/foundation.dart';
 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/house.dart' as domain;
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
    final snapshot = await _firestore.collection('houses')
      .where('ownerId', isEqualTo: _uid)
      .where('id', isEqualTo: id)
      .limit(1)
      .get();
      
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'isDeleted': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      final unitsSnapshot = await _firestore.collection('units')
        .where('houseId', isEqualTo: id)
        .get();
        
      for (final doc in unitsSnapshot.docs) {
        await doc.reference.update({
          'isDeleted': true,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    }
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
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> deleteUnit(int id) async {
     final snapshot = await _firestore.collection('units')
      .where('ownerId', isEqualTo: _uid)
      .where('id', isEqualTo: id)
      .limit(1)
      .get();
      
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'isDeleted': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  // --- Mappers ---

  domain.House _mapHouse(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return domain.House(
      id: data['id'],
      name: data['name'],
      address: data['address'],
      notes: data['notes'],
      imageUrl: data['imageUrl'], // Map field
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
      defaultDueDay: data['defaultDueDay'],
    );
  }
}
