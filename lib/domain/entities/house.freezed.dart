// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'house.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

House _$HouseFromJson(Map<String, dynamic> json) {
  return _House.fromJson(json);
}

/// @nodoc
mixin _$House {
  String get id => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get imageBase64 =>
      throw _privateConstructorUsedError; // NEW: Base64 storage
  String get propertyType =>
      throw _privateConstructorUsedError; // NEW: 'Apartment', 'Hostel', 'PG'
  int get unitCount => throw _privateConstructorUsedError;

  /// Serializes this House to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of House
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HouseCopyWith<House> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HouseCopyWith<$Res> {
  factory $HouseCopyWith(House value, $Res Function(House) then) =
      _$HouseCopyWithImpl<$Res, House>;
  @useResult
  $Res call(
      {String id,
      String ownerId,
      String name,
      String address,
      String? notes,
      String? imageUrl,
      String? imageBase64,
      String propertyType,
      int unitCount});
}

/// @nodoc
class _$HouseCopyWithImpl<$Res, $Val extends House>
    implements $HouseCopyWith<$Res> {
  _$HouseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of House
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? name = null,
    Object? address = null,
    Object? notes = freezed,
    Object? imageUrl = freezed,
    Object? imageBase64 = freezed,
    Object? propertyType = null,
    Object? unitCount = null,
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
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      imageBase64: freezed == imageBase64
          ? _value.imageBase64
          : imageBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      propertyType: null == propertyType
          ? _value.propertyType
          : propertyType // ignore: cast_nullable_to_non_nullable
              as String,
      unitCount: null == unitCount
          ? _value.unitCount
          : unitCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HouseImplCopyWith<$Res> implements $HouseCopyWith<$Res> {
  factory _$$HouseImplCopyWith(
          _$HouseImpl value, $Res Function(_$HouseImpl) then) =
      __$$HouseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String ownerId,
      String name,
      String address,
      String? notes,
      String? imageUrl,
      String? imageBase64,
      String propertyType,
      int unitCount});
}

