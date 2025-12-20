import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../constants/firebase_collections.dart';

class BackupService {
  final FirebaseFirestore _firestore;

  BackupService(this._firestore);

  static const int CURRENT_SCHEMA_VERSION = 1;

  Future<void> exportData({
    required String uid,
    bool share = true,
  }) async {
    try {
      // 1. Fetch All Data for Owner
      final houses = await _fetchCollection(FirebaseCollections.properties, uid);
      final units = await _fetchCollection(FirebaseCollections.units, uid);
      final tenants = await _fetchCollection(FirebaseCollections.tenants, uid);
      final contracts = await _fetchCollection(FirebaseCollections.contracts, uid); // NEW
      final rentCycles = await _fetchCollection(FirebaseCollections.invoices, uid);
      final payments = await _fetchCollection(FirebaseCollections.transactions, uid);
      final expenses = await _fetchCollection(FirebaseCollections.expenses, uid);
      final tickets = await _fetchCollection(FirebaseCollections.tickets, uid); // NEW
      final electricReadings = await _fetchCollection(FirebaseCollections.electricReadings, uid);

      // 2. Structure Data with Metadata
      final backupData = {
        'metadata': {
          'version': '1.0', // App Version
          'schemaVersion': CURRENT_SCHEMA_VERSION,
          'timestamp': DateTime.now().toIso8601String(),
          'ownerId': uid, // For integrity check on restore
          'platform': kIsWeb ? 'web' : Platform.operatingSystem,
        },
        'data': {
          'houses': houses,
          'units': units,
          'tenants': tenants,
          'contracts': contracts,
          'rentCycles': rentCycles,
          'payments': payments,
          'expenses': expenses,
          'tickets': tickets, // NEW
          'electricReadings': electricReadings,
        }
      };

      // 3. Serialize
      final jsonString = jsonEncode(backupData);
      final bytes = utf8.encode(jsonString);
      final fileName = 'kirayabook_backup_${DateTime.now().millisecondsSinceEpoch}';

      // 4. Save/Share
      if (kIsWeb) {
        // Web: Always Download
        await FileSaver.instance.saveFile(
          name: '$fileName.json',
          bytes: bytes,
          mimeType: MimeType.json,
        );
      } else {
        if (share) {
          final dir = await getTemporaryDirectory();
          final file = File('${dir.path}/$fileName.json');
          await file.writeAsString(jsonString);
          await Share.shareXFiles(
            [XFile(file.path, mimeType: 'application/json')],
            text: 'KirayaBook Pro Backup',
          );
        } else {
          await FileSaver.instance.saveFile(
            name: '$fileName.json',
            bytes: bytes,
            mimeType: MimeType.json,
          );
        }
      }
    } catch (e) {
      debugPrint('Export Error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCollection(String collection, String uid) async {
    final snapshot = await _firestore.collection(collection)
        .where('ownerId', isEqualTo: uid)
        .get();
        
    return snapshot.docs.map((d) {
      final data = d.data();
      // Handle timestamps for JSON
      return data.map((key, value) {
        if (value is Timestamp) {
          return MapEntry(key, value.toDate().toIso8601String());
        }
        return MapEntry(key, value);
      });
    }).toList();
  }

  Future<Map<String, dynamic>> fetchAllDataAsMap(String uid) async {
      // 1. Fetch All Data for Owner
      final houses = await _fetchCollection(FirebaseCollections.properties, uid);
      final units = await _fetchCollection(FirebaseCollections.units, uid);
      final tenants = await _fetchCollection(FirebaseCollections.tenants, uid);
      final contracts = await _fetchCollection(FirebaseCollections.contracts, uid); // NEW
      final rentCycles = await _fetchCollection(FirebaseCollections.invoices, uid);
      final payments = await _fetchCollection(FirebaseCollections.transactions, uid);
      final expenses = await _fetchCollection(FirebaseCollections.expenses, uid);
      final tickets = await _fetchCollection(FirebaseCollections.tickets, uid); // NEW
      final electricReadings = await _fetchCollection(FirebaseCollections.electricReadings, uid);

      return {
        'metadata': {
          'version': '1.0',
          'schemaVersion': CURRENT_SCHEMA_VERSION,
          'timestamp': DateTime.now().toIso8601String(),
          'ownerId': uid,
        },
        'data': {
          'houses': houses,
          'units': units,
          'tenants': tenants,
          'contracts': contracts,
          'rentCycles': rentCycles,
          'payments': payments,
          'expenses': expenses,
          'tickets': tickets, // NEW
          'electricReadings': electricReadings,
        }
      };
  }

  Future<void> restoreData(String jsonString, String currentUid) async {
    // Placeholder - implemented in MigrationService
    throw UnimplementedError('Use MigrationService for restore');
  }
}
