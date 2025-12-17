// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rent_cycle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RentCycle _$RentCycleFromJson(Map<String, dynamic> json) {
  return _RentCycle.fromJson(json);
}

/// @nodoc
mixin _$RentCycle {
  String get id => throw _privateConstructorUsedError; // UUID
  String get tenancyId => throw _privateConstructorUsedError; // Link to Tenancy
  String get ownerId => throw _privateConstructorUsedError;
  String get month => throw _privateConstructorUsedError; // Format: YYYY-MM
  String? get billNumber => throw _privateConstructorUsedError;
  DateTime? get billPeriodStart => throw _privateConstructorUsedError;
  DateTime? get billPeriodEnd => throw _privateConstructorUsedError;
  DateTime get billGeneratedDate => throw _privateConstructorUsedError;
  double get baseRent => throw _privateConstructorUsedError;
  double get electricAmount => throw _privateConstructorUsedError;
  double get otherCharges => throw _privateConstructorUsedError;
  double get lateFee =>
      throw _privateConstructorUsedError; // [NEW] Track late fees explicitly
  double get discount => throw _privateConstructorUsedError;
  double get totalDue => throw _privateConstructorUsedError;
  double get totalPaid => throw _privateConstructorUsedError;
  RentStatus get status => throw _privateConstructorUsedError;
  DateTime? get dueDate => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this RentCycle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RentCycle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RentCycleCopyWith<RentCycle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RentCycleCopyWith<$Res> {
  factory $RentCycleCopyWith(RentCycle value, $Res Function(RentCycle) then) =
      _$RentCycleCopyWithImpl<$Res, RentCycle>;
  @useResult
  $Res call(
      {String id,
      String tenancyId,
      String ownerId,
      String month,
      String? billNumber,
      DateTime? billPeriodStart,
      DateTime? billPeriodEnd,
      DateTime billGeneratedDate,
      double baseRent,
      double electricAmount,
      double otherCharges,
      double lateFee,
      double discount,
      double totalDue,
      double totalPaid,
      RentStatus status,
      DateTime? dueDate,
      String? notes});
}

/// @nodoc
class _$RentCycleCopyWithImpl<$Res, $Val extends RentCycle>
    implements $RentCycleCopyWith<$Res> {
  _$RentCycleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RentCycle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenancyId = null,
    Object? ownerId = null,
    Object? month = null,
    Object? billNumber = freezed,
    Object? billPeriodStart = freezed,
    Object? billPeriodEnd = freezed,
    Object? billGeneratedDate = null,
    Object? baseRent = null,
    Object? electricAmount = null,
    Object? otherCharges = null,
    Object? lateFee = null,
    Object? discount = null,
    Object? totalDue = null,
    Object? totalPaid = null,
    Object? status = null,
    Object? dueDate = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenancyId: null == tenancyId
          ? _value.tenancyId
          : tenancyId // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as String,
      billNumber: freezed == billNumber
          ? _value.billNumber
          : billNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      billPeriodStart: freezed == billPeriodStart
          ? _value.billPeriodStart
          : billPeriodStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      billPeriodEnd: freezed == billPeriodEnd
          ? _value.billPeriodEnd
          : billPeriodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      billGeneratedDate: null == billGeneratedDate
          ? _value.billGeneratedDate
          : billGeneratedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      baseRent: null == baseRent
          ? _value.baseRent
          : baseRent // ignore: cast_nullable_to_non_nullable
              as double,
      electricAmount: null == electricAmount
          ? _value.electricAmount
          : electricAmount // ignore: cast_nullable_to_non_nullable
              as double,
      otherCharges: null == otherCharges
          ? _value.otherCharges
          : otherCharges // ignore: cast_nullable_to_non_nullable
              as double,
      lateFee: null == lateFee
          ? _value.lateFee
          : lateFee // ignore: cast_nullable_to_non_nullable
              as double,
      discount: null == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double,
      totalDue: null == totalDue
          ? _value.totalDue
          : totalDue // ignore: cast_nullable_to_non_nullable
              as double,
      totalPaid: null == totalPaid
          ? _value.totalPaid
          : totalPaid // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RentStatus,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RentCycleImplCopyWith<$Res>
    implements $RentCycleCopyWith<$Res> {
  factory _$$RentCycleImplCopyWith(
          _$RentCycleImpl value, $Res Function(_$RentCycleImpl) then) =
      __$$RentCycleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tenancyId,
      String ownerId,
      String month,
      String? billNumber,
      DateTime? billPeriodStart,
      DateTime? billPeriodEnd,
      DateTime billGeneratedDate,
      double baseRent,
      double electricAmount,
      double otherCharges,
      double lateFee,
      double discount,
      double totalDue,
      double totalPaid,
      RentStatus status,
      DateTime? dueDate,
      String? notes});
}

