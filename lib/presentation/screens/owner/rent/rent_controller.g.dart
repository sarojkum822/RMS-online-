// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rent_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardStatsHash() => r'4fb011372563078d5eb3ceb3791ff22cd318ecbf';

/// See also [dashboardStats].
@ProviderFor(dashboardStats)
final dashboardStatsProvider = FutureProvider<DashboardStats>.internal(
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
typedef DashboardStatsRef = FutureProviderRef<DashboardStats>;
String _$rentControllerHash() => r'9021fa2461443f89636b3f37f5d80bfb850ac973';

/// See also [RentController].
@ProviderFor(RentController)
final rentControllerProvider =
    AsyncNotifierProvider<RentController, List<RentCycle>>.internal(
  RentController.new,
  name: r'rentControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rentControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RentController = AsyncNotifier<List<RentCycle>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
