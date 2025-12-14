import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../providers/data_providers.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../house/house_controller.dart'; 
import '../rent/rent_controller.dart'; // Import RentController 

part 'tenant_controller.g.dart';

@riverpod
class TenantController extends _$TenantController {
  @override
  FutureOr<List<Tenant>> build() async {
    return _fetchTenants();
  }

  Future<List<Tenant>> _fetchTenants() async {
    final repo = ref.watch(tenantRepositoryProvider);
    return repo.getAllTenants();
  }

  Future<void> addTenant(Tenant tenant, {double? initialElectricReading, File? imageFile}) async {
    final repo = ref.read(tenantRepositoryProvider);
    final newTenantId = await repo.createTenant(tenant, imageFile: imageFile);

    // Verify unit update
    final propertyRepo = ref.read(propertyRepositoryProvider);
    final unit = await propertyRepo.getUnit(tenant.unitId);
    if (unit != null) {
      final rentToLock = tenant.agreedRent ?? unit.baseRent;
      await propertyRepo.updateUnit(unit.copyWith(
        isOccupied: true,
        tenantId: newTenantId,
        editableRent: rentToLock,
        baseRent: rentToLock,
      ));
    }

    if (initialElectricReading != null) {
      await ref.read(rentRepositoryProvider).addElectricReading(
        tenant.unitId,
        tenant.startDate,
        initialElectricReading,
      );
    }
    
    // FAST UPDATE: Update local state immediately instead of waiting for network fetch
    // This fixes "Unknown" issue by ensuring the tenant is in the list BEFORE rent generation
    final currentList = state.value ?? [];
    final newTenant = tenant.copyWith(id: newTenantId);
    state = AsyncValue.data([...currentList, newTenant]);
    
    ref.invalidate(houseUnitsProvider(tenant.houseId)); 
    
    // Auto-Generate Rent for this new tenant immediately
    ref.read(rentControllerProvider.notifier).generateRentForCurrentMonth();
  }

  Future<void> updateTenant(Tenant tenant, {File? imageFile}) async {
     final repo = ref.read(tenantRepositoryProvider);
     await repo.updateTenant(tenant, imageFile: imageFile);
     
     // Sync Unit Rent if Tenant Rent changed
     if (tenant.agreedRent != null) {
        final propertyRepo = ref.read(propertyRepositoryProvider);
        final unit = await propertyRepo.getUnit(tenant.unitId);
        if (unit != null) {
           await propertyRepo.updateUnit(unit.copyWith(
              baseRent: tenant.agreedRent!,
              editableRent: tenant.agreedRent!,
           ));
           ref.invalidate(houseUnitsProvider(tenant.houseId));
        }
     }
     
     ref.invalidateSelf();
  }

  Future<void> registerTenant({
    required int houseId,
    required int unitId,
    required String tenantName,
    required String phone,
    String? email,
    String? password,
    double? agreedRent,
    double? initialElectricReading,
    File? imageFile,
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

    final tenant = Tenant(
        id: 0,
        houseId: houseId,
        unitId: unitId,
        tenantCode: phone, 
        name: tenantName,
        phone: phone,
        email: email,
        password: password, 
        authId: authId, 
        startDate: DateTime.now(),
        status: TenantStatus.active,
        agreedRent: agreedRent,
        ownerId: FirebaseAuth.instance.currentUser?.uid ?? '', 
    );

    try {
      await addTenant(tenant, initialElectricReading: initialElectricReading, imageFile: imageFile);
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
      // We don't want to stay signed in as the new user on the secondary app
      await FirebaseAuth.instanceFor(app: app).signOut(); 
      return userCred.user?.uid;
    } catch (e) {
      rethrow;
    }
  }

  // "Sudo" Update: Login as Tenant -> Update Creds -> Logout
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
      // 1. Login as Tenant with OLD credentials
      await auth.signInWithEmailAndPassword(email: oldEmail, password: oldPassword);
      
      // 2. Update Password if changed
      if (newPassword != oldPassword && newPassword.isNotEmpty) {
          await auth.currentUser?.updatePassword(newPassword);
      }

      // 3. Update Email if changed
      if (newEmail != oldEmail && newEmail.isNotEmpty) {
          // Use modern API: verifyBeforeUpdateEmail
          // This sends a verification email to the new address.
          // The email on the account won't update until the user clicks the link.
          await auth.currentUser?.verifyBeforeUpdateEmail(newEmail);
      }
      
      // 4. Cleanup
      await auth.signOut();
    } catch (e) {
      // Ensure we sign out even if error
      await auth.signOut();
      throw Exception('Failed to update Tenant Login: $e');
    }
  }

  // Delete Tenant Auth User (Sudo Delete)
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
        await auth.currentUser?.delete(); // Actually delete from Firebase Auth
      } catch (e) {
        // If login fails (changed password?) or delete fails, just log it. 
        // We shouldn't block the Firestore delete.
        print('Warning: Failed to delete Auth user: $e');
      } finally {
         try { await auth.signOut(); } catch (_) {}
      }
  }


  // Tenant Authentication Logic
  Future<Tenant?> login(String email, String password) async {
    final repo = ref.read(tenantRepositoryProvider);
    return repo.authenticateTenant(email, password);
  }

  Future<void> deleteTenant(int id) async {
    final repo = ref.read(tenantRepositoryProvider);
    
    // 1. Fetch Tenant details before deleting
    Tenant? tenant;
    try {
       tenant = await repo.getTenant(id);
       if (tenant != null && tenant.email != null && tenant.password != null) {
          // Attempt to delete the Auth User
          await _deleteTenantAuth(tenant.email!, tenant.password!);
       }
    } catch (e) {
       print('Error during auth cleanup: $e');
    }

    // 2. Delete from Database
    await repo.deleteTenant(id);

    // 3. Free up Unit
    if (tenant != null) {
       final propertyRepo = ref.read(propertyRepositoryProvider);
       final unit = await propertyRepo.getUnit(tenant.unitId);
       if (unit != null) {
          await propertyRepo.updateUnit(unit.copyWith(isOccupied: false));
       }
    }

    ref.invalidateSelf();
  }
}
