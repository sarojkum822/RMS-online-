import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';

class DocumentViewerScreen extends StatelessWidget {
  final String title;
  final String? content;
  final Uint8List? pdfBytes;

  const DocumentViewerScreen({
    super.key,
    required this.title,
    this.content,
    this.pdfBytes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          if (pdfBytes != null)
            IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: () => Printing.sharePdf(bytes: pdfBytes!, filename: '$title.pdf'),
            ),
        ],
      ),
      body: pdfBytes != null 
        ? PdfPreview(
            build: (format) => pdfBytes!,
            allowPrinting: true,
            allowSharing: true,
            canChangeOrientation: false,
            canChangePageFormat: false,
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
              ),
              child: Text(
                content ?? 'No content available for this document.',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  height: 1.6,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
    );
  }
}
