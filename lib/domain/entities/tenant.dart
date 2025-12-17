import 'package:freezed_annotation/freezed_annotation.dart';

part 'tenant.freezed.dart';
part 'tenant.g.dart';

enum TenantStatus { active, inactive }

@freezed
class Tenant with _$Tenant {
  const factory Tenant({
    required String id,
    required String tenantCode, // for login
    required String name,
    required String phone,
    String? email,
    required String ownerId, // NEW: Needed for fetching payments
    @Default(true) bool isActive,
    String? password,
    String? imageUrl,
    String? imageBase64, // NEW: Base64 Storage
    String? authId, // Firebase Auth UID for secure login
  }) = _Tenant;

  factory Tenant.fromJson(Map<String, dynamic> json) => _$TenantFromJson(json);
}
