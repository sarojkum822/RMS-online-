// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tenant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Tenant _$TenantFromJson(Map<String, dynamic> json) {
  return _Tenant.fromJson(json);
}

/// @nodoc
mixin _$Tenant {
  String get id => throw _privateConstructorUsedError;
  String get tenantCode => throw _privateConstructorUsedError; // for login
  String get name => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String get ownerId =>
      throw _privateConstructorUsedError; // NEW: Needed for fetching payments
  bool get isActive => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get imageBase64 =>
      throw _privateConstructorUsedError; // NEW: Base64 Storage
  String? get authId =>
      throw _privateConstructorUsedError; // Firebase Auth UID for secure login
  double get advanceAmount => throw _privateConstructorUsedError;
  bool get policeVerification => throw _privateConstructorUsedError;
  String? get idProof => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get dob => throw _privateConstructorUsedError; // NEW
  String? get gender => throw _privateConstructorUsedError; // NEW
  int get memberCount => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this Tenant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Tenant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TenantCopyWith<Tenant> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TenantCopyWith<$Res> {
  factory $TenantCopyWith(Tenant value, $Res Function(Tenant) then) =
      _$TenantCopyWithImpl<$Res, Tenant>;
  @useResult
  $Res call(
      {String id,
      String tenantCode,
      String name,
      String phone,
      String? email,
      String ownerId,
      bool isActive,
      String? imageUrl,
      String? imageBase64,
      String? authId,
      double advanceAmount,
      bool policeVerification,
      String? idProof,
      String? address,
      String? dob,
      String? gender,
      int memberCount,
      String? notes});
}

/// @nodoc
class _$TenantCopyWithImpl<$Res, $Val extends Tenant>
    implements $TenantCopyWith<$Res> {
  _$TenantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Tenant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantCode = null,
    Object? name = null,
    Object? phone = null,
    Object? email = freezed,
    Object? ownerId = null,
    Object? isActive = null,
    Object? imageUrl = freezed,
    Object? imageBase64 = freezed,
    Object? authId = freezed,
    Object? advanceAmount = null,
    Object? policeVerification = null,
    Object? idProof = freezed,
    Object? address = freezed,
    Object? dob = freezed,
    Object? gender = freezed,
    Object? memberCount = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantCode: null == tenantCode
          ? _value.tenantCode
          : tenantCode // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      imageBase64: freezed == imageBase64
          ? _value.imageBase64
          : imageBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      authId: freezed == authId
          ? _value.authId
          : authId // ignore: cast_nullable_to_non_nullable
              as String?,
      advanceAmount: null == advanceAmount
          ? _value.advanceAmount
          : advanceAmount // ignore: cast_nullable_to_non_nullable
              as double,
      policeVerification: null == policeVerification
          ? _value.policeVerification
          : policeVerification // ignore: cast_nullable_to_non_nullable
              as bool,
      idProof: freezed == idProof
          ? _value.idProof
          : idProof // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      dob: freezed == dob
          ? _value.dob
          : dob // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      memberCount: null == memberCount
          ? _value.memberCount
          : memberCount // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TenantImplCopyWith<$Res> implements $TenantCopyWith<$Res> {
  factory _$$TenantImplCopyWith(
          _$TenantImpl value, $Res Function(_$TenantImpl) then) =
      __$$TenantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tenantCode,
      String name,
      String phone,
      String? email,
      String ownerId,
      bool isActive,
      String? imageUrl,
      String? imageBase64,
      String? authId,
      double advanceAmount,
      bool policeVerification,
      String? idProof,
      String? address,
      String? dob,
      String? gender,
      int memberCount,
      String? notes});
}

