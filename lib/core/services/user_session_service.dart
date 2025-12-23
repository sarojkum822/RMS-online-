import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'session_manager.dart'; // NEW: Session timeout

class UserSessionService {
  User? get currentUser => FirebaseAuth.instance.currentUser;
  static const String keyRole = 'user_role';
  static const String keyTenantId = 'tenant_id';
  static const String keyBiometricEnabled = 'k_biometric_enabled'; // Matches SecureStorageService

  final NotificationService? _notificationService;

  UserSessionService({NotificationService? notificationService}) 
      : _notificationService = notificationService;

  Future<void> saveSession({required String role, String? tenantId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyRole, role);
      if (tenantId != null) {
        await prefs.setString(keyTenantId, tenantId);
      } else {
        await prefs.remove(keyTenantId);
      }
      
      // Record activity timestamp for session timeout (1-day inactivity)
      await SessionManager.recordActivity();
    } catch (e) {
//      print('Error saving session: $e');
    }
  }

  // FCM token saving logic removed as per user request

  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(keyRole);
      await prefs.remove(keyTenantId);
      
      // Clear session timestamp
      await SessionManager.clearSession();
      
      if (_notificationService != null) {
          await _notificationService.cancelAll(); // Cancel local reminders on logout
      }
    } catch (e) {
//      print('Error clearing session: $e');
    }
  }

  /// Get session info - also records activity and checks for expiry
  Future<Map<String, dynamic>> getSession() async {
    try {
      // Check for session expiry (1-day inactivity)
      final isExpired = await SessionManager.isSessionExpired();
      if (isExpired) {
        await clearSession();
        return {'role': null, 'tenantId': null, 'expired': true};
      }
      
      // Record activity (user opened app)
      await SessionManager.recordActivity();
      
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString(keyRole);
      final tenantId = prefs.getString(keyTenantId);
      return {
        'role': role,
        'tenantId': tenantId,
        'expired': false,
      };
    } catch (e) {
//      print('Error getting session: $e');
      return {'role': null, 'tenantId': null, 'expired': false};
    }
  }

  Future<void> saveBiometricPreference(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(keyBiometricEnabled, enabled);
    } catch (e) {
//      print('Error saving biometric preference: $e');
    }
  }

  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(keyBiometricEnabled) ?? false;
    } catch (e) {
//      print('Error checking biometric preference: $e');
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
//      print('Error saving vault lock preference: $e');
    }
  }

  Future<bool> isVaultLockEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(keyVaultLockEnabled) ?? false;
    } catch (e) {
//      print('Error checking vault lock preference: $e');
      return false;
    }
  }
}



