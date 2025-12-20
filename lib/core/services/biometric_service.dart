import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart'; // for debugPrint

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      // Gracefully handle errors (e.g., missing biometric hardware)
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await auth.authenticate(
        localizedReason: 'Please authenticate to access KirayaBook Pro',
      );
    } catch (e) {
      // Catch all exceptions including LocalAuthException (noCredentialsSet)
      // which might not be caught by PlatformException depending on version
      debugPrint('Biometric Auth Error: $e');
      return false;
    }
  }
}
