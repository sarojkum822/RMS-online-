import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/owner.dart';
import '../../../providers/data_providers.dart';

class OwnerController extends AsyncNotifier<Owner?> {
  @override
  FutureOr<Owner?> build() async {
    return _fetchOwner();
  }

  Future<Owner?> _fetchOwner() async {
    final repo = ref.watch(ownerRepositoryProvider);
    var owner = await repo.getOwner();
    
    // If no owner exists (first run), create a default one
    if (owner == null) {
      final newOwner = Owner(
        id: -1, 
        name: 'My Name', 
        phone: '', 
        email: '', 
        currency: 'INR',
        createdAt: DateTime.now()
      );
      await repo.saveOwner(newOwner);
      owner = await repo.getOwner();
    }
    return owner;
  }

  Future<void> updateProfile({required String name, required String email, required String phone, String? firestoreId}) async {
    final repo = ref.read(ownerRepositoryProvider);
    final currentOwner = state.value;
    if (currentOwner == null) return;

    final updatedOwner = currentOwner.copyWith(
      name: name,
      email: email,
      phone: phone,
      firestoreId: firestoreId ?? currentOwner.firestoreId,
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.updateOwner(updatedOwner);
      return updatedOwner;
    });
  }


}

final ownerControllerProvider = AsyncNotifierProvider<OwnerController, Owner?>(() {
  return OwnerController();
});
