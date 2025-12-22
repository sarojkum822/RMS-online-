
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import '../../../../domain/entities/tenant.dart';
import '../../../../domain/entities/tenancy.dart'; // Import
import '../../../providers/data_providers.dart';
import '../../../../data/repositories/owner_repository_impl.dart'; // For email uniqueness check
import 'dart:io';
import 'package:uuid/uuid.dart'; // import uuid
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../house/house_controller.dart'; 
import '../rent/rent_controller.dart'; 

part 'tenant_controller.g.dart';

@riverpod
@riverpod
Stream<Tenancy?> activeTenancy(ActiveTenancyRef ref, String tenantId) {
  final repo = ref.watch(tenantRepositoryProvider);
  // Efficiently stream only the active tenancy for this tenant (owner-side)
  return repo.watchActiveTenancyForTenant(tenantId);
}

/// For TENANT-SIDE ACCESS: Uses ownerId from tenant profile
/// because tenants log in with their own Firebase Auth credentials, not the owner's.
@riverpod
Stream<Tenancy?> activeTenancyForTenantAccess(
  ActiveTenancyForTenantAccessRef ref, 
  String tenantId, 
  String ownerId,
) {
  final repo = ref.watch(tenantRepositoryProvider);
  return repo.watchActiveTenancyForTenantAccess(tenantId, ownerId);
}

@Riverpod(keepAlive: true)
class TenantController extends _$TenantController {
  @override
  Stream<List<Tenant>> build() {
    final repo = ref.watch(tenantRepositoryProvider);
    // Direct Firestore fetch - no local caching needed
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
    File? imageFile,
    required DateTime startDate,
    double? initialElectricReading, 
    double? securityDeposit,
    double? openingBalance,
    String? notes, 
    // NEW Fields
    double? advanceAmount,
    bool policeVerification = false,
    String? idProof,
    String? address,
    String? dob,
    String? gender,
    int memberCount = 1,
  }) async {
    // 0. SECURITY: Check if email is already registered as an owner
    if (email != null && email.isNotEmpty) {
      final ownerRepo = ref.read(ownerRepositoryProvider);
      // Need to cast to get the isEmailRegisteredAsOwner method
      if (ownerRepo is OwnerRepositoryImpl) {
        final isOwnerEmail = await ownerRepo.isEmailRegisteredAsOwner(email);
        if (isOwnerEmail) {
          throw Exception('This email is already registered as an owner. Owner and tenant emails cannot be the same.');
        }
      }
    }

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
        authId: authId, 
        isActive: true,
        ownerId: ownerId,
        // New Fields
        advanceAmount: advanceAmount ?? 0.0,
        policeVerification: policeVerification,
        idProof: idProof,
        address: address,
        dob: dob,
        gender: gender,
        memberCount: memberCount, 
        notes: null, 
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
        securityDeposit: securityDeposit ?? 0.0,
        openingBalance: openingBalance ?? 0.0, 
        status: TenancyStatus.active,
        notes: notes, // Tenancy Notes passed here
      );
      
      await createTenancy(tenancy, houseId);
      
      // 4. Record Initial Electric Reading (Linked to Flat)
      if (initialElectricReading != null) {
          final rentRepo = ref.read(rentRepositoryProvider);
          await rentRepo.addElectricReading(unitId, startDate, initialElectricReading);
          // Invalidate cache
          ref.invalidate(initialReadingProvider(unitId));
      }

      // 5. Auto-generate first month's rent bill
      try {
        await ref.read(rentControllerProvider.notifier).generateRentForCurrentMonth();
      } catch (e) {
        debugPrint('Note: Could not auto-generate first rent bill: $e');
        // Don't fail tenant creation if rent generation fails
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
     // NOTE: Updating auth now requires Knowing the old password. 
     // Since we don't store it, the owner must ask the tenant or just reset it.
     // For now, retaining logically but might fail if oldPassword is incorrect.
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

  // Removed _deleteTenantAuth because we no longer store passwords to authenticate the delete action.
  // Deletion will only remove the database record. Auth user remains (orphaned) until Admin cleanup.

  Future<Tenant?> login(String email, String password) async {
    final repo = ref.read(tenantRepositoryProvider);
    return repo.authenticateTenant(email, password);
  }

  // Google Login removed - use email/password login only

  Future<void> endTenancy(String tenancyId) async {
    final repo = ref.read(tenantRepositoryProvider);
    
    // Fetch directly (Optimization)
    final tenancy = await repo.getTenancy(tenancyId);
    if (tenancy == null) throw Exception('Tenancy not found');

    // 1. End Tenancy
    await repo.endTenancy(tenancyId);

    // 2. Vacate Unit
    final propertyRepo = ref.read(propertyRepositoryProvider);
    final unit = await propertyRepo.getUnit(tenancy.unitId);
    if (unit != null) {
      await propertyRepo.updateUnit(unit.copyWith(
        isOccupied: false,
        currentTenancyId: null, 
      ));
      ref.invalidate(houseUnitsProvider(unit.houseId));
    }
  }

  // --- NEW: Slide Actions Logic ---

  Future<void> moveOutTenant(String tenantId, String? tenancyId) async {
    final repo = ref.read(tenantRepositoryProvider);
    
    // 1. Update Tenant Profile
    final tenant = await repo.getTenant(tenantId);
    if (tenant != null) {
      await repo.updateTenant(tenant.copyWith(isActive: false));
    }

    // 2. If active tenancy exists, end it
    if (tenancyId != null && tenancyId.isNotEmpty) {
      try {
        await endTenancy(tenancyId);
      } catch (e) {
        print('Ignore endTenancy error if already ended: $e');
      }
    }
  }

  Future<void> moveInTenant({
    required String tenantId,
    required String houseId,
    required String unitId,
    required double agreedRent,
    required DateTime startDate,
  }) async {
    final repo = ref.read(tenantRepositoryProvider);
    final ownerId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // 1. Update Tenant Profile to Active
    final tenant = await repo.getTenant(tenantId);
    if (tenant != null) {
      await repo.updateTenant(tenant.copyWith(isActive: true));
    }

    // 2. Create New Tenancy
    final tenancy = Tenancy(
      id: const Uuid().v4(),
      tenantId: tenantId,
      unitId: unitId,
      ownerId: ownerId,
      startDate: startDate,
      agreedRent: agreedRent,
      status: TenancyStatus.active,
    );
    
    await createTenancy(tenancy, houseId);
  }

  Future<void> deleteTenantsBatch(List<String> tenantIds) async {
      final repo = ref.read(tenantRepositoryProvider);
      
      int successCount = 0;
      int failCount = 0;
      String lastError = '';

      // Process sequentially
      for (final id in tenantIds) {
          try {
             // 1. Auth Cleanup REMOVED (No Password)
             // 2. Cascade Delete
             await repo.deleteTenantCascade(id, null);
             
             // 3. Invalidate local
             ref.invalidate(activeTenancyProvider(id));
             successCount++;
             
          } catch (e) {
             print('Error deleting tenant $id in batch: $e');
             failCount++;
             lastError = e.toString();
          }
      }
      
      if (failCount > 0) {
          throw Exception('Failed to delete $failCount tenants. Last error: $lastError');
      }
  }

  Future<void> deleteTenant(String id, String? unitId, String? houseId) async {
    final repo = ref.read(tenantRepositoryProvider);
    
    // Auth Cleanup REMOVED

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
