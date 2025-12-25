import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kirayabook/presentation/screens/owner/tenant/tenant_form_screen.dart';
import 'package:kirayabook/presentation/screens/owner/house/house_controller.dart';
import 'package:kirayabook/domain/entities/house.dart';
import 'dart:async';

void main() {
  testWidgets('TenantFormScreen has correct length limits', (tester) async {
    // Set a large height to ensure all ListView items are built
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    // Reset after test
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          houseControllerProvider.overrideWith(() => HouseControllerStub()),
        ],
        child: const MaterialApp(
          home: TenantFormScreen(),
        ),
      ),
    );
    
    // Allow any async loads to settle (though we expect loading state)
    await tester.pump();

    // Name
    final nameField = find.widgetWithText(TextFormField, 'Name').first;
    final nameTextField = find.descendant(of: nameField, matching: find.byType(TextField));
    final nameWidget = tester.widget<TextField>(nameTextField);
    expect(nameWidget.maxLength, 50);

    // Phone
    final phoneField = find.widgetWithText(TextFormField, 'Phone').first;
    final phoneTextField = find.descendant(of: phoneField, matching: find.byType(TextField));
    final phoneWidget = tester.widget<TextField>(phoneTextField);
    expect(phoneWidget.maxLength, 15);

    // Address
    final addressField = find.widgetWithText(TextFormField, 'Permanent Address').first;
    final addressTextField = find.descendant(of: addressField, matching: find.byType(TextField));
    final addressWidget = tester.widget<TextField>(addressTextField);
    expect(addressWidget.maxLength, 200);

    // Email
    final emailField = find.widgetWithText(TextFormField, 'Email (Login ID)').first;
    final emailTextField = find.descendant(of: emailField, matching: find.byType(TextField));
    final emailWidget = tester.widget<TextField>(emailTextField);
    expect(emailWidget.maxLength, 100);
    
    // Notes
    final notesField = find.widgetWithText(TextFormField, 'Notes (Optional)').first;
    final notesTextField = find.descendant(of: notesField, matching: find.byType(TextField));
    final notesWidget = tester.widget<TextField>(notesTextField);
    expect(notesWidget.maxLength, 500);

    // --- Negative Value Validation Tests ---

    // Rent
    final rentField = find.widgetWithText(TextFormField, 'Agreed Rent Amount').first;
    await tester.enterText(rentField, '-1000');
    await tester.pumpAndSettle();
    expect(find.text('Cannot be negative'), findsOneWidget);
    await tester.enterText(rentField, '5000'); // Reset to valid
    await tester.pumpAndSettle();

    // Security Deposit
    final depositField = find.widgetWithText(TextFormField, 'Security Deposit (Optional)').first;
    await tester.drag(depositField, const Offset(0, -100)); // Scroll if needed
    await tester.enterText(depositField, '-500');
    await tester.pumpAndSettle();
    expect(find.text('Cannot be negative'), findsOneWidget);
    await tester.enterText(depositField, ''); // Reset to empty
    await tester.pumpAndSettle();

    // Member Count
    final memberField = find.widgetWithText(TextFormField, 'Members Count').first;
    await tester.enterText(memberField, '0');
    await tester.pumpAndSettle();
    expect(find.text('Must be > 0'), findsOneWidget);
  });
}

class HouseControllerStub extends HouseController {
  @override
  Stream<List<House>> build() {
    return Stream.value([]);
  }
}
