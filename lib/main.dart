import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'presentation/screens/common/error_screen.dart';
import 'core/theme/app_theme.dart';
import 'presentation/routes/app_router.dart';
import 'core/services/notification_service.dart';
// Corrected path

import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/services/user_session_service.dart';
import 'domain/entities/tenant.dart';

import 'presentation/providers/data_providers.dart'; // NEW import
import 'core/theme/theme_provider.dart';

void main() async {
  // Ensure binding is initialized first
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    
    // Initialize Notification Service
    final notificationService = NotificationService();
    await notificationService.initialize();

    // 1. Global Error Handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details); 
      // TODO: Add Crashlytics here when ready
    };
    
    // 2. Custom Error Widget
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ErrorScreen(details: details),
      );
    };

    // 3. Async Error Handling
    PlatformDispatcher.instance.onError = (error, stack) {
       debugPrint('Async Error: $error');
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
        // Direct Firestore Fetch
        final snapshot = await FirebaseFirestore.instance
            .collection('tenants')
            .where('id', isEqualTo: tenantId)
            .limit(1)
            .get(); // This might timeout if offline

        if (snapshot.docs.isNotEmpty) {
           final data = snapshot.docs.first.data();
           final tenant = Tenant(
              id: data['id'],
              houseId: data['houseId'],
              unitId: data['unitId'],
              tenantCode: data['tenantCode'] ?? '', 
              name: data['name'] ?? 'Unknown',
              phone: data['phone'] ?? '',
              email: data['email'],
              imageUrl: data['imageUrl'],
              startDate: data['startDate'] != null ? (data['startDate'] as Timestamp).toDate() : DateTime.now(),
              status: (data['isActive'] ?? true) ? TenantStatus.active : TenantStatus.inactive,
              openingBalance: (data['openingBalance'] as num?)?.toDouble() ?? 0.0,
              agreedRent: (data['agreedRent'] as num?)?.toDouble() ?? 0.0,
              password: data['password'],
              ownerId: data['ownerId'] ?? '', 
           );

           if (tenant.status == TenantStatus.active) {
              initialLocation = '/tenant/dashboard';
              initialExtra = tenant;
           }
        }
      } catch (e) {
        debugPrint('Error restoring tenant session: $e');
        // Continue to login if this fails
      }
    }

    runApp(
      ProviderScope(
        overrides: [
          notificationServiceProvider.overrideWithValue(notificationService),
        ],
        child: MyApp(initialLocation: initialLocation, initialExtra: initialExtra),
      ),
    );

  } catch (e, stack) {
    debugPrint('Startup Error: $e');
    // Run app with error screen if initialization fails
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ErrorScreen(details: FlutterErrorDetails(exception: e, stack: stack)),
      )
    );
  }
}



class MyApp extends ConsumerStatefulWidget {
  final String initialLocation;
  final Object? initialExtra;

  const MyApp({
    super.key, 
    required this.initialLocation, 
    this.initialExtra
  });

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Initialize Router ONCE
    _router = createRouter(
       initialLocation: widget.initialLocation,
       initialExtra: widget.initialExtra
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider); // Watch Theme changes
    
    return MaterialApp.router(
      title: 'KirayaBook',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode, // Dynamic Config
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      themeAnimationDuration: const Duration(milliseconds: 600), // Smooth transition
      themeAnimationCurve: Curves.easeInOut,
    );
  }
}
