import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Numeric Validation Logic Tests', () {
    
    // Test the Regex used in the app: RegExp(r'^\d+\.?\d{0,2}')
    final regex = RegExp(r'^\d+\.?\d{0,2}');

    test('Regex should allow valid integers', () {
      expect(regex.hasMatch('100'), true);
      expect(regex.hasMatch('0'), true);
    });

    test('Regex should allow valid decimals (up to 2 places)', () {
      expect(regex.hasMatch('100.5'), true);
      expect(regex.hasMatch('100.55'), true);
    });

    test('Regex should block negative numbers at the start', () {
      // InputFormatter blocks the typing, but let's check the regex match logic
      expect(regex.stringMatch('-100'), isNull); 
    });

    test('Regex should block non-numeric characters', () {
      expect(regex.stringMatch('abc'), isNull);
      expect(regex.stringMatch('10a'), '10'); // It matches the '10' part if partial
    });

    // Test the logical validation used in Tenant Form
    String? validateRent(String? v) {
      if (v == null || v.isEmpty) return 'Required';
      final val = double.tryParse(v);
      if (val == null || val < 0) return 'Invalid amount';
      return null;
    }

    test('Rent Validator should require a value', () {
      expect(validateRent(''), 'Required');
      expect(validateRent(null), 'Required');
    });

    test('Rent Validator should block negative values', () {
      expect(validateRent('-10'), 'Invalid amount');
    });

    test('Rent Validator should allow valid positive values', () {
      expect(validateRent('1500'), isNull);
      expect(validateRent('1500.50'), isNull);
    });

    // Test Meter Reading range logic if applicable
    String? validateReading(double current, double previous) {
      if (current < previous) return 'Current reading must be >= Previous';
      return null;
    }

    test('Meter Reading logic should enforce current >= previous', () {
      expect(validateReading(100, 150), 'Current reading must be >= Previous');
      expect(validateReading(200, 150), isNull);
      expect(validateReading(150, 150), isNull);
    });

    // Test Due Day range logic
    String? validateDueDay(String? v) {
      if (v == null || v.isEmpty) return null;
      final val = int.tryParse(v);
      if (val == null || val < 1 || val > 28) return 'Must be between 1 and 28';
      return null;
    }

    test('Due Day Validator should enforce range 1-28', () {
      expect(validateDueDay('0'), 'Must be between 1 and 28');
      expect(validateDueDay('29'), 'Must be between 1 and 28');
      expect(validateDueDay('15'), isNull);
      expect(validateDueDay('1'), isNull);
      expect(validateDueDay('28'), isNull);
    });
  });
}
