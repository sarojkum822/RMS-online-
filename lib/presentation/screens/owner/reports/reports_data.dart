import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../features/rent/domain/entities/rent_cycle.dart';

part 'reports_data.freezed.dart';
part 'reports_data.g.dart';

@freezed
class MonthlyStats with _$MonthlyStats {
  const factory MonthlyStats({
    required String monthLabel,
    required double collected,
    required double pending,
  }) = _MonthlyStats;

  factory MonthlyStats.fromJson(Map<String, dynamic> json) => _$MonthlyStatsFromJson(json);
}

@freezed
class TenantDue with _$TenantDue {
  const factory TenantDue({
    required String name,
    required double amount,
    required String phone,
  }) = _TenantDue;

  factory TenantDue.fromJson(Map<String, dynamic> json) => _$TenantDueFromJson(json);
}

@freezed
class PropertyRevenue with _$PropertyRevenue {
  const factory PropertyRevenue({
    required String houseName,
    required double revenue,
  }) = _PropertyRevenue;

  factory PropertyRevenue.fromJson(Map<String, dynamic> json) => _$PropertyRevenueFromJson(json);
}

@freezed
class ReportsData with _$ReportsData {
  const factory ReportsData({
    required double totalCollected,
    required double totalPending,
    required double totalExpected,
    required double totalExpenses,
    required double netProfit,
    required double previousMonthCollected,
    required int totalUnits,
    required int occupiedUnits,
    required int vacantUnits,
    required List<Payment> recentPayments,
    required List<MonthlyStats> revenueTrend,
    required List<MonthlyStats> expenseTrend,
    required Map<String, double> paymentMethods,
    required List<TenantDue> topDefaulters,
    required List<PropertyRevenue> propertyPerformance,
  }) = _ReportsData;

  factory ReportsData.fromJson(Map<String, dynamic> json) => _$ReportsDataFromJson(json);
}