/// @nodoc
class __$$RentCycleImplCopyWithImpl<$Res>
    extends _$RentCycleCopyWithImpl<$Res, _$RentCycleImpl>
    implements _$$RentCycleImplCopyWith<$Res> {
  __$$RentCycleImplCopyWithImpl(
      _$RentCycleImpl _value, $Res Function(_$RentCycleImpl) _then)
      : super(_value, _then);

  /// Create a copy of RentCycle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenancyId = null,
    Object? ownerId = null,
    Object? month = null,
    Object? billNumber = freezed,
    Object? billPeriodStart = freezed,
    Object? billPeriodEnd = freezed,
    Object? billGeneratedDate = null,
    Object? baseRent = null,
    Object? electricAmount = null,
    Object? otherCharges = null,
    Object? lateFee = null,
    Object? discount = null,
    Object? totalDue = null,
    Object? totalPaid = null,
    Object? status = null,
    Object? dueDate = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$RentCycleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenancyId: null == tenancyId
          ? _value.tenancyId
          : tenancyId // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as String,
      billNumber: freezed == billNumber
          ? _value.billNumber
          : billNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      billPeriodStart: freezed == billPeriodStart
          ? _value.billPeriodStart
          : billPeriodStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      billPeriodEnd: freezed == billPeriodEnd
          ? _value.billPeriodEnd
          : billPeriodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      billGeneratedDate: null == billGeneratedDate
          ? _value.billGeneratedDate
          : billGeneratedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      baseRent: null == baseRent
          ? _value.baseRent
          : baseRent // ignore: cast_nullable_to_non_nullable
              as double,
      electricAmount: null == electricAmount
          ? _value.electricAmount
          : electricAmount // ignore: cast_nullable_to_non_nullable
              as double,
      otherCharges: null == otherCharges
          ? _value.otherCharges
          : otherCharges // ignore: cast_nullable_to_non_nullable
              as double,
      lateFee: null == lateFee
          ? _value.lateFee
          : lateFee // ignore: cast_nullable_to_non_nullable
              as double,
      discount: null == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double,
      totalDue: null == totalDue
          ? _value.totalDue
          : totalDue // ignore: cast_nullable_to_non_nullable
              as double,
      totalPaid: null == totalPaid
          ? _value.totalPaid
          : totalPaid // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RentStatus,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RentCycleImpl implements _RentCycle {
  const _$RentCycleImpl(
      {required this.id,
      required this.tenancyId,
      required this.ownerId,
      required this.month,
      this.billNumber,
      this.billPeriodStart,
      this.billPeriodEnd,
      required this.billGeneratedDate,
      required this.baseRent,
      this.electricAmount = 0.0,
      this.otherCharges = 0.0,
      this.lateFee = 0.0,
      this.discount = 0.0,
      required this.totalDue,
      this.totalPaid = 0.0,
      this.status = RentStatus.pending,
      this.dueDate,
      this.notes});

  factory _$RentCycleImpl.fromJson(Map<String, dynamic> json) =>
      _$$RentCycleImplFromJson(json);

  @override
  final String id;
// UUID
  @override
  final String tenancyId;
// Link to Tenancy
  @override
  final String ownerId;
  @override
  final String month;
// Format: YYYY-MM
  @override
  final String? billNumber;
  @override
  final DateTime? billPeriodStart;
  @override
  final DateTime? billPeriodEnd;
  @override
  final DateTime billGeneratedDate;
  @override
  final double baseRent;
  @override
  @JsonKey()
  final double electricAmount;
  @override
  @JsonKey()
  final double otherCharges;
  @override
  @JsonKey()
  final double lateFee;
// [NEW] Track late fees explicitly
  @override
  @JsonKey()
  final double discount;
  @override
  final double totalDue;
  @override
  @JsonKey()
  final double totalPaid;
  @override
  @JsonKey()
  final RentStatus status;
  @override
  final DateTime? dueDate;
  @override
  final String? notes;

  @override
  String toString() {
    return 'RentCycle(id: $id, tenancyId: $tenancyId, ownerId: $ownerId, month: $month, billNumber: $billNumber, billPeriodStart: $billPeriodStart, billPeriodEnd: $billPeriodEnd, billGeneratedDate: $billGeneratedDate, baseRent: $baseRent, electricAmount: $electricAmount, otherCharges: $otherCharges, lateFee: $lateFee, discount: $discount, totalDue: $totalDue, totalPaid: $totalPaid, status: $status, dueDate: $dueDate, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RentCycleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenancyId, tenancyId) ||
                other.tenancyId == tenancyId) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.billNumber, billNumber) ||
                other.billNumber == billNumber) &&
            (identical(other.billPeriodStart, billPeriodStart) ||
                other.billPeriodStart == billPeriodStart) &&
            (identical(other.billPeriodEnd, billPeriodEnd) ||
                other.billPeriodEnd == billPeriodEnd) &&
            (identical(other.billGeneratedDate, billGeneratedDate) ||
                other.billGeneratedDate == billGeneratedDate) &&
            (identical(other.baseRent, baseRent) ||
                other.baseRent == baseRent) &&
            (identical(other.electricAmount, electricAmount) ||
                other.electricAmount == electricAmount) &&
            (identical(other.otherCharges, otherCharges) ||
                other.otherCharges == otherCharges) &&
            (identical(other.lateFee, lateFee) || other.lateFee == lateFee) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            (identical(other.totalDue, totalDue) ||
                other.totalDue == totalDue) &&
            (identical(other.totalPaid, totalPaid) ||
                other.totalPaid == totalPaid) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tenancyId,
      ownerId,
      month,
      billNumber,
      billPeriodStart,
      billPeriodEnd,
      billGeneratedDate,
      baseRent,
      electricAmount,
      otherCharges,
      lateFee,
      discount,
      totalDue,
      totalPaid,
      status,
      dueDate,
      notes);

  /// Create a copy of RentCycle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RentCycleImplCopyWith<_$RentCycleImpl> get copyWith =>
      __$$RentCycleImplCopyWithImpl<_$RentCycleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RentCycleImplToJson(
      this,
    );
  }
}

