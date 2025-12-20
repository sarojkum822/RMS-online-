import 'package:freezed_annotation/freezed_annotation.dart';

part 'rent_cycle.freezed.dart';
part 'rent_cycle.g.dart';

@freezed
class RentCycle with _$RentCycle {
  const factory RentCycle({
    required String id, // UUID
    required String tenancyId, // Link to Tenancy
    required String ownerId,
    required String month, // Format: YYYY-MM
    String? billNumber,
    DateTime? billPeriodStart,
    DateTime? billPeriodEnd,
    required DateTime billGeneratedDate,
    required double baseRent,
    @Default(0.0) double electricAmount,
    @Default(0.0) double otherCharges,
    @Default(0.0) double lateFee, // [NEW] Track late fees explicitly
    @Default(0.0) double discount,
    required double totalDue,
    @Default(0.0) double totalPaid,
    @Default(RentStatus.pending) RentStatus status,
    DateTime? dueDate,
    String? notes,
    @Default(false) bool isDeleted,
  }) = _RentCycle;



  factory RentCycle.fromJson(Map<String, dynamic> json) => _$RentCycleFromJson(json);
}

@freezed
class Payment with _$Payment {
  const factory Payment({
    required String id,
    required String rentCycleId,
    required String tenancyId, 
    required String tenantId, 
    required double amount,
    required DateTime date,
    required String method, // e.g., 'Cash', 'UPI'
    int? channelId,
    String? referenceId,
    String? collectedBy,
    String? notes,
    @Default(false) bool isDeleted,
  }) = _Payment;



  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
}

@freezed
class OtherCharge with _$OtherCharge {
  const factory OtherCharge({
    required String id,
    required String rentCycleId,
    required double amount,
    required String category,
    String? notes,
  }) = _OtherCharge;



  factory OtherCharge.fromJson(Map<String, dynamic> json) => _$OtherChargeFromJson(json);
}

@freezed
class PaymentChannel with _$PaymentChannel {
  const factory PaymentChannel({
    required int id,
    required String name,
    required String type,
    String? details,
  }) = _PaymentChannel;

  factory PaymentChannel.fromJson(Map<String, dynamic> json) => _$PaymentChannelFromJson(json);
}

enum RentStatus { pending, partial, paid, overdue }
