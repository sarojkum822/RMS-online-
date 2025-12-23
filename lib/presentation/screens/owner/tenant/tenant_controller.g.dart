// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeTenancyHash() => r'a4d3348ffc78a69e2f546c7ba2630b35ee4f28c8';

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
class ActiveTenancyProvider extends AutoDisposeStreamProvider<Tenancy?> {
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
    Stream<Tenancy?> Function(ActiveTenancyRef provider) create,
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
  AutoDisposeStreamProviderElement<Tenancy?> createElement() {
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
mixin ActiveTenancyRef on AutoDisposeStreamProviderRef<Tenancy?> {
  /// The parameter `tenantId` of this provider.
  String get tenantId;
}

class _ActiveTenancyProviderElement
    extends AutoDisposeStreamProviderElement<Tenancy?> with ActiveTenancyRef {
  _ActiveTenancyProviderElement(super.provider);

  @override
  String get tenantId => (origin as ActiveTenancyProvider).tenantId;
}

String _$activeTenancyForTenantAccessHash() =>
    r'3f855d670491beeea13e242469ca4c53bb0ce722';

/// For TENANT-SIDE ACCESS: Uses ownerId from tenant profile
/// because tenants log in with their own Firebase Auth credentials, not the owner's.
///
/// Copied from [activeTenancyForTenantAccess].
@ProviderFor(activeTenancyForTenantAccess)
const activeTenancyForTenantAccessProvider =
    ActiveTenancyForTenantAccessFamily();

/// For TENANT-SIDE ACCESS: Uses ownerId from tenant profile
/// because tenants log in with their own Firebase Auth credentials, not the owner's.
///
/// Copied from [activeTenancyForTenantAccess].
class ActiveTenancyForTenantAccessFamily extends Family<AsyncValue<Tenancy?>> {
  /// For TENANT-SIDE ACCESS: Uses ownerId from tenant profile
  /// because tenants log in with their own Firebase Auth credentials, not the owner's.
  ///
  /// Copied from [activeTenancyForTenantAccess].
  const ActiveTenancyForTenantAccessFamily();

  /// For TENANT-SIDE ACCESS: Uses ownerId from tenant profile
  /// because tenants log in with their own Firebase Auth credentials, not the owner's.
  ///
  /// Copied from [activeTenancyForTenantAccess].
  ActiveTenancyForTenantAccessProvider call(
    String tenantId,
    String ownerId,
  ) {
    return ActiveTenancyForTenantAccessProvider(
      tenantId,
      ownerId,
    );
  }

  @override
  ActiveTenancyForTenantAccessProvider getProviderOverride(
    covariant ActiveTenancyForTenantAccessProvider provider,
  ) {
    return call(
      provider.tenantId,
      provider.ownerId,
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
  String? get name => r'activeTenancyForTenantAccessProvider';
}

/// For TENANT-SIDE ACCESS: Uses ownerId from tenant profile
/// because tenants log in with their own Firebase Auth credentials, not the owner's.
///
/// Copied from [activeTenancyForTenantAccess].
class ActiveTenancyForTenantAccessProvider
    extends AutoDisposeStreamProvider<Tenancy?> {
  /// For TENANT-SIDE ACCESS: Uses ownerId from tenant profile
  /// because tenants log in with their own Firebase Auth credentials, not the owner's.
  ///
  /// Copied from [activeTenancyForTenantAccess].
  ActiveTenancyForTenantAccessProvider(
    String tenantId,
    String ownerId,
  ) : this._internal(
          (ref) => activeTenancyForTenantAccess(
            ref as ActiveTenancyForTenantAccessRef,
            tenantId,
            ownerId,
          ),
          from: activeTenancyForTenantAccessProvider,
          name: r'activeTenancyForTenantAccessProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$activeTenancyForTenantAccessHash,
          dependencies: ActiveTenancyForTenantAccessFamily._dependencies,
          allTransitiveDependencies:
              ActiveTenancyForTenantAccessFamily._allTransitiveDependencies,
          tenantId: tenantId,
          ownerId: ownerId,
        );

  ActiveTenancyForTenantAccessProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tenantId,
    required this.ownerId,
  }) : super.internal();

  final String tenantId;
  final String ownerId;

  @override
  Override overrideWith(
    Stream<Tenancy?> Function(ActiveTenancyForTenantAccessRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ActiveTenancyForTenantAccessProvider._internal(
        (ref) => create(ref as ActiveTenancyForTenantAccessRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tenantId: tenantId,
        ownerId: ownerId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Tenancy?> createElement() {
    return _ActiveTenancyForTenantAccessProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveTenancyForTenantAccessProvider &&
        other.tenantId == tenantId &&
        other.ownerId == ownerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tenantId.hashCode);
    hash = _SystemHash.combine(hash, ownerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ActiveTenancyForTenantAccessRef
    on AutoDisposeStreamProviderRef<Tenancy?> {
  /// The parameter `tenantId` of this provider.
  String get tenantId;

  /// The parameter `ownerId` of this provider.
  String get ownerId;
}

class _ActiveTenancyForTenantAccessProviderElement
    extends AutoDisposeStreamProviderElement<Tenancy?>
    with ActiveTenancyForTenantAccessRef {
  _ActiveTenancyForTenantAccessProviderElement(super.provider);

  @override
  String get tenantId =>
      (origin as ActiveTenancyForTenantAccessProvider).tenantId;
  @override
  String get ownerId =>
      (origin as ActiveTenancyForTenantAccessProvider).ownerId;
}

String _$tenantControllerHash() => r'b85a5f0b3724c85ea1b965a19275e5c94ad7c9a9';

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
