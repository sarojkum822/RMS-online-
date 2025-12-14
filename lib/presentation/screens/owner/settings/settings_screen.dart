import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../../../core/services/user_session_service.dart';
import '../../../providers/data_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            _buildSectionHeader(context, 'General'),
            // Profile Section
            GestureDetector(
              onTap: () => context.push('/owner/settings/profile'), 
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: isDark ? Border.all(color: Colors.white10) : null,
                  boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
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
                           Text('Owner Profile', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
                           Text('View & Edit Profile', style: GoogleFonts.outfit(color: theme.textTheme.bodyMedium?.color)),
                         ],
                       ),
                     ),
                     Icon(Icons.arrow_forward_ios, size: 16, color: theme.iconTheme.color?.withValues(alpha: 0.5)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Appearance Section
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: isDark ? Border.all(color: Colors.white10) : null,
              ),
              child: Consumer(
                builder: (context, ref, _) {
                  final themeMode = ref.watch(themeProvider);
                  final isDarkModeOn = themeMode == ThemeMode.dark;
                  
                  return SwitchListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1), 
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Icon(isDarkModeOn ? Icons.dark_mode : Icons.light_mode, color: theme.colorScheme.primary),
                    ),
                    title: Text('Dark Mode', style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: theme.textTheme.bodyLarge?.color)),
                    subtitle: Text(isDarkModeOn ? 'On' : 'Off', style: GoogleFonts.outfit(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 12)),
                    value: isDarkModeOn,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) {
                      ref.read(themeProvider.notifier).setTheme(val ? ThemeMode.dark : ThemeMode.light);
                    },
                  );
                }
              ),
            ),

            _buildSettingItem(
              context: context,
              icon: Icons.currency_rupee, 
              title: 'Currency & Format', 
              onTap: () => context.push('/owner/settings/currency'),
              theme: theme,
              isDark: isDark,
            ),
            
            _buildSectionHeader(context, 'Notification & Security'),
             _buildSettingItem(
              context: context,
              icon: Icons.notifications, 
              title: 'Notifications', 
              onTap: () => context.push('/owner/settings/notifications'),
              theme: theme,
              isDark: isDark,
            ),
            _buildSettingItem(
              context: context,
              icon: Icons.security, 
              title: 'Security', 
              onTap: () => context.push('/owner/settings/security'),
              theme: theme,
              isDark: isDark,
            ),

            _buildSettingItem(
              context: context,
              icon: Icons.vpn_key_outlined, 
              title: 'Tenant Access', 
              subtitle: 'View credentials & Share',
              onTap: () => context.push('/owner/settings/tenant-access'),
              theme: theme,
              isDark: isDark,
            ),

            _buildSectionHeader(context, 'Data Management'),
            _buildSettingItem(
              context: context,
              icon: Icons.cloud_sync_outlined, 
              title: 'Backup & Restore', 
              subtitle: 'Data Export, Import, and Repair',
              onTap: () => context.push('/owner/settings/backup'),
              theme: theme,
              isDark: isDark,
            ),

            _buildSettingItem(
              context: context,
              icon: Icons.print,
              title: 'Print Data',
              onTap: () async {
                 try {
                   // Fetch Live Data
                   final tenants = await ref.read(tenantRepositoryProvider).getAllTenants();
                   final rentCycles = await ref.read(rentRepositoryProvider).getAllRentCycles();
                   final payments = await ref.read(rentRepositoryProvider).getAllPayments();

                   await ref.read(printServiceProvider).printBackupData(
                     tenants: tenants,
                     rentCycles: rentCycles,
                     payments: payments,
                   );
                 } catch (e) {
                   if(context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Print Failed: $e')),
                      );
                   }
                 }
              },
              theme: theme,
              isDark: isDark,
            ),


            _buildSectionHeader(context, 'Support'),
            
            _buildSettingItem(
              context: context,
              icon: Icons.help_center_outlined, 
              title: 'Help Center', 
              onTap: () => context.push('/owner/settings/support'),
              theme: theme,
              isDark: isDark,
            ),
            _buildSettingItem(
              context: context,
              icon: Icons.mail_outline, 
              title: 'Contact Us', 
              onTap: () async {
                 final Uri emailLaunchUri = Uri(
                   scheme: 'mailto',
                   path: 'support@rentpilotpro.com',
                   queryParameters: {'subject': 'Support Request'},
                 );
                 if (await canLaunchUrl(emailLaunchUri)) {
                   await launchUrl(emailLaunchUri);
                 } else {
                   if(context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch email client')));
                   }
                 }
              },
              theme: theme,
              isDark: isDark,
            ),
             _buildSettingItem(
              context: context,
              icon: Icons.privacy_tip_outlined, 
              title: 'Terms & Privacy', 
                onTap: () => context.push('/owner/settings/terms'),
              theme: theme,
              isDark: isDark,
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
             Text('App Version 1.0.0', style: GoogleFonts.outfit(color: theme.textTheme.bodySmall?.color, fontSize: 12)),
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
    required ThemeData theme,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? (isDark ? Colors.white70 : Colors.black54)).withValues(alpha: 0.1), 
            borderRadius: BorderRadius.circular(8)
          ),
          child: Icon(icon, color: iconColor ?? (isDark ? Colors.white70 : Colors.black54)),
        ),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: theme.textTheme.bodyLarge?.color)),
        subtitle: subtitle != null ? Text(subtitle, style: GoogleFonts.outfit(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 12)) : null,
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.iconTheme.color?.withValues(alpha: 0.5)),
        onTap: onTap,
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    // ... no changes to dialog logic ...
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
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 12),
      child: Text(
        title, 
        style: GoogleFonts.outfit(
          fontSize: 14, 
          fontWeight: FontWeight.bold, 
          color: Theme.of(context).colorScheme.primary
        ),
      ),
    );
  }
}
