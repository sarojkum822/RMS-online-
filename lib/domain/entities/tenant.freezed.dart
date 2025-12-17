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
  String? get password => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get imageBase64 =>
      throw _privateConstructorUsedError; // NEW: Base64 Storage
  String? get authId => throw _privateConstructorUsedError;

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
      String? password,
      String? imageUrl,
      String? imageBase64,
      String? authId});
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
    Object? password = freezed,
    Object? imageUrl = freezed,
    Object? imageBase64 = freezed,
    Object? authId = freezed,
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
      password: freezed == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String?,
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
      String? password,
      String? imageUrl,
      String? imageBase64,
      String? authId});
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
    Object? password = freezed,
    Object? imageUrl = freezed,
    Object? imageBase64 = freezed,
    Object? authId = freezed,
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
      password: freezed == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String?,
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
      this.password,
      this.imageUrl,
      this.imageBase64,
      this.authId});

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
  final String? password;
  @override
  final String? imageUrl;
  @override
  final String? imageBase64;
// NEW: Base64 Storage
  @override
  final String? authId;

  @override
  String toString() {
    return 'Tenant(id: $id, tenantCode: $tenantCode, name: $name, phone: $phone, email: $email, ownerId: $ownerId, isActive: $isActive, password: $password, imageUrl: $imageUrl, imageBase64: $imageBase64, authId: $authId)';
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
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.imageBase64, imageBase64) ||
                other.imageBase64 == imageBase64) &&
            (identical(other.authId, authId) || other.authId == authId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, tenantCode, name, phone,
      email, ownerId, isActive, password, imageUrl, imageBase64, authId);

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
      final String? password,
      final String? imageUrl,
      final String? imageBase64,
      final String? authId}) = _$TenantImpl;

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
  String? get password;
  @override
  String? get imageUrl;
  @override
  String? get imageBase64; // NEW: Base64 Storage
  @override
  String? get authId;

  /// Create a copy of Tenant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TenantImplCopyWith<_$TenantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
