import 'package:freezed_annotation/freezed_annotation.dart';

part 'owner.freezed.dart';
part 'owner.g.dart';

@freezed
class Owner with _$Owner {
  const factory Owner({
    required int id,
    required String name,
    String? phone,
    String? email,
    String? firestoreId, // NEW
    @Default('free') String subscriptionPlan, // 'free', 'pro', 'power'
    @Default('INR') String currency,
    String? timezone,
    String? upiId, // NEW: Payment destination
    DateTime? createdAt,
  }) = _Owner;

  factory Owner.fromJson(Map<String, dynamic> json) => _$OwnerFromJson(json);
}

@freezed
class ElectricReading with _$ElectricReading {
  const factory ElectricReading({
    required int id,
    required int unitId,
    required DateTime readingDate,
    String? meterName,
    @Default(0.0) double prevReading,
    required double currentReading,
    @Default(0.0) double ratePerUnit,
    required double amount,
    String? notes,
  }) = _ElectricReading;

  factory ElectricReading.fromJson(Map<String, dynamic> json) => _$ElectricReadingFromJson(json);
}

