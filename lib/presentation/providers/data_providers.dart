import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/print_service.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/data_management_service.dart';
import '../../core/services/notification_service.dart'; // NEW
import '../../core/services/user_session_service.dart';
import '../../core/services/migration_service.dart';
import '../../core/services/pdf_service.dart'; // NEW
import '../../core/services/pdf_generator_service.dart'; // NEW Receipt Service
import '../../core/services/database_migration_service.dart'; // Database Migration
import '../../data/datasources/local/database.dart' as db; // Re-added for Expenses logic
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
import '../../domain/entities/owner.dart'; // For ownerByIdProvider
import '../../domain/entities/tenancy.dart'; 
import '../../domain/entities/notice.dart'; 
import '../../domain/repositories/i_notice_repository.dart';
import '../../data/repositories/notice_repository_impl.dart';
import '../../domain/repositories/i_maintenance_repository.dart';
import '../../data/repositories/maintenance_repository_impl.dart';
import '../../domain/repositories/i_expense_repository.dart'; // NEW
import '../../data/repositories/expense_repository_impl.dart'; // NEW
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_providers.g.dart';

// Database Provider Removed

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

final expenseRepositoryProvider = Provider<IExpenseRepository>((ref) {
   // Note: ExpenseRepo uses Local Database (Drift), not Firestore directly in this implementation plan
   // We use AppDatabase singleton or new instance. 
   return ExpenseRepositoryImpl(db.AppDatabase());
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

/// Get owner by ID - for tenant-side access to owner's subscription plan
final ownerByIdProvider = FutureProvider.family<Owner?, String>((ref, ownerId) async {
  final repo = ref.watch(ownerRepositoryProvider);
  return repo.getOwnerById(ownerId);
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
  return UserSessionService(notificationService: notificationService);
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

final pdfGeneratorServiceProvider = Provider<PdfGeneratorService>((ref) {
  return PdfGeneratorService();
});

final allUnitsProvider = StreamProvider<List<Unit>>((ref) {
  final repo = ref.watch(propertyRepositoryProvider);
  return repo.getAllUnits();
});

final allTenanciesProvider = StreamProvider<List<Tenancy>>((ref) {
  final repo = ref.watch(tenantRepositoryProvider);
  return repo.getAllTenancies();
});

// Unit Details Provider
final unitDetailsProvider = FutureProvider.family<Unit?, String>((ref, unitId) async {
  final repo = ref.watch(propertyRepositoryProvider);
  return repo.getUnit(unitId);
});

// House Details Provider
final houseDetailsProvider = FutureProvider.family<House?, String>((ref, houseId) async {
  final repo = ref.watch(propertyRepositoryProvider);
  return repo.getHouse(houseId);
});

// Unit Details Provider for Tenant Access
final unitDetailsForTenantProvider = FutureProvider.family<Unit?, ({String unitId, String ownerId}) >((ref, arg) async {
  final repo = ref.watch(propertyRepositoryProvider);
  return repo.getUnitForTenant(arg.unitId, arg.ownerId);
});

final houseDetailsForTenantProvider = FutureProvider.family<House?, ({String houseId, String ownerId}) >((ref, arg) async {
  final repo = ref.watch(propertyRepositoryProvider);
  return repo.getHouseForTenant(arg.houseId, arg.ownerId);
});

final noticesForHouseProvider = StreamProvider.family<List<Notice>, ({String houseId, String ownerId}) >((ref, arg) {
  final repo = ref.watch(noticeRepositoryProvider);
  return repo.watchNoticesForHouse(arg.houseId, arg.ownerId);
});

/// Notices provider for tenant dashboard - includes global, house, and unit-level broadcasts
final noticesForTenantProvider = StreamProvider.family<List<Notice>, ({String houseId, String? unitId, String ownerId}) >((ref, arg) {
  final repo = ref.watch(noticeRepositoryProvider);
  return repo.watchNoticesForTenant(arg.houseId, arg.unitId, arg.ownerId);
});

/// ALL notices for owner - unified history view (used in BroadcastCenterSheet History tab)
final allOwnerNoticesProvider = StreamProvider.family<List<Notice>, String>((ref, ownerId) {
  final repo = ref.watch(noticeRepositoryProvider);
  return repo.watchNoticesForOwner(ownerId);
});

final databaseMigrationServiceProvider = Provider<DatabaseMigrationService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return DatabaseMigrationService(firestore);
});

