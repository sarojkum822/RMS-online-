// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'owner.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Owner _$OwnerFromJson(Map<String, dynamic> json) {
  return _Owner.fromJson(json);
}

/// @nodoc
mixin _$Owner {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get firestoreId => throw _privateConstructorUsedError; // NEW
  String get subscriptionPlan =>
      throw _privateConstructorUsedError; // 'free', 'pro', 'power'
  String get currency => throw _privateConstructorUsedError;
  String? get timezone => throw _privateConstructorUsedError;
  String? get upiId =>
      throw _privateConstructorUsedError; // NEW: Payment destination
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Owner to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Owner
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OwnerCopyWith<Owner> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OwnerCopyWith<$Res> {
  factory $OwnerCopyWith(Owner value, $Res Function(Owner) then) =
      _$OwnerCopyWithImpl<$Res, Owner>;
  @useResult
  $Res call(
      {int id,
      String name,
      String? phone,
      String? email,
      String? firestoreId,
      String subscriptionPlan,
      String currency,
      String? timezone,
      String? upiId,
      DateTime? createdAt});
}

/// @nodoc
class _$OwnerCopyWithImpl<$Res, $Val extends Owner>
    implements $OwnerCopyWith<$Res> {
  _$OwnerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Owner
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = freezed,
    Object? email = freezed,
    Object? firestoreId = freezed,
    Object? subscriptionPlan = null,
    Object? currency = null,
    Object? timezone = freezed,
    Object? upiId = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      firestoreId: freezed == firestoreId
          ? _value.firestoreId
          : firestoreId // ignore: cast_nullable_to_non_nullable
              as String?,
      subscriptionPlan: null == subscriptionPlan
          ? _value.subscriptionPlan
          : subscriptionPlan // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      timezone: freezed == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String?,
      upiId: freezed == upiId
          ? _value.upiId
          : upiId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OwnerImplCopyWith<$Res> implements $OwnerCopyWith<$Res> {
  factory _$$OwnerImplCopyWith(
          _$OwnerImpl value, $Res Function(_$OwnerImpl) then) =
      __$$OwnerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String? phone,
      String? email,
      String? firestoreId,
      String subscriptionPlan,
      String currency,
      String? timezone,
      String? upiId,
      DateTime? createdAt});
}

/// @nodoc
class __$$OwnerImplCopyWithImpl<$Res>
    extends _$OwnerCopyWithImpl<$Res, _$OwnerImpl>
    implements _$$OwnerImplCopyWith<$Res> {
  __$$OwnerImplCopyWithImpl(
      _$OwnerImpl _value, $Res Function(_$OwnerImpl) _then)
      : super(_value, _then);

  /// Create a copy of Owner
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? phone = freezed,
    Object? email = freezed,
    Object? firestoreId = freezed,
    Object? subscriptionPlan = null,
    Object? currency = null,
    Object? timezone = freezed,
    Object? upiId = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$OwnerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      firestoreId: freezed == firestoreId
          ? _value.firestoreId
          : firestoreId // ignore: cast_nullable_to_non_nullable
              as String?,
      subscriptionPlan: null == subscriptionPlan
          ? _value.subscriptionPlan
          : subscriptionPlan // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      timezone: freezed == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String?,
      upiId: freezed == upiId
          ? _value.upiId
          : upiId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OwnerImpl implements _Owner {
  const _$OwnerImpl(
      {required this.id,
      required this.name,
      this.phone,
      this.email,
      this.firestoreId,
      this.subscriptionPlan = 'free',
      this.currency = 'INR',
      this.timezone,
      this.upiId,
      this.createdAt});

  factory _$OwnerImpl.fromJson(Map<String, dynamic> json) =>
      _$$OwnerImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  final String? firestoreId;
// NEW
  @override
  @JsonKey()
  final String subscriptionPlan;
// 'free', 'pro', 'power'
  @override
  @JsonKey()
  final String currency;
  @override
  final String? timezone;
  @override
  final String? upiId;
// NEW: Payment destination
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Owner(id: $id, name: $name, phone: $phone, email: $email, firestoreId: $firestoreId, subscriptionPlan: $subscriptionPlan, currency: $currency, timezone: $timezone, upiId: $upiId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OwnerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.firestoreId, firestoreId) ||
                other.firestoreId == firestoreId) &&
            (identical(other.subscriptionPlan, subscriptionPlan) ||
                other.subscriptionPlan == subscriptionPlan) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.upiId, upiId) || other.upiId == upiId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, phone, email,
      firestoreId, subscriptionPlan, currency, timezone, upiId, createdAt);

  /// Create a copy of Owner
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OwnerImplCopyWith<_$OwnerImpl> get copyWith =>
      __$$OwnerImplCopyWithImpl<_$OwnerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OwnerImplToJson(
      this,
    );
  }
}

