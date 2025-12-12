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
  int get id => throw _privateConstructorUsedError;
  int get houseId => throw _privateConstructorUsedError;
  int get unitId => throw _privateConstructorUsedError;
  String get tenantCode => throw _privateConstructorUsedError; // for login
  String get name => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  TenantStatus get status => throw _privateConstructorUsedError;
  double get openingBalance => throw _privateConstructorUsedError;
  double? get agreedRent => throw _privateConstructorUsedError;
  String? get password => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get authId =>
      throw _privateConstructorUsedError; // Firebase Auth UID for secure login
  String get ownerId => throw _privateConstructorUsedError;

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
      {int id,
      int houseId,
      int unitId,
      String tenantCode,
      String name,
      String phone,
      String? email,
      DateTime startDate,
      TenantStatus status,
      double openingBalance,
      double? agreedRent,
      String? password,
      String? imageUrl,
      String? authId,
      String ownerId});
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
    Object? houseId = null,
    Object? unitId = null,
    Object? tenantCode = null,
    Object? name = null,
    Object? phone = null,
    Object? email = freezed,
    Object? startDate = null,
    Object? status = null,
    Object? openingBalance = null,
    Object? agreedRent = freezed,
    Object? password = freezed,
    Object? imageUrl = freezed,
    Object? authId = freezed,
    Object? ownerId = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      houseId: null == houseId
          ? _value.houseId
          : houseId // ignore: cast_nullable_to_non_nullable
              as int,
      unitId: null == unitId
          ? _value.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as int,
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
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TenantStatus,
      openingBalance: null == openingBalance
          ? _value.openingBalance
          : openingBalance // ignore: cast_nullable_to_non_nullable
              as double,
      agreedRent: freezed == agreedRent
          ? _value.agreedRent
          : agreedRent // ignore: cast_nullable_to_non_nullable
              as double?,
      password: freezed == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      authId: freezed == authId
          ? _value.authId
          : authId // ignore: cast_nullable_to_non_nullable
              as String?,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
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
      {int id,
      int houseId,
      int unitId,
      String tenantCode,
      String name,
      String phone,
      String? email,
      DateTime startDate,
      TenantStatus status,
      double openingBalance,
      double? agreedRent,
      String? password,
      String? imageUrl,
      String? authId,
      String ownerId});
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
    Object? houseId = null,
    Object? unitId = null,
    Object? tenantCode = null,
    Object? name = null,
    Object? phone = null,
    Object? email = freezed,
    Object? startDate = null,
    Object? status = null,
    Object? openingBalance = null,
    Object? agreedRent = freezed,
    Object? password = freezed,
    Object? imageUrl = freezed,
    Object? authId = freezed,
    Object? ownerId = null,
  }) {
    return _then(_$TenantImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      houseId: null == houseId
          ? _value.houseId
          : houseId // ignore: cast_nullable_to_non_nullable
              as int,
      unitId: null == unitId
          ? _value.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as int,
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
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TenantStatus,
      openingBalance: null == openingBalance
          ? _value.openingBalance
          : openingBalance // ignore: cast_nullable_to_non_nullable
              as double,
      agreedRent: freezed == agreedRent
          ? _value.agreedRent
          : agreedRent // ignore: cast_nullable_to_non_nullable
              as double?,
      password: freezed == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      authId: freezed == authId
          ? _value.authId
          : authId // ignore: cast_nullable_to_non_nullable
              as String?,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TenantImpl implements _Tenant {
  const _$TenantImpl(
      {required this.id,
      required this.houseId,
      required this.unitId,
      required this.tenantCode,
      required this.name,
      required this.phone,
      this.email,
      required this.startDate,
      required this.status,
      this.openingBalance = 0.0,
      this.agreedRent,
      this.password,
      this.imageUrl,
      this.authId,
      required this.ownerId});

  factory _$TenantImpl.fromJson(Map<String, dynamic> json) =>
      _$$TenantImplFromJson(json);

  @override
  final int id;
  @override
  final int houseId;
  @override
  final int unitId;
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
  final DateTime startDate;
  @override
  final TenantStatus status;
  @override
  @JsonKey()
  final double openingBalance;
  @override
  final double? agreedRent;
  @override
  final String? password;
  @override
  final String? imageUrl;
  @override
  final String? authId;
// Firebase Auth UID for secure login
  @override
  final String ownerId;

  @override
  String toString() {
    return 'Tenant(id: $id, houseId: $houseId, unitId: $unitId, tenantCode: $tenantCode, name: $name, phone: $phone, email: $email, startDate: $startDate, status: $status, openingBalance: $openingBalance, agreedRent: $agreedRent, password: $password, imageUrl: $imageUrl, authId: $authId, ownerId: $ownerId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TenantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.houseId, houseId) || other.houseId == houseId) &&
            (identical(other.unitId, unitId) || other.unitId == unitId) &&
            (identical(other.tenantCode, tenantCode) ||
                other.tenantCode == tenantCode) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.openingBalance, openingBalance) ||
                other.openingBalance == openingBalance) &&
            (identical(other.agreedRent, agreedRent) ||
                other.agreedRent == agreedRent) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.authId, authId) || other.authId == authId) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      houseId,
      unitId,
      tenantCode,
      name,
      phone,
      email,
      startDate,
      status,
      openingBalance,
      agreedRent,
      password,
      imageUrl,
      authId,
      ownerId);

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
      {required final int id,
      required final int houseId,
      required final int unitId,
      required final String tenantCode,
      required final String name,
      required final String phone,
      final String? email,
      required final DateTime startDate,
      required final TenantStatus status,
      final double openingBalance,
      final double? agreedRent,
      final String? password,
      final String? imageUrl,
      final String? authId,
      required final String ownerId}) = _$TenantImpl;

  factory _Tenant.fromJson(Map<String, dynamic> json) = _$TenantImpl.fromJson;

  @override
  int get id;
  @override
  int get houseId;
  @override
  int get unitId;
  @override
  String get tenantCode; // for login
  @override
  String get name;
  @override
  String get phone;
  @override
  String? get email;
  @override
  DateTime get startDate;
  @override
  TenantStatus get status;
  @override
  double get openingBalance;
  @override
  double? get agreedRent;
  @override
  String? get password;
  @override
  String? get imageUrl;
  @override
  String? get authId; // Firebase Auth UID for secure login
  @override
  String get ownerId;

  /// Create a copy of Tenant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TenantImplCopyWith<_$TenantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
