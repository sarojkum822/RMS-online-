import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kirayabook/presentation/screens/owner/house/house_form_screen.dart';

void main() {
  testWidgets('HouseFormScreen has correct length limits', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HouseFormScreen(),
        ),
      ),
    );

    // House Name
    final nameField = find.widgetWithText(TextFormField, 'House Name').first;
    final nameTextField = find.descendant(of: nameField, matching: find.byType(TextField));
    final nameWidget = tester.widget<TextField>(nameTextField);
    expect(nameWidget.maxLength, 50);

    // Address
    final addressField = find.widgetWithText(TextFormField, 'Address').first;
    final addressTextField = find.descendant(of: addressField, matching: find.byType(TextField));
    final addressWidget = tester.widget<TextField>(addressTextField);
    expect(addressWidget.maxLength, 200);

    // Notes
    final notesField = find.widgetWithText(TextFormField, 'Notes').first;
    final notesTextField = find.descendant(of: notesField, matching: find.byType(TextField));
    final notesWidget = tester.widget<TextField>(notesTextField);
    expect(notesWidget.maxLength, 500);

    // Verify Negative Units Validation
    final unitsField = find.widgetWithText(TextFormField, 'Total Number of Flats / Units').first;
    await tester.enterText(unitsField, '-5');
    await tester.pumpAndSettle();
    expect(find.text('Cannot be negative'), findsOneWidget);
  });
}
