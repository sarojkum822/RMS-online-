
import '../domain/ai_service.dart';

/// A deterministic, template-based implementation of [AIService].
///
/// This service provides reliable, hard-coded message generation
/// that functions without external API dependencies or network connectivity.
/// Suitable for fallback scenarios or strict-privacy modes.
class TemplateMessageService implements AIService {
  @override
  Future<String> generateRentReminder({
    required String tenantName,
    required double amountDue,
    required String dueDate,
    String? language,
    String? tone,
  }) async {
    // Determine template based on tone/language if needed in future.
    // For now, return a standard, professional reminder.
    return "Hello $tenantName, this is a friendly reminder that your rent of \u20B9${amountDue.toStringAsFixed(2)} is due on $dueDate. Kindly complete payment at your earliest convenience.";
  }

  @override
  Future<String> summarizePaymentHistory(List<dynamic> payments) async {
    if (payments.isEmpty) return "No payment history available.";
    
    // Simple summary logic
    return "Total Records: ${payments.length}. Please review detailed statement.";
  }
}
