import 'package:shared_preferences/shared_preferences.dart';

/// Session Manager for handling app inactivity timeout
/// 
/// SECURITY: Clears session if user hasn't opened app for specified duration.
/// Default timeout: 1 day (24 hours)
class SessionManager {
  static const _kLastActivityKey = 'k_last_activity_timestamp';
  static const sessionTimeout = Duration(days: 1);

  /// Record current activity timestamp
  static Future<void> recordActivity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLastActivityKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Check if session has expired (user hasn't opened app for > 1 day)
  static Future<bool> isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActivity = prefs.getInt(_kLastActivityKey);
    
    if (lastActivity == null) {
      // First time user, session is valid
      return false;
    }
    
    final lastActivityDate = DateTime.fromMillisecondsSinceEpoch(lastActivity);
    final now = DateTime.now();
    final difference = now.difference(lastActivityDate);
    
    return difference > sessionTimeout;
  }

  /// Get remaining time before session expires
  static Future<Duration?> getTimeUntilExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActivity = prefs.getInt(_kLastActivityKey);
    
    if (lastActivity == null) return null;
    
    final lastActivityDate = DateTime.fromMillisecondsSinceEpoch(lastActivity);
    final expiryDate = lastActivityDate.add(sessionTimeout);
    final now = DateTime.now();
    
    if (now.isAfter(expiryDate)) return Duration.zero;
    return expiryDate.difference(now);
  }

  /// Clear session (for logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLastActivityKey);
  }
}
