/// Email format validation utility
class EmailValidator {
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Check if email format is valid
  static bool isValid(String email) => _emailRegex.hasMatch(email.trim());

  /// Validate email for form fields (returns error message or null)
  static String? validate(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }
    if (!isValid(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Normalize email (lowercase, trimmed)
  static String normalize(String email) => email.trim().toLowerCase();
}
