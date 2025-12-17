
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/local/database.dart';
// NEW
import 'package:flutter/foundation.dart';

class SyncService {
  final AppDatabase _db;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  SyncService(this._db) {
    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        debugPrint('Connectivity is back. Triggering Sync...');
        sync();
      }
    });
  }

  // Sync Strategy
  // 1. Check Connectivity
  // 2. Push Local Changes (isSynced = false) -> Firestore
  // 3. Pull Remote Changes (lastUpdated > localLastSync) -> Local DB
  
  Future<void> sync() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return;

    try {
      // PUSH
      await _pushOwners();
      await _pushHouses();
      await _pushUnits();
      await _pushTenants();
      await _pushRentCycles(); 
      await _pushPayments();   
      await _pushExpenses();
      await _pushElectricReadings(); // NEW
      
      // PULL
      await _pullOwners();
      await _pullHouses();
      await _pullUnits();
      await _pullTenants();
      await _pullRentCycles(); 
      await _pullPayments();   
      await _pullExpenses();
      await _pullElectricReadings(); // NEW

    } catch (e) {
      debugPrint('Sync Error: $e');
    }
  }

  // --- PUSH LOGIC ---

  Future<void> _pushOwners() async {
    final unsynced = await (_db.select(_db.owners)..where((tbl) => tbl.isSynced.equals(false))).get();
    
    for (final record in unsynced) {
      final docId = record.firestoreId ?? _uuid.v4();
      
      if (record.firestoreId == null) {
        await (_db.update(_db.owners)..where((tbl) => tbl.id.equals(record.id))).write(OwnersCompanion(firestoreId: Value(docId)));
      }

      final data = {
        'name': record.name,
        'phone': record.phone,
        'email': record.email,
        'currency': record.currency,
        'timezone': record.timezone,
        'createdAt': record.createdAt.toIso8601String(),
        'lastUpdated': record.lastUpdated.toIso8601String(),
        'isDeleted': record.isDeleted,
      };

      await _firestore.collection('owners').doc(docId).set(data);
      await (_db.update(_db.owners)..where((tbl) => tbl.id.equals(record.id))).write(const OwnersCompanion(isSynced: Value(true)));
    }
  }
  
  Future<void> _pushHouses() async {
     final unsynced = await (_db.select(_db.houses)..where((tbl) => tbl.isSynced.equals(false))).get();
     
     for (final record in unsynced) {
        final owner = await (_db.select(_db.owners)..where((tbl) => tbl.id.equals(record.ownerId))).getSingleOrNull();
        if (owner?.firestoreId == null) continue;
        
        final docId = record.firestoreId ?? _uuid.v4();
        if (record.firestoreId == null) {
          await (_db.update(_db.houses)..where((tbl) => tbl.id.equals(record.id))).write(HousesCompanion(firestoreId: Value(docId)));
        }
        
        final data = {
          'ownerId': owner!.firestoreId,
          'name': record.name,
          'address': record.address,
          'notes': record.notes,
          'lastUpdated': record.lastUpdated.toIso8601String(),
          'isDeleted': record.isDeleted,
        };
        
        await _firestore.collection('houses').doc(docId).set(data);
        await (_db.update(_db.houses)..where((tbl) => tbl.id.equals(record.id))).write(const HousesCompanion(isSynced: Value(true)));
     }
  }

   Future<void> _pushUnits() async {
     final unsynced = await (_db.select(_db.units)..where((tbl) => tbl.isSynced.equals(false))).get();
     
     for (final record in unsynced) {
        final house = await (_db.select(_db.houses)..where((tbl) => tbl.id.equals(record.houseId))).getSingleOrNull();
        if (house?.firestoreId == null) continue; 
        
        final docId = record.firestoreId ?? _uuid.v4();
        if (record.firestoreId == null) {
          await (_db.update(_db.units)..where((tbl) => tbl.id.equals(record.id))).write(UnitsCompanion(firestoreId: Value(docId)));
        }
        
        final data = {
          'houseId': house!.firestoreId,
          'nameOrNumber': record.nameOrNumber,
          'floor': record.floor,
          'baseRent': record.baseRent,
          'defaultDueDay': record.defaultDueDay,
          'lastUpdated': record.lastUpdated.toIso8601String(),
          'isDeleted': record.isDeleted,
        };
        
        await _firestore.collection('units').doc(docId).set(data);
        await (_db.update(_db.units)..where((tbl) => tbl.id.equals(record.id))).write(const UnitsCompanion(isSynced: Value(true)));
     }
  }

  Future<void> _pushTenants() async {
    final unsynced = await (_db.select(_db.tenants)..where((tbl) => tbl.isSynced.equals(false))).get();
    
    for (final record in unsynced) {
      final house = await (_db.select(_db.houses)..where((tbl) => tbl.id.equals(record.houseId))).getSingleOrNull();
      final unit = await (_db.select(_db.units)..where((tbl) => tbl.id.equals(record.unitId))).getSingleOrNull();
      
      if (house?.firestoreId == null || unit?.firestoreId == null) continue;

      final docId = record.firestoreId ?? _uuid.v4();
        if (record.firestoreId == null) {
          await (_db.update(_db.tenants)..where((tbl) => tbl.id.equals(record.id))).write(TenantsCompanion(firestoreId: Value(docId)));
        }
      
      final data = {
         'houseId': house!.firestoreId,
         'unitId': unit!.firestoreId,
         'tenantCode': record.tenantCode,
         'name': record.name,
         'phone': record.phone,
         'email': record.email,
         'startDate': record.startDate.toIso8601String(),
         'isActive': record.isActive,
         'openingBalance': record.openingBalance,
         'agreedRent': record.agreedRent,
         'password': record.password,
          'lastUpdated': record.lastUpdated.toIso8601String(),
          'isDeleted': record.isDeleted,
      };

      await _firestore.collection('tenants').doc(docId).set(data);
      await (_db.update(_db.tenants)..where((tbl) => tbl.id.equals(record.id))).write(const TenantsCompanion(isSynced: Value(true)));
    }
  }

  Future<void> _pushRentCycles() async {
    final unsynced = await (_db.select(_db.rentCycles)..where((tbl) => tbl.isSynced.equals(false))).get();
    
    for (final record in unsynced) {
      final tenant = await (_db.select(_db.tenants)..where((tbl) => tbl.id.equals(record.tenantId))).getSingleOrNull();
      if (tenant?.firestoreId == null) continue; 

      final docId = record.firestoreId ?? _uuid.v4();
      if (record.firestoreId == null) {
        await (_db.update(_db.rentCycles)..where((tbl) => tbl.id.equals(record.id))).write(RentCyclesCompanion(firestoreId: Value(docId)));
      }

      final data = {
        'tenantId': tenant!.firestoreId,
        'month': record.month,
        'billNumber': record.billNumber,
        'billPeriodStart': record.billPeriodStart?.toIso8601String(),
        'billPeriodEnd': record.billPeriodEnd?.toIso8601String(),
        'billGeneratedDate': record.billGeneratedDate.toIso8601String(),
        'dueDate': record.dueDate?.toIso8601String(),
        'baseRent': record.baseRent,
        'electricAmount': record.electricAmount,
        'otherCharges': record.otherCharges,
        'discount': record.discount,
        'totalDue': record.totalDue,
        'totalPaid': record.totalPaid,
        'status': record.status, // Store as int
        'notes': record.notes,
        'lastUpdated': record.lastUpdated.toIso8601String(),
        'isDeleted': record.isDeleted,
      };

      await _firestore.collection('rent_cycles').doc(docId).set(data);
      await (_db.update(_db.rentCycles)..where((tbl) => tbl.id.equals(record.id))).write(const RentCyclesCompanion(isSynced: Value(true)));
    }
  }

  Future<void> _pushPayments() async {
    final unsynced = await (_db.select(_db.payments)..where((tbl) => tbl.isSynced.equals(false))).get();
    
    for (final record in unsynced) {
      final rentCycle = await (_db.select(_db.rentCycles)..where((tbl) => tbl.id.equals(record.rentCycleId))).getSingleOrNull();
      final tenant = await (_db.select(_db.tenants)..where((tbl) => tbl.id.equals(record.tenantId))).getSingleOrNull();
      
      if (rentCycle?.firestoreId == null || tenant?.firestoreId == null) continue;

      final docId = record.firestoreId ?? _uuid.v4();
      if (record.firestoreId == null) {
         await (_db.update(_db.payments)..where((tbl) => tbl.id.equals(record.id))).write(PaymentsCompanion(firestoreId: Value(docId)));
      }

      final data = {
        'rentCycleId': rentCycle!.firestoreId,
        'tenantId': tenant!.firestoreId,
        'amount': record.amount,
        'date': record.date.toIso8601String(),
        'method': record.method,
        'referenceId': record.referenceId,
        'collectedBy': record.collectedBy,
        'notes': record.notes,
        'lastUpdated': record.lastUpdated.toIso8601String(),
        'isDeleted': record.isDeleted,
      };

      await _firestore.collection('payments').doc(docId).set(data);
      await (_db.update(_db.payments)..where((tbl) => tbl.id.equals(record.id))).write(const PaymentsCompanion(isSynced: Value(true)));
    }
  }

  Future<void> _pushExpenses() async {
    final unsynced = await (_db.select(_db.expenses)..where((tbl) => tbl.isSynced.equals(false))).get();
    
    for (final record in unsynced) {
      final owner = await (_db.select(_db.owners)..where((tbl) => tbl.id.equals(record.ownerId))).getSingleOrNull();
      if (owner?.firestoreId == null) continue;

      final docId = record.firestoreId ?? _uuid.v4();
      if (record.firestoreId == null) {
        await (_db.update(_db.expenses)..where((tbl) => tbl.id.equals(record.id))).write(ExpensesCompanion(firestoreId: Value(docId)));
      }

      final data = {
        'ownerId': owner!.firestoreId,
        'title': record.title,
        'date': record.date.toIso8601String(),
        'amount': record.amount,
        'category': record.category,
        'description': record.description,
        'lastUpdated': record.lastUpdated.toIso8601String(),
        'isDeleted': record.isDeleted,
      };

      await _firestore.collection('expenses').doc(docId).set(data);
      await (_db.update(_db.expenses)..where((tbl) => tbl.id.equals(record.id))).write(const ExpensesCompanion(isSynced: Value(true)));
    }
  }

  // --- PULL LOGIC ---
  // Simplified pull: Fetch everything changed recently (or all)
  // For production, track 'lastSyncTimestamp' locally.

  Future<void> _pullOwners() async {
    final snapshot = await _firestore.collection('owners').get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final firestoreId = doc.id;
      final existing = await (_db.select(_db.owners)..where((tbl) => tbl.firestoreId.equals(firestoreId))).getSingleOrNull();
      
      final companion = OwnersCompanion(
        firestoreId: Value(firestoreId),
        name: Value(data['name']),
        phone: Value(data['phone']),
        email: Value(data['email']),
        currency: Value(data['currency']),
        timezone: Value(data['timezone']),
        createdAt: Value(DateTime.parse(data['createdAt'])),
        lastUpdated: Value(DateTime.parse(data['lastUpdated'])),
        isDeleted: Value(data['isDeleted'] ?? false),
        isSynced: const Value(true), // Data from cloud is already synced
      );

      if (existing == null) {
        await _db.into(_db.owners).insert(companion);
      } else {
        // Resolve conflict: Cloud wins here for simplicity, or check timestamps
        if (existing.lastUpdated.isBefore(DateTime.parse(data['lastUpdated']))) {
           await (_db.update(_db.owners)..where((tbl) => tbl.id.equals(existing.id))).write(companion);
        }
      }
    }
  }

   Future<void> _pullHouses() async {
    final snapshot = await _firestore.collection('houses').get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final firestoreId = doc.id;
      final ownerFirestoreId = data['ownerId'];
      
      // Resolve Owner
      final owner = await (_db.select(_db.owners)..where((tbl) => tbl.firestoreId.equals(ownerFirestoreId))).getSingleOrNull();
      if (owner == null) continue; // Owner not synced yet

      final existing = await (_db.select(_db.houses)..where((tbl) => tbl.firestoreId.equals(firestoreId))).getSingleOrNull();

      final companion = HousesCompanion(
        firestoreId: Value(firestoreId),
        ownerId: Value(owner.id),
        name: Value(data['name']),
        address: Value(data['address']),
        notes: Value(data['notes']),
        lastUpdated: Value(DateTime.parse(data['lastUpdated'])),
        isDeleted: Value(data['isDeleted'] ?? false),
        isSynced: const Value(true),
      );

        if (existing == null) {
        await _db.into(_db.houses).insert(companion);
      } else {
         if (existing.lastUpdated.isBefore(DateTime.parse(data['lastUpdated']))) {
           await (_db.update(_db.houses)..where((tbl) => tbl.id.equals(existing.id))).write(companion);
        }
      }
    }
  }

  Future<void> _pullUnits() async {
    final snapshot = await _firestore.collection('units').get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final firestoreId = doc.id;
      final houseFirestoreId = data['houseId'];
      
      final house = await (_db.select(_db.houses)..where((tbl) => tbl.firestoreId.equals(houseFirestoreId))).getSingleOrNull();
      if (house == null) continue; 

      final existing = await (_db.select(_db.units)..where((tbl) => tbl.firestoreId.equals(firestoreId))).getSingleOrNull();

      final companion = UnitsCompanion(
        firestoreId: Value(firestoreId),
        houseId: Value(house.id),
        nameOrNumber: Value(data['nameOrNumber']),
        floor: Value(data['floor']),
        baseRent: Value(data['baseRent']),
        defaultDueDay: Value(data['defaultDueDay']),
        lastUpdated: Value(DateTime.parse(data['lastUpdated'])),
        isDeleted: Value(data['isDeleted'] ?? false),
        isSynced: const Value(true),
      );

       if (existing == null) {
        await _db.into(_db.units).insert(companion);
      } else {
         if (existing.lastUpdated.isBefore(DateTime.parse(data['lastUpdated']))) {
           await (_db.update(_db.units)..where((tbl) => tbl.id.equals(existing.id))).write(companion);
        }
      }
    }
  }

    Future<void> _pullTenants() async {
    final snapshot = await _firestore.collection('tenants').get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final firestoreId = doc.id;
      final houseFirestoreId = data['houseId'];
      final unitFirestoreId = data['unitId'];
      
      final house = await (_db.select(_db.houses)..where((tbl) => tbl.firestoreId.equals(houseFirestoreId))).getSingleOrNull();
      final unit = await (_db.select(_db.units)..where((tbl) => tbl.firestoreId.equals(unitFirestoreId))).getSingleOrNull();
      
      if (house == null || unit == null) continue;

      final existing = await (_db.select(_db.tenants)..where((tbl) => tbl.firestoreId.equals(firestoreId))).getSingleOrNull();

      final companion = TenantsCompanion(
         firestoreId: Value(firestoreId),
         houseId: Value(house.id),
         unitId: Value(unit.id),
         tenantCode: Value(data['tenantCode']),
         name: Value(data['name']),
         phone: Value(data['phone']),
         email: Value(data['email']),
         startDate: Value(DateTime.parse(data['startDate'])),
         isActive: Value(data['isActive']),
         openingBalance: Value(data['openingBalance']),
         agreedRent: Value(data['agreedRent']),
         password: Value(data['password']),
        lastUpdated: Value(DateTime.parse(data['lastUpdated'])),
        isDeleted: Value(data['isDeleted'] ?? false),
        isSynced: const Value(true),
      );

       if (existing == null) {
        await _db.into(_db.tenants).insert(companion);
      } else {
         if (existing.lastUpdated.isBefore(DateTime.parse(data['lastUpdated']))) {
           await (_db.update(_db.tenants)..where((tbl) => tbl.id.equals(existing.id))).write(companion);
        }
      }
    }
  }

  Future<void> _pullRentCycles() async {
    final snapshot = await _firestore.collection('rent_cycles').get();
    for (final doc in snapshot.docs) {
       final data = doc.data();
       final firestoreId = doc.id;
       final tenantFirestoreId = data['tenantId'];
       
       final tenant = await (_db.select(_db.tenants)..where((tbl) => tbl.firestoreId.equals(tenantFirestoreId))).getSingleOrNull();
       if (tenant == null) continue;

       final existing = await (_db.select(_db.rentCycles)..where((tbl) => tbl.firestoreId.equals(firestoreId))).getSingleOrNull();
       
       // Handle Status (Int)
       int status = data['status'] is int ? data['status'] : 0;
       
       final companion = RentCyclesCompanion(
         firestoreId: Value(firestoreId),
         tenantId: Value(tenant.id),
         month: Value(data['month']),
         billNumber: Value(data['billNumber']),
         billPeriodStart: Value(data['billPeriodStart'] != null ? DateTime.parse(data['billPeriodStart']) : null),
         billPeriodEnd: Value(data['billPeriodEnd'] != null ? DateTime.parse(data['billPeriodEnd']) : null),
         billGeneratedDate: Value(DateTime.parse(data['billGeneratedDate'])),
         dueDate: Value(data['dueDate'] != null ? DateTime.parse(data['dueDate']) : null),
         baseRent: Value(data['baseRent']),
         electricAmount: Value(data['electricAmount']),
         otherCharges: Value(data['otherCharges']),
         discount: Value(data['discount']),
         totalDue: Value(data['totalDue']),
         totalPaid: Value(data['totalPaid']),
         status: Value(status), // Int
         notes: Value(data['notes']),
         lastUpdated: Value(DateTime.parse(data['lastUpdated'])),
         isDeleted: Value(data['isDeleted'] ?? false),
         isSynced: const Value(true),
       );

       if (existing == null) {
         await _db.into(_db.rentCycles).insert(companion);
       } else {
         if (existing.lastUpdated.isBefore(DateTime.parse(data['lastUpdated']))) {
            await (_db.update(_db.rentCycles)..where((tbl) => tbl.id.equals(existing.id))).write(companion);
         }
       }
    }
  }

  Future<void> _pullPayments() async {
    final snapshot = await _firestore.collection('payments').get();
    for (final doc in snapshot.docs) {
       final data = doc.data();
       final firestoreId = doc.id;
       final rentCycleFirestoreId = data['rentCycleId'];
       final tenantFirestoreId = data['tenantId'];
       
       final rentCycle = await (_db.select(_db.rentCycles)..where((tbl) => tbl.firestoreId.equals(rentCycleFirestoreId))).getSingleOrNull();
       final tenant = await (_db.select(_db.tenants)..where((tbl) => tbl.firestoreId.equals(tenantFirestoreId))).getSingleOrNull();
       
       if (rentCycle == null || tenant == null) continue;

       final existing = await (_db.select(_db.payments)..where((tbl) => tbl.firestoreId.equals(firestoreId))).getSingleOrNull();

       final companion = PaymentsCompanion(
         firestoreId: Value(firestoreId),
         rentCycleId: Value(rentCycle.id),
         tenantId: Value(tenant.id),
         amount: Value(data['amount']),
         date: Value(DateTime.parse(data['date'])),
         method: Value(data['method']),
         referenceId: Value(data['referenceId']),
         collectedBy: Value(data['collectedBy']),
         notes: Value(data['notes']),
         lastUpdated: Value(DateTime.parse(data['lastUpdated'])),
         isDeleted: Value(data['isDeleted'] ?? false),
         isSynced: const Value(true),
       );

        if (existing == null) {
         await _db.into(_db.payments).insert(companion);
       } else {
         if (existing.lastUpdated.isBefore(DateTime.parse(data['lastUpdated']))) {
            await (_db.update(_db.payments)..where((tbl) => tbl.id.equals(existing.id))).write(companion);
         }
       }
    }
  }

  Future<void> _pullExpenses() async {
    final snapshot = await _firestore.collection('expenses').get();
    for (final doc in snapshot.docs) {
       final data = doc.data();
       final firestoreId = doc.id;
       final ownerFirestoreId = data['ownerId'];
       
       final owner = await (_db.select(_db.owners)..where((tbl) => tbl.firestoreId.equals(ownerFirestoreId))).getSingleOrNull();
       if (owner == null) continue;

       final existing = await (_db.select(_db.expenses)..where((tbl) => tbl.firestoreId.equals(firestoreId))).getSingleOrNull();

       final companion = ExpensesCompanion(
         firestoreId: Value(firestoreId),
         ownerId: Value(owner.id),
         title: Value(data['title']),
         date: Value(DateTime.parse(data['date'])),
         amount: Value(data['amount']),
         category: Value(data['category']),
         description: Value(data['description']),
         lastUpdated: Value(DateTime.parse(data['lastUpdated'])),
         isDeleted: Value(data['isDeleted'] ?? false),
         isSynced: const Value(true),
       );

       if (existing == null) {
         await _db.into(_db.expenses).insert(companion);
       } else {
         if (existing.lastUpdated.isBefore(DateTime.parse(data['lastUpdated']))) {
            await (_db.update(_db.expenses)..where((tbl) => tbl.id.equals(existing.id))).write(companion);
         }
       }
    }
  }

  Future<void> _pushElectricReadings() async {
    final unsynced = await (_db.select(_db.electricReadings)..where((tbl) => tbl.isSynced.equals(false))).get();
    
    for (final record in unsynced) {
      final unit = await (_db.select(_db.units)..where((tbl) => tbl.id.equals(record.unitId))).getSingleOrNull();
      if (unit?.firestoreId == null) continue;

      final docId = record.firestoreId ?? _uuid.v4();
      if (record.firestoreId == null) {
        await (_db.update(_db.electricReadings)..where((tbl) => tbl.id.equals(record.id))).write(ElectricReadingsCompanion(firestoreId: Value(docId)));
      }

      final data = {
        'unitId': unit!.firestoreId,
        'readingDate': record.readingDate.toIso8601String(),
        'meterName': record.meterName,
        'prevReading': record.prevReading,
        'currentReading': record.currentReading,
        'ratePerUnit': record.ratePerUnit,
        'amount': record.amount,
        'imagePath': record.imagePath,
        'notes': record.notes,
        'lastUpdated': record.lastUpdated.toIso8601String(),
        'isDeleted': record.isDeleted,
      };
      
      await _firestore.collection('electric_readings').doc(docId).set(data);
      await (_db.update(_db.electricReadings)..where((tbl) => tbl.id.equals(record.id))).write(const ElectricReadingsCompanion(isSynced: Value(true)));
    }
  }

  // --- PULL LOGIC ---
  
  Future<void> _pullElectricReadings() async {
     final snapshot = await _firestore.collection('electric_readings').get();
    for (final doc in snapshot.docs) {
       final data = doc.data();
       final firestoreId = doc.id;
       final unitFirestoreId = data['unitId'];
       
       final unit = await (_db.select(_db.units)..where((tbl) => tbl.firestoreId.equals(unitFirestoreId))).getSingleOrNull();
       if (unit == null) continue;
       
       final existing = await (_db.select(_db.electricReadings)..where((tbl) => tbl.firestoreId.equals(firestoreId))).getSingleOrNull();

       final companion = ElectricReadingsCompanion(
         firestoreId: Value(firestoreId),
         unitId: Value(unit.id),
         readingDate: Value(DateTime.parse(data['readingDate'])),
         meterName: Value(data['meterName']),
         prevReading: Value(data['prevReading'] ?? 0.0),
         currentReading: Value(data['currentReading']),
         ratePerUnit: Value(data['ratePerUnit'] ?? 0.0),
         amount: Value(data['amount']),
         imagePath: Value(data['imagePath']),
         notes: Value(data['notes']),
         lastUpdated: Value(DateTime.parse(data['lastUpdated'])),
         isDeleted: Value(data['isDeleted'] ?? false),
         isSynced: const Value(true),
       );

       if (existing == null) {
         await _db.into(_db.electricReadings).insert(companion);
       } else {
         if (existing.lastUpdated.isBefore(DateTime.parse(data['lastUpdated']))) {
            await (_db.update(_db.electricReadings)..where((tbl) => tbl.id.equals(existing.id))).write(companion);
         }
       }
    }
  }
}