abstract class _RentCycle implements RentCycle {
  const factory _RentCycle(
      {required final String id,
      required final String tenancyId,
      required final String ownerId,
      required final String month,
      final String? billNumber,
      final DateTime? billPeriodStart,
      final DateTime? billPeriodEnd,
      required final DateTime billGeneratedDate,
      required final double baseRent,
      final double electricAmount,
      final double otherCharges,
      final double lateFee,
      final double discount,
      required final double totalDue,
      final double totalPaid,
      final RentStatus status,
      final DateTime? dueDate,
      final String? notes}) = _$RentCycleImpl;

  factory _RentCycle.fromJson(Map<String, dynamic> json) =
      _$RentCycleImpl.fromJson;

  @override
  String get id; // UUID
  @override
  String get tenancyId; // Link to Tenancy
  @override
  String get ownerId;
  @override
  String get month; // Format: YYYY-MM
  @override
  String? get billNumber;
  @override
  DateTime? get billPeriodStart;
  @override
  DateTime? get billPeriodEnd;
  @override
  DateTime get billGeneratedDate;
  @override
  double get baseRent;
  @override
  double get electricAmount;
  @override
  double get otherCharges;
  @override
  double get lateFee; // [NEW] Track late fees explicitly
  @override
  double get discount;
  @override
  double get totalDue;
  @override
  double get totalPaid;
  @override
  RentStatus get status;
  @override
  DateTime? get dueDate;
  @override
  String? get notes;

