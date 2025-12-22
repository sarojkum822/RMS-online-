/// Password validation utility for signup and password change
class PasswordValidator {
  static const int minLength = 8;

  /// Validate password strength
  static ValidationResult validate(String password) {
    final List<String> errors = [];

    if (password.length < minLength) {
      errors.add('At least $minLength characters');
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      errors.add('One uppercase letter');
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      errors.add('One lowercase letter');
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      errors.add('One number');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Get password strength as a score from 0.0 to 1.0
  static double getStrength(String password) {
    if (password.isEmpty) return 0.0;
    
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    return score / 6;
  }

  /// Get strength label for UI
  static String getStrengthLabel(double strength) {
    if (strength == 0) return '';
    if (strength < 0.33) return 'Weak';
    if (strength < 0.67) return 'Medium';
    return 'Strong';
  }

  /// Get strength color for UI
  static int getStrengthColor(double strength) {
    if (strength < 0.33) return 0xFFE53935; // Red
    if (strength < 0.67) return 0xFFFFA726; // Orange
    return 0xFF43A047; // Green
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({required this.isValid, required this.errors});
}
