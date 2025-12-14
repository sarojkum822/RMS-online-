import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart';

class SecureStorageService {
  static const _kEmailKey = 'k_secure_email';
  static const _kPasswordKey = 'k_secure_password';
  static const _kBiometricEnabledKey = 'k_biometric_enabled';
  
  // Hardcoded key for MVP (In prod, use Keystore/Keychain)
  final _key = Key.fromUtf8('RentPilotProSecretKey2024Secure!'); // 32 chars
  final _iv = IV.fromLength(16);
  late Encrypter _encrypter;

  SecureStorageService() {
    _encrypter = Encrypter(AES(_key));
  }

  Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedEmail = _encrypter.encrypt(email, iv: _iv);
    final encryptedPassword = _encrypter.encrypt(password, iv: _iv);
    
    await prefs.setString(_kEmailKey, encryptedEmail.base64);
    await prefs.setString(_kPasswordKey, encryptedPassword.base64);
  }

  Future<Map<String, String>?> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final emailStr = prefs.getString(_kEmailKey);
    final passwordStr = prefs.getString(_kPasswordKey);
    
    if (emailStr == null || passwordStr == null) return null;
    
    try {
      final email = _encrypter.decrypt64(emailStr, iv: _iv);
      final password = _encrypter.decrypt64(passwordStr, iv: _iv);
      return {'email': email, 'password': password};
    } catch (e) {
      return null;
    }
  }

  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kEmailKey);
    await prefs.remove(_kPasswordKey);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBiometricEnabledKey, enabled);
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kBiometricEnabledKey) ?? false;
  }
}
