import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/notice.dart';
import 'package:kirayabook/presentation/providers/data_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'notice_controller.g.dart';

@riverpod
class NoticeController extends _$NoticeController {
  @override
  FutureOr<void> build() {}

  Future<void> sendNotice({
    required String houseId,
    required String ownerId,
    required String subject,
    required String message,
    String priority = 'medium',
    String targetType = 'house', // 'all', 'house', 'unit'
    String? targetId,
  }) async {
    final repo = ref.read(noticeRepositoryProvider);
    final notice = Notice(
      id: '', // Firestore gen
      ownerId: ownerId,
      houseId: houseId,
      subject: subject,
      message: message,
      date: DateTime.now(),
      readBy: [],
      readAt: {},
      priority: priority,
      targetType: targetType,
      targetId: targetId ?? houseId, // Default to houseId if null
    );
    
    // Send to Firestore first (throws on failure)
    await repo.sendNotice(notice);
    
    // Trigger Push Notifications in background (non-blocking, best-effort)
    // Using unawaited to prevent "Future already completed" errors
    _sendPushNotificationsInBackground(
      targetType: targetType,
      targetId: targetId,
      houseId: houseId,
      subject: subject,
      message: message,
    );
  }

  /// Sends push notifications in background - errors are logged but don't fail the broadcast
  Future<void> _sendPushNotificationsInBackground({
    required String targetType,
    String? targetId,
    required String houseId,
    required String subject,
    required String message,
  }) async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      
      List<String> tenantIds = [];
      
      if (targetType == 'unit' && targetId != null) {
        // 1. Target Single Unit: Get current tenancy for this unit
        final allTenancies = ref.read(allTenanciesProvider).valueOrNull ?? [];
        final activeTenancy = allTenancies.where(
          (t) => t.unitId == targetId && t.status.name == 'active',
        ).firstOrNull;
        if (activeTenancy != null) {
          tenantIds = [activeTenancy.tenantId];
        }
      } else if (targetType == 'house') {
        // 2. Target Entire Building
        final allUnits = ref.read(allUnitsProvider).valueOrNull ?? [];
        final houseUnits = allUnits.where((u) => u.houseId == houseId).map((u) => u.id).toList();
        
        final allTenancies = ref.read(allTenanciesProvider).valueOrNull ?? [];
        tenantIds = allTenancies.where((t) => 
          houseUnits.contains(t.unitId) && 
          t.status.name == 'active'
        ).map((t) => t.tenantId).toList();
      } else if (targetType == 'all') {
        // 3. Target All Properties for this owner
        final allTenancies = ref.read(allTenanciesProvider).valueOrNull ?? [];
        tenantIds = allTenancies
            .where((t) => t.status.name == 'active')
            .map((t) => t.tenantId)
            .toList();
      }
      
      if (tenantIds.isNotEmpty) {
         // 4. Resolve Auth UIDs from Tenant documents (Batched fetch)
         final chunks = _chunkList(tenantIds, 30);
         List<String> authIds = [];
         
         for (var chunk in chunks) {
            final tenantSnapshot = await FirebaseFirestore.instance
                .collection('tenants')
                .where('id', whereIn: chunk)
                .get();
            
            authIds.addAll(tenantSnapshot.docs
                .map((d) => d.data()['authId'] as String?)
                .whereType<String>());
         }

         if (authIds.isNotEmpty) {
           await notificationService.triggerPushNotification(
             userIds: authIds,
             title: 'Building Notice: $subject',
             body: message,
             data: {'route': '/notices', 'houseId': houseId},
           );
         }
      }
    } catch (e) {
      print('Error sending push notifications: $e');
      // Don't rethrow - push notification failure shouldn't fail the broadcast
    }
  }

  List<List<T>> _chunkList<T>(List<T> list, int size) {
    return List.generate((list.length / size).ceil(), (i) => list.sublist(i * size, (i + 1) * size > list.length ? list.length : (i + 1) * size));
  }

  Future<void> markAsRead(String noticeId, String tenantId, String ownerId) async {
    final repo = ref.read(noticeRepositoryProvider);
    await repo.markAsRead(noticeId, tenantId, ownerId);
  }

  Future<void> deleteNotice(String noticeId, String ownerId) async {
    final repo = ref.read(noticeRepositoryProvider);
    await repo.deleteNotice(noticeId, ownerId);
  }

  Future<void> cleanupOldNotices(String ownerId) async {
    final repo = ref.read(noticeRepositoryProvider);
    await repo.deleteOldNotices(ownerId);
  }
}

final noticesForHouseProvider = StreamProvider.family<List<Notice>, ({String houseId, String ownerId})>((ref, arg) {
  final repo = ref.watch(noticeRepositoryProvider);
  return repo.watchNoticesForHouse(arg.houseId, arg.ownerId);
});
