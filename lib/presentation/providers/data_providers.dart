import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/print_service.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/data_management_service.dart'; // NEW
import '../../data/datasources/local/database.dart' hide Unit; // Keeping for BackupService
import '../../data/repositories/property_repository_impl.dart';
import '../../data/repositories/rent_repository_impl.dart';
import '../../data/repositories/tenant_repository_impl.dart';
import '../../domain/repositories/i_property_repository.dart';
import '../../domain/repositories/i_rent_repository.dart';
import '../../domain/repositories/i_tenant_repository.dart';
import '../../domain/repositories/i_owner_repository.dart';
import '../../data/repositories/owner_repository_impl.dart';
import '../../domain/entities/house.dart'; 
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_providers.g.dart';

// Database Provider (Legacy / Backup Only)
@Riverpod(keepAlive: true)
AppDatabase database(DatabaseRef ref) {
  return AppDatabase();
}

// Firestore Provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Repository Providers
@Riverpod(keepAlive: true)
IPropertyRepository propertyRepository(PropertyRepositoryRef ref) {
  final firestore = ref.watch(firestoreProvider);
  return PropertyRepositoryImpl(firestore);
}

@Riverpod(keepAlive: true)
ITenantRepository tenantRepository(TenantRepositoryRef ref) {
  final firestore = ref.watch(firestoreProvider);
  return TenantRepositoryImpl(firestore);
}

@Riverpod(keepAlive: true)
IRentRepository rentRepository(RentRepositoryRef ref) {
  final firestore = ref.watch(firestoreProvider);
  return RentRepositoryImpl(firestore);
}

final ownerRepositoryProvider = Provider<IOwnerRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return OwnerRepositoryImpl(firestore);
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

final dataManagementServiceProvider = Provider<DataManagementService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return DataManagementService(firestore);
});

final allUnitsProvider = FutureProvider<List<Unit>>((ref) {
  final repo = ref.watch(propertyRepositoryProvider);
  return repo.getAllUnits();
});
