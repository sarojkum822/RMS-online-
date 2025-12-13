// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rent_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardStatsHash() => r'636983351a96e0ff839739413dd09721d9459272';

/// See also [dashboardStats].
@ProviderFor(dashboardStats)
final dashboardStatsProvider =
    AutoDisposeFutureProvider<DashboardStats>.internal(
  dashboardStats,
  name: r'dashboardStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardStatsRef = AutoDisposeFutureProviderRef<DashboardStats>;
String _$rentControllerHash() => r'fdacb2f85f421804b5697c890e83d7cbfe715fb4';

/// See also [RentController].
@ProviderFor(RentController)
final rentControllerProvider =
    AutoDisposeAsyncNotifierProvider<RentController, List<RentCycle>>.internal(
  RentController.new,
  name: r'rentControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rentControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RentController = AutoDisposeAsyncNotifier<List<RentCycle>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
