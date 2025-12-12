import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserSessionService {
  static const String keyRole = 'user_role';
  static const String keyTenantId = 'tenant_id';

  Future<void> saveSession({required String role, int? tenantId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyRole, role);
    if (tenantId != null) {
      await prefs.setInt(keyTenantId, tenantId);
    } else {
      await prefs.remove(keyTenantId);
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyRole);
    await prefs.remove(keyTenantId);
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
}

final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  return UserSessionService();
});
