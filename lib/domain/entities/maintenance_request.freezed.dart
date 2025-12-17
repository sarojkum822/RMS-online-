// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'maintenance_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MaintenanceRequest _$MaintenanceRequestFromJson(Map<String, dynamic> json) {
  return _MaintenanceRequest.fromJson(json);
}

/// @nodoc
mixin _$MaintenanceRequest {
  String get id => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError;
  String get pId => throw _privateConstructorUsedError; // Property ID
  String get unitId => throw _privateConstructorUsedError;
  String get tenantId => throw _privateConstructorUsedError;
  String get category =>
      throw _privateConstructorUsedError; // Plumbing, Electrical, etc.
  String get description => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  MaintenanceStatus get status => throw _privateConstructorUsedError;
  double? get cost =>
      throw _privateConstructorUsedError; // Optional cost tracking
  String? get resolutionNotes => throw _privateConstructorUsedError;

  /// Serializes this MaintenanceRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MaintenanceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MaintenanceRequestCopyWith<MaintenanceRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MaintenanceRequestCopyWith<$Res> {
  factory $MaintenanceRequestCopyWith(
          MaintenanceRequest value, $Res Function(MaintenanceRequest) then) =
      _$MaintenanceRequestCopyWithImpl<$Res, MaintenanceRequest>;
  @useResult
  $Res call(
      {String id,
      String ownerId,
      String pId,
      String unitId,
      String tenantId,
      String category,
      String description,
      String? photoUrl,
      DateTime date,
      MaintenanceStatus status,
      double? cost,
      String? resolutionNotes});
}

/// @nodoc
class _$MaintenanceRequestCopyWithImpl<$Res, $Val extends MaintenanceRequest>
    implements $MaintenanceRequestCopyWith<$Res> {
  _$MaintenanceRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MaintenanceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? pId = null,
    Object? unitId = null,
    Object? tenantId = null,
    Object? category = null,
    Object? description = null,
    Object? photoUrl = freezed,
    Object? date = null,
    Object? status = null,
    Object? cost = freezed,
    Object? resolutionNotes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      pId: null == pId
          ? _value.pId
          : pId // ignore: cast_nullable_to_non_nullable
              as String,
      unitId: null == unitId
          ? _value.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MaintenanceStatus,
      cost: freezed == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double?,
      resolutionNotes: freezed == resolutionNotes
          ? _value.resolutionNotes
          : resolutionNotes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MaintenanceRequestImplCopyWith<$Res>
    implements $MaintenanceRequestCopyWith<$Res> {
  factory _$$MaintenanceRequestImplCopyWith(_$MaintenanceRequestImpl value,
          $Res Function(_$MaintenanceRequestImpl) then) =
      __$$MaintenanceRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String ownerId,
      String pId,
      String unitId,
      String tenantId,
      String category,
      String description,
      String? photoUrl,
      DateTime date,
      MaintenanceStatus status,
      double? cost,
      String? resolutionNotes});
}

/// @nodoc
class __$$MaintenanceRequestImplCopyWithImpl<$Res>
    extends _$MaintenanceRequestCopyWithImpl<$Res, _$MaintenanceRequestImpl>
    implements _$$MaintenanceRequestImplCopyWith<$Res> {
  __$$MaintenanceRequestImplCopyWithImpl(_$MaintenanceRequestImpl _value,
      $Res Function(_$MaintenanceRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of MaintenanceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? pId = null,
    Object? unitId = null,
    Object? tenantId = null,
    Object? category = null,
    Object? description = null,
    Object? photoUrl = freezed,
    Object? date = null,
    Object? status = null,
    Object? cost = freezed,
    Object? resolutionNotes = freezed,
  }) {
    return _then(_$MaintenanceRequestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      pId: null == pId
          ? _value.pId
          : pId // ignore: cast_nullable_to_non_nullable
              as String,
      unitId: null == unitId
          ? _value.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MaintenanceStatus,
      cost: freezed == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double?,
      resolutionNotes: freezed == resolutionNotes
          ? _value.resolutionNotes
          : resolutionNotes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MaintenanceRequestImpl implements _MaintenanceRequest {
  const _$MaintenanceRequestImpl(
      {required this.id,
      required this.ownerId,
      required this.pId,
      required this.unitId,
      required this.tenantId,
      required this.category,
      required this.description,
      this.photoUrl,
      required this.date,
      required this.status,
      this.cost,
      this.resolutionNotes});

  factory _$MaintenanceRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$MaintenanceRequestImplFromJson(json);

  @override
  final String id;
  @override
  final String ownerId;
  @override
  final String pId;
// Property ID
  @override
  final String unitId;
  @override
  final String tenantId;
  @override
  final String category;
// Plumbing, Electrical, etc.
  @override
  final String description;
  @override
  final String? photoUrl;
  @override
  final DateTime date;
  @override
  final MaintenanceStatus status;
  @override
  final double? cost;
// Optional cost tracking
  @override
  final String? resolutionNotes;

  @override
  String toString() {
    return 'MaintenanceRequest(id: $id, ownerId: $ownerId, pId: $pId, unitId: $unitId, tenantId: $tenantId, category: $category, description: $description, photoUrl: $photoUrl, date: $date, status: $status, cost: $cost, resolutionNotes: $resolutionNotes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MaintenanceRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.pId, pId) || other.pId == pId) &&
            (identical(other.unitId, unitId) || other.unitId == unitId) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.cost, cost) || other.cost == cost) &&
            (identical(other.resolutionNotes, resolutionNotes) ||
                other.resolutionNotes == resolutionNotes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      ownerId,
      pId,
      unitId,
      tenantId,
      category,
      description,
      photoUrl,
      date,
      status,
      cost,
      resolutionNotes);

  /// Create a copy of MaintenanceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MaintenanceRequestImplCopyWith<_$MaintenanceRequestImpl> get copyWith =>
      __$$MaintenanceRequestImplCopyWithImpl<_$MaintenanceRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MaintenanceRequestImplToJson(
      this,
    );
  }
}

abstract class _MaintenanceRequest implements MaintenanceRequest {
  const factory _MaintenanceRequest(
      {required final String id,
      required final String ownerId,
      required final String pId,
      required final String unitId,
      required final String tenantId,
      required final String category,
      required final String description,
      final String? photoUrl,
      required final DateTime date,
      required final MaintenanceStatus status,
      final double? cost,
      final String? resolutionNotes}) = _$MaintenanceRequestImpl;

  factory _MaintenanceRequest.fromJson(Map<String, dynamic> json) =
      _$MaintenanceRequestImpl.fromJson;

  @override
  String get id;
  @override
  String get ownerId;
  @override
  String get pId; // Property ID
  @override
  String get unitId;
  @override
  String get tenantId;
  @override
  String get category; // Plumbing, Electrical, etc.
  @override
  String get description;
  @override
  String? get photoUrl;
  @override
  DateTime get date;
  @override
  MaintenanceStatus get status;
  @override
  double? get cost; // Optional cost tracking
  @override
  String? get resolutionNotes;

  /// Create a copy of MaintenanceRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MaintenanceRequestImplCopyWith<_$MaintenanceRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
