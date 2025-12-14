import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserSessionService {
  static const String keyRole = 'user_role';
  static const String keyTenantId = 'tenant_id';
  static const String keyBiometricEnabled = 'biometric_enabled';

  final FirebaseFirestore? _firestore; // Optional to keep backward compatibility or just use dependency injection
  final NotificationService? _notificationService;

  UserSessionService({FirebaseFirestore? firestore, NotificationService? notificationService}) 
      : _firestore = firestore, _notificationService = notificationService;

  Future<void> saveSession({required String role, int? tenantId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyRole, role);
    if (tenantId != null) {
      await prefs.setInt(keyTenantId, tenantId);
    } else {
      await prefs.remove(keyTenantId);
    }
  }

  Future<void> saveFcmToken(String uid) async {
    if (_firestore == null || _notificationService == null) return;
    
    try {
      final token = await _notificationService!.getFcmToken();
      if (token != null) {
        // user_devices/{uid} or users/{uid}
        // Let's us users/{uid} merge true
        await _firestore!.collection('users').doc(uid).set({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      // Ignore errors in token saving to not block login
      print('Error saving FCM Token: $e');
    }
  }

  Future<void> saveTenantFcmToken(int tenantId) async {
     if (_firestore == null || _notificationService == null) return;
     try {
       final token = await _notificationService!.getFcmToken();
       if (token != null) {
         // Query by ID for tenants (legacy structure)
         final snapshot = await _firestore!.collection('tenants').where('id', isEqualTo: tenantId).limit(1).get();
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyRole);
    await prefs.remove(keyTenantId);
    if (_notificationService != null) {
        await _notificationService!.cancelAll(); // Cancel local reminders on logout
    }
  }

  Future<Map<String, dynamic>> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString(keyRole);
    final tenantId = prefs.getInt(keyTenantId);
    return {
      'role': role,
      'tenantId': tenantId,
    };
  }

  Future<void> saveBiometricPreference(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyBiometricEnabled, enabled);
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyBiometricEnabled) ?? false;
  }
}



