import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserSessionService {
  User? get currentUser => FirebaseAuth.instance.currentUser;
  static const String keyRole = 'user_role';
  static const String keyTenantId = 'tenant_id';
  static const String keyBiometricEnabled = 'k_biometric_enabled'; // Matches SecureStorageService

  final FirebaseFirestore? _firestore; // Optional to keep backward compatibility or just use dependency injection
  final NotificationService? _notificationService;

  UserSessionService({FirebaseFirestore? firestore, NotificationService? notificationService}) 
      : _firestore = firestore, _notificationService = notificationService;

  Future<void> saveSession({required String role, String? tenantId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyRole, role);
      if (tenantId != null) {
        await prefs.setString(keyTenantId, tenantId);
      } else {
        await prefs.remove(keyTenantId);
      }
    } catch (e) {
      print('Error saving session: $e');
    }
  }

  Future<void> saveFcmToken(String uid) async {
    if (_firestore == null || _notificationService == null) return;
    
    try {
      final token = await _notificationService.getFcmToken();
      if (token != null) {
        // user_devices/{uid} or users/{uid}
        // Let's us users/{uid} merge true
        await _firestore.collection('users').doc(uid).set({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      // Ignore errors in token saving to not block login
      print('Error saving FCM Token: $e');
    }
  }

  Future<void> saveTenantFcmToken(String tenantId) async {
     if (_firestore == null || _notificationService == null) return;
     try {
       final token = await _notificationService.getFcmToken();
       if (token != null) {
         // Query by ID for tenants (legacy structure)
         final snapshot = await _firestore.collection('tenants').where('id', isEqualTo: tenantId).limit(1).get();
         if (snapshot.docs.isNotEmpty) {
           await snapshot.docs.first.reference.update({
             'fcmToken': token, 
             'lastTokenUpdate': FieldValue.serverTimestamp(),
           });
         }
       }
     } catch (e) {
       print('Error saving Tenant FCM Token: $e');
     }
  }

  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(keyRole);
      await prefs.remove(keyTenantId);
      if (_notificationService != null) {
          await _notificationService.cancelAll(); // Cancel local reminders on logout
      }
    } catch (e) {
      print('Error clearing session: $e');
    }
  }

  Future<Map<String, dynamic>> getSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString(keyRole);
      final tenantId = prefs.getString(keyTenantId);
      return {
        'role': role,
        'tenantId': tenantId,
      };
    } catch (e) {
      print('Error getting session: $e');
      return {'role': null, 'tenantId': null};
    }
  }

  Future<void> saveBiometricPreference(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(keyBiometricEnabled, enabled);
    } catch (e) {
      print('Error saving biometric preference: $e');
    }
  }

  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(keyBiometricEnabled) ?? false;
    } catch (e) {
      print('Error checking biometric preference: $e');
      return false;
    }
  }

  // NEW: Vault Lock - separate from general biometric auth
  static const String keyVaultLockEnabled = 'k_vault_lock_enabled';

  Future<void> saveVaultLockPreference(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(keyVaultLockEnabled, enabled);
    } catch (e) {
      print('Error saving vault lock preference: $e');
    }
  }

  Future<bool> isVaultLockEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(keyVaultLockEnabled) ?? false;
    } catch (e) {
      print('Error checking vault lock preference: $e');
      return false;
    }
  }
}