  /// Create a copy of RentCycle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RentCycleImplCopyWith<_$RentCycleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Payment _$PaymentFromJson(Map<String, dynamic> json) {
  return _Payment.fromJson(json);
}

/// @nodoc
mixin _$Payment {
  String get id => throw _privateConstructorUsedError;
  String get rentCycleId => throw _privateConstructorUsedError;
  String get tenantId =>
      throw _privateConstructorUsedError; // Or tenancyId? Keeping tenantId generic 'String' for now.
  double get amount => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get method =>
      throw _privateConstructorUsedError; // e.g., 'Cash', 'UPI'
  int? get channelId => throw _privateConstructorUsedError;
  String? get referenceId => throw _privateConstructorUsedError;
  String? get collectedBy => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this Payment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentCopyWith<Payment> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentCopyWith<$Res> {
  factory $PaymentCopyWith(Payment value, $Res Function(Payment) then) =
      _$PaymentCopyWithImpl<$Res, Payment>;
  @useResult
  $Res call(
      {String id,
      String rentCycleId,
      String tenantId,
      double amount,
      DateTime date,
      String method,
      int? channelId,
      String? referenceId,
      String? collectedBy,
      String? notes});
}

/// @nodoc
class _$PaymentCopyWithImpl<$Res, $Val extends Payment>
    implements $PaymentCopyWith<$Res> {
  _$PaymentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rentCycleId = null,
    Object? tenantId = null,
    Object? amount = null,
    Object? date = null,
    Object? method = null,
    Object? channelId = freezed,
    Object? referenceId = freezed,
    Object? collectedBy = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      rentCycleId: null == rentCycleId
          ? _value.rentCycleId
          : rentCycleId // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      channelId: freezed == channelId
          ? _value.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as int?,
      referenceId: freezed == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String?,
      collectedBy: freezed == collectedBy
          ? _value.collectedBy
          : collectedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaymentImplCopyWith<$Res> implements $PaymentCopyWith<$Res> {
  factory _$$PaymentImplCopyWith(
          _$PaymentImpl value, $Res Function(_$PaymentImpl) then) =
      __$$PaymentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String rentCycleId,
      String tenantId,
      double amount,
      DateTime date,
      String method,
      int? channelId,
      String? referenceId,
      String? collectedBy,
      String? notes});
}

/// @nodoc
class __$$PaymentImplCopyWithImpl<$Res>
    extends _$PaymentCopyWithImpl<$Res, _$PaymentImpl>
    implements _$$PaymentImplCopyWith<$Res> {
  __$$PaymentImplCopyWithImpl(
      _$PaymentImpl _value, $Res Function(_$PaymentImpl) _then)
      : super(_value, _then);

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rentCycleId = null,
    Object? tenantId = null,
    Object? amount = null,
    Object? date = null,
    Object? method = null,
    Object? channelId = freezed,
    Object? referenceId = freezed,
    Object? collectedBy = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$PaymentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      rentCycleId: null == rentCycleId
          ? _value.rentCycleId
          : rentCycleId // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _value.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      channelId: freezed == channelId
          ? _value.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as int?,
      referenceId: freezed == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String?,
      collectedBy: freezed == collectedBy
          ? _value.collectedBy
          : collectedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentImpl implements _Payment {
  const _$PaymentImpl(
      {required this.id,
      required this.rentCycleId,
      required this.tenantId,
      required this.amount,
      required this.date,
      required this.method,
      this.channelId,
      this.referenceId,
      this.collectedBy,
      this.notes});

  factory _$PaymentImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentImplFromJson(json);

  @override
  final String id;
  @override
  final String rentCycleId;
  @override
  final String tenantId;
// Or tenancyId? Keeping tenantId generic 'String' for now.
  @override
  final double amount;
  @override
  final DateTime date;
  @override
  final String method;
// e.g., 'Cash', 'UPI'
  @override
  final int? channelId;
  @override
  final String? referenceId;
  @override
  final String? collectedBy;
  @override
  final String? notes;

  @override
  String toString() {
    return 'Payment(id: $id, rentCycleId: $rentCycleId, tenantId: $tenantId, amount: $amount, date: $date, method: $method, channelId: $channelId, referenceId: $referenceId, collectedBy: $collectedBy, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rentCycleId, rentCycleId) ||
                other.rentCycleId == rentCycleId) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.channelId, channelId) ||
                other.channelId == channelId) &&
            (identical(other.referenceId, referenceId) ||
                other.referenceId == referenceId) &&
            (identical(other.collectedBy, collectedBy) ||
                other.collectedBy == collectedBy) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, rentCycleId, tenantId,
      amount, date, method, channelId, referenceId, collectedBy, notes);

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentImplCopyWith<_$PaymentImpl> get copyWith =>
      __$$PaymentImplCopyWithImpl<_$PaymentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentImplToJson(
      this,
    );
  }
}

