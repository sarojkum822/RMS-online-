// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeTenancyHash() => r'6901be231873fcf714eb0de04dd8da874e5ff0e1';

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

/// See also [activeTenancy].
@ProviderFor(activeTenancy)
const activeTenancyProvider = ActiveTenancyFamily();

/// See also [activeTenancy].
class ActiveTenancyFamily extends Family<AsyncValue<Tenancy?>> {
  /// See also [activeTenancy].
  const ActiveTenancyFamily();

  /// See also [activeTenancy].
  ActiveTenancyProvider call(
    String tenantId,
  ) {
    return ActiveTenancyProvider(
      tenantId,
    );
  }

  @override
  ActiveTenancyProvider getProviderOverride(
    covariant ActiveTenancyProvider provider,
  ) {
    return call(
      provider.tenantId,
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
  String? get name => r'activeTenancyProvider';
}

/// See also [activeTenancy].
class ActiveTenancyProvider extends AutoDisposeFutureProvider<Tenancy?> {
  /// See also [activeTenancy].
  ActiveTenancyProvider(
    String tenantId,
  ) : this._internal(
          (ref) => activeTenancy(
            ref as ActiveTenancyRef,
            tenantId,
          ),
          from: activeTenancyProvider,
          name: r'activeTenancyProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$activeTenancyHash,
          dependencies: ActiveTenancyFamily._dependencies,
          allTransitiveDependencies:
              ActiveTenancyFamily._allTransitiveDependencies,
          tenantId: tenantId,
        );

  ActiveTenancyProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tenantId,
  }) : super.internal();

  final String tenantId;

  @override
  Override overrideWith(
    FutureOr<Tenancy?> Function(ActiveTenancyRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ActiveTenancyProvider._internal(
        (ref) => create(ref as ActiveTenancyRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tenantId: tenantId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Tenancy?> createElement() {
    return _ActiveTenancyProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveTenancyProvider && other.tenantId == tenantId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tenantId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ActiveTenancyRef on AutoDisposeFutureProviderRef<Tenancy?> {
  /// The parameter `tenantId` of this provider.
  String get tenantId;
}

class _ActiveTenancyProviderElement
    extends AutoDisposeFutureProviderElement<Tenancy?> with ActiveTenancyRef {
  _ActiveTenancyProviderElement(super.provider);

  @override
  String get tenantId => (origin as ActiveTenancyProvider).tenantId;
}

String _$tenantControllerHash() => r'bd515506413c542466f7d38634c317fc48d4ded7';

/// See also [TenantController].
@ProviderFor(TenantController)
final tenantControllerProvider =
    StreamNotifierProvider<TenantController, List<Tenant>>.internal(
  TenantController.new,
  name: r'tenantControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tenantControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TenantController = StreamNotifier<List<Tenant>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
