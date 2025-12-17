import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/bhk_template.dart';
import '../../../providers/data_providers.dart';

part 'bhk_template_controller.g.dart';

@riverpod
class BhkTemplateController extends _$BhkTemplateController {
  @override
  Stream<List<BhkTemplate>> build(int houseId) {
    final repo = ref.watch(propertyRepositoryProvider);
    return repo.getBhkTemplates(houseId);
  }

  Future<void> addBhkTemplate({
    required int houseId,
    required String bhkType,
    required double defaultRent,
    String? description,
    int roomCount = 1,
    int kitchenCount = 1,
    int hallCount = 1,
    bool hasBalcony = false,
  }) async {
    final repo = ref.read(propertyRepositoryProvider);
    final template = BhkTemplate(
      id: 0,
      houseId: houseId,
      bhkType: bhkType,
      defaultRent: defaultRent,
      description: description,
      roomCount: roomCount,
      kitchenCount: kitchenCount,
      hallCount: hallCount,
      hasBalcony: hasBalcony,
    );
    await repo.createBhkTemplate(template);
    // Explicit invalidation is not needed for StreamProvider/StreamNotifier 
    // IF the repository emits a new value.
    // However, if using snapshots(), it is automatic. 
    // ref.invalidateSelf(); 
  }

  Future<void> updateBhkTemplate({
    required int id,
    required int houseId,
    required String bhkType,
    required double defaultRent,
    String? description,
    int roomCount = 1,
    int kitchenCount = 1,
    int hallCount = 1,
    bool hasBalcony = false,
  }) async {
    final repo = ref.read(propertyRepositoryProvider);
    final template = BhkTemplate(
      id: id,
      houseId: houseId,
      bhkType: bhkType,
      defaultRent: defaultRent,
      description: description,
      roomCount: roomCount,
      kitchenCount: kitchenCount,
      hallCount: hallCount,
      hasBalcony: hasBalcony,
    );
    await repo.updateBhkTemplate(template);
  }
}
