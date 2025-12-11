import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../../providers/seed_data_provider.dart';
import '../../../providers/data_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Section
            GestureDetector(
              onTap: () => context.push('/owner/settings/profile'), 
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                     const CircleAvatar(
                       radius: 30,
                       backgroundColor: Colors.blueGrey,
                       child: Icon(Icons.person, color: Colors.white, size: 30),
                     ),
                     const SizedBox(width: 16),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text('Owner Profile', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                           Text('View & Edit Profile', style: GoogleFonts.outfit(color: Colors.grey)),
                         ],
                       ),
                     ),
                     const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Settings List
            _buildSettingItem(
              context: context,
              icon: Icons.notifications, 
              title: 'Notifications', 
              onTap: () => context.push('/owner/settings/notifications'),
            ),
            _buildSettingItem(
              context: context,
              icon: Icons.currency_rupee, 
              title: 'Currency & Format', 
              onTap: () => context.push('/owner/settings/currency'),
            ),
            _buildSettingItem(
              context: context,
              icon: Icons.security, 
              title: 'Security', 
              onTap: () => context.push('/owner/settings/security'),
            ),

             _buildSettingItem(
              context: context,
              icon: Icons.share, 
              title: 'Share Backup', 
              onTap: () async {
                 try {
                   await ref.read(backupServiceProvider).exportData(share: true);
                 } catch (e) {
                   if(context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Share Failed: $e')),
                      );
                   }
                 }
              },
            ),
            
            _buildSettingItem(
              context: context,
              icon: Icons.save_alt, 
              title: 'Save Backup to Device', 
              subtitle: 'Save to Downloads/Documents',
              onTap: () async {
                 try {
                   await ref.read(backupServiceProvider).exportData(share: false);
                    if(context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Backup Saved to Device!')),
                      );
                   }
                 } catch (e) {
                   if(context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Save Failed: $e')),
                      );
                   }
                 }
              },
            ),
            
            _buildSettingItem(
              context: context,
              icon: Icons.restore,
              title: 'Import Backup',
              onTap: () async {
                 try {
                   FilePickerResult? result = await FilePicker.platform.pickFiles(
                     type: FileType.custom,
                     allowedExtensions: ['json'],
                   );

                   if (result != null && result.files.single.path != null) {
                     final file = File(result.files.single.path!);
                     if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restoring Data...')));
                     }
                     
                     await ref.read(backupServiceProvider).restoreData(file);
                     
                     if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Backup Restored Successfully!')),
                        );
                     }
                   }
                 } catch (e) {
                   if(context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Restore Failed: $e')),
                      );
                   }
                 }
              },
            ),

            _buildSettingItem(
              context: context,
              icon: Icons.print,
              title: 'Print Data',
              onTap: () async {
                 try {
                   await ref.read(printServiceProvider).printBackupData();
                 } catch (e) {
                   if(context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Print Failed: $e')),
                      );
                   }
                 }
              },
            ),

            // TEST DATA BUTTON (Dev Only)
            _buildSettingItem(
              context: context,
              icon: Icons.bug_report, 
              title: 'Seed Test Data (Dev Only)', 
              iconColor: Colors.orange,
              onTap: () async {
                 try {
                   await ref.read(seedDataProvider.future);
                   if(context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Test Data Added: Green Valley Apts & Tenant Rahul')),
                     );
                   }
                 } catch (e) {
                   if(context.mounted) {
                     String message = 'Error seeding data: $e';
                     if (e.toString().contains('UNIQUE constraint failed') || e.toString().contains('constraint failed')) {
                        message = 'Already in Dev Mode'; 
                     }
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text(message)),
                     );
                   }
                 }
              },
            ),

            _buildSettingItem(
              context: context,
              icon: Icons.help_outline, 
              title: 'Help & Support', 
              onTap: () => context.push('/owner/settings/support'),
            ),
            
            const SizedBox(height: 32),
            
            // Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50], // Light red
                  foregroundColor: Colors.red,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  context.go('/'); 
                },
              ),
            ),
             const SizedBox(height: 20),
             Text('App Version 1.0.0', style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context, 
    required IconData icon, 
    required String title, 
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: (iconColor ?? Colors.grey).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: iconColor ?? Colors.black54),
        ),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle, style: GoogleFonts.outfit(color: Colors.grey[500], fontSize: 12)) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
