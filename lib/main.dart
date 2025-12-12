import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/common/error_screen.dart';
import 'core/theme/app_theme.dart';
import 'presentation/routes/app_router.dart';
import 'core/services/notification_service.dart';
// Corrected path

import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/services/user_session_service.dart';
import 'domain/entities/tenant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init();

  // 1. Global Error Handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details); 
    // TODO: Add Crashlytics here when ready
    // FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };
  
  // 2. Custom Error Widget (Replaces Red Screen)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ErrorScreen(details: details),
    );
  };

  // 3. Async Error Handling
  PlatformDispatcher.instance.onError = (error, stack) {
     debugPrint('Async Error: $error');
     // TODO: Add Crashlytics here
     // FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
     return true;
  };

  // Session Check
  final sessionService = UserSessionService();
  final session = await sessionService.getSession();
  
  String initialLocation = '/';
  Object? initialExtra;

  if (session['role'] == 'owner') {
    initialLocation = '/owner/dashboard';
  } else if (session['role'] == 'tenant' && session['tenantId'] != null) {
    try {
      final tenantId = session['tenantId'] as int;
      // Direct Firestore Fetch because Repository needs Owner Auth which might not be ready/applicable
      final snapshot = await FirebaseFirestore.instance
          .collection('tenants')
          .where('id', isEqualTo: tenantId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
         final data = snapshot.docs.first.data();
         // Basic Mapping - ensure this matches Repository logic or Domain
         // Assuming data is correct.
         final tenant = Tenant(
            id: data['id'],
            houseId: data['houseId'],
            unitId: data['unitId'],
            tenantCode: data['tenantCode'] ?? '', // Handle potential nulls
            name: data['name'] ?? 'Unknown',
            phone: data['phone'] ?? '',
            email: data['email'],
            imageUrl: data['imageUrl'],
            startDate: data['startDate'] != null ? (data['startDate'] as Timestamp).toDate() : DateTime.now(),
            status: (data['isActive'] ?? true) ? TenantStatus.active : TenantStatus.inactive,
            openingBalance: (data['openingBalance'] as num?)?.toDouble() ?? 0.0,
            agreedRent: (data['agreedRent'] as num?)?.toDouble() ?? 0.0,
            password: data['password'],
            ownerId: data['ownerId'] ?? '', // Map ownerId
         );

         if (tenant.status == TenantStatus.active) {
            initialLocation = '/tenant/dashboard';
            initialExtra = tenant;
         }
      }
    } catch (e) {
      debugPrint('Error restoring tenant session: $e');
    }
  }

  runApp(
    ProviderScope(
      child: MyApp(initialLocation: initialLocation, initialExtra: initialExtra),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final String initialLocation;
  final Object? initialExtra;

  const MyApp({
    super.key, 
    required this.initialLocation, 
    this.initialExtra
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create Router with initial location
    final router = createRouter(
       initialLocation: initialLocation,
       initialExtra: initialExtra
    );

    return MaterialApp.router(
      title: 'KirayaBook',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
