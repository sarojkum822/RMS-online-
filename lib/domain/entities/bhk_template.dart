import 'package:freezed_annotation/freezed_annotation.dart';

part 'bhk_template.freezed.dart';
part 'bhk_template.g.dart';

@freezed
class BhkTemplate with _$BhkTemplate {
  const factory BhkTemplate({
    required int id,
    required int houseId,
    required String bhkType,
    required double defaultRent,
    String? description,
  }) = _BhkTemplate;

  factory BhkTemplate.fromJson(Map<String, dynamic> json) => _$BhkTemplateFromJson(json);
}
