// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reportsControllerHash() => r'1f7063e18d6072e26e4c170038b63635fdac6773';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ReportsController
    extends BuildlessAutoDisposeAsyncNotifier<ReportsData> {
  late final ReportRange range;

  FutureOr<ReportsData> build(
    ReportRange range,
  );
}

/// See also [ReportsController].
@ProviderFor(ReportsController)
const reportsControllerProvider = ReportsControllerFamily();

/// See also [ReportsController].
class ReportsControllerFamily extends Family<AsyncValue<ReportsData>> {
  /// See also [ReportsController].
  const ReportsControllerFamily();

  /// See also [ReportsController].
  ReportsControllerProvider call(
    ReportRange range,
  ) {
    return ReportsControllerProvider(
      range,
    );
  }

  @override
  ReportsControllerProvider getProviderOverride(
    covariant ReportsControllerProvider provider,
  ) {
    return call(
      provider.range,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'reportsControllerProvider';
}

/// See also [ReportsController].
class ReportsControllerProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ReportsController, ReportsData> {
  /// See also [ReportsController].
  ReportsControllerProvider(
    ReportRange range,
  ) : this._internal(
          () => ReportsController()..range = range,
          from: reportsControllerProvider,
          name: r'reportsControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$reportsControllerHash,
          dependencies: ReportsControllerFamily._dependencies,
          allTransitiveDependencies:
              ReportsControllerFamily._allTransitiveDependencies,
          range: range,
        );

  ReportsControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.range,
  }) : super.internal();

  final ReportRange range;

  @override
  FutureOr<ReportsData> runNotifierBuild(
    covariant ReportsController notifier,
  ) {
    return notifier.build(
      range,
    );
  }

  @override
  Override overrideWith(ReportsController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ReportsControllerProvider._internal(
        () => create()..range = range,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        range: range,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ReportsController, ReportsData>
      createElement() {
    return _ReportsControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReportsControllerProvider && other.range == range;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, range.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReportsControllerRef on AutoDisposeAsyncNotifierProviderRef<ReportsData> {
  /// The parameter `range` of this provider.
  ReportRange get range;
}

class _ReportsControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ReportsController,
        ReportsData> with ReportsControllerRef {
  _ReportsControllerProviderElement(super.provider);

  @override
  ReportRange get range => (origin as ReportsControllerProvider).range;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
