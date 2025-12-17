
abstract class AIService {
  /// Generates a polite reminder message for a tenant.
  /// [tenantName]: Name of the tenant
  /// [amountDue]: Total amount due
  /// [dueDate]: Due date of the rent
  /// [customNote]: Optional tone or extra detail
  Future<String> generateRentReminder({
    required String tenantName,
    required double amountDue,
    required String dueDate,
    String? language,
    String? tone,
  });

  /// Summarizes payment history.
  Future<String> summarizePaymentHistory(List<dynamic> payments);
}
