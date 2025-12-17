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
import 'package:easy_localization/easy_localization.dart';
import 'owner_controller.dart'; // Import Owner Controller

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ownerAsync = ref.watch(ownerControllerProvider);

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
            
            // --- 1. Profile Header Card ---
            ownerAsync.when(
              data: (owner) {
                final name = owner?.name ?? 'Owner';
                final email = owner?.email ?? 'No Email';
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: isDark ? Border.all(color: Colors.white10) : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'O',
                            style: GoogleFonts.outfit(
                              fontSize: 24, 
                              fontWeight: FontWeight.bold, 
                              color: theme.colorScheme.primary
                            )
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold,
                                      color: theme.textTheme.titleLarge?.color
                                    ),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(6)
                                  ),
                                  child: Text('Admin', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: theme.hintColor)),
                                )
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: theme.hintColor
                              ),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
              error: (_,__) => const SizedBox(),
            ),

            // --- 2. Plan & Billing ---
            _buildSectionHeader(context, 'PLAN & BILLING'),
            _buildSectionCard(
              context, 
              children: [
                _buildSettingRow(
                  context,
                  icon: Icons.star_border_rounded,
                  title: 'Manage Subscription',
                  subtitle: 'Pro Plan starting @ ₹99/mo',
                  onTap: () => context.push('/owner/settings/subscription'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(12)),
                    child: Text('PRO', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black)),
                  )
                ),
              ]
            ),
            
            const SizedBox(height: 24),

            // --- 3. General Section ---
            _buildSectionHeader(context, 'GENERAL'),
            _buildSectionCard(
              context,
              children: [
                 _buildSettingRow(
                  context,
                  icon: Icons.person_outline,
                  title: 'settings.profile'.tr(), // View & Edit Profile
                  onTap: () => context.push('/owner/settings/profile'),
                ),
                _buildDivider(theme),
                // Dark Mode Toggle
                Consumer(
                  builder: (context, ref, _) {
                    final themeMode = ref.watch(themeProvider);
                    final isDarkModeOn = themeMode == ThemeMode.dark;
                    return _buildSettingRow(
                      context,
                      icon: isDarkModeOn ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                      title: 'settings.dark_mode'.tr(),
                      trailing: Switch.adaptive(
                        value: isDarkModeOn,
                        onChanged: (val) {
                          ref.read(themeProvider.notifier).setTheme(val ? ThemeMode.dark : ThemeMode.light);
                        },
                        activeColor: theme.colorScheme.primary,
                      ),
                    );
                  }
                ),
                 _buildDivider(theme),
                 // Language
                 _buildSettingRow(
                    context,
                    icon: Icons.language,
                    title: 'settings.language'.tr(),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                         color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                         borderRadius: BorderRadius.circular(8)
                      ),
                      child: Row(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           Text(
                             context.locale.languageCode == 'en' ? 'English' : 'हिंदी',
                             style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textTheme.bodyMedium?.color),
                           ),
                           const SizedBox(width: 4),
                           Icon(Icons.chevron_right, size: 16, color: theme.hintColor),
                         ],
                      )
                    ),
                    onTap: () {
                       // Simple language toggle for now or show dialog
                       final nextLocale = context.locale.languageCode == 'en' ? const Locale('hi', 'IN') : const Locale('en', 'US');
                       context.setLocale(nextLocale);
                    },
                 ),
                 _buildDivider(theme),
                 _buildSettingRow(
                  context,
                  icon: Icons.currency_rupee,
                  title: 'settings.currency'.tr(), // Currency & Format
                  onTap: () => context.push('/owner/settings/currency'),
                ),
              ]
            ),

            const SizedBox(height: 24),

            // --- 3. Notification & Security ---
            _buildSectionHeader(context, 'NOTIFICATION & SECURITY'),
            _buildSectionCard(
               context,
               children: [
                 _buildSettingRow(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'settings.notifications'.tr(),
                    onTap: () => context.push('/owner/settings/notifications'),
                 ),
                 _buildDivider(theme),
                 _buildSettingRow(
                    context,
                    icon: Icons.security_outlined,
                    title: 'settings.security'.tr(),
                    onTap: () => context.push('/owner/settings/security'),
                 ),
                 _buildDivider(theme),
                 _buildSettingRow(
                    context,
                    icon: Icons.vpn_key_outlined,
                    title: 'settings.tenant_access'.tr(),
                    subtitle: 'View credentials & Share',
                    onTap: () => context.push('/owner/settings/tenant-access'),
                 ),
               ]
            ),

            const SizedBox(height: 24),

            // --- 4. Data Management ---
            _buildSectionHeader(context, 'DATA MANAGEMENT'),
             _buildSectionCard(
               context,
               children: [
                 _buildSettingRow(
                    context,
                    icon: Icons.cloud_upload_outlined, // Backup
                    title: 'settings.backup'.tr(), // Backup & Restore
                    onTap: () => context.push('/owner/settings/backup'),
                 ),
                 _buildDivider(theme),
                 _buildSettingRow(
                    context,
                    icon: Icons.download_outlined, 
                    title: 'Data Export, Import, and Repair',
                    onTap: () {}, // Placeholder or link to same backup page if it handles import
                 ),
                 _buildDivider(theme),
                 _buildSettingRow(
                    context,
                    icon: Icons.print_outlined,
                    title: 'settings.print'.tr(),
                    onTap: () async {
                       try {
                         // Fetch Live Data
                         final tenants = await ref.read(tenantRepositoryProvider).getAllTenants().first;
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
                 ),
               ]
            ),
            
            const SizedBox(height: 24),

            // --- 5. Support ---
            _buildSectionHeader(context, 'SUPPORT'),
            _buildSectionCard(
              context,
              children: [
                 _buildSettingRow(
                    context,
                    icon: Icons.help_outline,
                    title: 'settings.help_center'.tr(),
                    onTap: () => context.push('/owner/settings/support'),
                 ),
                 _buildDivider(theme),
                 _buildSettingRow(
                    context,
                    icon: Icons.chat_bubble_outline,
                    title: 'settings.contact_us'.tr(),
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
                 ),
                 _buildDivider(theme),
                 _buildSettingRow(
                    context,
                    icon: Icons.description_outlined,
                    title: 'settings.terms'.tr(), // Terms & Privacy
                    onTap: () => context.push('/owner/settings/terms'),
                 ),
              ]
            ),

            const SizedBox(height: 32),

            // --- 6. Danger Zone ---
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.deepOrangeAccent, size: 18),
                const SizedBox(width: 8),
                Text(
                  'DANGER ZONE',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.deepOrangeAccent,
                  ),
                ),
              ],
            ),
            // DANGER ZONE
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(isDark ? 0.1 : 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
                      const SizedBox(width: 8),
                      Text('settings.danger_zone'.tr(), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('settings.danger_warning'.tr(), style: GoogleFonts.outfit(color: Colors.red[800], fontSize: 13)),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete_forever, size: 20),
                      label: Text('settings.reset_data'.tr()),
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
            Divider(color: theme.dividerColor.withOpacity(0.5)),
            const SizedBox(height: 20),
            
            // Logout
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: isDark ? Border.all(color: Colors.white10) : null,
                boxShadow: [
                   BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2)
                   )
                ],
              ),
              child: TextButton.icon(
                icon: const Icon(Icons.logout, size: 20),
                label: Text('settings.logout'.tr(), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  await ref.read(userSessionServiceProvider).clearSession();
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) context.go('/'); 
                },
              ),
            ),
             const SizedBox(height: 10),
             Center(child: Text('${'settings.version'.tr()} 1.0.0', style: GoogleFonts.outfit(color: theme.textTheme.bodySmall?.color, fontSize: 12))),
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 4),
      child: Text(
        title, 
        style: GoogleFonts.outfit(
          fontSize: 12, 
          fontWeight: FontWeight.bold, 
          letterSpacing: 1.2,
          color: Theme.of(context).hintColor
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required List<Widget> children}) {
     final theme = Theme.of(context);
     final isDark = theme.brightness == Brightness.dark;
     return Container(
       decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: Colors.white10) : null,
          boxShadow: [
             BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2)
             )
          ],
       ),
       child: Column(
          children: children,
       ),
     );
  }
  
  Widget _buildDivider(ThemeData theme) {
    return Divider(height: 1, thickness: 1, color: theme.dividerColor.withOpacity(0.1));
  }

  Widget _buildSettingRow(BuildContext context, {
    required IconData icon, 
    required String title, 
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
       borderRadius: BorderRadius.circular(16), // TBC if first/last logic needed, but simplistic is fine
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
             Container(
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(
                 color: theme.scaffoldBackgroundColor, // Light background for icon
                 shape: BoxShape.circle,
               ),
               child: Icon(icon, size: 20, color: theme.textTheme.titleMedium?.color),
             ),
             const SizedBox(width: 16),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16, color: theme.textTheme.bodyLarge?.color)),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: theme.hintColor)),
                      )
                 ],
               ),
             ),
             if (trailing != null) 
               trailing
             else
               Icon(Icons.chevron_right, size: 20, color: theme.hintColor)
          ],
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
             const SizedBox(width: 8),
             Text('Reset All Data?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This will permanently delete ALL your properties, tenants, rents, and payments.', style: GoogleFonts.outfit()),
            const SizedBox(height: 16),
            Text('This action cannot be undone.', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 16),
            Text('Type "DELETE" to confirm:', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                hintText: 'DELETE',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
              ),
              onChanged: (_) => (context as Element).markNeedsBuild(), // Force rebuild to enable button
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
                        if (context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('All Data Reset Successfully!')),
                           );
                           ref.invalidate(allUnitsProvider);
                           context.go('/owner/dashboard');
                        }
                     }
                   } catch (e) {
                      if (context.mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reset Failed: $e')));
                      }
                   }
                } : null, 
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
