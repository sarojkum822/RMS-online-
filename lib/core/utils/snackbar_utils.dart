import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SnackbarUtils {
  static void showSuccess(BuildContext context, String message) {
    HapticFeedback.lightImpact(); // Micro-interaction
    _show(context, message, isError: false);
  }

  static void showError(BuildContext context, String message) {
    HapticFeedback.mediumImpact(); // Distinct haptic for error
    _show(context, message, isError: true);
  }

  static void _show(BuildContext context, String message, {required bool isError}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Clear current snackbars to avoid stacking
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError 
            ? const Color(0xFFEF4444) // Red-500
            : const Color(0xFF10B981), // Emerald-500
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }
}
