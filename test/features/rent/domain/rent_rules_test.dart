
import 'package:flutter_test/flutter_test.dart';
import 'package:kirayabook/features/rent/domain/rent_rules.dart';

void main() {
  group('RentRules', () {
    test('calculateDueDate should always return the 5th of the month', () {
      final input = DateTime(2023, 10, 1);
      final result = RentRules.calculateDueDate(input);
      expect(result, DateTime(2023, 10, 5));
    });

    test('calculateBillPeriodStart should return 1st of the month', () {
      final input = DateTime(2023, 10, 15);
      final result = RentRules.calculateBillPeriodStart(input);
      expect(result, DateTime(2023, 10, 1));
    });

    test('calculateBillPeriodEnd should return last day of the month (31st)', () {
      final input = DateTime(2023, 10, 10);
      final result = RentRules.calculateBillPeriodEnd(input);
      expect(result, DateTime(2023, 10, 31));
    });

    test('calculateBillPeriodEnd should return last day of the month (30th)', () {
      final input = DateTime(2023, 11, 10);
      final result = RentRules.calculateBillPeriodEnd(input);
      expect(result, DateTime(2023, 11, 30));
    });

    test('calculateLateFee should return 0 if paid within grace period (8th)', () {
      final totalDue = 10000.0;
      final dueDate = DateTime(2023, 10, 5);
      final paymentDate = DateTime(2023, 10, 8); // On the last day of grace period
      
      final fee = RentRules.calculateLateFee(
        totalDue: totalDue,
        dueDate: dueDate,
        paymentDate: paymentDate,
      );
      expect(fee, 0.0);
    });

    test('calculateLateFee should return 100 if paid AFTER grace period (9th)', () {
      final totalDue = 10000.0;
      final dueDate = DateTime(2023, 10, 5);
      final paymentDate = DateTime(2023, 10, 9); // Late
      
      final fee = RentRules.calculateLateFee(
        totalDue: totalDue,
        dueDate: dueDate,
        paymentDate: paymentDate,
      );
      expect(fee, 100.0);
    });
  });
}