abstract class _Payment implements Payment {
  const factory _Payment(
      {required final String id,
      required final String rentCycleId,
      required final String tenantId,
      required final double amount,
      required final DateTime date,
      required final String method,
      final int? channelId,
      final String? referenceId,
      final String? collectedBy,
      final String? notes}) = _$PaymentImpl;

  factory _Payment.fromJson(Map<String, dynamic> json) = _$PaymentImpl.fromJson;

  @override
  String get id;
  @override
  String get rentCycleId;
  @override
  String
      get tenantId; // Or tenancyId? Keeping tenantId generic 'String' for now.
  @override
  double get amount;
  @override
  DateTime get date;
  @override
  String get method; // e.g., 'Cash', 'UPI'
  @override
  int? get channelId;
  @override
  String? get referenceId;
  @override
  String? get collectedBy;
  @override
  String? get notes;

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentImplCopyWith<_$PaymentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OtherCharge _$OtherChargeFromJson(Map<String, dynamic> json) {
  return _OtherCharge.fromJson(json);
}

/// @nodoc
mixin _$OtherCharge {
  String get id => throw _privateConstructorUsedError;
  String get rentCycleId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this OtherCharge to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OtherCharge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OtherChargeCopyWith<OtherCharge> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OtherChargeCopyWith<$Res> {
  factory $OtherChargeCopyWith(
          OtherCharge value, $Res Function(OtherCharge) then) =
      _$OtherChargeCopyWithImpl<$Res, OtherCharge>;
  @useResult
  $Res call(
      {String id,
      String rentCycleId,
      double amount,
      String category,
      String? notes});
}

/// @nodoc
class _$OtherChargeCopyWithImpl<$Res, $Val extends OtherCharge>
    implements $OtherChargeCopyWith<$Res> {
  _$OtherChargeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OtherCharge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rentCycleId = null,
    Object? amount = null,
    Object? category = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      rentCycleId: null == rentCycleId
          ? _value.rentCycleId
          : rentCycleId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OtherChargeImplCopyWith<$Res>
    implements $OtherChargeCopyWith<$Res> {
  factory _$$OtherChargeImplCopyWith(
          _$OtherChargeImpl value, $Res Function(_$OtherChargeImpl) then) =
      __$$OtherChargeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String rentCycleId,
      double amount,
      String category,
      String? notes});
}

/// @nodoc
class __$$OtherChargeImplCopyWithImpl<$Res>
    extends _$OtherChargeCopyWithImpl<$Res, _$OtherChargeImpl>
    implements _$$OtherChargeImplCopyWith<$Res> {
  __$$OtherChargeImplCopyWithImpl(
      _$OtherChargeImpl _value, $Res Function(_$OtherChargeImpl) _then)
      : super(_value, _then);

  /// Create a copy of OtherCharge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rentCycleId = null,
    Object? amount = null,
    Object? category = null,
    Object? notes = freezed,
  }) {
    return _then(_$OtherChargeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      rentCycleId: null == rentCycleId
          ? _value.rentCycleId
          : rentCycleId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OtherChargeImpl implements _OtherCharge {
  const _$OtherChargeImpl(
      {required this.id,
      required this.rentCycleId,
      required this.amount,
      required this.category,
      this.notes});

  factory _$OtherChargeImpl.fromJson(Map<String, dynamic> json) =>
      _$$OtherChargeImplFromJson(json);

  @override
  final String id;
  @override
  final String rentCycleId;
  @override
  final double amount;
  @override
  final String category;
  @override
  final String? notes;

  @override
  String toString() {
    return 'OtherCharge(id: $id, rentCycleId: $rentCycleId, amount: $amount, category: $category, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OtherChargeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rentCycleId, rentCycleId) ||
                other.rentCycleId == rentCycleId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, rentCycleId, amount, category, notes);

  /// Create a copy of OtherCharge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OtherChargeImplCopyWith<_$OtherChargeImpl> get copyWith =>
      __$$OtherChargeImplCopyWithImpl<_$OtherChargeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OtherChargeImplToJson(
      this,
    );
  }
}

abstract class _OtherCharge implements OtherCharge {
  const factory _OtherCharge(
      {required final String id,
      required final String rentCycleId,
      required final double amount,
      required final String category,
      final String? notes}) = _$OtherChargeImpl;

  factory _OtherCharge.fromJson(Map<String, dynamic> json) =
      _$OtherChargeImpl.fromJson;

  @override
  String get id;
  @override
  String get rentCycleId;
  @override
  double get amount;
  @override
  String get category;
  @override
  String? get notes;

  /// Create a copy of OtherCharge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OtherChargeImplCopyWith<_$OtherChargeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PaymentChannel _$PaymentChannelFromJson(Map<String, dynamic> json) {
  return _PaymentChannel.fromJson(json);
}

/// @nodoc
mixin _$PaymentChannel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get details => throw _privateConstructorUsedError;

  /// Serializes this PaymentChannel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentChannel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentChannelCopyWith<PaymentChannel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentChannelCopyWith<$Res> {
  factory $PaymentChannelCopyWith(
          PaymentChannel value, $Res Function(PaymentChannel) then) =
      _$PaymentChannelCopyWithImpl<$Res, PaymentChannel>;
  @useResult
  $Res call({int id, String name, String type, String? details});
}

