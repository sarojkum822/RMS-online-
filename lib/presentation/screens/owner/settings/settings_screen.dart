import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../../../core/services/user_session_service.dart';
import '../../../providers/data_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
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
              icon: Icons.vpn_key_outlined, 
              title: 'Tenant Access', 
              subtitle: 'View credentials & Share',
              onTap: () => context.push('/owner/settings/tenant-access'),
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



            _buildSettingItem(
              context: context,
              icon: Icons.help_outline, 
              title: 'Help & Support', 
              onTap: () => context.push('/owner/settings/support'),
            ),
            
            const SizedBox(height: 32),

            // DANGER ZONE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
                      const SizedBox(width: 8),
                      Text('Danger Zone', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('These actions are irreversible. Please be certain.', style: GoogleFonts.outfit(color: Colors.red[800], fontSize: 13)),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete_forever, size: 20),
                      label: const Text('Reset All Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showResetConfirmation(context, ref),
                    ),
                  ),
                ],
              ),
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
                onPressed: () async {
                  await ref.read(userSessionServiceProvider).clearSession();
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) context.go('/'); 
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
          decoration: BoxDecoration(color: (iconColor ?? Colors.grey).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: iconColor ?? Colors.black54),
        ),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle, style: GoogleFonts.outfit(color: Colors.grey[500], fontSize: 12)) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This will permanently delete ALL your properties, tenants, rents, and payments.'),
            const SizedBox(height: 16),
            const Text('This action cannot be undone.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 16),
            const Text('Type "DELETE" to confirm:'),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'DELETE',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, child) {
              return ElevatedButton(
                onPressed: value.text == 'DELETE' ? () async {
                   Navigator.pop(context); // Close Dialog
                   
                   // Show loading
                   if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Resetting Data... Please Wait.'), duration: Duration(seconds: 10)),
                     );
                   }

                   try {
                     final uid = FirebaseAuth.instance.currentUser?.uid;
                     if(uid != null) {
                        await ref.read(dataManagementServiceProvider).resetAllData(uid);
                        
                        // Seed fresh data? OR Force Logout?
                        // Let's force logout to ensure clean state
                        // Or just show success.
                        if (context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('All Data Reset Successfully!')),
                           );
                           // Refresh providers
                           ref.invalidate(allUnitsProvider);
                           // Maybe navigate home
                           context.go('/owner/dashboard');
                        }
                     }
                   } catch (e) {
                      if (context.mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reset Failed: $e')));
                      }
                   }
                } : null, // Disable if not "DELETE"
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: const Text('Confirm Reset'),
              );
            },
          ),
        ],
      ),
    );
  }
}