/// @nodoc
class __$$HouseImplCopyWithImpl<$Res>
    extends _$HouseCopyWithImpl<$Res, _$HouseImpl>
    implements _$$HouseImplCopyWith<$Res> {
  __$$HouseImplCopyWithImpl(
      _$HouseImpl _value, $Res Function(_$HouseImpl) _then)
      : super(_value, _then);

  /// Create a copy of House
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? name = null,
    Object? address = null,
    Object? notes = freezed,
    Object? imageUrl = freezed,
    Object? imageBase64 = freezed,
    Object? propertyType = null,
    Object? unitCount = null,
  }) {
    return _then(_$HouseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      imageBase64: freezed == imageBase64
          ? _value.imageBase64
          : imageBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      propertyType: null == propertyType
          ? _value.propertyType
          : propertyType // ignore: cast_nullable_to_non_nullable
              as String,
      unitCount: null == unitCount
          ? _value.unitCount
          : unitCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HouseImpl implements _House {
  const _$HouseImpl(
      {required this.id,
      required this.ownerId,
      required this.name,
      required this.address,
      this.notes,
      this.imageUrl,
      this.imageBase64,
      this.propertyType = 'Apartment',
      this.unitCount = 0});

  factory _$HouseImpl.fromJson(Map<String, dynamic> json) =>
      _$$HouseImplFromJson(json);

  @override
  final String id;
  @override
  final String ownerId;
  @override
  final String name;
  @override
  final String address;
  @override
  final String? notes;
  @override
  final String? imageUrl;
  @override
  final String? imageBase64;
// NEW: Base64 storage
  @override
  @JsonKey()
  final String propertyType;
// NEW: 'Apartment', 'Hostel', 'PG'
  @override
  @JsonKey()
  final int unitCount;

  @override
  String toString() {
    return 'House(id: $id, ownerId: $ownerId, name: $name, address: $address, notes: $notes, imageUrl: $imageUrl, imageBase64: $imageBase64, propertyType: $propertyType, unitCount: $unitCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HouseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.imageBase64, imageBase64) ||
                other.imageBase64 == imageBase64) &&
            (identical(other.propertyType, propertyType) ||
                other.propertyType == propertyType) &&
            (identical(other.unitCount, unitCount) ||
                other.unitCount == unitCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, ownerId, name, address,
      notes, imageUrl, imageBase64, propertyType, unitCount);

  /// Create a copy of House
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HouseImplCopyWith<_$HouseImpl> get copyWith =>
      __$$HouseImplCopyWithImpl<_$HouseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HouseImplToJson(
      this,
    );
  }
}

abstract class _House implements House {
  const factory _House(
      {required final String id,
      required final String ownerId,
      required final String name,
      required final String address,
      final String? notes,
      final String? imageUrl,
      final String? imageBase64,
      final String propertyType,
      final int unitCount}) = _$HouseImpl;

  factory _House.fromJson(Map<String, dynamic> json) = _$HouseImpl.fromJson;

  @override
  String get id;
  @override
  String get ownerId;
  @override
  String get name;
  @override
  String get address;
  @override
  String? get notes;
  @override
  String? get imageUrl;
  @override
  String? get imageBase64; // NEW: Base64 storage
  @override
  String get propertyType; // NEW: 'Apartment', 'Hostel', 'PG'
  @override
  int get unitCount;

  /// Create a copy of House
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HouseImplCopyWith<_$HouseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Unit _$UnitFromJson(Map<String, dynamic> json) {
  return _Unit.fromJson(json);
}

/// @nodoc
mixin _$Unit {
  String get id => throw _privateConstructorUsedError;
  String get houseId => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError;
  String get nameOrNumber => throw _privateConstructorUsedError;
  int? get floor => throw _privateConstructorUsedError;
  double get baseRent =>
      throw _privateConstructorUsedError; // NEW Fields for BHK
  String? get bhkTemplateId => throw _privateConstructorUsedError;
  String? get bhkType => throw _privateConstructorUsedError;
  double? get editableRent => throw _privateConstructorUsedError;
  String? get currentTenancyId =>
      throw _privateConstructorUsedError; // Replaces tenantId
// Advanced Details
  String? get furnishingStatus => throw _privateConstructorUsedError;
  double? get carpetArea => throw _privateConstructorUsedError;
  String? get parkingSlot => throw _privateConstructorUsedError;
  String? get meterNumber => throw _privateConstructorUsedError;
  int get defaultDueDay => throw _privateConstructorUsedError;
  bool get isOccupied =>
      throw _privateConstructorUsedError; // NEW: Image Upload Support (Max 4 images)
  List<String> get imageUrls => throw _privateConstructorUsedError;
  List<String> get imagesBase64 => throw _privateConstructorUsedError;

  /// Serializes this Unit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Unit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UnitCopyWith<Unit> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UnitCopyWith<$Res> {
  factory $UnitCopyWith(Unit value, $Res Function(Unit) then) =
      _$UnitCopyWithImpl<$Res, Unit>;
  @useResult
  $Res call(
      {String id,
      String houseId,
      String ownerId,
      String nameOrNumber,
      int? floor,
      double baseRent,
      String? bhkTemplateId,
      String? bhkType,
      double? editableRent,
      String? currentTenancyId,
      String? furnishingStatus,
      double? carpetArea,
      String? parkingSlot,
      String? meterNumber,
      int defaultDueDay,
      bool isOccupied,
      List<String> imageUrls,
      List<String> imagesBase64});
}

/// @nodoc
class _$UnitCopyWithImpl<$Res, $Val extends Unit>
    implements $UnitCopyWith<$Res> {
  _$UnitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Unit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? houseId = null,
    Object? ownerId = null,
    Object? nameOrNumber = null,
    Object? floor = freezed,
    Object? baseRent = null,
    Object? bhkTemplateId = freezed,
    Object? bhkType = freezed,
    Object? editableRent = freezed,
    Object? currentTenancyId = freezed,
    Object? furnishingStatus = freezed,
    Object? carpetArea = freezed,
    Object? parkingSlot = freezed,
    Object? meterNumber = freezed,
    Object? defaultDueDay = null,
    Object? isOccupied = null,
    Object? imageUrls = null,
    Object? imagesBase64 = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      houseId: null == houseId
          ? _value.houseId
          : houseId // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      nameOrNumber: null == nameOrNumber
          ? _value.nameOrNumber
          : nameOrNumber // ignore: cast_nullable_to_non_nullable
              as String,
      floor: freezed == floor
          ? _value.floor
          : floor // ignore: cast_nullable_to_non_nullable
              as int?,
      baseRent: null == baseRent
          ? _value.baseRent
          : baseRent // ignore: cast_nullable_to_non_nullable
              as double,
      bhkTemplateId: freezed == bhkTemplateId
          ? _value.bhkTemplateId
          : bhkTemplateId // ignore: cast_nullable_to_non_nullable
              as String?,
      bhkType: freezed == bhkType
          ? _value.bhkType
          : bhkType // ignore: cast_nullable_to_non_nullable
              as String?,
      editableRent: freezed == editableRent
          ? _value.editableRent
          : editableRent // ignore: cast_nullable_to_non_nullable
              as double?,
      currentTenancyId: freezed == currentTenancyId
          ? _value.currentTenancyId
          : currentTenancyId // ignore: cast_nullable_to_non_nullable
              as String?,
      furnishingStatus: freezed == furnishingStatus
          ? _value.furnishingStatus
          : furnishingStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      carpetArea: freezed == carpetArea
          ? _value.carpetArea
          : carpetArea // ignore: cast_nullable_to_non_nullable
              as double?,
      parkingSlot: freezed == parkingSlot
          ? _value.parkingSlot
          : parkingSlot // ignore: cast_nullable_to_non_nullable
              as String?,
      meterNumber: freezed == meterNumber
          ? _value.meterNumber
          : meterNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultDueDay: null == defaultDueDay
          ? _value.defaultDueDay
          : defaultDueDay // ignore: cast_nullable_to_non_nullable
              as int,
      isOccupied: null == isOccupied
          ? _value.isOccupied
          : isOccupied // ignore: cast_nullable_to_non_nullable
              as bool,
      imageUrls: null == imageUrls
          ? _value.imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      imagesBase64: null == imagesBase64
          ? _value.imagesBase64
          : imagesBase64 // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UnitImplCopyWith<$Res> implements $UnitCopyWith<$Res> {
  factory _$$UnitImplCopyWith(
          _$UnitImpl value, $Res Function(_$UnitImpl) then) =
      __$$UnitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String houseId,
      String ownerId,
      String nameOrNumber,
      int? floor,
      double baseRent,
      String? bhkTemplateId,
      String? bhkType,
      double? editableRent,
      String? currentTenancyId,
      String? furnishingStatus,
      double? carpetArea,
      String? parkingSlot,
      String? meterNumber,
      int defaultDueDay,
      bool isOccupied,
      List<String> imageUrls,
      List<String> imagesBase64});
}

