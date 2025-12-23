import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'presentation/screens/common/error_screen.dart';
import 'core/theme/app_theme.dart';
import 'presentation/routes/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/app_prefs_cache.dart'; // NEW: Unified prefs cache

import 'package:cloud_firestore/cloud_firestore.dart';

import 'presentation/providers/data_providers.dart';
import 'core/theme/theme_provider.dart';

import 'package:easy_localization/easy_localization.dart';

void main() async {
  // Ensure binding is initialized first and preserve splash
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await EasyLocalization.ensureInitialized();

  // Pre-cache ALL preferences for INSTANT access (theme, locale, currency, stats)
  await AppPrefsCache.init();

  try {
    await Firebase.initializeApp();
    
    // 2. Enable Firestore Persistence (Offline Capabilities)
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
    
    // Initialize Notification Service
    final notificationService = NotificationService();
    notificationService.initialize().catchError((e) => debugPrint('Notif Init Error: $e'));

    // Initialize Ads
    MobileAds.instance.initialize().catchError((e) {
      debugPrint('AdMob Init Error: $e');
      return InitializationStatus({});
    });

    // Global Error Handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details); 
    };
    
    // Custom Error Widget
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ErrorScreen(details: details),
      );
    };

    // Async Error Handling
    PlatformDispatcher.instance.onError = (error, stack) {
       debugPrint('Async Error: $error');
       return true;
    };

    // Remove native splash - go directly to login
    FlutterNativeSplash.remove();

    // Go directly to login (native splash already showed branding)
    String initialLocation = '/login';
    Object? initialExtra;

    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('hi', 'IN')],
        path: 'assets/translations',
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
    FlutterNativeSplash.remove();
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
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp.router(
      title: 'KirayaBook',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      themeAnimationDuration: const Duration(milliseconds: 150),
      themeAnimationCurve: Curves.easeInOut,
    );
  }
}
