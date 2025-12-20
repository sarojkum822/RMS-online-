import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/bhk_template.dart';
import '../../../providers/data_providers.dart';
import 'package:uuid/uuid.dart';

part 'bhk_template_controller.g.dart';

@riverpod
class BhkTemplateController extends _$BhkTemplateController {
  @override
  Stream<List<BhkTemplate>> build(String houseId) {
    final repo = ref.watch(propertyRepositoryProvider);
    return repo.getBhkTemplates(houseId);
  }

  Future<void> addBhkTemplate({
    required String houseId,
    required String bhkType,
    required double defaultRent,
    String? description,
    int roomCount = 1,
    int kitchenCount = 1,
    int hallCount = 1,
    bool hasBalcony = false,
    String? imageBase64,
  }) async {
    final repo = ref.read(propertyRepositoryProvider);
    final template = BhkTemplate(
      id: const Uuid().v4(),
      houseId: houseId,
      bhkType: bhkType,
      defaultRent: defaultRent,
      description: description,
      roomCount: roomCount,
      kitchenCount: kitchenCount,
      hallCount: hallCount,
      hasBalcony: hasBalcony,
      imageBase64: imageBase64,
    );
    await repo.createBhkTemplate(template);
  }

  Future<void> updateBhkTemplate({
    required String id,
    required String houseId,
    required String bhkType,
    required double defaultRent,
    String? description,
    int roomCount = 1,
    int kitchenCount = 1,
    int hallCount = 1,
    bool hasBalcony = false,
    String? imageBase64,
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
      imageBase64: imageBase64,
    );
    await repo.updateBhkTemplate(template);
  }
}
