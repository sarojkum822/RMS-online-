import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Help & Support', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Frequently Asked Questions', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
            const SizedBox(height: 16),
            
            _buildFAQItem(context, 'How do I add a new tenant?', 'Go to the "My Tenants" tab and tap the + button.'),
            _buildFAQItem(context, 'Can I export bill receipts?', 'Yes, go to any paid bill and look for the PDF icon (Coming Soon).'),
            _buildFAQItem(context, 'How is rent calculated?', 'Rent is calculated based on the Unit\'s base rent + electricity + other charges.'),
            
            const SizedBox(height: 32),
            Text('Still need help?', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.email),
                label: const Text('Contact Support'),
                 style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary, // Adapted
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Email Client...')));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String q, String a) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ExpansionTile(
        title: Text(q, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14, color: theme.textTheme.bodyLarge?.color)),
        iconColor: theme.iconTheme.color,
        collapsedIconColor: theme.iconTheme.color,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(a, style: GoogleFonts.outfit(color: theme.textTheme.bodyMedium?.color)),
          )
        ],
      ),
    );
  }
}
