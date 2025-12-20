import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/notice.dart';
import 'package:kirayabook/presentation/providers/data_providers.dart';

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
    );
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repo.sendNotice(notice));
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
