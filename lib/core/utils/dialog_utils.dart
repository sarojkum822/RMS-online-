import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DialogUtils {
  static void showErrorDialog(BuildContext context, {required String title, required String message}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.red)),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.outfit(fontSize: 16, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  static void showInfoDialog(BuildContext context, {required String title, required String message}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.blue, size: 28),
            const SizedBox(width: 12),
            Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.blue)),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.outfit(fontSize: 16, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
    static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.3), // Dim background
      builder: (ctx) => PopScope(
        canPop: false, // Prevent back button
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9), // Glassy white
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 4,
                )
              ]
            ),
            child: const CupertinoActivityIndicator(radius: 16), // iOS Spinner
          ),
        ),
      ),
    );
  }

  static void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop(); // dismiss dialog
  }

  // Helper to run Future with loading
  static Future<void> runWithLoading(BuildContext context, Future<void> Function() asyncFunction) async {
    showLoading(context);
    try {
      await asyncFunction();
    } finally {
      if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
         hideLoading(context);
      }
    }
  }
  static void showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
             ClipRRect(
               borderRadius: BorderRadius.circular(16),
               child: Image.network(imageUrl, fit: BoxFit.contain),
             ),
             Positioned(
               top: 0,
               right: 0,
               child: Container(
                 decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                 child: IconButton(
                   icon: const Icon(Icons.close, color: Colors.white, size: 24),
                   onPressed: () => Navigator.pop(ctx),
                 ),
               ),
             ),
          ],
        ),
      ),
    );
  }
}
