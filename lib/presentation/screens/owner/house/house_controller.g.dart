// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'house_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$houseUnitsHash() => r'2d7c4f6d7ffa0c718b5eed66d32c30d980ad2b77';

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

/// See also [houseUnits].
@ProviderFor(houseUnits)
const houseUnitsProvider = HouseUnitsFamily();

/// See also [houseUnits].
class HouseUnitsFamily extends Family<AsyncValue<List<Unit>>> {
  /// See also [houseUnits].
  const HouseUnitsFamily();

  /// See also [houseUnits].
  HouseUnitsProvider call(
    int houseId,
  ) {
    return HouseUnitsProvider(
      houseId,
    );
  }

  @override
  HouseUnitsProvider getProviderOverride(
    covariant HouseUnitsProvider provider,
  ) {
    return call(
      provider.houseId,
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
  String? get name => r'houseUnitsProvider';
}

/// See also [houseUnits].
class HouseUnitsProvider extends AutoDisposeFutureProvider<List<Unit>> {
  /// See also [houseUnits].
  HouseUnitsProvider(
    int houseId,
  ) : this._internal(
          (ref) => houseUnits(
            ref as HouseUnitsRef,
            houseId,
          ),
          from: houseUnitsProvider,
          name: r'houseUnitsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$houseUnitsHash,
          dependencies: HouseUnitsFamily._dependencies,
          allTransitiveDependencies:
              HouseUnitsFamily._allTransitiveDependencies,
          houseId: houseId,
        );

  HouseUnitsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.houseId,
  }) : super.internal();

  final int houseId;

  @override
  Override overrideWith(
    FutureOr<List<Unit>> Function(HouseUnitsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HouseUnitsProvider._internal(
        (ref) => create(ref as HouseUnitsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        houseId: houseId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Unit>> createElement() {
    return _HouseUnitsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HouseUnitsProvider && other.houseId == houseId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, houseId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HouseUnitsRef on AutoDisposeFutureProviderRef<List<Unit>> {
  /// The parameter `houseId` of this provider.
  int get houseId;
}

class _HouseUnitsProviderElement
    extends AutoDisposeFutureProviderElement<List<Unit>> with HouseUnitsRef {
  _HouseUnitsProviderElement(super.provider);

  @override
  int get houseId => (origin as HouseUnitsProvider).houseId;
}

String _$availableUnitsHash() => r'3f8447b0b57244593198fb2e69784f458f374ba2';

/// See also [availableUnits].
@ProviderFor(availableUnits)
const availableUnitsProvider = AvailableUnitsFamily();

/// See also [availableUnits].
class AvailableUnitsFamily extends Family<AsyncValue<List<Unit>>> {
  /// See also [availableUnits].
  const AvailableUnitsFamily();

  /// See also [availableUnits].
  AvailableUnitsProvider call(
    int houseId,
  ) {
    return AvailableUnitsProvider(
      houseId,
    );
  }

  @override
  AvailableUnitsProvider getProviderOverride(
    covariant AvailableUnitsProvider provider,
  ) {
    return call(
      provider.houseId,
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
  String? get name => r'availableUnitsProvider';
}

/// See also [availableUnits].
class AvailableUnitsProvider extends AutoDisposeFutureProvider<List<Unit>> {
  /// See also [availableUnits].
  AvailableUnitsProvider(
    int houseId,
  ) : this._internal(
          (ref) => availableUnits(
            ref as AvailableUnitsRef,
            houseId,
          ),
          from: availableUnitsProvider,
          name: r'availableUnitsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$availableUnitsHash,
          dependencies: AvailableUnitsFamily._dependencies,
          allTransitiveDependencies:
              AvailableUnitsFamily._allTransitiveDependencies,
          houseId: houseId,
        );

  AvailableUnitsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.houseId,
  }) : super.internal();

  final int houseId;

  @override
  Override overrideWith(
    FutureOr<List<Unit>> Function(AvailableUnitsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AvailableUnitsProvider._internal(
        (ref) => create(ref as AvailableUnitsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        houseId: houseId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Unit>> createElement() {
    return _AvailableUnitsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AvailableUnitsProvider && other.houseId == houseId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, houseId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AvailableUnitsRef on AutoDisposeFutureProviderRef<List<Unit>> {
  /// The parameter `houseId` of this provider.
  int get houseId;
}

class _AvailableUnitsProviderElement
    extends AutoDisposeFutureProviderElement<List<Unit>>
    with AvailableUnitsRef {
  _AvailableUnitsProviderElement(super.provider);

  @override
  int get houseId => (origin as AvailableUnitsProvider).houseId;
}

String _$houseStatsHash() => r'0c6d857946a5e31678debcba2ee619cdb61187ac';

/// See also [houseStats].
@ProviderFor(houseStats)
const houseStatsProvider = HouseStatsFamily();

/// See also [houseStats].
class HouseStatsFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [houseStats].
  const HouseStatsFamily();

  /// See also [houseStats].
  HouseStatsProvider call(
    int houseId,
  ) {
    return HouseStatsProvider(
      houseId,
    );
  }

  @override
  HouseStatsProvider getProviderOverride(
    covariant HouseStatsProvider provider,
  ) {
    return call(
      provider.houseId,
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
  String? get name => r'houseStatsProvider';
}

/// See also [houseStats].
class HouseStatsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [houseStats].
  HouseStatsProvider(
    int houseId,
  ) : this._internal(
          (ref) => houseStats(
            ref as HouseStatsRef,
            houseId,
          ),
          from: houseStatsProvider,
          name: r'houseStatsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$houseStatsHash,
          dependencies: HouseStatsFamily._dependencies,
          allTransitiveDependencies:
              HouseStatsFamily._allTransitiveDependencies,
          houseId: houseId,
        );

  HouseStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.houseId,
  }) : super.internal();

  final int houseId;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(HouseStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HouseStatsProvider._internal(
        (ref) => create(ref as HouseStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        houseId: houseId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _HouseStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HouseStatsProvider && other.houseId == houseId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, houseId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HouseStatsRef on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `houseId` of this provider.
  int get houseId;
}

class _HouseStatsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with HouseStatsRef {
  _HouseStatsProviderElement(super.provider);

  @override
  int get houseId => (origin as HouseStatsProvider).houseId;
}

String _$houseControllerHash() => r'1e9eacea91d6f3691de74f2b0bf22825b9176cf9';

/// See also [HouseController].
@ProviderFor(HouseController)
final houseControllerProvider =
    AutoDisposeAsyncNotifierProvider<HouseController, List<House>>.internal(
  HouseController.new,
  name: r'houseControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$houseControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HouseController = AutoDisposeAsyncNotifier<List<House>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
