import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kirayabook/presentation/screens/auth/login_screen.dart';
import 'package:kirayabook/presentation/providers/data_providers.dart';
import 'package:kirayabook/core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kirayabook/domain/repositories/i_owner_repository.dart';
import 'package:kirayabook/core/services/user_session_service.dart';

class MockAuthService extends Mock implements AuthService {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}
class MockOwnerRepository extends Mock implements IOwnerRepository {}
class MockUserSessionService extends Mock implements UserSessionService {}

void main() {
  late MockAuthService mockAuthService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockOwnerRepository mockOwnerRepo;
  late MockUserSessionService mockSessionService;
  late MockUser mockUser;

  setUp(() {
    mockAuthService = MockAuthService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockOwnerRepo = MockOwnerRepository();
    mockSessionService = MockUserSessionService();
    mockUser = MockUser();

    when(() => mockAuthService.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('new_owner_id');
    
    // Default mock behavior for repository used by controller
    when(() => mockOwnerRepo.getOwner()).thenAnswer((_) async => null);
    when(() => mockOwnerRepo.saveOwner(any())).thenAnswer((_) async => {});
  });

  testWidgets('Signup flow shows "Account Created" dialog and does not auto-login', (WidgetTester tester) async {
    // 1. Build LoginScreen in Signup mode
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          firebaseAuthProvider.overrideWithValue(mockFirebaseAuth),
          ownerRepositoryProvider.overrideWithValue(mockOwnerRepo),
          userSessionServiceProvider.overrideWithValue(mockSessionService),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // 2. Switch to Signup mode
    await tester.tap(find.text('Create Owner Account'));
    await tester.pumpAndSettle();

    // 3. Fill details
    // TextField order: Name, Email, Password, Confirm Password
    await tester.enterText(find.byType(TextField).at(0), 'Test Owner');
    await tester.enterText(find.byType(TextField).at(1), 'sarojkum822@gmail.com');
    await tester.enterText(find.byType(TextField).at(2), '123456');
    await tester.enterText(find.byType(TextField).at(3), '123456');
    
    // 4. Mock Signup response
    when(() => mockAuthService.signUp('sarojkum822@gmail.com', '123456'))
        .thenAnswer((_) async => MockUserCredential());

    // 5. Submit
    await tester.tap(find.text('Sign Up'));
    await tester.pump(); // Start signup
    await tester.pump(); // Trigger navigation/dialogs
    await tester.pumpAndSettle();

    // 6. Verify "Account Created" dialog
    expect(find.text('Account Created'), findsOneWidget);
    expect(find.text('Your account has been successfully created.\n\nPlease login with your new credentials to continue.'), findsOneWidget);
    
    // 7. Click "Login Now"
    await tester.tap(find.text('Login Now'));
    await tester.pumpAndSettle();

    // 8. Verify we are back on Login mode (Welcome Back text)
    expect(find.text('Welcome Back!'), findsOneWidget);
    
    // 9. Verify NO auto-login happened (saveSession not called after signup)
    verifyNever(() => mockSessionService.saveSession(role: 'owner'));
  });
}
