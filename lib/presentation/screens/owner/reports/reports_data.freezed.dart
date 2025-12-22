// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reports_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MonthlyStats _$MonthlyStatsFromJson(Map<String, dynamic> json) {
  return _MonthlyStats.fromJson(json);
}

/// @nodoc
mixin _$MonthlyStats {
  String get monthLabel => throw _privateConstructorUsedError;
  double get collected => throw _privateConstructorUsedError;
  double get pending => throw _privateConstructorUsedError;

  /// Serializes this MonthlyStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MonthlyStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthlyStatsCopyWith<MonthlyStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyStatsCopyWith<$Res> {
  factory $MonthlyStatsCopyWith(
          MonthlyStats value, $Res Function(MonthlyStats) then) =
      _$MonthlyStatsCopyWithImpl<$Res, MonthlyStats>;
  @useResult
  $Res call({String monthLabel, double collected, double pending});
}

/// @nodoc
class _$MonthlyStatsCopyWithImpl<$Res, $Val extends MonthlyStats>
    implements $MonthlyStatsCopyWith<$Res> {
  _$MonthlyStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthlyStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthLabel = null,
    Object? collected = null,
    Object? pending = null,
  }) {
    return _then(_value.copyWith(
      monthLabel: null == monthLabel
          ? _value.monthLabel
          : monthLabel // ignore: cast_nullable_to_non_nullable
              as String,
      collected: null == collected
          ? _value.collected
          : collected // ignore: cast_nullable_to_non_nullable
              as double,
      pending: null == pending
          ? _value.pending
          : pending // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MonthlyStatsImplCopyWith<$Res>
    implements $MonthlyStatsCopyWith<$Res> {
  factory _$$MonthlyStatsImplCopyWith(
          _$MonthlyStatsImpl value, $Res Function(_$MonthlyStatsImpl) then) =
      __$$MonthlyStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String monthLabel, double collected, double pending});
}

/// @nodoc
class __$$MonthlyStatsImplCopyWithImpl<$Res>
    extends _$MonthlyStatsCopyWithImpl<$Res, _$MonthlyStatsImpl>
    implements _$$MonthlyStatsImplCopyWith<$Res> {
  __$$MonthlyStatsImplCopyWithImpl(
      _$MonthlyStatsImpl _value, $Res Function(_$MonthlyStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of MonthlyStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthLabel = null,
    Object? collected = null,
    Object? pending = null,
  }) {
    return _then(_$MonthlyStatsImpl(
      monthLabel: null == monthLabel
          ? _value.monthLabel
          : monthLabel // ignore: cast_nullable_to_non_nullable
              as String,
      collected: null == collected
          ? _value.collected
          : collected // ignore: cast_nullable_to_non_nullable
              as double,
      pending: null == pending
          ? _value.pending
          : pending // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MonthlyStatsImpl implements _MonthlyStats {
  const _$MonthlyStatsImpl(
      {required this.monthLabel,
      required this.collected,
      required this.pending});

  factory _$MonthlyStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonthlyStatsImplFromJson(json);

  @override
  final String monthLabel;
  @override
  final double collected;
  @override
  final double pending;

  @override
  String toString() {
    return 'MonthlyStats(monthLabel: $monthLabel, collected: $collected, pending: $pending)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyStatsImpl &&
            (identical(other.monthLabel, monthLabel) ||
                other.monthLabel == monthLabel) &&
            (identical(other.collected, collected) ||
                other.collected == collected) &&
            (identical(other.pending, pending) || other.pending == pending));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, monthLabel, collected, pending);

  /// Create a copy of MonthlyStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyStatsImplCopyWith<_$MonthlyStatsImpl> get copyWith =>
      __$$MonthlyStatsImplCopyWithImpl<_$MonthlyStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthlyStatsImplToJson(
      this,
    );
  }
}

abstract class _MonthlyStats implements MonthlyStats {
  const factory _MonthlyStats(
      {required final String monthLabel,
      required final double collected,
      required final double pending}) = _$MonthlyStatsImpl;

  factory _MonthlyStats.fromJson(Map<String, dynamic> json) =
      _$MonthlyStatsImpl.fromJson;

  @override
  String get monthLabel;
  @override
  double get collected;
  @override
  double get pending;

  /// Create a copy of MonthlyStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthlyStatsImplCopyWith<_$MonthlyStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TenantDue _$TenantDueFromJson(Map<String, dynamic> json) {
  return _TenantDue.fromJson(json);
}

/// @nodoc
mixin _$TenantDue {
  String get name => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;

  /// Serializes this TenantDue to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TenantDue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TenantDueCopyWith<TenantDue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TenantDueCopyWith<$Res> {
  factory $TenantDueCopyWith(TenantDue value, $Res Function(TenantDue) then) =
      _$TenantDueCopyWithImpl<$Res, TenantDue>;
  @useResult
  $Res call({String name, double amount, String phone});
}

/// @nodoc
class _$TenantDueCopyWithImpl<$Res, $Val extends TenantDue>
    implements $TenantDueCopyWith<$Res> {
  _$TenantDueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TenantDue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? amount = null,
    Object? phone = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TenantDueImplCopyWith<$Res>
    implements $TenantDueCopyWith<$Res> {
  factory _$$TenantDueImplCopyWith(
          _$TenantDueImpl value, $Res Function(_$TenantDueImpl) then) =
      __$$TenantDueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, double amount, String phone});
}

/// @nodoc
class __$$TenantDueImplCopyWithImpl<$Res>
    extends _$TenantDueCopyWithImpl<$Res, _$TenantDueImpl>
    implements _$$TenantDueImplCopyWith<$Res> {
  __$$TenantDueImplCopyWithImpl(
      _$TenantDueImpl _value, $Res Function(_$TenantDueImpl) _then)
      : super(_value, _then);

  /// Create a copy of TenantDue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? amount = null,
    Object? phone = null,
  }) {
    return _then(_$TenantDueImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TenantDueImpl implements _TenantDue {
  const _$TenantDueImpl(
      {required this.name, required this.amount, required this.phone});

  factory _$TenantDueImpl.fromJson(Map<String, dynamic> json) =>
      _$$TenantDueImplFromJson(json);

  @override
  final String name;
  @override
  final double amount;
  @override
  final String phone;

  @override
  String toString() {
    return 'TenantDue(name: $name, amount: $amount, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TenantDueImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.phone, phone) || other.phone == phone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, amount, phone);

  /// Create a copy of TenantDue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TenantDueImplCopyWith<_$TenantDueImpl> get copyWith =>
      __$$TenantDueImplCopyWithImpl<_$TenantDueImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TenantDueImplToJson(
      this,
    );
  }
}

abstract class _TenantDue implements TenantDue {
  const factory _TenantDue(
      {required final String name,
      required final double amount,
      required final String phone}) = _$TenantDueImpl;

  factory _TenantDue.fromJson(Map<String, dynamic> json) =
      _$TenantDueImpl.fromJson;

  @override
  String get name;
  @override
  double get amount;
  @override
  String get phone;

  /// Create a copy of TenantDue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TenantDueImplCopyWith<_$TenantDueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PropertyRevenue _$PropertyRevenueFromJson(Map<String, dynamic> json) {
  return _PropertyRevenue.fromJson(json);
}

/// @nodoc
mixin _$PropertyRevenue {
  String get houseName => throw _privateConstructorUsedError;
  double get revenue => throw _privateConstructorUsedError;

  /// Serializes this PropertyRevenue to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PropertyRevenue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PropertyRevenueCopyWith<PropertyRevenue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PropertyRevenueCopyWith<$Res> {
  factory $PropertyRevenueCopyWith(
          PropertyRevenue value, $Res Function(PropertyRevenue) then) =
      _$PropertyRevenueCopyWithImpl<$Res, PropertyRevenue>;
  @useResult
  $Res call({String houseName, double revenue});
}

/// @nodoc
class _$PropertyRevenueCopyWithImpl<$Res, $Val extends PropertyRevenue>
    implements $PropertyRevenueCopyWith<$Res> {
  _$PropertyRevenueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PropertyRevenue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? houseName = null,
    Object? revenue = null,
  }) {
    return _then(_value.copyWith(
      houseName: null == houseName
          ? _value.houseName
          : houseName // ignore: cast_nullable_to_non_nullable
              as String,
      revenue: null == revenue
          ? _value.revenue
          : revenue // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PropertyRevenueImplCopyWith<$Res>
    implements $PropertyRevenueCopyWith<$Res> {
  factory _$$PropertyRevenueImplCopyWith(_$PropertyRevenueImpl value,
          $Res Function(_$PropertyRevenueImpl) then) =
      __$$PropertyRevenueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String houseName, double revenue});
}

/// @nodoc
class __$$PropertyRevenueImplCopyWithImpl<$Res>
    extends _$PropertyRevenueCopyWithImpl<$Res, _$PropertyRevenueImpl>
    implements _$$PropertyRevenueImplCopyWith<$Res> {
  __$$PropertyRevenueImplCopyWithImpl(
      _$PropertyRevenueImpl _value, $Res Function(_$PropertyRevenueImpl) _then)
      : super(_value, _then);

  /// Create a copy of PropertyRevenue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? houseName = null,
    Object? revenue = null,
  }) {
    return _then(_$PropertyRevenueImpl(
      houseName: null == houseName
          ? _value.houseName
          : houseName // ignore: cast_nullable_to_non_nullable
              as String,
      revenue: null == revenue
          ? _value.revenue
          : revenue // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PropertyRevenueImpl implements _PropertyRevenue {
  const _$PropertyRevenueImpl({required this.houseName, required this.revenue});

  factory _$PropertyRevenueImpl.fromJson(Map<String, dynamic> json) =>
      _$$PropertyRevenueImplFromJson(json);

  @override
  final String houseName;
  @override
  final double revenue;

  @override
  String toString() {
    return 'PropertyRevenue(houseName: $houseName, revenue: $revenue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PropertyRevenueImpl &&
            (identical(other.houseName, houseName) ||
                other.houseName == houseName) &&
            (identical(other.revenue, revenue) || other.revenue == revenue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, houseName, revenue);

  /// Create a copy of PropertyRevenue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PropertyRevenueImplCopyWith<_$PropertyRevenueImpl> get copyWith =>
      __$$PropertyRevenueImplCopyWithImpl<_$PropertyRevenueImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PropertyRevenueImplToJson(
      this,
    );
  }
}

abstract class _PropertyRevenue implements PropertyRevenue {
  const factory _PropertyRevenue(
      {required final String houseName,
      required final double revenue}) = _$PropertyRevenueImpl;

  factory _PropertyRevenue.fromJson(Map<String, dynamic> json) =
      _$PropertyRevenueImpl.fromJson;

  @override
  String get houseName;
  @override
  double get revenue;

  /// Create a copy of PropertyRevenue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PropertyRevenueImplCopyWith<_$PropertyRevenueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReportsData _$ReportsDataFromJson(Map<String, dynamic> json) {
  return _ReportsData.fromJson(json);
}

/// @nodoc
mixin _$ReportsData {
  double get totalCollected => throw _privateConstructorUsedError;
  double get totalPending => throw _privateConstructorUsedError;
  double get totalExpected => throw _privateConstructorUsedError;
  double get totalExpenses => throw _privateConstructorUsedError;
  double get netProfit => throw _privateConstructorUsedError;
  double get previousMonthCollected => throw _privateConstructorUsedError;
  int get totalUnits => throw _privateConstructorUsedError;
  int get occupiedUnits => throw _privateConstructorUsedError;
  int get vacantUnits => throw _privateConstructorUsedError;
  List<Payment> get recentPayments => throw _privateConstructorUsedError;
  List<MonthlyStats> get revenueTrend => throw _privateConstructorUsedError;
  List<MonthlyStats> get expenseTrend => throw _privateConstructorUsedError;
  Map<String, double> get paymentMethods => throw _privateConstructorUsedError;
  List<TenantDue> get topDefaulters => throw _privateConstructorUsedError;
  List<PropertyRevenue> get propertyPerformance =>
      throw _privateConstructorUsedError;

  /// Serializes this ReportsData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReportsData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportsDataCopyWith<ReportsData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportsDataCopyWith<$Res> {
  factory $ReportsDataCopyWith(
          ReportsData value, $Res Function(ReportsData) then) =
      _$ReportsDataCopyWithImpl<$Res, ReportsData>;
  @useResult
  $Res call(
      {double totalCollected,
      double totalPending,
      double totalExpected,
      double totalExpenses,
      double netProfit,
      double previousMonthCollected,
      int totalUnits,
      int occupiedUnits,
      int vacantUnits,
      List<Payment> recentPayments,
      List<MonthlyStats> revenueTrend,
      List<MonthlyStats> expenseTrend,
      Map<String, double> paymentMethods,
      List<TenantDue> topDefaulters,
      List<PropertyRevenue> propertyPerformance});
}

/// @nodoc
class _$ReportsDataCopyWithImpl<$Res, $Val extends ReportsData>
    implements $ReportsDataCopyWith<$Res> {
  _$ReportsDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportsData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalCollected = null,
    Object? totalPending = null,
    Object? totalExpected = null,
    Object? totalExpenses = null,
    Object? netProfit = null,
    Object? previousMonthCollected = null,
    Object? totalUnits = null,
    Object? occupiedUnits = null,
    Object? vacantUnits = null,
    Object? recentPayments = null,
    Object? revenueTrend = null,
    Object? expenseTrend = null,
    Object? paymentMethods = null,
    Object? topDefaulters = null,
    Object? propertyPerformance = null,
  }) {
    return _then(_value.copyWith(
      totalCollected: null == totalCollected
          ? _value.totalCollected
          : totalCollected // ignore: cast_nullable_to_non_nullable
              as double,
      totalPending: null == totalPending
          ? _value.totalPending
          : totalPending // ignore: cast_nullable_to_non_nullable
              as double,
      totalExpected: null == totalExpected
          ? _value.totalExpected
          : totalExpected // ignore: cast_nullable_to_non_nullable
              as double,
      totalExpenses: null == totalExpenses
          ? _value.totalExpenses
          : totalExpenses // ignore: cast_nullable_to_non_nullable
              as double,
      netProfit: null == netProfit
          ? _value.netProfit
          : netProfit // ignore: cast_nullable_to_non_nullable
              as double,
      previousMonthCollected: null == previousMonthCollected
          ? _value.previousMonthCollected
          : previousMonthCollected // ignore: cast_nullable_to_non_nullable
              as double,
      totalUnits: null == totalUnits
          ? _value.totalUnits
          : totalUnits // ignore: cast_nullable_to_non_nullable
              as int,
      occupiedUnits: null == occupiedUnits
          ? _value.occupiedUnits
          : occupiedUnits // ignore: cast_nullable_to_non_nullable
              as int,
      vacantUnits: null == vacantUnits
          ? _value.vacantUnits
          : vacantUnits // ignore: cast_nullable_to_non_nullable
              as int,
      recentPayments: null == recentPayments
          ? _value.recentPayments
          : recentPayments // ignore: cast_nullable_to_non_nullable
              as List<Payment>,
      revenueTrend: null == revenueTrend
          ? _value.revenueTrend
          : revenueTrend // ignore: cast_nullable_to_non_nullable
              as List<MonthlyStats>,
      expenseTrend: null == expenseTrend
          ? _value.expenseTrend
          : expenseTrend // ignore: cast_nullable_to_non_nullable
              as List<MonthlyStats>,
      paymentMethods: null == paymentMethods
          ? _value.paymentMethods
          : paymentMethods // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      topDefaulters: null == topDefaulters
          ? _value.topDefaulters
          : topDefaulters // ignore: cast_nullable_to_non_nullable
              as List<TenantDue>,
      propertyPerformance: null == propertyPerformance
          ? _value.propertyPerformance
          : propertyPerformance // ignore: cast_nullable_to_non_nullable
              as List<PropertyRevenue>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReportsDataImplCopyWith<$Res>
    implements $ReportsDataCopyWith<$Res> {
  factory _$$ReportsDataImplCopyWith(
          _$ReportsDataImpl value, $Res Function(_$ReportsDataImpl) then) =
      __$$ReportsDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double totalCollected,
      double totalPending,
      double totalExpected,
      double totalExpenses,
      double netProfit,
      double previousMonthCollected,
      int totalUnits,
      int occupiedUnits,
      int vacantUnits,
      List<Payment> recentPayments,
      List<MonthlyStats> revenueTrend,
      List<MonthlyStats> expenseTrend,
      Map<String, double> paymentMethods,
      List<TenantDue> topDefaulters,
      List<PropertyRevenue> propertyPerformance});
}

/// @nodoc
class __$$ReportsDataImplCopyWithImpl<$Res>
    extends _$ReportsDataCopyWithImpl<$Res, _$ReportsDataImpl>
    implements _$$ReportsDataImplCopyWith<$Res> {
  __$$ReportsDataImplCopyWithImpl(
      _$ReportsDataImpl _value, $Res Function(_$ReportsDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportsData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalCollected = null,
    Object? totalPending = null,
    Object? totalExpected = null,
    Object? totalExpenses = null,
    Object? netProfit = null,
    Object? previousMonthCollected = null,
    Object? totalUnits = null,
    Object? occupiedUnits = null,
    Object? vacantUnits = null,
    Object? recentPayments = null,
    Object? revenueTrend = null,
    Object? expenseTrend = null,
    Object? paymentMethods = null,
    Object? topDefaulters = null,
    Object? propertyPerformance = null,
  }) {
    return _then(_$ReportsDataImpl(
      totalCollected: null == totalCollected
          ? _value.totalCollected
          : totalCollected // ignore: cast_nullable_to_non_nullable
              as double,
      totalPending: null == totalPending
          ? _value.totalPending
          : totalPending // ignore: cast_nullable_to_non_nullable
              as double,
      totalExpected: null == totalExpected
          ? _value.totalExpected
          : totalExpected // ignore: cast_nullable_to_non_nullable
              as double,
      totalExpenses: null == totalExpenses
          ? _value.totalExpenses
          : totalExpenses // ignore: cast_nullable_to_non_nullable
              as double,
      netProfit: null == netProfit
          ? _value.netProfit
          : netProfit // ignore: cast_nullable_to_non_nullable
              as double,
      previousMonthCollected: null == previousMonthCollected
          ? _value.previousMonthCollected
          : previousMonthCollected // ignore: cast_nullable_to_non_nullable
              as double,
      totalUnits: null == totalUnits
          ? _value.totalUnits
          : totalUnits // ignore: cast_nullable_to_non_nullable
              as int,
      occupiedUnits: null == occupiedUnits
          ? _value.occupiedUnits
          : occupiedUnits // ignore: cast_nullable_to_non_nullable
              as int,
      vacantUnits: null == vacantUnits
          ? _value.vacantUnits
          : vacantUnits // ignore: cast_nullable_to_non_nullable
              as int,
      recentPayments: null == recentPayments
          ? _value._recentPayments
          : recentPayments // ignore: cast_nullable_to_non_nullable
              as List<Payment>,
      revenueTrend: null == revenueTrend
          ? _value._revenueTrend
          : revenueTrend // ignore: cast_nullable_to_non_nullable
              as List<MonthlyStats>,
      expenseTrend: null == expenseTrend
          ? _value._expenseTrend
          : expenseTrend // ignore: cast_nullable_to_non_nullable
              as List<MonthlyStats>,
      paymentMethods: null == paymentMethods
          ? _value._paymentMethods
          : paymentMethods // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      topDefaulters: null == topDefaulters
          ? _value._topDefaulters
          : topDefaulters // ignore: cast_nullable_to_non_nullable
              as List<TenantDue>,
      propertyPerformance: null == propertyPerformance
          ? _value._propertyPerformance
          : propertyPerformance // ignore: cast_nullable_to_non_nullable
              as List<PropertyRevenue>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReportsDataImpl implements _ReportsData {
  const _$ReportsDataImpl(
      {required this.totalCollected,
      required this.totalPending,
      required this.totalExpected,
      required this.totalExpenses,
      required this.netProfit,
      required this.previousMonthCollected,
      required this.totalUnits,
      required this.occupiedUnits,
      required this.vacantUnits,
      required final List<Payment> recentPayments,
      required final List<MonthlyStats> revenueTrend,
      required final List<MonthlyStats> expenseTrend,
      required final Map<String, double> paymentMethods,
      required final List<TenantDue> topDefaulters,
      required final List<PropertyRevenue> propertyPerformance})
      : _recentPayments = recentPayments,
        _revenueTrend = revenueTrend,
        _expenseTrend = expenseTrend,
        _paymentMethods = paymentMethods,
        _topDefaulters = topDefaulters,
        _propertyPerformance = propertyPerformance;

  factory _$ReportsDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportsDataImplFromJson(json);

  @override
  final double totalCollected;
  @override
  final double totalPending;
  @override
  final double totalExpected;
  @override
  final double totalExpenses;
  @override
  final double netProfit;
  @override
  final double previousMonthCollected;
  @override
  final int totalUnits;
  @override
  final int occupiedUnits;
  @override
  final int vacantUnits;
  final List<Payment> _recentPayments;
  @override
  List<Payment> get recentPayments {
    if (_recentPayments is EqualUnmodifiableListView) return _recentPayments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentPayments);
  }

  final List<MonthlyStats> _revenueTrend;
  @override
  List<MonthlyStats> get revenueTrend {
    if (_revenueTrend is EqualUnmodifiableListView) return _revenueTrend;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_revenueTrend);
  }

  final List<MonthlyStats> _expenseTrend;
  @override
  List<MonthlyStats> get expenseTrend {
    if (_expenseTrend is EqualUnmodifiableListView) return _expenseTrend;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_expenseTrend);
  }

  final Map<String, double> _paymentMethods;
  @override
  Map<String, double> get paymentMethods {
    if (_paymentMethods is EqualUnmodifiableMapView) return _paymentMethods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_paymentMethods);
  }

  final List<TenantDue> _topDefaulters;
  @override
  List<TenantDue> get topDefaulters {
    if (_topDefaulters is EqualUnmodifiableListView) return _topDefaulters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topDefaulters);
  }

  final List<PropertyRevenue> _propertyPerformance;
  @override
  List<PropertyRevenue> get propertyPerformance {
    if (_propertyPerformance is EqualUnmodifiableListView)
      return _propertyPerformance;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_propertyPerformance);
  }

  @override
  String toString() {
    return 'ReportsData(totalCollected: $totalCollected, totalPending: $totalPending, totalExpected: $totalExpected, totalExpenses: $totalExpenses, netProfit: $netProfit, previousMonthCollected: $previousMonthCollected, totalUnits: $totalUnits, occupiedUnits: $occupiedUnits, vacantUnits: $vacantUnits, recentPayments: $recentPayments, revenueTrend: $revenueTrend, expenseTrend: $expenseTrend, paymentMethods: $paymentMethods, topDefaulters: $topDefaulters, propertyPerformance: $propertyPerformance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportsDataImpl &&
            (identical(other.totalCollected, totalCollected) ||
                other.totalCollected == totalCollected) &&
            (identical(other.totalPending, totalPending) ||
                other.totalPending == totalPending) &&
            (identical(other.totalExpected, totalExpected) ||
                other.totalExpected == totalExpected) &&
            (identical(other.totalExpenses, totalExpenses) ||
                other.totalExpenses == totalExpenses) &&
            (identical(other.netProfit, netProfit) ||
                other.netProfit == netProfit) &&
            (identical(other.previousMonthCollected, previousMonthCollected) ||
                other.previousMonthCollected == previousMonthCollected) &&
            (identical(other.totalUnits, totalUnits) ||
                other.totalUnits == totalUnits) &&
            (identical(other.occupiedUnits, occupiedUnits) ||
                other.occupiedUnits == occupiedUnits) &&
            (identical(other.vacantUnits, vacantUnits) ||
                other.vacantUnits == vacantUnits) &&
            const DeepCollectionEquality()
                .equals(other._recentPayments, _recentPayments) &&
            const DeepCollectionEquality()
                .equals(other._revenueTrend, _revenueTrend) &&
            const DeepCollectionEquality()
                .equals(other._expenseTrend, _expenseTrend) &&
            const DeepCollectionEquality()
                .equals(other._paymentMethods, _paymentMethods) &&
            const DeepCollectionEquality()
                .equals(other._topDefaulters, _topDefaulters) &&
            const DeepCollectionEquality()
                .equals(other._propertyPerformance, _propertyPerformance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalCollected,
      totalPending,
      totalExpected,
      totalExpenses,
      netProfit,
      previousMonthCollected,
      totalUnits,
      occupiedUnits,
      vacantUnits,
      const DeepCollectionEquality().hash(_recentPayments),
      const DeepCollectionEquality().hash(_revenueTrend),
      const DeepCollectionEquality().hash(_expenseTrend),
      const DeepCollectionEquality().hash(_paymentMethods),
      const DeepCollectionEquality().hash(_topDefaulters),
      const DeepCollectionEquality().hash(_propertyPerformance));

  /// Create a copy of ReportsData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportsDataImplCopyWith<_$ReportsDataImpl> get copyWith =>
      __$$ReportsDataImplCopyWithImpl<_$ReportsDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportsDataImplToJson(
      this,
    );
  }
}

abstract class _ReportsData implements ReportsData {
  const factory _ReportsData(
          {required final double totalCollected,
          required final double totalPending,
          required final double totalExpected,
          required final double totalExpenses,
          required final double netProfit,
          required final double previousMonthCollected,
          required final int totalUnits,
          required final int occupiedUnits,
          required final int vacantUnits,
          required final List<Payment> recentPayments,
          required final List<MonthlyStats> revenueTrend,
          required final List<MonthlyStats> expenseTrend,
          required final Map<String, double> paymentMethods,
          required final List<TenantDue> topDefaulters,
          required final List<PropertyRevenue> propertyPerformance}) =
      _$ReportsDataImpl;

  factory _ReportsData.fromJson(Map<String, dynamic> json) =
      _$ReportsDataImpl.fromJson;

  @override
  double get totalCollected;
  @override
  double get totalPending;
  @override
  double get totalExpected;
  @override
  double get totalExpenses;
  @override
  double get netProfit;
  @override
  double get previousMonthCollected;
  @override
  int get totalUnits;
  @override
  int get occupiedUnits;
  @override
  int get vacantUnits;
  @override
  List<Payment> get recentPayments;
  @override
  List<MonthlyStats> get revenueTrend;
  @override
  List<MonthlyStats> get expenseTrend;
  @override
  Map<String, double> get paymentMethods;
  @override
  List<TenantDue> get topDefaulters;
  @override
  List<PropertyRevenue> get propertyPerformance;

  /// Create a copy of ReportsData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportsDataImplCopyWith<_$ReportsDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
