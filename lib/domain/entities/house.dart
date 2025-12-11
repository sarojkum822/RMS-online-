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
    @Default(1) int defaultDueDay,
  }) = _Unit;

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);
}
