/// Encapsulates all business rules for rent calculation, due dates, and penalties.
///
/// This class is pure logic: it depends only on inputs and returns outputs, 
/// making it 100% deterministic and testable.
abstract class RentRules {
  
  // -- Constants --
  static const int _dueDayOfMonth = 5;
  static const int _gracePeriodDays = 3;
  static const double _defaultLateFee = 100.0;

  /// Returns the standard due date for a bill generated in the given month.
  /// 
  /// Currently fixed to the 5th of the month.
  static DateTime calculateDueDate(DateTime billGeneratedDate) {
    return DateTime(billGeneratedDate.year, billGeneratedDate.month, _dueDayOfMonth);
  }

  /// Returns the start date of the billing cycle (1st of the month).
  static DateTime calculateBillPeriodStart(DateTime billGeneratedDate) {
    return DateTime(billGeneratedDate.year, billGeneratedDate.month, 1);
  }

  /// Returns the end date of the billing cycle (last day of the month).
  static DateTime calculateBillPeriodEnd(DateTime billGeneratedDate) {
    // 0th day of next month = last day of current month
    return DateTime(billGeneratedDate.year, billGeneratedDate.month + 1, 0); 
  }

  /// Calculates potential late fees based on the [dueDate] and actual [paymentDate].
  ///
  /// Rule:
  /// - Grace Period: 3 days after due date.
  /// - Penalty: Flat ₹100 if paid after grace period.
  static double calculateLateFee({
    required double totalDue,
    required DateTime dueDate,
    required DateTime paymentDate,
  }) {
    if (totalDue <= 0) return 0.0; // No fee on zero balance

    final gracePeriodEnd = dueDate.add(const Duration(days: _gracePeriodDays));
    
    // Check strict inequality: payment strictly AFTER grace period end merits a fine.
    // Using `isAfter` ensures even 1 second late triggers it.
    if (paymentDate.isAfter(gracePeriodEnd)) {
      return _defaultLateFee;
    }
    return 0.0;
  }

  static String generateBillNumber({
    required String tenantId,
    required DateTime billDate,
  }) {
    // Take first 6 chars of UUID for brevity while maintaining uniqueness in context of month
    final shortId = tenantId.length > 6 ? tenantId.substring(0, 6) : tenantId;
    return 'INV-${billDate.year}${billDate.month.toString().padLeft(2, '0')}-$shortId';
  }
}
