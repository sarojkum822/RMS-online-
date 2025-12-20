import 'package:freezed_annotation/freezed_annotation.dart';

part 'tenancy.freezed.dart';
part 'tenancy.g.dart';

enum TenancyStatus { active, ended, evicted }

@freezed
class Tenancy with _$Tenancy {
  const factory Tenancy({
    required String id,
    required String tenantId,
    required String unitId,
    required String ownerId, // Scope security
    required DateTime startDate,
    DateTime? endDate,
    required double agreedRent,
    @Default(0.0) double securityDeposit,
    @Default(0.0) double openingBalance,
    required TenancyStatus status,
    String? notes,
  }) = _Tenancy;

  factory Tenancy.fromJson(Map<String, dynamic> json) => _$TenancyFromJson(json);
}
