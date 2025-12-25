// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verification_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VerificationDocument _$VerificationDocumentFromJson(Map<String, dynamic> json) {
  return _VerificationDocument.fromJson(json);
}

/// @nodoc
mixin _$VerificationDocument {
  String get id => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // e.g., 'Aadhaar Card', 'PAN Card', 'Police Verification'
  VerificationStatus get status => throw _privateConstructorUsedError;
  String? get referenceNumber =>
      throw _privateConstructorUsedError; // e.g., '1234-5678-9012'
  String? get notes => throw _privateConstructorUsedError;
  String? get fileUrl => throw _privateConstructorUsedError;

  /// Serializes this VerificationDocument to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VerificationDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VerificationDocumentCopyWith<VerificationDocument> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerificationDocumentCopyWith<$Res> {
  factory $VerificationDocumentCopyWith(VerificationDocument value,
          $Res Function(VerificationDocument) then) =
      _$VerificationDocumentCopyWithImpl<$Res, VerificationDocument>;
  @useResult
  $Res call(
      {String id,
      String type,
      VerificationStatus status,
      String? referenceNumber,
      String? notes,
      String? fileUrl});
}

/// @nodoc
class _$VerificationDocumentCopyWithImpl<$Res,
        $Val extends VerificationDocument>
    implements $VerificationDocumentCopyWith<$Res> {
  _$VerificationDocumentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VerificationDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? status = null,
    Object? referenceNumber = freezed,
    Object? notes = freezed,
    Object? fileUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as VerificationStatus,
      referenceNumber: freezed == referenceNumber
          ? _value.referenceNumber
          : referenceNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      fileUrl: freezed == fileUrl
          ? _value.fileUrl
          : fileUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VerificationDocumentImplCopyWith<$Res>
    implements $VerificationDocumentCopyWith<$Res> {
  factory _$$VerificationDocumentImplCopyWith(_$VerificationDocumentImpl value,
          $Res Function(_$VerificationDocumentImpl) then) =
      __$$VerificationDocumentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      VerificationStatus status,
      String? referenceNumber,
      String? notes,
      String? fileUrl});
}

/// @nodoc
class __$$VerificationDocumentImplCopyWithImpl<$Res>
    extends _$VerificationDocumentCopyWithImpl<$Res, _$VerificationDocumentImpl>
    implements _$$VerificationDocumentImplCopyWith<$Res> {
  __$$VerificationDocumentImplCopyWithImpl(_$VerificationDocumentImpl _value,
      $Res Function(_$VerificationDocumentImpl) _then)
      : super(_value, _then);

  /// Create a copy of VerificationDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? status = null,
    Object? referenceNumber = freezed,
    Object? notes = freezed,
    Object? fileUrl = freezed,
  }) {
    return _then(_$VerificationDocumentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as VerificationStatus,
      referenceNumber: freezed == referenceNumber
          ? _value.referenceNumber
          : referenceNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      fileUrl: freezed == fileUrl
          ? _value.fileUrl
          : fileUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VerificationDocumentImpl implements _VerificationDocument {
  const _$VerificationDocumentImpl(
      {required this.id,
      required this.type,
      this.status = VerificationStatus.pending,
      this.referenceNumber,
      this.notes,
      this.fileUrl});

  factory _$VerificationDocumentImpl.fromJson(Map<String, dynamic> json) =>
      _$$VerificationDocumentImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
// e.g., 'Aadhaar Card', 'PAN Card', 'Police Verification'
  @override
  @JsonKey()
  final VerificationStatus status;
  @override
  final String? referenceNumber;
// e.g., '1234-5678-9012'
  @override
  final String? notes;
  @override
  final String? fileUrl;

  @override
  String toString() {
    return 'VerificationDocument(id: $id, type: $type, status: $status, referenceNumber: $referenceNumber, notes: $notes, fileUrl: $fileUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerificationDocumentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.referenceNumber, referenceNumber) ||
                other.referenceNumber == referenceNumber) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, type, status, referenceNumber, notes, fileUrl);

  /// Create a copy of VerificationDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VerificationDocumentImplCopyWith<_$VerificationDocumentImpl>
      get copyWith =>
          __$$VerificationDocumentImplCopyWithImpl<_$VerificationDocumentImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VerificationDocumentImplToJson(
      this,
    );
  }
}

abstract class _VerificationDocument implements VerificationDocument {
  const factory _VerificationDocument(
      {required final String id,
      required final String type,
      final VerificationStatus status,
      final String? referenceNumber,
      final String? notes,
      final String? fileUrl}) = _$VerificationDocumentImpl;

  factory _VerificationDocument.fromJson(Map<String, dynamic> json) =
      _$VerificationDocumentImpl.fromJson;

  @override
  String get id;
  @override
  String get type; // e.g., 'Aadhaar Card', 'PAN Card', 'Police Verification'
  @override
  VerificationStatus get status;
  @override
  String? get referenceNumber; // e.g., '1234-5678-9012'
  @override
  String? get notes;
  @override
  String? get fileUrl;

  /// Create a copy of VerificationDocument
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VerificationDocumentImplCopyWith<_$VerificationDocumentImpl>
      get copyWith => throw _privateConstructorUsedError;
}
