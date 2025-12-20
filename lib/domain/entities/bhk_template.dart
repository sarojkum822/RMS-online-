import 'package:freezed_annotation/freezed_annotation.dart';

part 'bhk_template.freezed.dart';
part 'bhk_template.g.dart';

@freezed
class BhkTemplate with _$BhkTemplate {
  const factory BhkTemplate({
    required String id,
    required String houseId,
    required String bhkType,
    required double defaultRent,
    String? description,
    @Default(1) int roomCount,
    @Default(1) int kitchenCount,
    @Default(1) int hallCount,
    @Default(false) bool hasBalcony,
    String? imageBase64,
  }) = _BhkTemplate;

  factory BhkTemplate.fromJson(Map<String, dynamic> json) => _$BhkTemplateFromJson(json);
}
