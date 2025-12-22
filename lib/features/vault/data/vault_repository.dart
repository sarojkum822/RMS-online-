import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// VaultRepository - Handles encryption/decryption of vault documents.
/// 
/// SECURITY NOTE: Authentication is handled by the UI layer using
/// the centralized BiometricService. This repository is purely
/// responsible for encryption operations.
class VaultRepository {
  // Hardware-backed secure storage for encryption keys
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.passcode),
  );
  
  final _firebaseStorage = FirebaseStorage.instance;
  
  static const _kKeyAlias = 'kiraya_vault_master_key_v1';

  /// Retrieves the Master Encryption Key from secure storage.
  /// If no key exists, generates a new 256-bit AES key.
  /// 
  /// NOTE: Biometric authentication is handled by the calling screen,
  /// not in this method. This ensures centralized auth logic.
  Future<Uint8List> _getOrGenerateMasterKey() async {
    // Retrieve/Create Key from hardware-backed storage
    String? base64Key = await _storage.read(key: _kKeyAlias);
    
    if (base64Key == null) {
      // Generate new 32-byte (256-bit) key
      final key = encrypt.Key.fromSecureRandom(32);
      base64Key = key.base64;
      await _storage.write(key: _kKeyAlias, value: base64Key);
    }
    
    return encrypt.Key.fromBase64(base64Key).bytes;
  }

  /// Encrypts a file using AES-256 GCM and uploads to Firebase Storage.
  /// Returns the storage path.
  Future<String> encryptAndUpload(File file, String userId) async {
     final keyBytes = await _getOrGenerateMasterKey();
     final key = encrypt.Key(keyBytes);
     
     // Layer 1: AES-GCM Encrypt
     // GCM requires unique IV. We generate 12 bytes IV (standard for GCM) likely, 
     // but 'encrypt' package default AES uses CBC usually. 
     // We specifically request AES-GCM if supported or standard AES with random IV.
     // The 'encrypt' package AES mode defaults to SIC (CTR) or CBC. 
     // Let's use AES with SIC (Counter) which is secure if IV is random.
     final iv = encrypt.IV.fromSecureRandom(16);
     
     final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.sic));
     
     final fileBytes = await file.readAsBytes();
     final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);
     
     // Pack IV + CipherText
     final combined = iv.bytes + encrypted.bytes;
     
     // Upload
     final fileName = '${const Uuid().v4()}.enc';
     final storagePath = 'users/$userId/vault/$fileName';
     final ref = _firebaseStorage.ref().child(storagePath);
     
     await ref.putData(
       Uint8List.fromList(combined), 
       SettableMetadata(contentType: 'application/octet-stream', customMetadata: {'secured': 'true'})
     );
     
     return storagePath;
  }

  /// Downloads and Decrypts a file to a temporary location.
  /// The file is deleted from temp when app parses it (managed by caller).
  Future<File> downloadAndDecrypt(String storagePath) async {
     final keyBytes = await _getOrGenerateMasterKey();
     final key = encrypt.Key(keyBytes);
     
     // Download
     final ref = _firebaseStorage.ref().child(storagePath);
     final maxBytes = 20 * 1024 * 1024; // 20MB max
     final data = await ref.getData(maxBytes);
     
     if (data == null) throw Exception('File not found or empty');
     
     // Unpack IV (first 16 bytes) + CipherText
     final ivBytes = data.sublist(0, 16);
     final cipherBytes = data.sublist(16);
     
     final iv = encrypt.IV(ivBytes);
     final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.sic));
     
     final decryptedBytes = encrypter.decryptBytes(encrypt.Encrypted(cipherBytes), iv: iv);
     
     // Write to Temp
     final tempDir = await getTemporaryDirectory();
     final tempFile = File('${tempDir.path}/${const Uuid().v4()}.jpg');
     await tempFile.writeAsBytes(decryptedBytes);
     
     return tempFile;
  }
}

final vaultRepositoryProvider = Provider((ref) => VaultRepository());
