import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kirayabook/presentation/screens/owner/tenant/tenant_form_screen.dart';
import 'package:kirayabook/presentation/providers/data_providers.dart';
import 'package:kirayabook/domain/entities/house.dart';
import 'package:kirayabook/domain/repositories/i_property_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockPropertyRepository extends Mock implements IPropertyRepository {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

void main() {
  late MockPropertyRepository mockRepo;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;

  setUp(() {
    mockRepo = MockPropertyRepository();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('test_owner_id');
  });

  testWidgets('TenantFormScreen shows "No flat config" note when units are empty', (WidgetTester tester) async {
    final house = House(
      id: 'house_123',
      name: 'Test House',
      address: '123 Test St',
      ownerId: 'test_owner_id',
    );

    // Setup Mock Repo
    when(() => mockRepo.getHouses()).thenAnswer((_) => Stream.value([house]));
    when(() => mockRepo.getUnits('house_123')).thenAnswer((_) => Stream.value([]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          propertyRepositoryProvider.overrideWithValue(mockRepo),
          firebaseAuthProvider.overrideWithValue(mockAuth),
        ],
        child: const MaterialApp(
          home: TenantFormScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. House dropdown should be visible
    expect(find.text('Select House'), findsOneWidget);

    // 2. Open dropdown and select house
    await tester.tap(find.text('Select House'));
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Test House').last);
    await tester.pumpAndSettle();

    // 3. Verify the warning note appears
    expect(find.text('* No flat config found'), findsOneWidget);
    expect(find.text('Tap to add units seamlessly ->'), findsOneWidget);
  });
}
