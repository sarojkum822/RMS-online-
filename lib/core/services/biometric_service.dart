import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    return canAuthenticate;
  }

  Future<bool> authenticate() async {
    try {
      return await auth.authenticate(
        localizedReason: 'Please authenticate to access RentPilot Pro',
        // options parameter removed to resolve build error with local_auth 3.0.0?
        // If stickyAuth/biometricOnly are needed, check correct API usage for this version.
      );
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable') {
         return false;
      }
      return false;
    }
  }
}
