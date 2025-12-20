
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/house.dart' as domain;
import '../../domain/entities/bhk_template.dart' as domain;
import '../../domain/repositories/i_property_repository.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/firebase_collections.dart'; // Import Constants

class PropertyRepositoryImpl implements IPropertyRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PropertyRepositoryImpl(this._firestore) 
      : _auth = FirebaseAuth.instance; // Init

  String? get _uid => _auth.currentUser?.uid;

  // --- Houses ---

  @override
  Stream<List<domain.House>> getHouses() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    
    return _firestore.collection(FirebaseCollections.properties)
      .where('ownerId', isEqualTo: uid)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
          .where((doc) => doc.data()['isDeleted'] != true)
          .map((doc) => _mapHouse(doc))
          .toList();
      });
  }

  @override
  Future<domain.House?> getHouse(String id) async {
    if (_uid == null) return null;

    final snapshot = await _firestore.collection(FirebaseCollections.properties)
        .where('ownerId', isEqualTo: _uid) 
        .where('id', isEqualTo: id)
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 10));
        
    if (snapshot.docs.isEmpty) return null;
    final data = snapshot.docs.first.data();
    if (data['isDeleted'] == true) return null;
    return _mapHouse(snapshot.docs.first);
  }

  @override
  Future<domain.House?> getHouseForTenant(String id, String ownerId) async {
    final snapshot = await _firestore.collection(FirebaseCollections.properties)
        .where('ownerId', isEqualTo: ownerId)
        .where('id', isEqualTo: id)
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 10));
        
    if (snapshot.docs.isEmpty) return null;
    final data = snapshot.docs.first.data();
    if (data['isDeleted'] == true) return null;
    return _mapHouse(snapshot.docs.first);
  }

  @override
  Future<String> createHouse(domain.House house) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');

    // Use the ID passed from the controller (ensures consistency)
    final id = house.id.isNotEmpty ? house.id : const Uuid().v4();
    
    final data = {
      'id': id,
      'ownerId': uid,
      'name': house.name,
      'address': house.address,
      'notes': house.notes,
      'imageUrl': house.imageUrl, 
      'imageBase64': house.imageBase64, 
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
      'isDeleted': false,
    };

    // Use .doc(id).set() to ensure Firestore document ID matches id field
    await _firestore.collection(FirebaseCollections.properties).doc(id).set(data);
    return id;
  }

  @override
  Future<void> updateHouse(domain.House house) async {
    final snapshot = await _firestore.collection(FirebaseCollections.properties)
        .where('ownerId', isEqualTo: _uid)
        .where('id', isEqualTo: house.id)
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 10));
        
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'name': house.name,
        'address': house.address,
        'notes': house.notes,
        'imageUrl': house.imageUrl, 
        'imageBase64': house.imageBase64, 
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> deleteHouse(String id) async {
    final batch = _firestore.batch();
    
    // 1. Get House Reference (Try Field ID first, then Doc ID)
    DocumentReference? houseRef;
    String? resolvedHouseId; // The ID used by units to link to this house

    // A. Try finding by internal 'id' field
    final snapshot = await _firestore.collection(FirebaseCollections.properties)
        .where('ownerId', isEqualTo: _uid)
        .where('id', isEqualTo: id)
        .limit(1)
        .get();
        
    if (snapshot.docs.isNotEmpty) {
      houseRef = snapshot.docs.first.reference;
      resolvedHouseId = snapshot.docs.first.data()['id']; 
    } else {
      // B. Fallback: Try finding by Document ID
      final docRef = _firestore.collection(FirebaseCollections.properties).doc(id);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists && docSnapshot.data()?['ownerId'] == _uid) {
        houseRef = docRef;
        resolvedHouseId = docSnapshot.data()?['id'] ?? docRef.id; 
        // If data['id'] is missing, assumed units might link via Doc ID (fallback behaviour)
      }
    }

    if (houseRef == null) {
       // House not found, nothing to delete
       return;
    }
    
    // 2. Queue House Deletion
    batch.delete(houseRef);
      
    // 3. Get Units linked to this House
    // Use the resolved ID (usually UUID)
    if (resolvedHouseId != null) {
      final unitsSnapshot = await _firestore.collection(FirebaseCollections.units)
          .where('ownerId', isEqualTo: _uid) 
          .where('houseId', isEqualTo: resolvedHouseId)
          .get();
          
      // 4. Queue Units Deletion
      for (final doc in unitsSnapshot.docs) {
        batch.delete(doc.reference);
      }
    }

    // 5. Commit
    await batch.commit();
  }

  // --- Units ---

  @override
  Stream<List<domain.Unit>> getAllUnits() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    
    return _firestore.collection(FirebaseCollections.units)
        .where('ownerId', isEqualTo: uid)
        // .where('isDeleted', isEqualTo: false) // Moved to memory for rule compatibility
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((doc) => doc.data()['isDeleted'] != true)
            .map((doc) => _mapUnit(doc))
            .toList());
  }

  @override
  Stream<List<domain.Unit>> getUnits(String houseId) {
    final uid = _uid;
    if (uid == null) return Stream.value([]);

    return _firestore.collection(FirebaseCollections.units)
        .where('ownerId', isEqualTo: uid) 
        .where('houseId', isEqualTo: houseId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          final units = snapshot.docs.map((doc) => _mapUnit(doc)).toList();
          units.sort((a, b) {
             final aNumStr = RegExp(r'(\d+)').firstMatch(a.nameOrNumber)?.group(0);
             final bNumStr = RegExp(r'(\d+)').firstMatch(b.nameOrNumber)?.group(0);
             if (aNumStr != null && bNumStr != null) {
                // If both look like "Flat 123", sort by 123
                final aNum = int.parse(aNumStr);
                final bNum = int.parse(bNumStr);
                final aText = a.nameOrNumber.replaceAll(RegExp(r'\d'), '').trim();
                final bText = b.nameOrNumber.replaceAll(RegExp(r'\d'), '').trim();
                if (aText == bText) return aNum.compareTo(bNum);
             }
             return a.nameOrNumber.compareTo(b.nameOrNumber);
          });
          return units;
        });
  }

  @override
  Future<domain.Unit?> getUnit(String id) async {
     if (_uid == null) return null;

    final snapshot = await _firestore.collection(FirebaseCollections.units)
        .where('ownerId', isEqualTo: _uid) 
        .where('id', isEqualTo: id)
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 10));
        
    if (snapshot.docs.isEmpty) return null;
    final data = snapshot.docs.first.data();
    if (data['isDeleted'] == true) return null;
    return _mapUnit(snapshot.docs.first);
  }

  @override
  Future<domain.Unit?> getUnitForTenant(String id, String ownerId) async {
    final snapshot = await _firestore.collection(FirebaseCollections.units)
        .where('ownerId', isEqualTo: ownerId)
        .where('id', isEqualTo: id)
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 10));
        
    if (snapshot.docs.isEmpty) return null;
    final data = snapshot.docs.first.data();
    if (data['isDeleted'] == true) return null;
    return _mapUnit(snapshot.docs.first);
  }

  @override
  Future<String> createUnit(domain.Unit unit) async {
     final uid = _uid;
    if (uid == null) throw Exception('User not logged in');
    
    // Check for duplicate name in this house to prevent ghosts
    final existingParams = await _firestore.collection(FirebaseCollections.units)
        .where('ownerId', isEqualTo: uid)
        .where('houseId', isEqualTo: unit.houseId)
        .where('nameOrNumber', isEqualTo: unit.nameOrNumber)
        .where('isDeleted', isEqualTo: false)
        .limit(1)
        .get();

    if (existingParams.docs.isNotEmpty) {
      return existingParams.docs.first.data()['id'] ?? existingParams.docs.first.id;
    }
    // Use the ID passed from the controller (ensures consistency with electric readings)
    final id = unit.id.isNotEmpty ? unit.id : const Uuid().v4();
    
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
      'currentTenancyId': unit.currentTenancyId,

      'furnishingStatus': unit.furnishingStatus,
      'carpetArea': unit.carpetArea,
      'parkingSlot': unit.parkingSlot,
      'meterNumber': unit.meterNumber,
      
      'imagesBase64': unit.imagesBase64, 
    };
    
    // Use .doc(id).set() to ensure Firestore document ID matches id field
    await _firestore.collection(FirebaseCollections.units).doc(id).set(data);
    return id;
  }

  @override
  Future<void> updateUnit(domain.Unit unit) async {
    final snapshot = await _firestore.collection(FirebaseCollections.units)
        .where('ownerId', isEqualTo: _uid)
        .where('id', isEqualTo: unit.id)
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 10));
        
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
        'currentTenancyId': unit.currentTenancyId,

        'furnishingStatus': unit.furnishingStatus,
        'carpetArea': unit.carpetArea,
        'parkingSlot': unit.parkingSlot,
        'meterNumber': unit.meterNumber,
        
        'imagesBase64': unit.imagesBase64, 

        'lastUpdated': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 10));
    }
  }

  @override
  Future<void> updateUnitsBatch(List<domain.Unit> units) async {
    final batch = _firestore.batch();
    
    if (units.isEmpty) return;
    final houseId = units.first.houseId;

    final snapshot = await _firestore.collection(FirebaseCollections.units)
        .where('ownerId', isEqualTo: _uid)
        .where('houseId', isEqualTo: houseId)
        .get();
        
    final Map<String, DocumentReference> idToRefMap = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final internalId = (data['id'] ?? doc.id).toString();
      idToRefMap[internalId] = doc.reference;
    }
    
    // Explicitly define Map key type as String
    final Map<String, DocumentReference> idToRefMapTyped = idToRefMap;

    for (final unit in units) {
      final ref = idToRefMapTyped[unit.id];
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
          'currentTenancyId': unit.currentTenancyId,

          'furnishingStatus': unit.furnishingStatus,
          'carpetArea': unit.carpetArea,
          'parkingSlot': unit.parkingSlot,
          'meterNumber': unit.meterNumber,
          
          'imagesBase64': unit.imagesBase64, 

          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    }

    await batch.commit();
  }

  @override
  Future<void> deleteUnit(String id) async {
     // 1. Try finding by internal 'id' (UUID) - REMOVE LIMIT to delete duplicates
     var snapshot = await _firestore.collection(FirebaseCollections.units)
        .where('ownerId', isEqualTo: _uid) 
        .where('id', isEqualTo: id)
        .get() // No limit(1)
        .timeout(const Duration(seconds: 10));
        
    bool deletedAny = false;
    if (snapshot.docs.isNotEmpty) {
      // Delete ALL matching duplicates
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
         batch.delete(doc.reference);
      }
      await batch.commit();
      deletedAny = true;
    }

    // 2. Fallback: Try finding by Document ID (only if searching by field didn't find anything, OR purely to be safe)
    // If the ID passed IS the Doc ID, step 1 finds nothing (unless 'id' field matches Doc ID).
    // So we check Doc ID explicitly.
    if (!deletedAny) {
       final docRef = _firestore.collection(FirebaseCollections.units).doc(id);
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists) {
         final data = docSnapshot.data();
         // Security Check: Ensure it belongs to current owner
         if (data != null && data['ownerId'] == _uid) {
            await docRef.delete();
         }
      }
    }
  }

  // --- BHK Templates ---
  
  @override
  Future<String> createBhkTemplate(domain.BhkTemplate template) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');
    
    final id = const Uuid().v4();
    
    final data = {
      'id': id,
      'ownerId': uid,
      'houseId': template.houseId,
      'bhkType': template.bhkType,
      'defaultRent': template.defaultRent,
      'description': template.description,
      'roomCount': template.roomCount,
      'kitchenCount': template.kitchenCount,
      'hallCount': template.hallCount,
      'hasBalcony': template.hasBalcony,
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
      'isDeleted': false,
    };
    
    await _firestore.collection(FirebaseCollections.bhkTemplates).add(data);
    return id;
  }
  
  @override
  Future<void> updateBhkTemplate(domain.BhkTemplate template) async {
    final snapshot = await _firestore.collection(FirebaseCollections.bhkTemplates)
        .where('ownerId', isEqualTo: _uid)
        .where('id', isEqualTo: template.id)
        .limit(1)
        .get()
        .timeout(const Duration(seconds: 10));
        
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'bhkType': template.bhkType,
        'defaultRent': template.defaultRent,
        'description': template.description,
        'roomCount': template.roomCount,
        'kitchenCount': template.kitchenCount,
        'hallCount': template.hallCount,
        'hasBalcony': template.hasBalcony,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }
  
  @override
  Stream<List<domain.BhkTemplate>> getBhkTemplates(String houseId) {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    
    return _firestore.collection(FirebaseCollections.bhkTemplates)
        .where('ownerId', isEqualTo: uid)
        .where('houseId', isEqualTo: houseId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
            .where((doc) => doc.data()['isDeleted'] != true)
            .map((doc) => _mapBhkTemplate(doc))
            .toList();
        });
  }

  // --- Mappers ---

  domain.BhkTemplate _mapBhkTemplate(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return domain.BhkTemplate(
      id: (data['id'] ?? doc.id).toString(),
      houseId: data['houseId']?.toString() ?? '',
      bhkType: data['bhkType'],
      defaultRent: (data['defaultRent'] as num).toDouble(),
      description: data['description'],
      roomCount: data['roomCount'] ?? 1,
      kitchenCount: data['kitchenCount'] ?? 1,
      hallCount: data['hallCount'] ?? 1,
      hasBalcony: data['hasBalcony'] ?? false,
    );
  }

  domain.House _mapHouse(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return domain.House(
      id: (data['id'] ?? doc.id).toString(),
      ownerId: data['ownerId']?.toString() ?? '',
      name: data['name'],
      address: data['address'],
      notes: data['notes'],
      imageUrl: data['imageUrl'], 
      imageBase64: data['imageBase64'], 
      unitCount: 0, 
    );
  }

  domain.Unit _mapUnit(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return domain.Unit(
      id: (data['id'] ?? doc.id).toString(),
      ownerId: data['ownerId']?.toString() ?? '',
      houseId: data['houseId']?.toString() ?? '',
      nameOrNumber: data['nameOrNumber'],
      floor: data['floor'],
      baseRent: (data['baseRent'] as num).toDouble(),
      
      bhkTemplateId: data['bhkTemplateId']?.toString(),
      bhkType: data['bhkType'],
      editableRent: (data['editableRent'] as num?)?.toDouble(),
      currentTenancyId: data['currentTenancyId']?.toString() ?? data['tenantId']?.toString(), // Fallback for migration
 
      furnishingStatus: data['furnishingStatus'],
      carpetArea: (data['carpetArea'] as num?)?.toDouble(),
      parkingSlot: data['parkingSlot'],
      meterNumber: data['meterNumber'],
      
      defaultDueDay: data['defaultDueDay'],
      isOccupied: data['isOccupied'] ?? false,
      
      imagesBase64: (data['imagesBase64'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [], 
      imageUrls: (data['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [], 
    );
  }
}
