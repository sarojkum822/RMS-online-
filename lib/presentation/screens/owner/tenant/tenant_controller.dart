import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../../domain/entities/house.dart';
import '../../../providers/data_providers.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

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
    await repo.createTenant(tenant, imageFile: imageFile);

    if (initialElectricReading != null) {
      await ref.read(rentRepositoryProvider).addElectricReading(
        tenant.unitId,
        tenant.startDate,
        initialElectricReading,
      );
    }
    
    ref.invalidateSelf();
  }

  Future<void> updateTenant(Tenant tenant, {File? imageFile}) async {
     final repo = ref.read(tenantRepositoryProvider);
     await repo.updateTenant(tenant, imageFile: imageFile);
     ref.invalidateSelf();
  }

  Future<void> addTenantWithManualUnit({
    required int houseId,
    required String unitName,
    required String floor, 
    required String tenantName,
    required String phone,
    String? email,
    String? password, 
    double? agreedRent,
    double? initialElectricReading,
    File? imageFile, // NEW
  }) async {
    final propertyRepo = ref.read(propertyRepositoryProvider);
    
    // 1. Check or Create Unit
    final units = await propertyRepo.getUnits(houseId);
    Unit? targetUnit;
    try {
      targetUnit = units.firstWhere(
        (u) => u.nameOrNumber.trim().toLowerCase() == unitName.trim().toLowerCase(),
      );
    } catch (_) {
      targetUnit = null;
    }

    int unitId;
    if (targetUnit != null) {
      unitId = targetUnit.id;
    } else {
      // Create Unit
      int parsedFloor = 0;
      final floorInt = int.tryParse(floor);
      if (floorInt != null) parsedFloor = floorInt;

      final newUnit = Unit(
        id: 0,
        houseId: houseId,
        nameOrNumber: unitName,
        floor: parsedFloor,
        baseRent: agreedRent ?? 0.0,
        defaultDueDay: 1,
      );
      unitId = await propertyRepo.createUnit(newUnit);
    }

    // 2. Create Tenant (Securely)
    String? authId;
    if (email != null && email.isNotEmpty && password != null && password.isNotEmpty) {
      try {
         authId = await _createFirebaseUser(email, password);
      } catch (e) {
         if (e.toString().contains('email-already-in-use')) {
             // DEADLOCK FIX:
             // The email exists in Auth (Zombie Account). 
             // 1. Try to Login with the provided password to see if we can "Claim" it.
             try {
                final userCred = await FirebaseAuth.instanceFor(app: Firebase.app('secondary'))
                    .signInWithEmailAndPassword(email: email, password: password);
                authId = userCred.user?.uid;
                
                // If we are here, we successfully "logged in" to the zombie account.
                // We can now reuse this User ID for the new Tenant record.
             } catch (loginError) {
                // Password didn't match (or other error). We can't claim it.
                throw Exception('This email is already registered in the system (Firebase Auth) with a DIFFERENT password. \n\nSolutions:\n1. Use the ORIGINAL password you created this user with.\n2. Use a different email address.\n3. (Developer) Go to Firebase Console -> Authentication and manually delete this user.');
             }
         } else {
            rethrow;
         }
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
        authId: authId, // Set the Real Auth ID
        startDate: DateTime.now(),
        status: TenantStatus.active,
        agreedRent: agreedRent,
        ownerId: FirebaseAuth.instance.currentUser?.uid ?? '', // Set Owner ID
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
    
    // 1. Fetch Tenant details before deleting to get credentials (if available)
    try {
       final tenant = await repo.getTenant(id);
       if (tenant != null && tenant.email != null && tenant.password != null) {
          // Attempt to delete the Auth User
          await _deleteTenantAuth(tenant.email!, tenant.password!);
       }
    } catch (e) {
       print('Error during auth cleanup: $e');
    }

    // 2. Delete from Database
    await repo.deleteTenant(id);
    ref.invalidateSelf();
  }
}
