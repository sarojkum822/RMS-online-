import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kirayabook/presentation/screens/auth/login_screen.dart';
import 'package:kirayabook/presentation/screens/owner/owner_dashboard_screen.dart';
import 'package:kirayabook/presentation/providers/data_providers.dart';
import 'package:kirayabook/core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kirayabook/domain/repositories/i_owner_repository.dart';
import 'package:kirayabook/domain/repositories/i_property_repository.dart';
import 'package:kirayabook/domain/repositories/i_tenant_repository.dart';
import 'package:kirayabook/domain/repositories/i_rent_repository.dart';
import 'package:kirayabook/domain/repositories/i_expense_repository.dart';
import 'package:kirayabook/core/services/user_session_service.dart';
import 'package:kirayabook/core/services/secure_storage_service.dart';
import 'package:kirayabook/core/services/biometric_service.dart';
import 'package:kirayabook/core/services/app_prefs_cache.dart';
import 'package:kirayabook/domain/repositories/i_notice_repository.dart';
import 'package:kirayabook/domain/repositories/i_maintenance_repository.dart';
import 'package:kirayabook/presentation/screens/owner/rent/rent_controller.dart';
import 'package:kirayabook/presentation/screens/maintenance/maintenance_controller.dart';
import 'package:kirayabook/presentation/screens/owner/tenant/tenant_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kirayabook/domain/entities/owner.dart';
import 'package:kirayabook/presentation/routes/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthService extends Mock implements AuthService {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}
class MockOwnerRepository extends Mock implements IOwnerRepository {}
class MockPropertyRepository extends Mock implements IPropertyRepository {}
class MockTenantRepository extends Mock implements ITenantRepository {}
class MockRentRepository extends Mock implements IRentRepository {}
class MockExpenseRepository extends Mock implements IExpenseRepository {}
class MockNoticeRepository extends Mock implements INoticeRepository {}
class MockMaintenanceRepository extends Mock implements IMaintenanceRepository {}
class MockFirestore extends Mock implements FirebaseFirestore {}
class MockUserSessionService extends Mock implements UserSessionService {}
class MockSecureStorageService extends Mock implements SecureStorageService {}
class MockBiometricService extends Mock implements BiometricService {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();
  await AppPrefsCache.init();
  
  late MockAuthService mockAuthService;
  late MockOwnerRepository mockOwnerRepo;
  late MockPropertyRepository mockPropertyRepo;
  late MockTenantRepository mockTenantRepo;
  late MockRentRepository mockRentRepo;
  late MockNoticeRepository mockNoticeRepo;
  late MockMaintenanceRepository mockMaintenanceRepo;
  late MockUserSessionService mockSessionService;
  late MockSecureStorageService mockSecureStorage;
  late MockBiometricService mockBiometric;
  late MockUser mockUser;

