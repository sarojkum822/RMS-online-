
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../../domain/entities/tenancy.dart'; // Import
import '../../../providers/data_providers.dart';
import 'dart:io';
import 'package:uuid/uuid.dart'; // import uuid
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../house/house_controller.dart'; 
import '../rent/rent_controller.dart'; 

part 'tenant_controller.g.dart';

@riverpod
Future<Tenancy?> activeTenancy(ActiveTenancyRef ref, String tenantId) async {
  final repo = ref.watch(tenantRepositoryProvider);
  final allTenancies = await repo.getAllTenancies();
  
  // Return the first active tenancy for this tenant
  return allTenancies.cast<Tenancy?>().firstWhere(
    (t) => t?.tenantId == tenantId && t?.status == TenancyStatus.active,
    orElse: () => null
  );
}

@Riverpod(keepAlive: true)
class TenantController extends _$TenantController {
  @override
  Stream<List<Tenant>> build() {
    final repo = ref.watch(tenantRepositoryProvider);
    return repo.getAllTenants();
  }

  // Refactored: Simply creates the Tenant profile
  Future<String> createTenantProfile(Tenant tenant, {File? imageFile}) async {
    final repo = ref.read(tenantRepositoryProvider);
    return await repo.createTenant(tenant, imageFile: imageFile);
  }

  // New: Create Tenancy
  Future<void> createTenancy(Tenancy tenancy, String houseId) async {
    final repo = ref.read(tenantRepositoryProvider);
    await repo.createTenancy(tenancy);

    // Lock Unit
    final propertyRepo = ref.read(propertyRepositoryProvider);
    final unit = await propertyRepo.getUnit(tenancy.unitId);
    if (unit != null) {
      await propertyRepo.updateUnit(unit.copyWith(
        isOccupied: true,
        currentTenancyId: tenancy.id, // Linked
        editableRent: tenancy.agreedRent,
      ));
      ref.invalidate(houseUnitsProvider(houseId)); 
    }
    
    // Generate First Month Rent (Optional / To be decided by user)
    // ref.read(rentControllerProvider.notifier).generateRentForCurrentMonth();
  }

  Future<void> updateTenant(Tenant tenant, {File? imageFile}) async {
     final repo = ref.read(tenantRepositoryProvider);
     await repo.updateTenant(tenant, imageFile: imageFile);
     // Tenancy details are now updated via Tenancy Update methods, not here.
  }

