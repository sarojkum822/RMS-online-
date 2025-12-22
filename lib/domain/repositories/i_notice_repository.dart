import '../entities/notice.dart';

abstract class INoticeRepository {
  Future<void> sendNotice(Notice notice);
  Stream<List<Notice>> watchNoticesForHouse(String houseId, String ownerId);
  Stream<List<Notice>> watchNoticesForTenant(String houseId, String? unitId, String ownerId);
  Stream<List<Notice>> watchNoticesForOwner(String ownerId);
  Future<void> markAsRead(String noticeId, String tenantId, String ownerId);
  Future<void> deleteNotice(String noticeId, String ownerId);
  Future<void> deleteOldNotices(String ownerId); // 7-day cleanup
}
