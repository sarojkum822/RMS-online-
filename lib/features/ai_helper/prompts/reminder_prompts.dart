
class ReminderPrompts {
  static String rentReminder({
    required String tenantName,
    required double amountDue,
    required String dueDate,
    String? language = 'English',
    String? tone = 'Polite',
  }) {
    return '''
You are a helpful assistant for a landlord.
Write a precise rent reminder message for a tenant.

Data:
- Tenant Name: $tenantName
- Amount Due: $amountDue
- Due Date: $dueDate

Constraints:
- Language: $language
- Tone: $tone
- Do NOT add fake fees.
- Do NOT threaten.
- Keep it under 50 words.
- Format for WhatsApp.
''';
  }
}