abstract class _Owner implements Owner {
  const factory _Owner(
      {required final int id,
      required final String name,
      final String? phone,
      final String? email,
      final String? firestoreId,
      final String subscriptionPlan,
      final String currency,
      final String? timezone,
      final String? upiId,
      final DateTime? createdAt}) = _$OwnerImpl;

  factory _Owner.fromJson(Map<String, dynamic> json) = _$OwnerImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  String? get firestoreId; // NEW
  @override
  String get subscriptionPlan; // 'free', 'pro', 'power'
  @override
  String get currency;
  @override
  String? get timezone;
  @override
  String? get upiId; // NEW: Payment destination
  @override
  DateTime? get createdAt;

  /// Create a copy of Owner
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OwnerImplCopyWith<_$OwnerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ElectricReading _$ElectricReadingFromJson(Map<String, dynamic> json) {
  return _ElectricReading.fromJson(json);
}

/// @nodoc
mixin _$ElectricReading {
  int get id => throw _privateConstructorUsedError;
  int get unitId => throw _privateConstructorUsedError;
  DateTime get readingDate => throw _privateConstructorUsedError;
  String? get meterName => throw _privateConstructorUsedError;
  double get prevReading => throw _privateConstructorUsedError;
  double get currentReading => throw _privateConstructorUsedError;
  double get ratePerUnit => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this ElectricReading to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ElectricReading
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ElectricReadingCopyWith<ElectricReading> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ElectricReadingCopyWith<$Res> {
  factory $ElectricReadingCopyWith(
          ElectricReading value, $Res Function(ElectricReading) then) =
      _$ElectricReadingCopyWithImpl<$Res, ElectricReading>;
  @useResult
  $Res call(
      {int id,
      int unitId,
      DateTime readingDate,
      String? meterName,
      double prevReading,
      double currentReading,
      double ratePerUnit,
      double amount,
      String? notes});
}

/// @nodoc
class _$ElectricReadingCopyWithImpl<$Res, $Val extends ElectricReading>
    implements $ElectricReadingCopyWith<$Res> {
  _$ElectricReadingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ElectricReading
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? unitId = null,
    Object? readingDate = null,
    Object? meterName = freezed,
    Object? prevReading = null,
    Object? currentReading = null,
    Object? ratePerUnit = null,
    Object? amount = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      unitId: null == unitId
          ? _value.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as int,
      readingDate: null == readingDate
          ? _value.readingDate
          : readingDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      meterName: freezed == meterName
          ? _value.meterName
          : meterName // ignore: cast_nullable_to_non_nullable
              as String?,
      prevReading: null == prevReading
          ? _value.prevReading
          : prevReading // ignore: cast_nullable_to_non_nullable
              as double,
      currentReading: null == currentReading
          ? _value.currentReading
          : currentReading // ignore: cast_nullable_to_non_nullable
              as double,
      ratePerUnit: null == ratePerUnit
          ? _value.ratePerUnit
          : ratePerUnit // ignore: cast_nullable_to_non_nullable
              as double,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ElectricReadingImplCopyWith<$Res>
    implements $ElectricReadingCopyWith<$Res> {
  factory _$$ElectricReadingImplCopyWith(_$ElectricReadingImpl value,
          $Res Function(_$ElectricReadingImpl) then) =
      __$$ElectricReadingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int unitId,
      DateTime readingDate,
      String? meterName,
      double prevReading,
      double currentReading,
      double ratePerUnit,
      double amount,
      String? notes});
}

/// @nodoc
class __$$ElectricReadingImplCopyWithImpl<$Res>
    extends _$ElectricReadingCopyWithImpl<$Res, _$ElectricReadingImpl>
    implements _$$ElectricReadingImplCopyWith<$Res> {
  __$$ElectricReadingImplCopyWithImpl(
      _$ElectricReadingImpl _value, $Res Function(_$ElectricReadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of ElectricReading
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? unitId = null,
    Object? readingDate = null,
    Object? meterName = freezed,
    Object? prevReading = null,
    Object? currentReading = null,
    Object? ratePerUnit = null,
    Object? amount = null,
    Object? notes = freezed,
  }) {
    return _then(_$ElectricReadingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      unitId: null == unitId
          ? _value.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as int,
      readingDate: null == readingDate
          ? _value.readingDate
          : readingDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      meterName: freezed == meterName
          ? _value.meterName
          : meterName // ignore: cast_nullable_to_non_nullable
              as String?,
      prevReading: null == prevReading
          ? _value.prevReading
          : prevReading // ignore: cast_nullable_to_non_nullable
              as double,
      currentReading: null == currentReading
          ? _value.currentReading
          : currentReading // ignore: cast_nullable_to_non_nullable
              as double,
      ratePerUnit: null == ratePerUnit
          ? _value.ratePerUnit
          : ratePerUnit // ignore: cast_nullable_to_non_nullable
              as double,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ElectricReadingImpl implements _ElectricReading {
  const _$ElectricReadingImpl(
      {required this.id,
      required this.unitId,
      required this.readingDate,
      this.meterName,
      this.prevReading = 0.0,
      required this.currentReading,
      this.ratePerUnit = 0.0,
      required this.amount,
      this.notes});

  factory _$ElectricReadingImpl.fromJson(Map<String, dynamic> json) =>
      _$$ElectricReadingImplFromJson(json);

  @override
  final int id;
  @override
  final int unitId;
  @override
  final DateTime readingDate;
  @override
  final String? meterName;
  @override
  @JsonKey()
  final double prevReading;
  @override
  final double currentReading;
  @override
  @JsonKey()
  final double ratePerUnit;
  @override
  final double amount;
  @override
  final String? notes;

  @override
  String toString() {
    return 'ElectricReading(id: $id, unitId: $unitId, readingDate: $readingDate, meterName: $meterName, prevReading: $prevReading, currentReading: $currentReading, ratePerUnit: $ratePerUnit, amount: $amount, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ElectricReadingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.unitId, unitId) || other.unitId == unitId) &&
            (identical(other.readingDate, readingDate) ||
                other.readingDate == readingDate) &&
            (identical(other.meterName, meterName) ||
                other.meterName == meterName) &&
            (identical(other.prevReading, prevReading) ||
                other.prevReading == prevReading) &&
            (identical(other.currentReading, currentReading) ||
                other.currentReading == currentReading) &&
            (identical(other.ratePerUnit, ratePerUnit) ||
                other.ratePerUnit == ratePerUnit) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, unitId, readingDate,
      meterName, prevReading, currentReading, ratePerUnit, amount, notes);

  /// Create a copy of ElectricReading
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ElectricReadingImplCopyWith<_$ElectricReadingImpl> get copyWith =>
      __$$ElectricReadingImplCopyWithImpl<_$ElectricReadingImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ElectricReadingImplToJson(
      this,
    );
  }
}

abstract class _ElectricReading implements ElectricReading {
  const factory _ElectricReading(
      {required final int id,
      required final int unitId,
      required final DateTime readingDate,
      final String? meterName,
      final double prevReading,
      required final double currentReading,
      final double ratePerUnit,
      required final double amount,
      final String? notes}) = _$ElectricReadingImpl;

  factory _ElectricReading.fromJson(Map<String, dynamic> json) =
      _$ElectricReadingImpl.fromJson;

  @override
  int get id;
  @override
  int get unitId;
  @override
  DateTime get readingDate;
  @override
  String? get meterName;
  @override
  double get prevReading;
  @override
  double get currentReading;
  @override
  double get ratePerUnit;
  @override
  double get amount;
  @override
  String? get notes;

  /// Create a copy of ElectricReading
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ElectricReadingImplCopyWith<_$ElectricReadingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