  Future<void> registerTenant({
    required String houseId,
    required String unitId,
    required String tenantName,
    required String phone,
    String? email,
    String? password,
    double? agreedRent,
    double? initialElectricReading,
    File? imageFile,
    required DateTime startDate,
  }) async {
    // 1. Create Tenant Auth (Securely)
    String? authId;
    if (email != null && email.isNotEmpty && password != null && password.isNotEmpty) {
      try {
         authId = await _createFirebaseUser(email, password);
      } on FirebaseAuthException catch (e) {
         if (e.code == 'email-already-in-use') {
             throw Exception('The email address is already in use by another account.');
         } else if (e.code == 'weak-password') {
             throw Exception('The password provided is too weak.');
         } else if (e.code == 'invalid-email') {
             throw Exception('The email address is invalid.');
         } else {
             throw Exception(e.message ?? 'Authentication failed.');
         }
      } catch (e) {
          throw Exception('Failed to create login: ${e.toString()}');
      }
    }

    final tenantId = const Uuid().v4();
    final ownerId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // 2. Create Tenant Profile
    final tenant = Tenant(
        id: tenantId,
        tenantCode: phone, 
        name: tenantName,
        phone: phone,
        email: email,
        password: password, 
        authId: authId, 
        isActive: true,
        ownerId: ownerId, 
    );

    try {
      await createTenantProfile(tenant, imageFile: imageFile);

      // 3. Create Tenancy (The Contract)
      final tenancy = Tenancy(
        id: const Uuid().v4(),
        tenantId: tenantId,
        unitId: unitId,
        ownerId: ownerId,
        startDate: startDate,
        agreedRent: agreedRent ?? 0.0,
        status: TenancyStatus.active,
      );
      
      await createTenancy(tenancy, houseId);
      
      // 4. Initial Reading
      if (initialElectricReading != null) {
          await ref.read(rentRepositoryProvider).addElectricReading(
            unitId,
            startDate,
            initialElectricReading,
          );
      }

    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
         throw Exception('A tenant with this phone number already exists.');
      }
      rethrow;
    }
  }

  Future<String?> _createFirebaseUser(String email, String password) async {
    FirebaseApp app;
    try {
      app = Firebase.app('secondary');
    } catch (_) {
      app = await Firebase.initializeApp(name: 'secondary', options: Firebase.app().options);
    }
    
    try {
      final userCred = await FirebaseAuth.instanceFor(app: app).createUserWithEmailAndPassword(email: email, password: password);
      await FirebaseAuth.instanceFor(app: app).signOut(); 
      return userCred.user?.uid;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTenantAuth({
    required String oldEmail,
    required String oldPassword,
    required String newEmail,
    required String newPassword,
  }) async {
     FirebaseApp app;
    try {
      app = Firebase.app('secondary');
    } catch (_) {
      app = await Firebase.initializeApp(name: 'secondary', options: Firebase.app().options);
    }

    final auth = FirebaseAuth.instanceFor(app: app);

    try {
      await auth.signInWithEmailAndPassword(email: oldEmail, password: oldPassword);
      if (newPassword != oldPassword && newPassword.isNotEmpty) {
          await auth.currentUser?.updatePassword(newPassword);
      }
      if (newEmail != oldEmail && newEmail.isNotEmpty) {
          await auth.currentUser?.verifyBeforeUpdateEmail(newEmail);
      }
      await auth.signOut();
    } catch (e) {
      await auth.signOut();
      throw Exception('Failed to update Tenant Login: $e');
    }
  }

  Future<void> _deleteTenantAuth(String email, String password) async {
      FirebaseApp app;
      try {
        app = Firebase.app('secondary');
      } catch (_) {
        app = await Firebase.initializeApp(name: 'secondary', options: Firebase.app().options);
      }
      final auth = FirebaseAuth.instanceFor(app: app);
      
      try {
        await auth.signInWithEmailAndPassword(email: email, password: password);
        await auth.currentUser?.delete(); 
      } catch (e) {
        print('Warning: Failed to delete Auth user: $e');
      } finally {
         try { await auth.signOut(); } catch (_) {}
      }
  }

  Future<Tenant?> login(String email, String password) async {
    final repo = ref.read(tenantRepositoryProvider);
    return repo.authenticateTenant(email, password);
  }

  Future<void> endTenancy(String tenancyId) async {
    final repo = ref.read(tenantRepositoryProvider);
    
    // Fetch tenancy to get Unit ID
    // We assume we can get it via repo or finding it from list
    // Since we don't have getTenancy(id) easily exposed on repo interface yet (maybe), 
    // let's fetch all and find. 
    // TODO: Optimize Repository to have getTenancy(id)
    final all = await repo.getAllTenancies();
    final tenancy = all.cast<Tenancy?>().firstWhere((t) => t?.id == tenancyId, orElse: () => null);

    if (tenancy == null) return;
    
    // 1. End Tenancy
    await repo.endTenancy(tenancyId);

    // 2. Vacate Unit
    final propertyRepo = ref.read(propertyRepositoryProvider);
    final unit = await propertyRepo.getUnit(tenancy.unitId);
    if (unit != null) {
      // Clear tenantId and isOccupied
      await propertyRepo.updateUnit(unit.copyWith(
        isOccupied: false,
        currentTenancyId: null, 
      ));
      
      // We need houseId to invalidate. Unit has it.
      ref.invalidate(houseUnitsProvider(unit.houseId));
    }
  }

  Future<void> deleteTenant(String id, String? unitId, String? houseId) async {
    final repo = ref.read(tenantRepositoryProvider);
    
    Tenant? tenant;
    try {
       tenant = await repo.getTenant(id);
       if (tenant != null && tenant.email != null && tenant.password != null) {
          await _deleteTenantAuth(tenant.email!, tenant.password!);
       }
    } catch (e) {
       print('Error during auth cleanup: $e');
    }

    await repo.deleteTenant(id);
    // Note: Tenancies might need separate cleanup or cascade delete at repository level

    if (unitId != null && houseId != null) {
       final propertyRepo = ref.read(propertyRepositoryProvider);
       final unit = await propertyRepo.getUnit(unitId);
       if (unit != null) {
          await propertyRepo.updateUnit(unit.copyWith(isOccupied: false, currentTenancyId: null));
          ref.invalidate(houseUnitsProvider(houseId));
       }
    }
  }
}
