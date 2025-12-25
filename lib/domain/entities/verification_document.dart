import 'package:freezed_annotation/freezed_annotation.dart';

part 'verification_document.freezed.dart';
part 'verification_document.g.dart';

enum VerificationStatus { pending, verified, rejected }

@freezed
class VerificationDocument with _$VerificationDocument {
  const factory VerificationDocument({
    required String id,
    required String type, // e.g., 'Aadhaar Card', 'PAN Card', 'Police Verification'
    @Default(VerificationStatus.pending) VerificationStatus status,
    String? referenceNumber, // e.g., '1234-5678-9012'
    String? notes,
    String? fileUrl, // Optional: if existing logic supports file upload for specific docs
  }) = _VerificationDocument;

  factory VerificationDocument.fromJson(Map<String, dynamic> json) => _$VerificationDocumentFromJson(json);
}
