import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notice.dart';
import '../../domain/repositories/i_notice_repository.dart';

class NoticeRepositoryImpl implements INoticeRepository {
  final FirebaseFirestore _firestore;

  NoticeRepositoryImpl(this._firestore);

  @override
  Future<void> sendNotice(Notice notice) async {
    // ID is typically auto-generated or passed. If empty, efficient to let Firestore gen it, 
    // but our entity expects ID. We usually pass empty string for create.
    await _firestore.collection('notices').add({
      ...notice.toJson(),
      'date': Timestamp.fromDate(notice.date), // Ensure timestamp
    });
  }

  @override
  Stream<List<Notice>> watchNoticesForHouse(String houseId, String ownerId) {
    if (houseId.isEmpty || ownerId.isEmpty) return Stream.value([]);
    
    return _firestore
        .collection('notices')
        .where('ownerId', isEqualTo: ownerId)
        .where('houseId', isEqualTo: houseId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Notice.fromFirestore(doc))
            .toList());
  }
  
  @override
  Stream<List<Notice>> watchNoticesForOwner(String ownerId) {
      return _firestore
        .collection('notices')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Notice.fromFirestore(doc))
            .toList());
  }

  @override
  Future<void> markAsRead(String noticeId, String tenantId) async {
    await _firestore.collection('notices').doc(noticeId).update({
      'readBy': FieldValue.arrayUnion([tenantId]),
      'readAt.$tenantId': FieldValue.serverTimestamp(), // Store timestamp
    });
  }

  @override
  Future<void> deleteNotice(String noticeId) async {
    await _firestore.collection('notices').doc(noticeId).delete();
  }

  @override
  Future<void> deleteOldNotices(String ownerId) async {
    // 7 Days Retention Policy
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    
    // Query notices older than cutoff
    // Note: Firestore requires composite index for 'ownerId' + 'date'.
    // If index missing, this might fail or require client-side filter.
    // Client-side is safer for now to avoid blocking user.
    
    final snapshot = await _firestore
        .collection('notices')
        .where('ownerId', isEqualTo: ownerId)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = data['date'] as Timestamp;
        if (timestamp.toDate().isBefore(cutoff)) {
            batch.delete(doc.reference);
        }
    }
    await batch.commit();
  }
}
