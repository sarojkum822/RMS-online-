import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/print_service.dart';
import '../../core/services/biometric_service.dart';
import '../../data/datasources/local/database.dart' hide Unit; // Unit conflict with house.dart
import '../../data/repositories/property_repository_impl.dart';
import '../../data/repositories/rent_repository_impl.dart';
import '../../data/repositories/tenant_repository_impl.dart';
import '../../domain/repositories/i_property_repository.dart';
import '../../domain/repositories/i_rent_repository.dart';
import '../../domain/repositories/i_tenant_repository.dart';
import '../../domain/repositories/i_owner_repository.dart';
import '../../data/repositories/owner_repository_impl.dart';
import '../../domain/entities/house.dart'; // For Unit
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_providers.g.dart';

// Database Provider
@Riverpod(keepAlive: true)
AppDatabase database(DatabaseRef ref) {
  return AppDatabase();
}

// Repository Providers
@Riverpod(keepAlive: true)
IPropertyRepository propertyRepository(PropertyRepositoryRef ref) {
  final db = ref.watch(databaseProvider);
  return PropertyRepositoryImpl(db);
}

@Riverpod(keepAlive: true)
ITenantRepository tenantRepository(TenantRepositoryRef ref) {
  final db = ref.watch(databaseProvider);
  return TenantRepositoryImpl(db);
}

@Riverpod(keepAlive: true)
IRentRepository rentRepository(RentRepositoryRef ref) {
  final db = ref.watch(databaseProvider);
  return RentRepositoryImpl(db);
}

final ownerRepositoryProvider = Provider<IOwnerRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return OwnerRepositoryImpl(db);
});

@Riverpod(keepAlive: true)
BackupService backupService(BackupServiceRef ref) {
  final db = ref.watch(databaseProvider);
  return BackupService(db);
}

@Riverpod(keepAlive: true)
PrintService printService(PrintServiceRef ref) {
  final db = ref.watch(databaseProvider);
  return PrintService(db);
}

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

final allUnitsProvider = FutureProvider<List<Unit>>((ref) {
  final repo = ref.watch(propertyRepositoryProvider);
  return repo.getAllUnits();
});
