import 'package:freezed_annotation/freezed_annotation.dart';

part 'house.freezed.dart';
part 'house.g.dart';

@freezed
class House with _$House {
  const factory House({
    required int id,
    required String name,
    required String address,
    String? notes,
    String? imageUrl,
    String? imageBase64, // NEW: Base64 storage
    @Default(0) int unitCount,
  }) = _House;

  factory House.fromJson(Map<String, dynamic> json) => _$HouseFromJson(json);
}

@freezed
class Unit with _$Unit {
  const factory Unit({
    required int id,
    required int houseId,
    required String nameOrNumber,
    int? floor,
    required double baseRent,
    
    // NEW Fields for BHK
    int? bhkTemplateId,
    String? bhkType,
    double? editableRent,
    int? tenantId,
    
    // Advanced Details
    String? furnishingStatus,
    double? carpetArea,
    String? parkingSlot,
    String? meterNumber,

    @Default(1) int defaultDueDay,
    @Default(false) bool isOccupied,
    
    // NEW: Image Upload Support (Max 4 images)
    @Default([]) List<String> imageUrls,
    @Default([]) List<String> imagesBase64, // NEW: Base64 Unit Images
  }) = _Unit;

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);
}
