import 'package:freezed_annotation/freezed_annotation.dart';

part 'tenant.freezed.dart';
part 'tenant.g.dart';

enum TenantStatus { active, inactive }

@freezed
class Tenant with _$Tenant {
  const factory Tenant({
    required int id,
    required int houseId,
    required int unitId,
    required String tenantCode, // for login
    required String name,
    required String phone,
    String? email,
    required DateTime startDate,
    required TenantStatus status,
    @Default(0.0) double openingBalance,
    double? agreedRent, // NEW
  }) = _Tenant;

  factory Tenant.fromJson(Map<String, dynamic> json) => _$TenantFromJson(json);
}
