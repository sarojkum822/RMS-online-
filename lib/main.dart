import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:go_router/go_router.dart';
import 'presentation/screens/common/error_screen.dart';
import 'core/theme/app_theme.dart';
import 'presentation/routes/app_router.dart';
import 'core/services/notification_service.dart';
// Corrected path

import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/services/user_session_service.dart';
import 'domain/entities/tenant.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart'; // NEW IMPORT
import 'presentation/providers/data_providers.dart'; // NEW import
import 'core/theme/theme_provider.dart';

import 'package:easy_localization/easy_localization.dart'; // NEW

void main() async {
  // Ensure binding is initialized first
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized(); // NEW: Initialize Localization

  try {
    await Firebase.initializeApp();
    // 0. Enable Firestore Persistence (Offline Capabilities)
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
    
    // Initialize Notification Service
    final notificationService = NotificationService();
    notificationService.initialize().catchError((e) => debugPrint('Notif Init Error: $e'));

    // Initialize Ads
    MobileAds.instance.initialize().catchError((e) => debugPrint('AdMob Init Error: $e'));

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

    // Session Check is now handled in SplashScreen
    String initialLocation = '/splash';
    Object? initialExtra;

    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('hi', 'IN')],
        path: 'assets/translations', // <-- change patch to your
        fallbackLocale: const Locale('en', 'US'),
        child: ProviderScope(
          overrides: [
            notificationServiceProvider.overrideWithValue(notificationService),
          ],
          child: MyApp(initialLocation: initialLocation, initialExtra: initialExtra),
        ),
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
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode, // Dynamic Config
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      themeAnimationDuration: const Duration(milliseconds: 150), // Snappy transition (reduced from 300ms)
      themeAnimationCurve: Curves.easeInOut,
    );
  }
}
