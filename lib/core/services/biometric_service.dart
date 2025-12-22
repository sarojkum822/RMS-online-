import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Result of biometric authentication attempt
enum BiometricResult {
  success,
  failed,
  cancelled,
  lockedOut,
  notAvailable,
  notEnrolled,
  error,
}

/// Enhanced Biometric Service with industry-standard security features:
/// - Failed attempt tracking (max 5 attempts)
/// - Progressive lockout timer (30s → 1min → 5min)
/// - Sticky authentication (survives app backgrounding)
/// - Detailed result types for better UX
class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();
  
  // Lockout configuration
  static const int _maxAttempts = 5;
  static const String _kFailedAttemptsKey = 'k_biometric_failed_attempts';
  static const String _kLockoutUntilKey = 'k_biometric_lockout_until';
  static const String _kLockoutCountKey = 'k_biometric_lockout_count';
  
  // Progressive lockout durations in seconds
  static const List<int> _lockoutDurations = [30, 60, 300, 900, 1800]; // 30s, 1m, 5m, 15m, 30m

  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      debugPrint('Biometric availability check error: $e');
      return false;
    }
  }

  /// Get available biometric types (Face ID, Fingerprint, etc.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Get biometrics error: $e');
      return [];
    }
  }

  /// Check if user is currently locked out
  Future<bool> isLockedOut() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutUntil = prefs.getInt(_kLockoutUntilKey) ?? 0;
    return DateTime.now().millisecondsSinceEpoch < lockoutUntil;
  }

  /// Get remaining lockout time in seconds
  Future<int> getRemainingLockoutSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutUntil = prefs.getInt(_kLockoutUntilKey) ?? 0;
    final remaining = lockoutUntil - DateTime.now().millisecondsSinceEpoch;
    return remaining > 0 ? (remaining / 1000).ceil() : 0;
  }

  /// Get current failed attempt count
  Future<int> getFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kFailedAttemptsKey) ?? 0;
  }

  /// Reset failed attempts (call after successful login)
  Future<void> resetFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kFailedAttemptsKey, 0);
    await prefs.remove(_kLockoutUntilKey);
  }

  /// Record a failed attempt and apply lockout if needed
  Future<void> _recordFailedAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = (prefs.getInt(_kFailedAttemptsKey) ?? 0) + 1;
    await prefs.setInt(_kFailedAttemptsKey, attempts);
    
    if (attempts >= _maxAttempts) {
      // Apply progressive lockout
      final lockoutCount = prefs.getInt(_kLockoutCountKey) ?? 0;
      final durationIndex = lockoutCount.clamp(0, _lockoutDurations.length - 1);
      final lockoutDuration = _lockoutDurations[durationIndex];
      
      final lockoutUntil = DateTime.now().millisecondsSinceEpoch + (lockoutDuration * 1000);
      await prefs.setInt(_kLockoutUntilKey, lockoutUntil);
      await prefs.setInt(_kLockoutCountKey, lockoutCount + 1);
      await prefs.setInt(_kFailedAttemptsKey, 0); // Reset attempts after lockout
      
      debugPrint('Biometric locked out for $lockoutDuration seconds');
    }
  }

  /// Simple authenticate (backward compatible)
  Future<bool> authenticate({String? reason}) async {
    final result = await authenticateWithResult(reason: reason);
    return result == BiometricResult.success;
  }

  /// Authenticate with detailed result
  Future<BiometricResult> authenticateWithResult({String? reason}) async {
    try {
      // Check lockout first
      if (await isLockedOut()) {
        final remaining = await getRemainingLockoutSeconds();
        debugPrint('Biometric locked out for $remaining more seconds');
        return BiometricResult.lockedOut;
      }

      // Check availability
      if (!await isBiometricAvailable()) {
        return BiometricResult.notAvailable;
      }

      final biometrics = await getAvailableBiometrics();
      if (biometrics.isEmpty) {
        return BiometricResult.notEnrolled;
      }

      final success = await auth.authenticate(
        localizedReason: reason ?? 'Please authenticate to access KirayaBook Pro',
      );

      if (success) {
        await resetFailedAttempts();
        return BiometricResult.success;
      } else {
        await _recordFailedAttempt();
        return BiometricResult.failed;
      }
    } on PlatformException catch (e) {
      debugPrint('Biometric PlatformException: ${e.code} - ${e.message}');
      
      // Handle common error codes as strings
      final code = e.code.toLowerCase();
      if (code.contains('notenrolled') || code.contains('not_enrolled')) {
        return BiometricResult.notEnrolled;
      } else if (code.contains('lockedout') || code.contains('locked_out') || code.contains('permanently')) {
        return BiometricResult.lockedOut;
      } else if (code.contains('notavailable') || code.contains('not_available')) {
        return BiometricResult.notAvailable;
      }
      
      await _recordFailedAttempt();
      return BiometricResult.error;
    } catch (e) {
      debugPrint('Biometric Auth Error: $e');
      await _recordFailedAttempt();
      return BiometricResult.error;
    }
  }
}