/// @nodoc
class __$$UnitImplCopyWithImpl<$Res>
    extends _$UnitCopyWithImpl<$Res, _$UnitImpl>
    implements _$$UnitImplCopyWith<$Res> {
  __$$UnitImplCopyWithImpl(_$UnitImpl _value, $Res Function(_$UnitImpl) _then)
      : super(_value, _then);

  /// Create a copy of Unit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? houseId = null,
    Object? ownerId = null,
    Object? nameOrNumber = null,
    Object? floor = freezed,
    Object? baseRent = null,
    Object? bhkTemplateId = freezed,
    Object? bhkType = freezed,
    Object? editableRent = freezed,
    Object? currentTenancyId = freezed,
    Object? furnishingStatus = freezed,
    Object? carpetArea = freezed,
    Object? parkingSlot = freezed,
    Object? meterNumber = freezed,
    Object? defaultDueDay = null,
    Object? isOccupied = null,
    Object? imageUrls = null,
    Object? imagesBase64 = null,
  }) {
    return _then(_$UnitImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      houseId: null == houseId
          ? _value.houseId
          : houseId // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      nameOrNumber: null == nameOrNumber
          ? _value.nameOrNumber
          : nameOrNumber // ignore: cast_nullable_to_non_nullable
              as String,
      floor: freezed == floor
          ? _value.floor
          : floor // ignore: cast_nullable_to_non_nullable
              as int?,
      baseRent: null == baseRent
          ? _value.baseRent
          : baseRent // ignore: cast_nullable_to_non_nullable
              as double,
      bhkTemplateId: freezed == bhkTemplateId
          ? _value.bhkTemplateId
          : bhkTemplateId // ignore: cast_nullable_to_non_nullable
              as String?,
      bhkType: freezed == bhkType
          ? _value.bhkType
          : bhkType // ignore: cast_nullable_to_non_nullable
              as String?,
      editableRent: freezed == editableRent
          ? _value.editableRent
          : editableRent // ignore: cast_nullable_to_non_nullable
              as double?,
      currentTenancyId: freezed == currentTenancyId
          ? _value.currentTenancyId
          : currentTenancyId // ignore: cast_nullable_to_non_nullable
              as String?,
      furnishingStatus: freezed == furnishingStatus
          ? _value.furnishingStatus
          : furnishingStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      carpetArea: freezed == carpetArea
          ? _value.carpetArea
          : carpetArea // ignore: cast_nullable_to_non_nullable
              as double?,
      parkingSlot: freezed == parkingSlot
          ? _value.parkingSlot
          : parkingSlot // ignore: cast_nullable_to_non_nullable
              as String?,
      meterNumber: freezed == meterNumber
          ? _value.meterNumber
          : meterNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultDueDay: null == defaultDueDay
          ? _value.defaultDueDay
          : defaultDueDay // ignore: cast_nullable_to_non_nullable
              as int,
      isOccupied: null == isOccupied
          ? _value.isOccupied
          : isOccupied // ignore: cast_nullable_to_non_nullable
              as bool,
      imageUrls: null == imageUrls
          ? _value._imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      imagesBase64: null == imagesBase64
          ? _value._imagesBase64
          : imagesBase64 // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UnitImpl implements _Unit {
  const _$UnitImpl(
      {required this.id,
      required this.houseId,
      required this.ownerId,
      required this.nameOrNumber,
      this.floor,
      required this.baseRent,
      this.bhkTemplateId,
      this.bhkType,
      this.editableRent,
      this.currentTenancyId,
      this.furnishingStatus,
      this.carpetArea,
      this.parkingSlot,
      this.meterNumber,
      this.defaultDueDay = 1,
      this.isOccupied = false,
      final List<String> imageUrls = const [],
      final List<String> imagesBase64 = const []})
      : _imageUrls = imageUrls,
        _imagesBase64 = imagesBase64;

  factory _$UnitImpl.fromJson(Map<String, dynamic> json) =>
      _$$UnitImplFromJson(json);

  @override
  final String id;
  @override
  final String houseId;
  @override
  final String ownerId;
  @override
  final String nameOrNumber;
  @override
  final int? floor;
  @override
  final double baseRent;
// NEW Fields for BHK
  @override
  final String? bhkTemplateId;
  @override
  final String? bhkType;
  @override
  final double? editableRent;
  @override
  final String? currentTenancyId;
// Replaces tenantId
// Advanced Details
  @override
  final String? furnishingStatus;
  @override
  final double? carpetArea;
  @override
  final String? parkingSlot;
  @override
  final String? meterNumber;
  @override
  @JsonKey()
  final int defaultDueDay;
  @override
  @JsonKey()
  final bool isOccupied;
// NEW: Image Upload Support (Max 4 images)
  final List<String> _imageUrls;
// NEW: Image Upload Support (Max 4 images)
  @override
  @JsonKey()
  List<String> get imageUrls {
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageUrls);
  }

  final List<String> _imagesBase64;
  @override
  @JsonKey()
  List<String> get imagesBase64 {
    if (_imagesBase64 is EqualUnmodifiableListView) return _imagesBase64;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imagesBase64);
  }

  @override
  String toString() {
    return 'Unit(id: $id, houseId: $houseId, ownerId: $ownerId, nameOrNumber: $nameOrNumber, floor: $floor, baseRent: $baseRent, bhkTemplateId: $bhkTemplateId, bhkType: $bhkType, editableRent: $editableRent, currentTenancyId: $currentTenancyId, furnishingStatus: $furnishingStatus, carpetArea: $carpetArea, parkingSlot: $parkingSlot, meterNumber: $meterNumber, defaultDueDay: $defaultDueDay, isOccupied: $isOccupied, imageUrls: $imageUrls, imagesBase64: $imagesBase64)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnitImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.houseId, houseId) || other.houseId == houseId) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.nameOrNumber, nameOrNumber) ||
                other.nameOrNumber == nameOrNumber) &&
            (identical(other.floor, floor) || other.floor == floor) &&
            (identical(other.baseRent, baseRent) ||
                other.baseRent == baseRent) &&
            (identical(other.bhkTemplateId, bhkTemplateId) ||
                other.bhkTemplateId == bhkTemplateId) &&
            (identical(other.bhkType, bhkType) || other.bhkType == bhkType) &&
            (identical(other.editableRent, editableRent) ||
                other.editableRent == editableRent) &&
            (identical(other.currentTenancyId, currentTenancyId) ||
                other.currentTenancyId == currentTenancyId) &&
            (identical(other.furnishingStatus, furnishingStatus) ||
                other.furnishingStatus == furnishingStatus) &&
            (identical(other.carpetArea, carpetArea) ||
                other.carpetArea == carpetArea) &&
            (identical(other.parkingSlot, parkingSlot) ||
                other.parkingSlot == parkingSlot) &&
            (identical(other.meterNumber, meterNumber) ||
                other.meterNumber == meterNumber) &&
            (identical(other.defaultDueDay, defaultDueDay) ||
                other.defaultDueDay == defaultDueDay) &&
            (identical(other.isOccupied, isOccupied) ||
                other.isOccupied == isOccupied) &&
            const DeepCollectionEquality()
                .equals(other._imageUrls, _imageUrls) &&
            const DeepCollectionEquality()
                .equals(other._imagesBase64, _imagesBase64));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      houseId,
      ownerId,
      nameOrNumber,
      floor,
      baseRent,
      bhkTemplateId,
      bhkType,
      editableRent,
      currentTenancyId,
      furnishingStatus,
      carpetArea,
      parkingSlot,
      meterNumber,
      defaultDueDay,
      isOccupied,
      const DeepCollectionEquality().hash(_imageUrls),
      const DeepCollectionEquality().hash(_imagesBase64));

  /// Create a copy of Unit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnitImplCopyWith<_$UnitImpl> get copyWith =>
      __$$UnitImplCopyWithImpl<_$UnitImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UnitImplToJson(
      this,
    );
  }
}

