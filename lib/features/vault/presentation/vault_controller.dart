import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/vault_doc.dart';
import '../data/vault_repository.dart';

final vaultControllerProvider = AsyncNotifierProvider<VaultController, List<VaultDoc>>(() => VaultController());

class VaultController extends AsyncNotifier<List<VaultDoc>> {
  @override
  Future<List<VaultDoc>> build() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    // Real-time listener could be better, but we'll use one-time fetch for now
    // Actually, let's use a stream if we can, but AsyncNotifier build returns Future/Stream.
    // We'll stick to simple fetch + refresh on add.
    
    final query = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('vault')
        .orderBy('uploadedAt', descending: true)
        .get();

    return query.docs.map((d) => VaultDoc.fromMap(d.data(), d.id)).toList();
  }

  Future<void> addDocument(File file, String title) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');
    
    // Optimistic Update? No, wait for secure upload.
    // 1. Encrypt & Upload Blob
    final repo = ref.read(vaultRepositoryProvider);
    final storagePath = await repo.encryptAndUpload(file, user.uid);
    
    // 2. Add Metadata to Firestore
    final docId = const Uuid().v4();
    final newDoc = VaultDoc(
      id: docId,
      title: title,
      storagePath: storagePath,
      uploadedAt: DateTime.now(),
    );
    
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('vault')
        .doc(docId)
        .set(newDoc.toMap());
        
    // 3. Refresh State
    ref.invalidateSelf();
  }

  Future<void> deleteDocument(VaultDoc doc) async {
      // Implement if needed
  }
}
