import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // NEW
import '../../core/services/backup_service.dart';
import '../../core/services/print_service.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/data_management_service.dart';
import '../../core/services/notification_service.dart'; // NEW
import '../../core/services/user_session_service.dart';
import '../../core/services/migration_service.dart';
import '../../core/services/pdf_service.dart'; // NEW // NEW
import '../../data/datasources/local/database.dart' hide Unit; // Keeping for BackupService
import '../../data/repositories/property_repository_impl.dart';
import '../../data/repositories/rent_repository_impl.dart';
import '../../data/repositories/tenant_repository_impl.dart';
import '../../core/services/storage_service.dart'; // NEW
import '../../domain/repositories/i_property_repository.dart';
import '../../domain/repositories/i_rent_repository.dart';
import '../../domain/repositories/i_tenant_repository.dart';
import '../../domain/repositories/i_owner_repository.dart';
import '../../data/repositories/owner_repository_impl.dart';
import '../../domain/entities/house.dart'; 
import '../../domain/repositories/i_notice_repository.dart';
import '../../data/repositories/notice_repository_impl.dart';
import '../../domain/repositories/i_maintenance_repository.dart';
import '../../data/repositories/maintenance_repository_impl.dart';
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

// Auth Provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Notice Repository Provider
final noticeRepositoryProvider = Provider<INoticeRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return NoticeRepositoryImpl(firestore);
});

// Maintenance Repository Provider
final maintenanceRepositoryProvider = Provider<IMaintenanceRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return MaintenanceRepositoryImpl(firestore);
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
  final firestore = ref.watch(firestoreProvider);
  return BackupService(firestore);
}

final migrationServiceProvider = Provider<MigrationService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final dataManager = ref.watch(dataManagementServiceProvider);
  return MigrationService(firestore, dataManager);
});

@Riverpod(keepAlive: true)
PrintService printService(PrintServiceRef ref) {
  return PrintService();
}

@Riverpod(keepAlive: true)
NotificationService notificationService(NotificationServiceRef ref) {
  return NotificationService();
}

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return UserSessionService(firestore: firestore, notificationService: notificationService);
});

final dataManagementServiceProvider = Provider<DataManagementService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return DataManagementService(firestore);
});

final pdfServiceProvider = Provider<PdfService>((ref) {
  return PdfService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final allUnitsProvider = StreamProvider<List<Unit>>((ref) {
  final repo = ref.watch(propertyRepositoryProvider);
  return repo.getAllUnits();
});
