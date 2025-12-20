import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorDisplayWidget extends StatefulWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;
  final String title;

  const ErrorDisplayWidget({
    super.key,
    required this.error,
    this.stackTrace,
    this.onRetry,
    this.title = 'Create a Ticket',
  });

  @override
  State<ErrorDisplayWidget> createState() => _ErrorDisplayWidgetState();
}

class _ErrorDisplayWidgetState extends State<ErrorDisplayWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Friendly Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 32, color: Colors.red),
            ),
            const SizedBox(height: 16),
            
            // Friendly Title
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Friendly Message
            Text(
              "Something went wrong while loading data.\nPlease try again later.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.onRetry != null)
                  ElevatedButton.icon(
                    onPressed: widget.onRetry,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  
                if (widget.onRetry != null) const SizedBox(width: 12),
                
                TextButton(
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  child: Text(
                    _isExpanded ? 'Hide Details' : 'See Details',
                    style: GoogleFonts.outfit(color: Colors.grey),
                  ),
                ),
              ],
            ),

            // Technical Details (Expandable)
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              const Divider(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.code, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('Technical Error:', style: GoogleFonts.sourceCodePro(fontWeight: FontWeight.bold, fontSize: 12)),
                        const Spacer(),
                        IconButton(
                           icon: const Icon(Icons.copy, size: 14),
                           onPressed: () {
                             Clipboard.setData(ClipboardData(text: "${widget.error}\n${widget.stackTrace}"));
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error copied to clipboard')));
                           },
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 150),
                      child: SingleChildScrollView(
                        child: Text(
                          widget.error.toString(),
                          style: GoogleFonts.sourceCodePro(fontSize: 12, color: Colors.red.shade800),
                        ),
                      ),
                    ),
                    if (widget.stackTrace != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Stack Trace:',
                        style: GoogleFonts.sourceCodePro(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 100,
                        child: SingleChildScrollView(
                          child: Text(
                            widget.stackTrace.toString(),
                            style: GoogleFonts.sourceCodePro(fontSize: 10, color: Colors.grey.shade700),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
