import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../features/rent/domain/entities/rent_cycle.dart' as domain;
import '../../domain/repositories/i_rent_repository.dart';
import '../../domain/entities/expense.dart' as domain;
import '../../core/services/notification_service.dart';
import '../../core/constants/firebase_collections.dart';

class RentRepositoryImpl implements IRentRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  RentRepositoryImpl(
    this._firestore, {
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  // --- Rent Cycles ---

  @override
  Future<List<domain.RentCycle>> getRentCyclesForTenancy(String tenancyId) async {
    if (_uid == null) return [];
    
    final snapshot = await _firestore.collection(FirebaseCollections.invoices)
        .where('ownerId', isEqualTo: _uid) 
        .where('tenancyId', isEqualTo: tenancyId) 
        .where('isDeleted', isEqualTo: false)
        .get();
        
    return snapshot.docs.map((c) => mapToDomain(c)).toList();
  }

  @override
  Future<List<domain.RentCycle>> getRentCyclesForMonth(String month) async {
    if (_uid == null) return [];

    final snapshot = await _firestore.collection(FirebaseCollections.invoices)
        .where('ownerId', isEqualTo: _uid)
        .get();
        
    return snapshot.docs
        .where((d) => d.data()['month'] == month && d.data()['isDeleted'] != true)
        .map((c) => mapToDomain(c))
        .toList();
  }

  @override
  Future<List<domain.RentCycle>> getAllRentCycles() async {
    if (_uid == null) return [];

    final snapshot = await _firestore.collection(FirebaseCollections.invoices)
        .where('ownerId', isEqualTo: _uid)
        .get();
        
    return snapshot.docs
        .where((doc) => doc.data()['isDeleted'] != true)
        .map((c) => mapToDomain(c))
        .toList();
  }

  @override
  Future<List<domain.RentCycle>> getAllPendingRentCycles() async {
    if (_uid == null) return [];

    final snapshot = await _firestore.collection(FirebaseCollections.invoices)
        .where('ownerId', isEqualTo: _uid)
        .get();
        
    return snapshot.docs
        .where((doc) {
          final data = doc.data();
          return data['isDeleted'] != true && (data['status'] as int? ?? 0) < 2;
        })
        .map((c) => mapToDomain(c))
        .toList();
  }

  @override
  Future<List<domain.RentCycle>> getRentCyclesByTenancyAccess(String tenancyId, String ownerId) async {
    final snapshot = await _firestore.collection(FirebaseCollections.invoices)
        .where('ownerId', isEqualTo: ownerId)
        .where('tenancyId', isEqualTo: tenancyId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('month', descending: true) 
        .get();
        
    return snapshot.docs.map((c) => mapToDomain(c)).toList();
  }

  @override
  Stream<List<domain.RentCycle>> watchRentCyclesByTenancyAccess(String tenancyId, String ownerId) {
    return _firestore.collection(FirebaseCollections.invoices)
        .where('ownerId', isEqualTo: ownerId)
        .where('tenancyId', isEqualTo: tenancyId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('month', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((c) => mapToDomain(c)).toList());
  }

  @override
  Future<domain.RentCycle?> getRentCycle(String id) async { 
    if (_uid == null) return null;

    final snapshot = await _firestore.collection(FirebaseCollections.invoices)
        .where('ownerId', isEqualTo: _uid) 
        .where('id', isEqualTo: id)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) return null;
    final data = snapshot.docs.first.data();
    if (data['isDeleted'] == true) return null;
    return mapToDomain(snapshot.docs.first);
  }

  @override
  Future<String> createRentCycle(domain.RentCycle rentCycle) async { 
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');

    final docId = '${rentCycle.tenancyId}_${rentCycle.month}'; 
    final docRef = _firestore.collection(FirebaseCollections.invoices).doc(docId);

    final snapshot = await docRef.get();
    if (snapshot.exists) {
       return snapshot.data()!['id'] as String;
    }

    final id = const Uuid().v4(); 

    final data = {
      'id': id,
      'ownerId': uid, 
      'tenancyId': rentCycle.tenancyId, 
      'month': rentCycle.month,
      'billNumber': rentCycle.billNumber,
      'billPeriodStart': rentCycle.billPeriodStart?.toIso8601String(),
      'billPeriodEnd': rentCycle.billPeriodEnd?.toIso8601String(),
      'billGeneratedDate': rentCycle.billGeneratedDate.toIso8601String(),
      'baseRent': rentCycle.baseRent,
      'electricAmount': rentCycle.electricAmount,
      'otherCharges': rentCycle.otherCharges,
      'discount': rentCycle.discount,
      'totalDue': rentCycle.totalDue,
      'totalPaid': rentCycle.totalPaid,
      'status': rentCycle.status.index,
      'dueDate': rentCycle.dueDate?.toIso8601String(),
      'notes': rentCycle.notes,
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
      'isDeleted': false,
    };

    await docRef.set(data);

    if (rentCycle.dueDate != null) {
      try {
        await NotificationService().scheduleNotification(
          id: id.hashCode & 0x7FFFFFFF, 
          title: 'Rent Due Reminder',
          body: 'Rent for ${rentCycle.month} is due today.',
          scheduledDate: rentCycle.dueDate!,
        );
      } catch (e) {
        debugPrint('Error scheduling notification: $e');
      }
    }
    return id;
  }

  @override
  Future<void> updateRentCycle(domain.RentCycle rentCycle) async {
    if (_uid == null) return;

    final snapshot = await _firestore.collection(FirebaseCollections.invoices)
        .where('ownerId', isEqualTo: _uid) 
        .where('id', isEqualTo: rentCycle.id)
        .limit(1)
        .get();
        
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'electricAmount': rentCycle.electricAmount,
        'otherCharges': rentCycle.otherCharges,
        'totalDue': rentCycle.totalDue,
        'totalPaid': rentCycle.totalPaid,
        'status': rentCycle.status.index,
        'notes': rentCycle.notes,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> deleteRentCycle(domain.RentCycle cycle) async {
    if (_uid == null) return;

    final docId = '${cycle.tenancyId}_${cycle.month}';
    final docRef = _firestore.collection(FirebaseCollections.invoices).doc(docId);
    
    final docSnapshot = await docRef.get();
    if (docSnapshot.exists && docSnapshot.data()?['ownerId'] == _uid) {
       await docRef.update({
         'isDeleted': true,
         'lastUpdated': FieldValue.serverTimestamp(),
       });
       return;
    }

    final snapshot = await _firestore.collection(FirebaseCollections.invoices)
        .where('ownerId', isEqualTo: _uid)
        .where('id', isEqualTo: cycle.id)
        .limit(1)
        .get();
        
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'isDeleted': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> recoverRentCycle(String id) async {
    if (_uid == null) return;

    final snapshot = await _firestore.collection(FirebaseCollections.invoices)
        .where('ownerId', isEqualTo: _uid)
        .where('id', isEqualTo: id)
        .limit(1)
        .get();
        
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'isDeleted': false,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> permanentlyDeleteRentCycle(domain.RentCycle cycle) async {
    if (_uid == null) return;

    final docId = '${cycle.tenancyId}_${cycle.month}';
    final docRef = _firestore.collection(FirebaseCollections.invoices).doc(docId);
    
    final docSnapshot = await docRef.get();
    if (docSnapshot.exists && docSnapshot.data()?['ownerId'] == _uid) {
       await docRef.delete();
       return;
    }

    final snapshot = await _firestore.collection(FirebaseCollections.invoices)
        .where('ownerId', isEqualTo: _uid)
        .where('id', isEqualTo: cycle.id)
        .limit(1)
        .get();
        
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.delete();
    }
  }

  @override
  Future<List<domain.RentCycle>> getDeletedRentCyclesForTenancy(String tenancyId) async {
    if (_uid == null) return [];
    
    final snapshot = await _firestore.collection(FirebaseCollections.invoices)
        .where('ownerId', isEqualTo: _uid) 
        .where('tenancyId', isEqualTo: tenancyId)
        .where('isDeleted', isEqualTo: true)
        .get();
        
    return snapshot.docs.map((c) => mapToDomain(c)).toList();
  }

  @override
  Future<List<domain.RentCycle>> getRentCyclesForTenant(String tenantId) async {
       if (_uid == null) return [];

       try {
           // 1. Find ALL contracts for this owner
           var contractsSnap = await _firestore.collection(FirebaseCollections.contracts)
               .where('ownerId', isEqualTo: _uid)
               .get();
               
           // Filter by tenantId in memory
           final filteredContracts = contractsSnap.docs.where((d) => d.data()['tenantId'] == tenantId).toList();

           // Fallback: If strict search yields nothing, try loose search (legacy data support)
           if (filteredContracts.isEmpty) {
               debugPrint("RentRepo: No owner-scoped contracts found. Trying loose search...");
               try {
                  contractsSnap = await _firestore.collection(FirebaseCollections.contracts)
                     .where('tenantId', isEqualTo: tenantId)
                     .get();
                  filteredContracts.addAll(contractsSnap.docs);
               } catch (e) {
                  debugPrint("RentRepo: Loose search blocked: $e");
               }
           }
               
           if (filteredContracts.isEmpty) {
              return [];
           }
           
           final tenancyIds = filteredContracts.map((d) => d.id).toList();
           if (tenancyIds.isEmpty) return [];

           // 2. Fetch Invoices
           final allInvoices = <domain.RentCycle>[];
           
           for(var i=0; i<tenancyIds.length; i+=10) {
               final end = (i+10 < tenancyIds.length) ? i+10 : tenancyIds.length;
               final chunk = tenancyIds.sublist(i, end);
               
               final invoicesSnap = await _firestore.collection(FirebaseCollections.invoices)
                 .where('tenancyId', whereIn: chunk)
                 .get();
                 
               final invoices = invoicesSnap.docs.map((d) => mapToDomain(d)).toList();
               allInvoices.addAll(invoices);
           }
           
            allInvoices.sort((a,b) {
                 // Sort: Overdue/Pending/Partial first, then Date Descending
                 final priorityA = (a.status == domain.RentStatus.overdue || a.status == domain.RentStatus.pending || a.status == domain.RentStatus.partial) ? 0 : 1;
                 final priorityB = (b.status == domain.RentStatus.overdue || b.status == domain.RentStatus.pending || b.status == domain.RentStatus.partial) ? 0 : 1;
                 
                 if (priorityA != priorityB) return priorityA.compareTo(priorityB);
                 return b.month.compareTo(a.month);
            });
           return allInvoices;
       } catch (e) {
           debugPrint('Error fetching tenant bills: $e');
           return [];
       }
  }

  // --- Payments ---

  @override
  Future<List<domain.Payment>> getAllPayments() async {
     if (_uid == null) return [];

    final snapshot = await _firestore.collection(FirebaseCollections.transactions)
        .where('ownerId', isEqualTo: _uid)
        .get();
        
    return snapshot.docs
        .where((doc) => doc.data()['isDeleted'] != true)
        .map((p) => _mapPaymentToDomain(p))
        .toList();
  }

  @override
  Future<List<domain.Payment>> getPaymentsForRentCycle(String rentCycleId) async { 
     if (_uid == null) return [];
     
    final snapshot = await _firestore.collection(FirebaseCollections.transactions)
        .where('ownerId', isEqualTo: _uid)
        .where('rentCycleId', isEqualTo: rentCycleId)
        .where('isDeleted', isEqualTo: false)
        .get();
    return snapshot.docs.map((p) => _mapPaymentToDomain(p)).toList();
  }

  @override
  Future<List<domain.Payment>> getPaymentsForRentCycleForTenant(String rentCycleId, String ownerId) async {
    final snapshot = await _firestore.collection(FirebaseCollections.transactions)
        .where('ownerId', isEqualTo: ownerId)
        .where('rentCycleId', isEqualTo: rentCycleId)
        .where('isDeleted', isEqualTo: false)
        .get();
    return snapshot.docs.map((p) => _mapPaymentToDomain(p)).toList();
  }

  @override
  Future<List<domain.Payment>> getPaymentsForTenancy(String tenancyId) async {
     if (_uid == null) return [];

    final snapshot = await _firestore.collection(FirebaseCollections.transactions)
        .where('ownerId', isEqualTo: _uid)
        .where('tenancyId', isEqualTo: tenancyId) 
        .where('isDeleted', isEqualTo: false)
        .get();
    return snapshot.docs.map((p) => _mapPaymentToDomain(p)).toList();
  }

  @override
  Future<List<domain.Payment>> getPaymentsByTenancyAccess(String tenancyId, String ownerId) async {
    final snapshot = await _firestore.collection(FirebaseCollections.transactions)
        .where('ownerId', isEqualTo: ownerId)
        .where('tenancyId', isEqualTo: tenancyId)
        .where('isDeleted', isEqualTo: false)
        .get();
    return snapshot.docs.map((p) => _mapPaymentToDomain(p)).toList();
  }

  @override
  Stream<List<domain.Payment>> watchPaymentsByTenancyAccess(String tenancyId, String ownerId) {
    return _firestore.collection(FirebaseCollections.transactions)
        .where('ownerId', isEqualTo: ownerId)
        .where('tenancyId', isEqualTo: tenancyId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((p) => _mapPaymentToDomain(p)).toList());
  }

  @override
  Future<List<domain.Payment>> getRecentPayments(int limit) async {
    if (_uid == null) return [];

    final snapshot = await _firestore.collection(FirebaseCollections.transactions)
        .where('ownerId', isEqualTo: _uid) 
        .get();
        
    final docs = snapshot.docs.where((d) => d.data()['isDeleted'] != true).toList();
    
    docs.sort((a, b) {
       final da = DateTime.tryParse(a.data()['date']) ?? DateTime(0);
       final db = DateTime.tryParse(b.data()['date']) ?? DateTime(0);
       return db.compareTo(da); 
    });
    
    return docs.take(limit).map((p) => _mapPaymentToDomain(p)).toList();
  }

  @override
  Future<DashboardStats> getDashboardStats() async {
     if (_uid == null) return DashboardStats(totalCollected: 0, totalPending: 0, thisMonthCollected: 0, thisMonthPending: 0);

    final now = DateTime.now();
    final currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    final snapshot = await _firestore.collection(FirebaseCollections.invoices)
        .where('ownerId', isEqualTo: _uid)
        .get(); 
        
    final docs = snapshot.docs.where((d) => d.data()['isDeleted'] != true);

    double totalCollected = 0;
    double totalPending = 0;
    double thisMonthCollected = 0;
    double thisMonthPending = 0;

    for (final doc in docs) {
       final data = doc.data();
       final totalPaid = (data['totalPaid'] as num?)?.toDouble() ?? 0.0;
       final totalDue = (data['totalDue'] as num?)?.toDouble() ?? 0.0;
       final month = data['month'] as String? ?? '';

       totalCollected += totalPaid;
       totalPending += max(0.0, totalDue - totalPaid);

       if (month == currentMonth) {
         thisMonthCollected += totalPaid;
         thisMonthPending += max(0.0, totalDue - totalPaid);
       }
    }

    return DashboardStats(
      totalCollected: totalCollected,
      totalPending: totalPending,
      thisMonthCollected: thisMonthCollected,
      thisMonthPending: thisMonthPending,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getMonthlyRevenue(int months) async {
    if (_uid == null) return [];

    // Calculate start date (months ago)
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - months + 1, 1);
    
    // Fetch all valid transactions for this owner
    final snapshot = await _firestore.collection(FirebaseCollections.transactions)
        .where('ownerId', isEqualTo: _uid)
        .where('isDeleted', isEqualTo: false)
        .get();

    // Map: '2023-10' -> totalAmount
    final Map<String, double> revenueMap = {};
    
    // Initialize map with 0.0 for all months in range
    for (int i = 0; i < months; i++) {
       final d = DateTime(now.year, now.month - i, 1);
       final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
       revenueMap[key] = 0.0;
    }

    // Aggregate Data
    for (final doc in snapshot.docs) {
       final data = doc.data();
       final dateStr = data['date'] as String?;
       if (dateStr == null) continue;
       
       final date = DateTime.tryParse(dateStr);
       if (date == null || date.isBefore(startDate)) continue;
       
       final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
       final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
       
       if (revenueMap.containsKey(key)) {
          revenueMap[key] = (revenueMap[key] ?? 0.0) + amount;
       }
    }

    // Convert to List sorted by date (oldest first)
    final sortedKeys = revenueMap.keys.toList()..sort();
    
    return sortedKeys.map((key) {
       return {
         'month': key, // "2023-10"
         'amount': revenueMap[key]!,
       };
    }).toList();
  }

  @override
  Future<void> deletePayment(String id) async {
    if (_uid == null) return;

    final snapshot = await _firestore.collection(FirebaseCollections.transactions)
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

  @override
  Future<void> recoverPayment(String id) async {
    if (_uid == null) return;

    final snapshot = await _firestore.collection(FirebaseCollections.transactions)
        .where('ownerId', isEqualTo: _uid)
        .where('id', isEqualTo: id)
        .limit(1)
        .get();
        
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'isDeleted': false,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> permanentlyDeletePayment(String id) async {
    if (_uid == null) return;

    final snapshot = await _firestore.collection(FirebaseCollections.transactions)
        .where('ownerId', isEqualTo: _uid)
        .where('id', isEqualTo: id)
        .limit(1)
        .get();
        
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.delete();
    }
  }

  @override
  Future<List<domain.Payment>> getDeletedPaymentsForRentCycle(String rentCycleId) async {
     if (_uid == null) return [];
     
    final snapshot = await _firestore.collection(FirebaseCollections.transactions)
        .where('ownerId', isEqualTo: _uid)
        .where('rentCycleId', isEqualTo: rentCycleId)
        .where('isDeleted', isEqualTo: true)
        .get();
    return snapshot.docs.map((p) => _mapPaymentToDomain(p)).toList();
  }

  @override
  Future<String> recordPayment(domain.Payment payment) async { 
     final uid = _uid;
     if (uid == null) throw Exception('User not logged in');

    final id = const Uuid().v4();

    final data = {
      'id': id,
      'ownerId': uid,
      'rentCycleId': payment.rentCycleId,
      'tenancyId': payment.tenancyId,
      'tenantId': payment.tenantId,
      'amount': payment.amount,
      'date': payment.date.toIso8601String(),
      'method': payment.method,
      'channelId': payment.channelId,
      'referenceId': payment.referenceId,
      'collectedBy': payment.collectedBy,
      'notes': payment.notes,
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
      'isDeleted': false,
    };
    
    await _firestore.collection(FirebaseCollections.transactions).doc(id).set(data); 

    // Self-Healing: Try to find cycle even if ownerId is missing (Legacy Data Fix)
    var cycle = await getRentCycle(payment.rentCycleId);
    if (cycle == null) {
       // Try fetching by ID only to check if it exists but lacks ownerId
       final rawDoc = await _firestore.collection(FirebaseCollections.invoices).doc(payment.rentCycleId).get();
       if (rawDoc.exists) {
           final data = rawDoc.data();
           // Security: Ensure the tenancy belongs to this owner before claiming
           final tenancyId = data?['tenancyId'];
           if (tenancyId != null) {
              final tenancyDoc = await _firestore.collection(FirebaseCollections.contracts).doc(tenancyId).get();
              if (tenancyDoc.exists && tenancyDoc.data()?['ownerId'] == uid) {
                  // It's our data! Fix the RentCycle by adding ownerId
                  await rawDoc.reference.update({'ownerId': uid});
                  cycle = mapToDomain(rawDoc); // Now mapped correctly
                  debugPrint('Self-healed RentCycle ${cycle.id} with ownerId');
              }
           }
       }
    }

    if (cycle != null) {
        // Robustness: Recalculate totalPaid from ALL transactions for this cycle
        final payments = await getPaymentsForRentCycle(payment.rentCycleId);
        final newTotalPaid = payments.fold(0.0, (sum, p) => sum + p.amount);
        
        domain.RentStatus newStatus = cycle.status;
        
        if (newTotalPaid >= cycle.totalDue - 0.01) {
          newStatus = domain.RentStatus.paid;
        } else if (newTotalPaid > 0) {
          newStatus = domain.RentStatus.partial;
        } else {
          newStatus = domain.RentStatus.pending;
        }
        
        await updateRentCycle(cycle.copyWith(
            totalPaid: newTotalPaid,
            status: newStatus,
        ));
    } else {
       debugPrint('Error: RentCycle ${payment.rentCycleId} not found for payment recording.');
    }
    return id;
  }

  // --- Electric Readings ---

  @override
  Future<void> addElectricReading(String unitId, DateTime date, double reading, {String? imagePath, double? rate}) async { 
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');
    
    final id = const Uuid().v4();
    
    await _firestore.collection(FirebaseCollections.electricReadings).add({
      'id': id,
      'ownerId': uid,
      'unitId': unitId,
      'readingDate': date.toIso8601String(),
      'currentReading': reading,
      'rate': rate ?? 0.0, 
      'amount': 0.0,
      'notes': 'Electric Reading',
      'imagePath': imagePath,
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
      'isDeleted': false,
    });
  }

  @override
  Future<List<double>> getElectricReadings(String unitId) async {
    if (_uid == null) return [];

    final snapshot = await _firestore.collection(FirebaseCollections.electricReadings)
        .where('ownerId', isEqualTo: _uid) 
        .where('unitId', isEqualTo: unitId)
        .get();
        
    final validDocs = snapshot.docs.where((d) => d.data()['isDeleted'] != true).toList();
    
    validDocs.sort((a, b) {
       final da = DateTime.tryParse(a.data()['readingDate']) ?? DateTime(0);
       final db = DateTime.tryParse(b.data()['readingDate']) ?? DateTime(0);
       return da.compareTo(db);
    });

    return validDocs.map((d) => (d.data()['currentReading'] as num).toDouble()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getElectricReadingsWithDetails(String unitId) async {
    if (_uid == null) return [];

    final snapshot = await _firestore.collection(FirebaseCollections.electricReadings)
        .where('ownerId', isEqualTo: _uid)
        .where('unitId', isEqualTo: unitId)
        .get();
        
    final validDocs = snapshot.docs.where((d) => d.data()['isDeleted'] != true).toList();
    
    validDocs.sort((a, b) {
       final da = DateTime.tryParse(a.data()['readingDate']) ?? DateTime(0);
       final db = DateTime.tryParse(b.data()['readingDate']) ?? DateTime(0);
       return db.compareTo(da);
    });

    return validDocs.map((d) {
      final data = d.data();
      return {
        'reading': (data['currentReading'] as num).toDouble(),
        'date': DateTime.parse(data['readingDate']),
        'rate': (data['rate'] as num?)?.toDouble() ?? 0.0,
      };
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getElectricReadingsForTenant(String unitId, String ownerId) async {
    final snapshot = await _firestore.collection(FirebaseCollections.electricReadings)
        .where('ownerId', isEqualTo: ownerId)
        .where('unitId', isEqualTo: unitId)
        .get();
        
    final validDocs = snapshot.docs.where((d) => d.data()['isDeleted'] != true).toList();
    
    validDocs.sort((a, b) {
       final da = DateTime.tryParse(a.data()['readingDate']) ?? DateTime(0);
       final db = DateTime.tryParse(b.data()['readingDate']) ?? DateTime(0);
       return db.compareTo(da);
    });

    return validDocs.map((d) {
      final data = d.data();
      return {
        'reading': (data['currentReading'] as num).toDouble(),
        'date': DateTime.parse(data['readingDate']),
        'rate': (data['rate'] as num?)?.toDouble() ?? 0.0,
      };
    }).toList();
  }
  
  @override
  Future<Map<String, double>?> getLastElectricReading(String unitId) async {
    if (_uid == null) return null;

    final snapshot = await _firestore.collection(FirebaseCollections.electricReadings)
        .where('ownerId', isEqualTo: _uid) 
        .where('unitId', isEqualTo: unitId)
        .get();

    final validDocs = snapshot.docs.where((d) => d.data()['isDeleted'] != true).toList();
    
    if (validDocs.isEmpty) return null;
    
    validDocs.sort((a, b) {
       final da = DateTime.tryParse(a.data()['readingDate']) ?? DateTime(0);
       final db = DateTime.tryParse(b.data()['readingDate']) ?? DateTime(0);
       return db.compareTo(da); 
    });
    
    final data = validDocs.first.data();
    return {
      'currentReading': (data['currentReading'] as num).toDouble(),
      'rate': (data['rate'] as num?)?.toDouble() ?? 10.0,
    };
  }

  // --- Expenses ---

  @override
  Future<void> addExpense(domain.Expense expense) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');
    
    final id = expense.id == '0' ? const Uuid().v4() : expense.id;
    
    await _firestore.collection(FirebaseCollections.expenses).doc(id).set({
       'id': id,
       'ownerId': uid,
       'title': expense.title,
       'amount': expense.amount,
       'date': expense.date.toIso8601String(),
       'category': expense.category,
       'description': expense.notes,
       'createdAt': FieldValue.serverTimestamp(),
       'lastUpdated': FieldValue.serverTimestamp(),
       'isDeleted': false,
    });
  }

  @override
  Future<List<domain.Expense>> getExpenses(String month) async {
     if (_uid == null) return [];
     
     final start = DateTime.parse('$month-01');
     final end = DateTime(start.year, start.month + 1, 0); 
     
     final snapshot = await _firestore.collection(FirebaseCollections.expenses)
        .where('ownerId', isEqualTo: _uid)
        .get();

     return snapshot.docs.where((doc) {
        final data = doc.data();
        if (data['isDeleted'] == true) return false;
        final dateStr = data['date'] as String;
        return dateStr.compareTo(start.toIso8601String()) >= 0 && 
               dateStr.compareTo(end.toIso8601String()) <= 0;
     }).map((e) => _mapExpenseToDomain(e)).toList();
  }

  @override
  Future<List<domain.Expense>> getAllExpenses() async {
    if (_uid == null) return [];

    final snapshot = await _firestore.collection(FirebaseCollections.expenses)
        .where('ownerId', isEqualTo: _uid)
        .where('isDeleted', isEqualTo: false)
        .get();
        
    return snapshot.docs.map((e) => _mapExpenseToDomain(e)).toList();
  }

  @override
  Future<void> deleteExpense(String id) async {
     if (_uid == null) return;

     final snapshot = await _firestore.collection(FirebaseCollections.expenses)
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

  @visibleForTesting
  domain.RentCycle mapToDomain(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return domain.RentCycle(
      id: (data['id'] ?? doc.id).toString(),
      ownerId: data['ownerId']?.toString() ?? '',
      tenancyId: data['tenancyId']?.toString() ?? '',
      month: data['month'] ?? '',
      billNumber: data['billNumber'] ?? '',
      billPeriodStart: parseDate(data['billPeriodStart']),
      billPeriodEnd: parseDate(data['billPeriodEnd']),
      billGeneratedDate: parseDate(data['billGeneratedDate']) ?? DateTime.now(),
      baseRent: (data['baseRent'] is String) ? (double.tryParse(data['baseRent']) ?? 0.0) : (data['baseRent'] as num?)?.toDouble() ?? 0.0,
      electricAmount: (data['electricAmount'] is String) ? (double.tryParse(data['electricAmount']) ?? 0.0) : (data['electricAmount'] as num?)?.toDouble() ?? 0.0,
      otherCharges: (data['otherCharges'] is String) ? (double.tryParse(data['otherCharges']) ?? 0.0) : (data['otherCharges'] as num?)?.toDouble() ?? 0.0,
      discount: (data['discount'] is String) ? (double.tryParse(data['discount']) ?? 0.0) : (data['discount'] as num?)?.toDouble() ?? 0.0,
      totalDue: (data['totalDue'] is String) ? (double.tryParse(data['totalDue']) ?? 0.0) : (data['totalDue'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (data['totalPaid'] is String) ? (double.tryParse(data['totalPaid']) ?? 0.0) : (data['totalPaid'] as num?)?.toDouble() ?? 0.0,
      status: domain.RentStatus.values[data['status'] as int? ?? 0], 
      dueDate: parseDate(data['dueDate']),
      notes: data['notes'] as String?,
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  @visibleForTesting
  DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  domain.Payment _mapPaymentToDomain(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return domain.Payment(
      id: (data['id'] ?? doc.id).toString(),
      rentCycleId: data['rentCycleId']?.toString() ?? '',
      tenancyId: data['tenancyId']?.toString() ?? '',
      tenantId: data['tenantId']?.toString() ?? '',
      amount: (data['amount'] is String) ? (double.tryParse(data['amount']) ?? 0.0) : (data['amount'] as num?)?.toDouble() ?? 0.0,
      date: parseDate(data['date']) ?? DateTime.now(),
      method: data['method'] ?? 'Cash',
      channelId: data['channelId'],
      referenceId: data['referenceId'],
      collectedBy: data['collectedBy'],
      notes: data['notes'],
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  domain.Expense _mapExpenseToDomain(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return domain.Expense(
      id: data['id'] ?? doc.id,
      ownerId: data['ownerId'] ?? '',
      title: data['title'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
      category: data['category'] ?? 'Other',
      notes: data['description'],
    );
  }
}
