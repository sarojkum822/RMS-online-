import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
      final houses = await _fetchCollection('houses', uid);
      final units = await _fetchCollection('units', uid);
      final tenants = await _fetchCollection('tenants', uid);
      final rentCycles = await _fetchCollection('rent_cycles', uid);
      final payments = await _fetchCollection('payments', uid);
      final expenses = await _fetchCollection('expenses', uid);
      final electricReadings = await _fetchCollection('electric_readings', uid);

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
          'rentCycles': rentCycles,
          'payments': payments,
          'expenses': expenses,
          'electricReadings': electricReadings,
        }
      };

      // 3. Serialize
      final jsonString = jsonEncode(backupData);
      final bytes = utf8.encode(jsonString);
      final fileName = 'rentpilot_backup_${DateTime.now().millisecondsSinceEpoch}';

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
            text: 'RentPilot Pro Backup',
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
      final houses = await _fetchCollection('houses', uid);
      final units = await _fetchCollection('units', uid);
      final tenants = await _fetchCollection('tenants', uid);
      final rentCycles = await _fetchCollection('rent_cycles', uid);
      final payments = await _fetchCollection('payments', uid);
      final expenses = await _fetchCollection('expenses', uid);
      final electricReadings = await _fetchCollection('electric_readings', uid);

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
          'rentCycles': rentCycles,
          'payments': payments,
          'expenses': expenses,
          'electricReadings': electricReadings,
        }
      };
  }

  Future<void> restoreData(String jsonString, String currentUid) async {
    // Placeholder - implemented in MigrationService
    throw UnimplementedError('Use MigrationService for restore');
  }
}
