import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/data_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'owner_controller.dart'; // Import Owner Controller
import '../../../../core/utils/dialog_utils.dart';
import '../../../../core/utils/snackbar_utils.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ownerAsync = ref.watch(ownerControllerProvider);
    final owner = ownerAsync.valueOrNull;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : Colors.white,
      appBar: AppBar(
        title: Text('Settings', 
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold, 
            fontSize: 24,
            color: theme.textTheme.titleLarge?.color
          )
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
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
                final plan = owner?.subscriptionPlan ?? 'free';
                final planColor = plan == 'power' ? Colors.purple : (plan == 'pro' ? const Color(0xFFF59E0B) : Colors.grey);

                return InkWell(
                  onTap: () => context.push('/owner/settings/profile'),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    // margin: const EdgeInsets.only(bottom: 24), // Moved margin to padding of column or keep if it's the only one
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: planColor.withValues(alpha: 0.5)),
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: planColor.withValues(alpha: 0.1),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'O',
                              style: GoogleFonts.outfit(
                                fontSize: 24, 
                                fontWeight: FontWeight.bold, 
                                color: planColor
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
                                          fontSize: 20, 
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : const Color(0xFF0F172A)
                                        ),
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: planColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: planColor.withValues(alpha: 0.3)),
                                      ),
                                      child: Text(plan.toUpperCase(), style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: planColor, letterSpacing: 1)),
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
                        Icon(Icons.chevron_right, size: 20, color: theme.hintColor),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
              error: (e, s) {
                  final errorStr = e.toString();
                  if (errorStr.contains('permission-denied') || errorStr.contains('missing-permissions')) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.lock_person, size: 40, color: Colors.red.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'Access Denied',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Session expired or permission missing.',
                            style: GoogleFonts.outfit(fontSize: 12, color: theme.textTheme.bodyMedium?.color),
                          ),
                          const SizedBox(height: 16),
                           ElevatedButton.icon(
                              icon: const Icon(Icons.logout, size: 16),
                              label: const Text('Logout'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                 await ref.read(userSessionServiceProvider).clearSession();
                                 await FirebaseAuth.instance.signOut();
                                 if (context.mounted) context.go('/');
                              },
                           )
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
              },
            ),
            const SizedBox(height: 24),

            // --- 2. Plan & Billing ---
            _buildSectionHeader(context, 'PLAN & BILLING'),
            _buildSectionCard(
              context, 
              children: [
                _buildSettingRow(
                  context,
                  icon: Icons.star_border_rounded,
                  title: 'Manage Subscription',
                  subtitle: ownerAsync.value?.subscriptionPlan == 'free' ? 'Upgrade to Pro @ ₹199/mo' : 'View plan details',
                  onTap: () => context.push('/owner/settings/subscription'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (ownerAsync.value?.subscriptionPlan == 'power' ? Colors.purple : 
                              (ownerAsync.value?.subscriptionPlan == 'pro' ? const Color(0xFFF59E0B) : Colors.grey)).withValues(alpha: 0.2), 
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: Text(
                      (ownerAsync.value?.subscriptionPlan ?? 'free').toUpperCase(), 
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold, 
                        fontSize: 10, 
                        color: ownerAsync.value?.subscriptionPlan == 'power' ? Colors.purple : 
                               (ownerAsync.value?.subscriptionPlan == 'pro' ? const Color(0xFFF59E0B) : Colors.grey)
                      )
                    ),
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
                             _getLanguageName(context),
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
                 _buildSettingRow(
                  context,
                  icon: Icons.public,
                  title: 'settings.timezone'.tr(), 
                  onTap: () => context.push('/owner/settings/timezone'),
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
                    icon: Icons.person_add_alt_1_outlined, // Changed Icon to person_add
                    title: 'Invite Tenants', // Renamed from Tenant Access
                    subtitle: 'Share login credentials',
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
                 // Backup & Repair REMOVED for public launch
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
                           path: 'support@kirayabookpro.com',
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
                    title: 'settings.tekirayabook'.tr(), // Tekirayabook & Privacy
                    onTap: () => context.push('/owner/settings/tekirayabook'),
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
                color: Colors.red.withValues(alpha: isDark ? 0.1 : 0.05),
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
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showDeleteAccountConfirmation(context, ref, owner?.id.toString() ?? ''),
                      icon: const Icon(Icons.person_remove_outlined, size: 20),
                      label: Text('settings.delete_account'.tr(), style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Divider(color: theme.dividerColor.withValues(alpha: 0.5)),
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
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
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
                  // Invalidate ALL providers FIRST to clear cached data
                  ref.invalidate(ownerControllerProvider);
                  ref.invalidate(tenantRepositoryProvider);
                  ref.invalidate(propertyRepositoryProvider);
                  ref.invalidate(allUnitsProvider);
                  
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 4),
      child: Text(
        title, 
        style: GoogleFonts.outfit(
          fontSize: 11, 
          fontWeight: FontWeight.bold, 
          letterSpacing: 2,
          color: isDark ? Colors.white24 : Colors.grey.withValues(alpha: 0.5)
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required List<Widget> children}) {
     final theme = Theme.of(context);
     final isDark = theme.brightness == Brightness.dark;
     return Container(
       decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
          boxShadow: [
             BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
                blurRadius: 20,
                offset: const Offset(0, 8)
             )
          ],
       ),
       child: Column(
          children: children,
       ),
     );
  }
  
  Widget _buildDivider(ThemeData theme) {
    return Divider(height: 1, thickness: 1, color: theme.dividerColor.withValues(alpha: 0.1));
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

  /// Repairs contract-tenant ID mismatches
  Future<void> _runDataRepair(BuildContext context, WidgetRef ref) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not logged in')));
      return;
    }

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Repair Data?'),
        content: const Text('This will scan all contracts and fix any tenant ID mismatches. This is safe and won\'t delete any data.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Run Repair')),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Running repair...')));

    try {
      final firestore = ref.read(firestoreProvider);
      int fixed = 0;

      // 1. Get all tenants
      final tenantsSnap = await firestore.collection('tenants')
        .where('ownerId', isEqualTo: uid)
        .where('isDeleted', isEqualTo: false)
        .get();
      
      // 2. Get all contracts
      final contractsSnap = await firestore.collection('contracts')
        .where('ownerId', isEqualTo: uid)
        .where('isDeleted', isEqualTo: false)
        .get();
      
      // 3. Get all units
      final unitsSnap = await firestore.collection('units')
        .where('ownerId', isEqualTo: uid)
        .get();
      
      // Build maps
      final tenantsById = <String, Map<String, dynamic>>{};
      for (final doc in tenantsSnap.docs) {
        final data = doc.data();
        final id = (data['id'] ?? doc.id).toString();
        tenantsById[id] = data;
      }
      
      final unitsById = <String, Map<String, dynamic>>{};
      for (final doc in unitsSnap.docs) {
        final data = doc.data();
        final id = (data['id'] ?? doc.id).toString();
        unitsById[id] = data;
      }
      
      // 4. For each contract, check if tenantId is valid
      final batch = firestore.batch();
      
      for (final contractDoc in contractsSnap.docs) {
        final contract = contractDoc.data();
        final currentTenantId = contract['tenantId']?.toString() ?? '';
        
        // Check if tenant exists
        if (tenantsById.containsKey(currentTenantId)) {
          continue; // OK
        }
        
        // Try to find correct tenant via unit
        final unitId = contract['unitId']?.toString() ?? '';
        final unit = unitsById[unitId];
        if (unit != null) {
          final unitTenantId = unit['tenantId']?.toString() ?? '';
          if (unitTenantId.isNotEmpty && tenantsById.containsKey(unitTenantId)) {
            batch.update(contractDoc.reference, {'tenantId': unitTenantId});
            fixed++;
          }
        }
      }
      
      if (fixed > 0) {
        await batch.commit();
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Repair complete! Fixed $fixed contracts.')),
        );
        // Invalidate providers to refresh data
        ref.invalidate(allUnitsProvider);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Repair failed: $e')));
      }
    }
  }

  Future<void> _showDeleteAccountConfirmation(BuildContext context, WidgetRef ref, String uid) async {
    // Step 1: Initial Warning
    final step1 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('settings.delete_account'.tr(), style: const TextStyle(color: Colors.red)),
        content: const Text('This will permanently delete your account and ALL associated data (properties, tenants, payments). \n\nThis action is irreversible. All data will be lost forever.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('properties.cancel'.tr())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Next: Confirm Deletion'),
          ),
        ],
      ),
    );

    if (step1 != true || !context.mounted) return;

    // Step 2: Backup & Final Confirm
    final step2 = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you absolutely sure? This cannot be undone.'),
            SizedBox(height: 12),
            Text('To confirm permanent deletion, please type "DELETE" below.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          ],
        ),
        actions: [
          _ConfirmationActions(
            onConfirm: () => Navigator.pop(ctx, true),
            onCancel: () => Navigator.pop(ctx, false),
          ),
        ],
      ),
    );

    if (step2 != true || !context.mounted) return;

    // Step 3: Execution
    try {
      await DialogUtils.runWithLoading(context, () async {
        await ref.read(ownerControllerProvider.notifier).deleteOwnerAccount();
      });
      
      if (context.mounted) {
        // Go back to login
        context.go('/'); // Go to Role Selection
        SnackbarUtils.showSuccess(context, 'Account deleted successfully');
      }
    } catch (e) {
       if (context.mounted) SnackbarUtils.showError(context, 'Deletion failed: $e');
    }
  }

  String _getLanguageName(BuildContext context) {
    try {
      return context.locale.languageCode == 'en' ? 'English' : 'हिंदी';
    } catch (_) {
      return 'English';
    }
  }
}

class _ConfirmationActions extends StatefulWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ConfirmationActions({required this.onConfirm, required this.onCancel});

  @override
  State<_ConfirmationActions> createState() => _ConfirmationActionsState();
}

class _ConfirmationActionsState extends State<_ConfirmationActions> {
  final _ctrl = TextEditingController();
  bool _canDelete = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _ctrl,
            decoration: const InputDecoration(hintText: 'DELETE', border: OutlineInputBorder()),
            onChanged: (v) => setState(() => _canDelete = v.trim().toUpperCase() == 'DELETE'),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _canDelete ? widget.onConfirm : null,
              child: const Text('Delete Forever'),
            ),
          ],
        ),
      ],
    );
  }
}