/// @nodoc
class __$$TenantImplCopyWithImpl<$Res>
    extends _$TenantCopyWithImpl<$Res, _$TenantImpl>
    implements _$$TenantImplCopyWith<$Res> {
  __$$TenantImplCopyWithImpl(
      _$TenantImpl _value, $Res Function(_$TenantImpl) _then)
      : super(_value, _then);

  /// Create a copy of Tenant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantCode = null,
    Object? name = null,
    Object? phone = null,
    Object? email = freezed,
    Object? ownerId = null,
    Object? isActive = null,
    Object? imageUrl = freezed,
    Object? imageBase64 = freezed,
    Object? authId = freezed,
    Object? advanceAmount = null,
    Object? policeVerification = null,
    Object? idProof = freezed,
    Object? address = freezed,
    Object? dob = freezed,
    Object? gender = freezed,
    Object? memberCount = null,
    Object? notes = freezed,
  }) {
    return _then(_$TenantImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantCode: null == tenantCode
          ? _value.tenantCode
          : tenantCode // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      imageBase64: freezed == imageBase64
          ? _value.imageBase64
          : imageBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      authId: freezed == authId
          ? _value.authId
          : authId // ignore: cast_nullable_to_non_nullable
              as String?,
      advanceAmount: null == advanceAmount
          ? _value.advanceAmount
          : advanceAmount // ignore: cast_nullable_to_non_nullable
              as double,
      policeVerification: null == policeVerification
          ? _value.policeVerification
          : policeVerification // ignore: cast_nullable_to_non_nullable
              as bool,
      idProof: freezed == idProof
          ? _value.idProof
          : idProof // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      dob: freezed == dob
          ? _value.dob
          : dob // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      memberCount: null == memberCount
          ? _value.memberCount
          : memberCount // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TenantImpl implements _Tenant {
  const _$TenantImpl(
      {required this.id,
      required this.tenantCode,
      required this.name,
      required this.phone,
      this.email,
      required this.ownerId,
      this.isActive = true,
      this.imageUrl,
      this.imageBase64,
      this.authId,
      this.advanceAmount = 0.0,
      this.policeVerification = false,
      this.idProof,
      this.address,
      this.dob,
      this.gender,
      this.memberCount = 1,
      this.notes});

  factory _$TenantImpl.fromJson(Map<String, dynamic> json) =>
      _$$TenantImplFromJson(json);

  @override
  final String id;
  @override
  final String tenantCode;
// for login
  @override
  final String name;
  @override
  final String phone;
  @override
  final String? email;
  @override
  final String ownerId;
// NEW: Needed for fetching payments
  @override
  @JsonKey()
  final bool isActive;
  @override
  final String? imageUrl;
  @override
  final String? imageBase64;
// NEW: Base64 Storage
  @override
  final String? authId;
// Firebase Auth UID for secure login
  @override
  @JsonKey()
  final double advanceAmount;
  @override
  @JsonKey()
  final bool policeVerification;
  @override
  final String? idProof;
  @override
  final String? address;
  @override
  final String? dob;
// NEW
  @override
  final String? gender;
// NEW
  @override
  @JsonKey()
  final int memberCount;
  @override
  final String? notes;

  @override
  String toString() {
    return 'Tenant(id: $id, tenantCode: $tenantCode, name: $name, phone: $phone, email: $email, ownerId: $ownerId, isActive: $isActive, imageUrl: $imageUrl, imageBase64: $imageBase64, authId: $authId, advanceAmount: $advanceAmount, policeVerification: $policeVerification, idProof: $idProof, address: $address, dob: $dob, gender: $gender, memberCount: $memberCount, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TenantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantCode, tenantCode) ||
                other.tenantCode == tenantCode) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.imageBase64, imageBase64) ||
                other.imageBase64 == imageBase64) &&
            (identical(other.authId, authId) || other.authId == authId) &&
            (identical(other.advanceAmount, advanceAmount) ||
                other.advanceAmount == advanceAmount) &&
            (identical(other.policeVerification, policeVerification) ||
                other.policeVerification == policeVerification) &&
            (identical(other.idProof, idProof) || other.idProof == idProof) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.dob, dob) || other.dob == dob) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.memberCount, memberCount) ||
                other.memberCount == memberCount) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tenantCode,
      name,
      phone,
      email,
      ownerId,
      isActive,
      imageUrl,
      imageBase64,
      authId,
      advanceAmount,
      policeVerification,
      idProof,
      address,
      dob,
      gender,
      memberCount,
      notes);

  /// Create a copy of Tenant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TenantImplCopyWith<_$TenantImpl> get copyWith =>
      __$$TenantImplCopyWithImpl<_$TenantImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TenantImplToJson(
      this,
    );
  }
}

abstract class _Tenant implements Tenant {
  const factory _Tenant(
      {required final String id,
      required final String tenantCode,
      required final String name,
      required final String phone,
      final String? email,
      required final String ownerId,
      final bool isActive,
      final String? imageUrl,
      final String? imageBase64,
      final String? authId,
      final double advanceAmount,
      final bool policeVerification,
      final String? idProof,
      final String? address,
      final String? dob,
      final String? gender,
      final int memberCount,
      final String? notes}) = _$TenantImpl;

  factory _Tenant.fromJson(Map<String, dynamic> json) = _$TenantImpl.fromJson;

  @override
  String get id;
  @override
  String get tenantCode; // for login
  @override
  String get name;
  @override
  String get phone;
  @override
  String? get email;
  @override
  String get ownerId; // NEW: Needed for fetching payments
  @override
  bool get isActive;
  @override
  String? get imageUrl;
  @override
  String? get imageBase64; // NEW: Base64 Storage
  @override
  String? get authId; // Firebase Auth UID for secure login
  @override
  double get advanceAmount;
  @override
  bool get policeVerification;
  @override
  String? get idProof;
  @override
  String? get address;
  @override
  String? get dob; // NEW
  @override
  String? get gender; // NEW
  @override
  int get memberCount;
  @override
  String? get notes;

  /// Create a copy of Tenant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TenantImplCopyWith<_$TenantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
