import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/bhk_template.dart';
import '../../../providers/data_providers.dart';

part 'bhk_template_controller.g.dart';

@riverpod
class BhkTemplateController extends _$BhkTemplateController {
  @override
  FutureOr<List<BhkTemplate>> build(int houseId) async {
    final repo = ref.watch(propertyRepositoryProvider);
    return repo.getBhkTemplates(houseId);
  }

  Future<void> addBhkTemplate({
    required int houseId,
    required String bhkType,
    required double defaultRent,
    String? description,
  }) async {
    final repo = ref.read(propertyRepositoryProvider);
    final template = BhkTemplate(
      id: 0,
      houseId: houseId,
      bhkType: bhkType,
      defaultRent: defaultRent,
      description: description,
    );
    await repo.createBhkTemplate(template);
    ref.invalidateSelf();
  }
}
