import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Terms & Privacy', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(context,
              'Terms of Service', 
              'By using RentPilot Pro, you agree to manage your properties responsibly and in accordance with local laws. This application is a tool to assist in management; you remain responsible for all legal agreements with your tenants.'
            ),
            _buildSection(context,
              'Privacy Policy', 
              'Your privacy is important to us. This policy outlines how we collect, use, and protect your data.'
            ),
            _buildSection(context,
              '1. Information You Manage', 
              'RentPilot Pro acts as a secure digital workspace for your rental business. We only process the information you explicitly enter—such as property addresses and tenant names—to organize your portfolio. You retain full ownership and control of your business data.'
            ),
            _buildSection(context,
              '2. Privacy First', 
              'Your data is used solely to power features like automated billing and revenue reports. We operate with a strict "No-Sell" policy: your tenant lists and financial records are never shared with advertisers or third parties.'
            ),
            _buildSection(context,
              '3. Secure Cloud Storage', 
              'Your business data is encrypted and securely stored using industry-standard Google Firebase infrastructure. This ensures your records are safe, backed up, and synchronized instantly across all your authorized devices.'
            ),
            _buildSection(context,
              '4. Your Rights', 
              'You have the right to access, correct, or delete your data at any time. You can export your data via the Backup & Restore feature or request account deletion via the Security settings.'
            ),
            _buildSection(context,
              '5. Changes to Terms', 
              'We may update these terms from time to time. We will notify you of significant changes through the application.'
            ),
            
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Last Updated: December 2025',
                style: GoogleFonts.outfit(color: theme.textTheme.bodySmall?.color, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, 
            style: GoogleFonts.outfit(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleMedium?.color, // Adapted
            )
          ),
          const SizedBox(height: 8),
          Text(
            content, 
            style: GoogleFonts.outfit(
              fontSize: 14, 
              color: theme.textTheme.bodyMedium?.color, // Adapted
              height: 1.5,
            )
          ),
        ],
      ),
    );
  }
}
