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
    
    // Clear current snackbars to avoid stacking
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min, // Added
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20, // Slightly smaller for better fit
            ),
            const SizedBox(width: 8), // Reduced spacing
            Flexible( // Changed from Expanded for better shrinking
              child: Text(
                message,
                maxLines: 2, // Added safety limit
                overflow: TextOverflow.ellipsis, // Added
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13, // Slightly smaller for better fit
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
        duration: const Duration(seconds: 2),
        dismissDirection: DismissDirection.horizontal,
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
             try {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
             } catch (_) {}
          },
        ),
      ),
    );
  }
}
