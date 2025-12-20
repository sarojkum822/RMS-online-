// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tenancy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Tenancy _$TenancyFromJson(Map<String, dynamic> json) {
  return _Tenancy.fromJson(json);
}

/// @nodoc
mixin _$Tenancy {
  String get id => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  String get unitId => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError; // Scope security
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  double get agreedRent => throw _privateConstructorUsedError;
  double get securityDeposit => throw _privateConstructorUsedError;
  double get openingBalance => throw _privateConstructorUsedError;
  TenancyStatus get status => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this Tenancy to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Tenancy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TenancyCopyWith<Tenancy> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TenancyCopyWith<$Res> {
  factory $TenancyCopyWith(Tenancy value, $Res Function(Tenancy) then) =
      _$TenancyCopyWithImpl<$Res, Tenancy>;
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String unitId,
      String ownerId,
      DateTime startDate,
      DateTime? endDate,
      double agreedRent,
      double securityDeposit,
      double openingBalance,
      TenancyStatus status,
      String? notes});
}

/// @nodoc
class _$TenancyCopyWithImpl<$Res, $Val extends Tenancy>
    implements $TenancyCopyWith<$Res> {
  _$TenancyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Tenancy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? unitId = null,
    Object? ownerId = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? agreedRent = null,
    Object? securityDeposit = null,
    Object? openingBalance = null,
    Object? status = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      unitId: null == unitId
          ? _value.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      agreedRent: null == agreedRent
          ? _value.agreedRent
          : agreedRent // ignore: cast_nullable_to_non_nullable
              as double,
      securityDeposit: null == securityDeposit
          ? _value.securityDeposit
          : securityDeposit // ignore: cast_nullable_to_non_nullable
              as double,
      openingBalance: null == openingBalance
          ? _value.openingBalance
          : openingBalance // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TenancyStatus,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TenancyImplCopyWith<$Res> implements $TenancyCopyWith<$Res> {
  factory _$$TenancyImplCopyWith(
          _$TenancyImpl value, $Res Function(_$TenancyImpl) then) =
      __$$TenancyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String unitId,
      String ownerId,
      DateTime startDate,
      DateTime? endDate,
      double agreedRent,
      double securityDeposit,
      double openingBalance,
      TenancyStatus status,
      String? notes});
}

/// @nodoc
class __$$TenancyImplCopyWithImpl<$Res>
    extends _$TenancyCopyWithImpl<$Res, _$TenancyImpl>
    implements _$$TenancyImplCopyWith<$Res> {
  __$$TenancyImplCopyWithImpl(
      _$TenancyImpl _value, $Res Function(_$TenancyImpl) _then)
      : super(_value, _then);

  /// Create a copy of Tenancy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? unitId = null,
    Object? ownerId = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? agreedRent = null,
    Object? securityDeposit = null,
    Object? openingBalance = null,
    Object? status = null,
    Object? notes = freezed,
  }) {
    return _then(_$TenancyImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      unitId: null == unitId
          ? _value.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      agreedRent: null == agreedRent
          ? _value.agreedRent
          : agreedRent // ignore: cast_nullable_to_non_nullable
              as double,
      securityDeposit: null == securityDeposit
          ? _value.securityDeposit
          : securityDeposit // ignore: cast_nullable_to_non_nullable
              as double,
      openingBalance: null == openingBalance
          ? _value.openingBalance
          : openingBalance // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TenancyStatus,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TenancyImpl implements _Tenancy {
  const _$TenancyImpl(
      {required this.id,
      required this.tenantId,
      required this.unitId,
      required this.ownerId,
      required this.startDate,
      this.endDate,
      required this.agreedRent,
      this.securityDeposit = 0.0,
      this.openingBalance = 0.0,
      required this.status,
      this.notes});

  factory _$TenancyImpl.fromJson(Map<String, dynamic> json) =>
      _$$TenancyImplFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String unitId;
  @override
  final String ownerId;
// Scope security
  @override
  final DateTime startDate;
  @override
  final DateTime? endDate;
  @override
  final double agreedRent;
  @override
  @JsonKey()
  final double securityDeposit;
  @override
  @JsonKey()
  final double openingBalance;
  @override
  final TenancyStatus status;
  @override
  final String? notes;

  @override
  String toString() {
    return 'Tenancy(id: $id, tenantId: $tenantId, unitId: $unitId, ownerId: $ownerId, startDate: $startDate, endDate: $endDate, agreedRent: $agreedRent, securityDeposit: $securityDeposit, openingBalance: $openingBalance, status: $status, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TenancyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.unitId, unitId) || other.unitId == unitId) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.agreedRent, agreedRent) ||
                other.agreedRent == agreedRent) &&
            (identical(other.securityDeposit, securityDeposit) ||
                other.securityDeposit == securityDeposit) &&
            (identical(other.openingBalance, openingBalance) ||
                other.openingBalance == openingBalance) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tenantId,
      unitId,
      ownerId,
      startDate,
      endDate,
      agreedRent,
      securityDeposit,
      openingBalance,
      status,
      notes);

  /// Create a copy of Tenancy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TenancyImplCopyWith<_$TenancyImpl> get copyWith =>
      __$$TenancyImplCopyWithImpl<_$TenancyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TenancyImplToJson(
      this,
    );
  }
}

abstract class _Tenancy implements Tenancy {
  const factory _Tenancy(
      {required final String id,
      required final String tenantId,
      required final String unitId,
      required final String ownerId,
      required final DateTime startDate,
      final DateTime? endDate,
      required final double agreedRent,
      final double securityDeposit,
      final double openingBalance,
      required final TenancyStatus status,
      final String? notes}) = _$TenancyImpl;

  factory _Tenancy.fromJson(Map<String, dynamic> json) = _$TenancyImpl.fromJson;

  @override
  String get id;
  @override
  String get tenantId;
  @override
  String get unitId;
  @override
  String get ownerId; // Scope security
  @override
  DateTime get startDate;
  @override
  DateTime? get endDate;
  @override
  double get agreedRent;
  @override
  double get securityDeposit;
  @override
  double get openingBalance;
  @override
  TenancyStatus get status;
  @override
  String? get notes;

  /// Create a copy of Tenancy
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TenancyImplCopyWith<_$TenancyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
