import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/owner.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/auth_service.dart';
import '../../../providers/data_providers.dart';

class OwnerController extends AsyncNotifier<Owner?> {
  @override
  FutureOr<Owner?> build() async {
    return _fetchOwner();
  }

  Future<Owner?> _fetchOwner() async {
    final repo = ref.read(ownerRepositoryProvider);
    final session = await ref.read(userSessionServiceProvider).getSession();
    final role = session['role'];
    
    var owner = await repo.getOwner();
    
    // Auto-create profile if missing for owners to prevent auto-logout
    if (owner == null && role == 'owner') {
      final auth = ref.read(authServiceProvider);
      final user = auth.currentUser;
      if (user != null) {
        debugPrint('OwnerController: Creating missing owner profile for UID: ${user.uid}');
        final newOwner = Owner(
          id: 0,
          name: user.displayName ?? 'New Owner',
          email: user.email ?? 'No Email',
          phone: user.phoneNumber ?? '',
          firestoreId: user.uid,
          subscriptionPlan: 'free',
          createdAt: DateTime.now(),
        );
        await repo.saveOwner(newOwner);
        owner = newOwner;
      }
    }

    // Auto-heal: If Owner exists but email is missing, sync from Auth
    if (owner != null && ((owner.email ?? '').isEmpty || owner.email == 'No Email')) {
       final auth = ref.read(authServiceProvider);
       final authEmail = auth.currentUser?.email;
       if (authEmail != null && authEmail.isNotEmpty) {
         debugPrint('OwnerController: Syncing missing email from Auth: $authEmail');
         owner = owner.copyWith(email: authEmail);
         await repo.updateOwner(owner);
       }
    }
    
    return owner;
  }

  Future<void> updateProfile({
    required String name, 
    required String email, 
    required String phone, 
    String? firestoreId,
    String? currency,
    String? timezone,
  }) async {
    final repo = ref.read(ownerRepositoryProvider);
    final currentOwner = state.value;
    if (currentOwner == null) return;

    final updatedOwner = currentOwner.copyWith(
      name: name,
      email: email,
      phone: phone,
      firestoreId: firestoreId ?? currentOwner.firestoreId,
      currency: currency ?? currentOwner.currency,
      timezone: timezone ?? currentOwner.timezone,
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
