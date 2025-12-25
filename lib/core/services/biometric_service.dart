import 'package:local_auth/local_auth.dart';
// for debugPrint

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      
      if (!canAuthenticate) return false;

      // Check if any biometrics are actually enrolled
      final List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();
      
      return availableBiometrics.isNotEmpty;
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
      rethrow; // Let the UI handle specific errors or show generic message
    }
  }
}