  setUp(() {
    mockAuthService = MockAuthService();
    mockOwnerRepo = MockOwnerRepository();
    mockPropertyRepo = MockPropertyRepository();
    mockTenantRepo = MockTenantRepository();
    mockRentRepo = MockRentRepository();
    mockNoticeRepo = MockNoticeRepository();
    mockMaintenanceRepo = MockMaintenanceRepository();
    mockSessionService = MockUserSessionService();
    mockSecureStorage = MockSecureStorageService();
    mockBiometric = MockBiometricService();
    mockUser = MockUser();

    when(() => mockAuthService.currentUser).thenReturn(mockUser);
    when(() => mockSessionService.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('test_owner_id');
    when(() => mockUser.email).thenReturn('test@example.com');
    
    when(() => mockSessionService.getSession()).thenAnswer((_) async => {
      'role': 'owner',
      'tenant_id': null,
      'expired': false,
    });
    
    // Mock Owner Data
    final mockOwner = Owner(
      id: 1,
      name: 'Test Owner',
      email: 'test@example.com',
      firestoreId: 'test_owner_id',
      createdAt: DateTime.now(),
    );
    when(() => mockOwnerRepo.getOwner()).thenAnswer((_) async => mockOwner);
    
    // Mock Empty Data for Dashboard
    when(() => mockPropertyRepo.getHouses()).thenAnswer((_) => Stream.value([]));
    when(() => mockPropertyRepo.getAllUnits()).thenAnswer((_) => Stream.value([]));
    when(() => mockTenantRepo.getAllTenants()).thenAnswer((_) => Stream.value([]));
    when(() => mockTenantRepo.getAllTenancies()).thenAnswer((_) => Stream.value([]));
    
    when(() => mockRentRepo.getRentCyclesForMonth(any())).thenAnswer((_) async => []);
    when(() => mockRentRepo.getAllPendingRentCycles()).thenAnswer((_) async => []);
    when(() => mockRentRepo.getDashboardStats()).thenAnswer((_) async => DashboardStats(
      totalCollected: 0,
      totalPending: 0,
      thisMonthCollected: 0,
      thisMonthPending: 0,
    ));
    
    when(() => mockMaintenanceRepo.watchRequestsForOwner(any())).thenAnswer((_) => Stream.value([]));
    when(() => mockNoticeRepo.deleteOldNotices(any())).thenAnswer((_) async => {});

    // Mock Secure Storage and Biometrics
    when(() => mockSecureStorage.isBiometricEnabled()).thenAnswer((_) async => false);
    when(() => mockSecureStorage.getCredentials(role: any(named: 'role'))).thenAnswer((_) async => null);
    when(() => mockSecureStorage.saveCredentials(any(), any(), role: any(named: 'role'), uid: any(named: 'uid')))
        .thenAnswer((_) async => {});
    
    when(() => mockBiometric.isBiometricAvailable()).thenAnswer((_) async => Future.value(false)); // Fixed: ensure it returns a Future
    when(() => mockBiometric.authenticate()).thenAnswer((_) async => Future.value(true));
  });

  Widget createTestWidget() {
    final mockFirestore = MockFirestore();

    final stats = DashboardStats(
      totalCollected: 1000,
      totalPending: 500,
      thisMonthCollected: 200,
      thisMonthPending: 100,
    );

    return EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('hi', 'IN')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: ProviderScope(
        overrides: [
          firestoreProvider.overrideWithValue(mockFirestore),
          authServiceProvider.overrideWithValue(mockAuthService),
          ownerRepositoryProvider.overrideWithValue(mockOwnerRepo),
          propertyRepositoryProvider.overrideWithValue(mockPropertyRepo),
          tenantRepositoryProvider.overrideWithValue(mockTenantRepo),
          rentRepositoryProvider.overrideWithValue(mockRentRepo),
          noticeRepositoryProvider.overrideWithValue(mockNoticeRepo),
          maintenanceRepositoryProvider.overrideWithValue(mockMaintenanceRepo),
          userSessionServiceProvider.overrideWithValue(mockSessionService),
          biometricServiceProvider.overrideWithValue(mockBiometric),
          secureStorageServiceProvider.overrideWithValue(mockSecureStorage),
          
          // Direct overrides for complex providers
          dashboardStatsProvider.overrideWith((ref) async => stats),
          ownerMaintenanceProvider('test_owner_id').overrideWith((ref) => Stream.value([])),
          ownerByIdProvider('test_owner_id').overrideWith((ref) async => Owner(
            id: 1, name: 'Test Owner', email: 'test@example.com', firestoreId: 'test_owner_id', createdAt: DateTime.now(),
          )),
          allUnitsProvider.overrideWith((ref) => Stream.value([])),
          allTenanciesProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: Consumer(builder: (context, ref, child) {
          return MaterialApp.router(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            routerConfig: createRouter(initialLocation: '/login'),
          );
        }),
      ),
    );
  }

  testWidgets('Full Flow: Login -> Dashboard -> Portfolio Navigation', (WidgetTester tester) async {
    // 1. Load Login Screen
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('KirayaBook'), findsOneWidget);
    expect(find.text('Makaan Malik Login'), findsOneWidget);

    // 2. Perform Login
    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    
    when(() => mockAuthService.signIn('test@example.com', 'password123'))
        .thenAnswer((_) async => MockUserCredential());
    when(() => mockSessionService.saveSession(role: 'owner')).thenAnswer((_) async => {});

    await tester.tap(find.text('Sign In to KirayaBook'));
    await tester.pump(); // Start sequence
    
    print('Waiting for login sequence...');
    // LoginScreen has 300ms + 1000ms + 1000ms delays in handleOwnerLoginSuccess
    // Plus DialogUtils.runWithLoading overhead.
    for (int i = 0; i < 8; i++) {
       await tester.pump(const Duration(seconds: 1));
       if (find.byType(LoginScreen).evaluate().isNotEmpty) {
         print('Pump ${i+1}s - Location: ${GoRouter.of(tester.element(find.byType(LoginScreen))).state.uri}');
       } else {
         print('Pump ${i+1}s - LoginScreen GONE (Navigation likely successful)');
       }
    }

    // Verify mocks were called
    verify(() => mockAuthService.signIn('test@example.com', 'password123')).called(1);
    verify(() => mockSessionService.saveSession(role: 'owner')).called(1);

    // Diagnostic: Verify LoginScreen is GONE
    expect(find.byType(LoginScreen), findsNothing);

    // 3. Verify Dashboard
    expect(find.byType(OwnerDashboardScreen), findsOneWidget);
    expect(find.text('Manage Portfolio'), findsOneWidget);

    // 4. Navigate to Portfolio
    await tester.tap(find.text('Manage Portfolio'));
    await tester.pumpAndSettle();

    // 5. Verify Portfolio Hub
    expect(find.text('Portfolio Hub'), findsOneWidget);
    debugPrint('Successfully reached Portfolio Hub');

    // Exhaust the 5-minute throttle timer in OwnerDashboardScreen to prevent test leak
    await tester.pump(const Duration(minutes: 5));
  });
}
