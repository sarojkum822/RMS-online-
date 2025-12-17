// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bhk_template_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bhkTemplateControllerHash() =>
    r'0f885aa3f81bf0c9377f3b78b212c9773e66e91d';

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

abstract class _$BhkTemplateController
    extends BuildlessAutoDisposeStreamNotifier<List<BhkTemplate>> {
  late final int houseId;

  Stream<List<BhkTemplate>> build(
    int houseId,
  );
}

/// See also [BhkTemplateController].
@ProviderFor(BhkTemplateController)
const bhkTemplateControllerProvider = BhkTemplateControllerFamily();

/// See also [BhkTemplateController].
class BhkTemplateControllerFamily
    extends Family<AsyncValue<List<BhkTemplate>>> {
  /// See also [BhkTemplateController].
  const BhkTemplateControllerFamily();

  /// See also [BhkTemplateController].
  BhkTemplateControllerProvider call(
    int houseId,
  ) {
    return BhkTemplateControllerProvider(
      houseId,
    );
  }

  @override
  BhkTemplateControllerProvider getProviderOverride(
    covariant BhkTemplateControllerProvider provider,
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
  String? get name => r'bhkTemplateControllerProvider';
}

/// See also [BhkTemplateController].
class BhkTemplateControllerProvider
    extends AutoDisposeStreamNotifierProviderImpl<BhkTemplateController,
        List<BhkTemplate>> {
  /// See also [BhkTemplateController].
  BhkTemplateControllerProvider(
    int houseId,
  ) : this._internal(
          () => BhkTemplateController()..houseId = houseId,
          from: bhkTemplateControllerProvider,
          name: r'bhkTemplateControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$bhkTemplateControllerHash,
          dependencies: BhkTemplateControllerFamily._dependencies,
          allTransitiveDependencies:
              BhkTemplateControllerFamily._allTransitiveDependencies,
          houseId: houseId,
        );

  BhkTemplateControllerProvider._internal(
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
  Stream<List<BhkTemplate>> runNotifierBuild(
    covariant BhkTemplateController notifier,
  ) {
    return notifier.build(
      houseId,
    );
  }

  @override
  Override overrideWith(BhkTemplateController Function() create) {
    return ProviderOverride(
      origin: this,
      override: BhkTemplateControllerProvider._internal(
        () => create()..houseId = houseId,
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
  AutoDisposeStreamNotifierProviderElement<BhkTemplateController,
      List<BhkTemplate>> createElement() {
    return _BhkTemplateControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BhkTemplateControllerProvider && other.houseId == houseId;
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
mixin BhkTemplateControllerRef
    on AutoDisposeStreamNotifierProviderRef<List<BhkTemplate>> {
  /// The parameter `houseId` of this provider.
  int get houseId;
}

class _BhkTemplateControllerProviderElement
    extends AutoDisposeStreamNotifierProviderElement<BhkTemplateController,
        List<BhkTemplate>> with BhkTemplateControllerRef {
  _BhkTemplateControllerProviderElement(super.provider);

  @override
  int get houseId => (origin as BhkTemplateControllerProvider).houseId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
