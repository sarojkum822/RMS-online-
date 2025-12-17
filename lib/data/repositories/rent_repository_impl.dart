import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../features/rent/domain/entities/rent_cycle.dart' as domain;
import '../../domain/repositories/i_rent_repository.dart';
import '../../domain/entities/expense.dart' as domain;
import '../../core/services/notification_service.dart';

class RentRepositoryImpl implements IRentRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  RentRepositoryImpl(this._firestore) : _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  // --- Rent Cycles ---

  @override
  Future<List<domain.RentCycle>> getRentCyclesForTenant(int tenantId) async {
    if (_uid == null) return [];
    
    final snapshot = await _firestore.collection('rent_cycles')
        .where('ownerId', isEqualTo: _uid) // CRITICAL: Must match Security Rule
        .where('tenantId', isEqualTo: tenantId)
        .where('isDeleted', isEqualTo: false)
        .get();
        
    return snapshot.docs.map((c) => _mapToDomain(c)).toList();
  }

  @override
  Future<List<domain.RentCycle>> getRentCyclesForMonth(String month) async {
    // Note: This query might be inefficient across all tenants if not filtered by Owner.
    // However, tenants filter by OwnerId inherently if we enforce it. 
    // Ideally we should filter by ownerId here too if we add it to rent_cycles data.
    // But for now, let's assume client-side filtering or that tenancy checks handle it.
    // BETTER: Filter by tenancy -> owner relation. 
    // Or just add ownerId to rent_cycles. I will assume we might strictly need it, but let's stick to simple query first.
    // Wait, if I am an owner, I shouldn't see other owners' data.
    // Firestore rules will enforcing this, but queries need to match.
    // Let's rely on the fact that we usually query in context.
    // Actually, getRentCyclesForMonth is for DASHBOARD. So yes, MUST filter by Owner.
    // I should add ownerId to rent_cycles? Or fetch all my tenants and then their cycles?
    // Adding 'ownerId' to RentCycle data is safest for NoSQL.
    
    if (_uid == null) return [];

    final snapshot = await _firestore.collection('rent_cycles')
        .where('ownerId', isEqualTo: _uid)
        .get();
        
    return snapshot.docs
        .where((d) => d.data()['month'] == month && d.data()['isDeleted'] != true)
        .map((c) => _mapToDomain(c))
        .toList();
  }

  @override
  Future<List<domain.RentCycle>> getAllRentCycles() async {
    if (_uid == null) return [];

    final snapshot = await _firestore.collection('rent_cycles')
        .where('ownerId', isEqualTo: _uid)
        .where('isDeleted', isEqualTo: false)
        .get();
        
    return snapshot.docs.map((c) => _mapToDomain(c)).toList();
  }

  @override
  Future<List<domain.RentCycle>> getAllPendingRentCycles() async {
    if (_uid == null) return [];

    // Filter by Owner, Not Deleted, and Status != Paid
    // RentStatus: pending(0), partial(1), paid(2).
    // So status < 2 means pending or partial.
    
    final snapshot = await _firestore.collection('rent_cycles')
        .where('ownerId', isEqualTo: _uid)
        .where('isDeleted', isEqualTo: false)
        .where('status', isLessThan: 2) // status < 2 (paid)
        .get();
        
    return snapshot.docs.map((c) => _mapToDomain(c)).toList();
  }

  @override
  Future<List<domain.RentCycle>> getRentCyclesByTenantAccess(int tenantId, String ownerId) async {
    // Allows fetching bills using known OwnerID (Tenant View)
    final snapshot = await _firestore.collection('rent_cycles')
        .where('ownerId', isEqualTo: ownerId)
        .where('tenantId', isEqualTo: tenantId)
        .where('isDeleted', isEqualTo: false)
        //.where('status', isLessThan: 2) // Optional: Show all history or just pending? User asked for "Bill History" so probably all.
        .orderBy('month', descending: true) // Show latest first
        .get();
        
    return snapshot.docs.map((c) => _mapToDomain(c)).toList();
  }

  @override
  Stream<List<domain.RentCycle>> watchRentCyclesByTenantAccess(int tenantId, String ownerId) {
    return _firestore.collection('rent_cycles')
        .where('ownerId', isEqualTo: ownerId)
        .where('tenantId', isEqualTo: tenantId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('month', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((c) => _mapToDomain(c)).toList());
  }

  @override
  Future<domain.RentCycle?> getRentCycle(int id) async {
    if (_uid == null) return null;

    final snapshot = await _firestore.collection('rent_cycles')
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
  Future<int> createRentCycle(domain.RentCycle rentCycle) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');

    // Deterministic Document ID: prevents valid duplicates at DB level
    final docId = '${rentCycle.tenantId}_${rentCycle.month}'; 
    final docRef = _firestore.collection('rent_cycles').doc(docId);

    final snapshot = await docRef.get();
    if (snapshot.exists) {
       // already exists
       return snapshot.data()!['id'] as int;
    }

    final id = DateTime.now().millisecondsSinceEpoch;

    final data = {
      'id': id,
      'ownerId': uid, // Add ownerId for easier dashboard queries
      'tenantId': rentCycle.tenantId,
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
          id: id,
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

    final snapshot = await _firestore.collection('rent_cycles')
        .where('ownerId', isEqualTo: _uid) // CRITICAL
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

    // Strategy 1: Try Deterministic Doc ID (Fastest & Most Accurate)
    final docId = '${cycle.tenantId}_${cycle.month}';
    final docRef = _firestore.collection('rent_cycles').doc(docId);
    
    final docSnapshot = await docRef.get();
    if (docSnapshot.exists && docSnapshot.data()?['ownerId'] == _uid) {
       await docRef.update({
         'isDeleted': true,
         'lastUpdated': FieldValue.serverTimestamp(),
       });
       return;
    }

    // Strategy 2: Fallback to ID query (Legacy support)
    final snapshot = await _firestore.collection('rent_cycles')
        .where('ownerId', isEqualTo: _uid) // CRITICAL
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

  // --- Payments ---

  @override
  Future<List<domain.Payment>> getAllPayments() async {
     if (_uid == null) return [];

    final snapshot = await _firestore.collection('payments')
        .where('ownerId', isEqualTo: _uid)
        .where('isDeleted', isEqualTo: false)
        .get();
        
    return snapshot.docs.map((p) => _mapPaymentToDomain(p)).toList();
  }

  @override
  Future<List<domain.Payment>> getPaymentsForRentCycle(int rentCycleId) async {
     if (_uid == null) return [];
     
    final snapshot = await _firestore.collection('payments')
        .where('ownerId', isEqualTo: _uid)
        .where('rentCycleId', isEqualTo: rentCycleId)
        .where('isDeleted', isEqualTo: false)
        .get();
    return snapshot.docs.map((p) => _mapPaymentToDomain(p)).toList();
  }

  @override
  Future<List<domain.Payment>> getPaymentsForRentCycleForTenant(int rentCycleId, String ownerId) async {
    final snapshot = await _firestore.collection('payments')
        .where('ownerId', isEqualTo: ownerId)
        .where('rentCycleId', isEqualTo: rentCycleId)
        .where('isDeleted', isEqualTo: false)
        .get();
    return snapshot.docs.map((p) => _mapPaymentToDomain(p)).toList();
  }

  @override
  Future<List<domain.Payment>> getPaymentsForTenant(int tenantId) async {
     if (_uid == null) return [];

    final snapshot = await _firestore.collection('payments')
        .where('ownerId', isEqualTo: _uid)
        .where('tenantId', isEqualTo: tenantId)
        .where('isDeleted', isEqualTo: false)
        .get();
    return snapshot.docs.map((p) => _mapPaymentToDomain(p)).toList();
  }

  @override
  Future<List<domain.Payment>> getPaymentsByTenantAccess(int tenantId, String ownerId) async {
    // Allows fetching payments using known OwnerID (Tenant View)
    final snapshot = await _firestore.collection('payments')
        .where('ownerId', isEqualTo: ownerId)
        .where('tenantId', isEqualTo: tenantId)
        .where('isDeleted', isEqualTo: false)
        .get();
    return snapshot.docs.map((p) => _mapPaymentToDomain(p)).toList();
  }

  @override
  Stream<List<domain.Payment>> watchPaymentsByTenantAccess(int tenantId, String ownerId) {
    return _firestore.collection('payments')
        .where('ownerId', isEqualTo: ownerId)
        .where('tenantId', isEqualTo: tenantId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((p) => _mapPaymentToDomain(p)).toList());
  }

  @override
  Future<List<domain.Payment>> getRecentPayments(int limit) async {
    if (_uid == null) return [];

    final snapshot = await _firestore.collection('payments')
        .where('ownerId', isEqualTo: _uid) 
        .get();
        
    final docs = snapshot.docs.where((d) => d.data()['isDeleted'] != true).toList();
    
    // Sort in Dart
    docs.sort((a, b) {
       final da = DateTime.tryParse(a.data()['date']) ?? DateTime(0);
       final db = DateTime.tryParse(b.data()['date']) ?? DateTime(0);
       return db.compareTo(da); // Descending
    });
    
    return docs.take(limit).map((p) => _mapPaymentToDomain(p)).toList();
  }

  @override
  Future<DashboardStats> getDashboardStats() async {
     if (_uid == null) return DashboardStats(totalCollected: 0, totalPending: 0, thisMonthCollected: 0, thisMonthPending: 0);

    final now = DateTime.now();
    final currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    final snapshot = await _firestore.collection('rent_cycles')
        .where('ownerId', isEqualTo: _uid)
        .get(); 
        
    // Filter isDeleted in memory
    final docs = snapshot.docs.where((d) => d.data()['isDeleted'] != true);

    double totalCollected = 0;
    double totalPending = 0;
    double thisMonthCollected = 0;
    double thisMonthPending = 0;

    for (final doc in docs) {
       final data = doc.data();
       final totalPaid = (data['totalPaid'] as num).toDouble();
       final totalDue = (data['totalDue'] as num).toDouble();
       final month = data['month'] as String;

       totalCollected += totalPaid;
       totalPending += (totalDue - totalPaid);

       if (month == currentMonth) {
         thisMonthCollected += totalPaid;
         thisMonthPending += (totalDue - totalPaid);
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
  Future<void> deletePayment(int id) async {
    if (_uid == null) return;

    final snapshot = await _firestore.collection('payments')
        .where('ownerId', isEqualTo: _uid) // CRITICAL
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
  Future<int> recordPayment(domain.Payment payment) async {
     final uid = _uid;
     if (uid == null) throw Exception('User not logged in');

    // Transaction? Firestore supports it.
    // Simple async sequence for MVP.
    final id = DateTime.now().millisecondsSinceEpoch;

    final data = {
      'id': id,
      'ownerId': uid,
      'rentCycleId': payment.rentCycleId,
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
    
    await _firestore.collection('payments').add(data);

    // Update Rent Cycle
    final cycle = await getRentCycle(payment.rentCycleId);
    if (cycle != null) {
        final newTotalPaid = cycle.totalPaid + payment.amount;
        domain.RentStatus newStatus = cycle.status;
        
        if (newTotalPaid >= cycle.totalDue) {
          newStatus = domain.RentStatus.paid;
        } else if (newTotalPaid > 0) {
          newStatus = domain.RentStatus.partial;
        }
        
        await updateRentCycle(cycle.copyWith(
            totalPaid: newTotalPaid,
            status: newStatus,
        ));
    }
    return id;
  }

  // --- Electric Readings ---

  @override
  Future<void> addElectricReading(int unitId, DateTime date, double reading, {String? imagePath, double? rate}) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');
    
    final id = DateTime.now().millisecondsSinceEpoch;
    
    await _firestore.collection('electric_readings').add({
      'id': id,
      'ownerId': uid,
      'unitId': unitId,
      'readingDate': date.toIso8601String(),
      'currentReading': reading,
      'rate': rate ?? 0.0, // Storing rate
      'amount': 0.0,
      'notes': 'Electric Reading',
      'imagePath': imagePath,
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
      'isDeleted': false,
    });
  }

  @override
  Future<List<double>> getElectricReadings(int unitId) async {
    if (_uid == null) return [];

    // Fetch ALL for unit, Sort in Memory to avoid Index requirements
    final snapshot = await _firestore.collection('electric_readings')
        .where('ownerId', isEqualTo: _uid) // Consistent security
        .where('unitId', isEqualTo: unitId)
        .get();
        
    final validDocs = snapshot.docs.where((d) => d.data()['isDeleted'] != true).toList();
    
    // Sort ascending by date
    validDocs.sort((a, b) {
       final da = DateTime.tryParse(a.data()['readingDate']) ?? DateTime(0);
       final db = DateTime.tryParse(b.data()['readingDate']) ?? DateTime(0);
       return da.compareTo(db);
    });

    return validDocs.map((d) => (d.data()['currentReading'] as num).toDouble()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getElectricReadingsWithDetails(int unitId) async {
    if (_uid == null) return [];

    final snapshot = await _firestore.collection('electric_readings')
        .where('ownerId', isEqualTo: _uid)
        .where('unitId', isEqualTo: unitId)
        .get();
        
    final validDocs = snapshot.docs.where((d) => d.data()['isDeleted'] != true).toList();
    
    // Sort descending by date (latest first)
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
  Future<List<Map<String, dynamic>>> getElectricReadingsForTenant(int unitId, String ownerId) async {
    final snapshot = await _firestore.collection('electric_readings')
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
  
  // NEW: Get Last Reading for smart pre-fill
  @override
  Future<Map<String, double>?> getLastElectricReading(int unitId) async {
    if (_uid == null) return null;

    // Fetch ALL for unit, Sort in Memory
    final snapshot = await _firestore.collection('electric_readings')
        .where('ownerId', isEqualTo: _uid) // Consistent security
        .where('unitId', isEqualTo: unitId)
        .get();

    final validDocs = snapshot.docs.where((d) => d.data()['isDeleted'] != true).toList();
    
    if (validDocs.isEmpty) return null;
    
    // Sort DESCENDING by date (Latest first)
    validDocs.sort((a, b) {
       final da = DateTime.tryParse(a.data()['readingDate']) ?? DateTime(0);
       final db = DateTime.tryParse(b.data()['readingDate']) ?? DateTime(0);
       return db.compareTo(da); // b compareTo a
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
    
    final id = DateTime.now().millisecondsSinceEpoch; // or expense.id if passed as 0? typically repository generates ID for create.
    
    await _firestore.collection('expenses').add({
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
     
     // Firestore doesn't support RANGE filter on one field AND EQUALITY on another easily without index.
     // But strictly speaking, date range filter is fine if filtering by ownerId.
     // Index might be needed: owners/{uid}/expenses OR composite index on ownerId + date
     
     final snapshot = await _firestore.collection('expenses')
        .where('ownerId', isEqualTo: _uid)
        .get();

     // Filter in Dart to avoid Composite Index requirement
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

    final snapshot = await _firestore.collection('expenses')
        .where('ownerId', isEqualTo: _uid)
        .where('isDeleted', isEqualTo: false)
        .get();
        
    return snapshot.docs.map((e) => _mapExpenseToDomain(e)).toList();
  }

  @override
  Future<void> deleteExpense(int id) async {
     if (_uid == null) return;

     final snapshot = await _firestore.collection('expenses')
        .where('ownerId', isEqualTo: _uid) // CRITICAL
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

  domain.RentCycle _mapToDomain(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return domain.RentCycle(
      id: data['id'],
      tenantId: data['tenantId'],
      month: data['month'],
      billNumber: data['billNumber'],
      billPeriodStart: data['billPeriodStart'] != null ? DateTime.parse(data['billPeriodStart']) : null,
      billPeriodEnd: data['billPeriodEnd'] != null ? DateTime.parse(data['billPeriodEnd']) : null,
      billGeneratedDate: DateTime.parse(data['billGeneratedDate']),
      baseRent: (data['baseRent'] as num).toDouble(),
      electricAmount: (data['electricAmount'] as num).toDouble(),
      otherCharges: (data['otherCharges'] as num).toDouble(),
      discount: (data['discount'] as num).toDouble(),
      totalDue: (data['totalDue'] as num).toDouble(),
      totalPaid: (data['totalPaid'] as num).toDouble(),
      status: domain.RentStatus.values[data['status'] ?? 0], 
      dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate']) : null,
      notes: data['notes'],
    );
  }

  domain.Payment _mapPaymentToDomain(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return domain.Payment(
      id: data['id'],
      rentCycleId: data['rentCycleId'],
      tenantId: data['tenantId'],
      amount: (data['amount'] as num).toDouble(),
      date: DateTime.parse(data['date']),
      method: data['method'],
      channelId: data['channelId'],
      referenceId: data['referenceId'],
      collectedBy: data['collectedBy'],
      notes: data['notes'],
    );
  }

  domain.Expense _mapExpenseToDomain(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return domain.Expense(
      id: data['id'],
      title: data['title'],
      amount: (data['amount'] as num).toDouble(),
      date: DateTime.parse(data['date']),
      category: data['category'],
      notes: data['description'],
    );
  }
}
