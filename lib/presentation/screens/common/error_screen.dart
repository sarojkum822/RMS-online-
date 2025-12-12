import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorScreen extends StatelessWidget {
  final FlutterErrorDetails details;

  const ErrorScreen({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong.',
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'We apologize for the inconvenience. Please try restarting the app.',
                style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Optional: Only show error details in debug mode
              if (true) ...[ 
                 Container(
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     color: Colors.grey[100],
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: Text(
                     details.exceptionAsString(),
                     style: GoogleFonts.robotoMono(fontSize: 12, color: Colors.red[800]),
                     maxLines: 5,
                     overflow: TextOverflow.ellipsis,
                   ),
                 )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
