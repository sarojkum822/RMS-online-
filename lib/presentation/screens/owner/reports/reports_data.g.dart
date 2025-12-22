// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MonthlyStatsImpl _$$MonthlyStatsImplFromJson(Map<String, dynamic> json) =>
    _$MonthlyStatsImpl(
      monthLabel: json['monthLabel'] as String,
      collected: (json['collected'] as num).toDouble(),
      pending: (json['pending'] as num).toDouble(),
    );

Map<String, dynamic> _$$MonthlyStatsImplToJson(_$MonthlyStatsImpl instance) =>
    <String, dynamic>{
      'monthLabel': instance.monthLabel,
      'collected': instance.collected,
      'pending': instance.pending,
    };

_$TenantDueImpl _$$TenantDueImplFromJson(Map<String, dynamic> json) =>
    _$TenantDueImpl(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      phone: json['phone'] as String,
    );

Map<String, dynamic> _$$TenantDueImplToJson(_$TenantDueImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'amount': instance.amount,
      'phone': instance.phone,
    };

_$PropertyRevenueImpl _$$PropertyRevenueImplFromJson(
        Map<String, dynamic> json) =>
    _$PropertyRevenueImpl(
      houseName: json['houseName'] as String,
      revenue: (json['revenue'] as num).toDouble(),
    );

Map<String, dynamic> _$$PropertyRevenueImplToJson(
        _$PropertyRevenueImpl instance) =>
    <String, dynamic>{
      'houseName': instance.houseName,
      'revenue': instance.revenue,
    };

_$ReportsDataImpl _$$ReportsDataImplFromJson(Map<String, dynamic> json) =>
    _$ReportsDataImpl(
      totalCollected: (json['totalCollected'] as num).toDouble(),
      totalPending: (json['totalPending'] as num).toDouble(),
      totalExpected: (json['totalExpected'] as num).toDouble(),
      totalExpenses: (json['totalExpenses'] as num).toDouble(),
      netProfit: (json['netProfit'] as num).toDouble(),
      previousMonthCollected:
          (json['previousMonthCollected'] as num).toDouble(),
      totalUnits: (json['totalUnits'] as num).toInt(),
      occupiedUnits: (json['occupiedUnits'] as num).toInt(),
      vacantUnits: (json['vacantUnits'] as num).toInt(),
      recentPayments: (json['recentPayments'] as List<dynamic>)
          .map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList(),
      revenueTrend: (json['revenueTrend'] as List<dynamic>)
          .map((e) => MonthlyStats.fromJson(e as Map<String, dynamic>))
          .toList(),
      expenseTrend: (json['expenseTrend'] as List<dynamic>)
          .map((e) => MonthlyStats.fromJson(e as Map<String, dynamic>))
          .toList(),
      paymentMethods: (json['paymentMethods'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      topDefaulters: (json['topDefaulters'] as List<dynamic>)
          .map((e) => TenantDue.fromJson(e as Map<String, dynamic>))
          .toList(),
      propertyPerformance: (json['propertyPerformance'] as List<dynamic>)
          .map((e) => PropertyRevenue.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ReportsDataImplToJson(_$ReportsDataImpl instance) =>
    <String, dynamic>{
      'totalCollected': instance.totalCollected,
      'totalPending': instance.totalPending,
      'totalExpected': instance.totalExpected,
      'totalExpenses': instance.totalExpenses,
      'netProfit': instance.netProfit,
      'previousMonthCollected': instance.previousMonthCollected,
      'totalUnits': instance.totalUnits,
      'occupiedUnits': instance.occupiedUnits,
      'vacantUnits': instance.vacantUnits,
      'recentPayments': instance.recentPayments,
      'revenueTrend': instance.revenueTrend,
      'expenseTrend': instance.expenseTrend,
      'paymentMethods': instance.paymentMethods,
      'topDefaulters': instance.topDefaulters,
      'propertyPerformance': instance.propertyPerformance,
    };