/// @nodoc
class _$PaymentChannelCopyWithImpl<$Res, $Val extends PaymentChannel>
    implements $PaymentChannelCopyWith<$Res> {
  _$PaymentChannelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentChannel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? details = freezed,
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaymentChannelImplCopyWith<$Res>
    implements $PaymentChannelCopyWith<$Res> {
  factory _$$PaymentChannelImplCopyWith(_$PaymentChannelImpl value,
          $Res Function(_$PaymentChannelImpl) then) =
      __$$PaymentChannelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, String type, String? details});
}

/// @nodoc
class __$$PaymentChannelImplCopyWithImpl<$Res>
    extends _$PaymentChannelCopyWithImpl<$Res, _$PaymentChannelImpl>
    implements _$$PaymentChannelImplCopyWith<$Res> {
  __$$PaymentChannelImplCopyWithImpl(
      _$PaymentChannelImpl _value, $Res Function(_$PaymentChannelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaymentChannel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? details = freezed,
  }) {
    return _then(_$PaymentChannelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentChannelImpl implements _PaymentChannel {
  const _$PaymentChannelImpl(
      {required this.id, required this.name, required this.type, this.details});

  factory _$PaymentChannelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentChannelImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String type;
  @override
  final String? details;

  @override
  String toString() {
    return 'PaymentChannel(id: $id, name: $name, type: $type, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentChannelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.details, details) || other.details == details));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, type, details);

  /// Create a copy of PaymentChannel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentChannelImplCopyWith<_$PaymentChannelImpl> get copyWith =>
      __$$PaymentChannelImplCopyWithImpl<_$PaymentChannelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentChannelImplToJson(
      this,
    );
  }
}

abstract class _PaymentChannel implements PaymentChannel {
  const factory _PaymentChannel(
      {required final int id,
      required final String name,
      required final String type,
      final String? details}) = _$PaymentChannelImpl;

  factory _PaymentChannel.fromJson(Map<String, dynamic> json) =
      _$PaymentChannelImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get type;
  @override
  String? get details;

  /// Create a copy of PaymentChannel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentChannelImplCopyWith<_$PaymentChannelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
