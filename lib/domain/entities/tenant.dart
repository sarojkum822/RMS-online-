import 'package:freezed_annotation/freezed_annotation.dart';
import 'verification_document.dart'; // NEW

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
    String? imageUrl,
    String? imageBase64, // NEW: Base64 Storage
    String? authId, // Firebase Auth UID for secure login
    @Default(0.0) double advanceAmount,
    @Default(false) bool policeVerification,
    String? idProof,
    String? address,
    String? dob, // NEW
    String? gender, // NEW
    @Default(1) int memberCount,
    String? notes,
    @Default([]) List<VerificationDocument> documents, // NEW
  }) = _Tenant;

  factory Tenant.fromJson(Map<String, dynamic> json) => _$TenantFromJson(json);
}