abstract class _Unit implements Unit {
  const factory _Unit(
      {required final String id,
      required final String houseId,
      required final String ownerId,
      required final String nameOrNumber,
      final int? floor,
      required final double baseRent,
      final String? bhkTemplateId,
      final String? bhkType,
      final double? editableRent,
      final String? currentTenancyId,
      final String? furnishingStatus,
      final double? carpetArea,
      final String? parkingSlot,
      final String? meterNumber,
      final int defaultDueDay,
      final bool isOccupied,
      final List<String> imageUrls,
      final List<String> imagesBase64}) = _$UnitImpl;

  factory _Unit.fromJson(Map<String, dynamic> json) = _$UnitImpl.fromJson;

  @override
  String get id;
  @override
  String get houseId;
  @override
  String get ownerId;
  @override
  String get nameOrNumber;
  @override
  int? get floor;
  @override
  double get baseRent; // NEW Fields for BHK
  @override
  String? get bhkTemplateId;
  @override
  String? get bhkType;
  @override
  double? get editableRent;
  @override
  String? get currentTenancyId; // Replaces tenantId
// Advanced Details
  @override
  String? get furnishingStatus;
  @override
  double? get carpetArea;
  @override
  String? get parkingSlot;
  @override
  String? get meterNumber;
  @override
  int get defaultDueDay;
  @override
  bool get isOccupied; // NEW: Image Upload Support (Max 4 images)
  @override
  List<String> get imageUrls;
  @override
  List<String> get imagesBase64;

  /// Create a copy of Unit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnitImplCopyWith<_$UnitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
