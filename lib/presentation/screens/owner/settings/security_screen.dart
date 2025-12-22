import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/data_providers.dart';
import '../../../../core/services/biometric_service.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool _biometricEnabled = false;
  bool _vaultLockEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final biometricEnabled = await ref.read(userSessionServiceProvider).isBiometricEnabled();
    final vaultLockEnabled = await ref.read(userSessionServiceProvider).isVaultLockEnabled();
    setState(() {
      _biometricEnabled = biometricEnabled;
      _vaultLockEnabled = vaultLockEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Security', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Biometric Auth Toggle (for app login)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: SwitchListTile(
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.fingerprint, color: theme.colorScheme.primary),
              ),
              title: Text('Biometric Auth', style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: theme.textTheme.bodyLarge?.color)),
              subtitle: Text('Use fingerprint for app login', style: GoogleFonts.outfit(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
              value: _biometricEnabled,
              onChanged: (v) async {
                final biometricService = ref.read(biometricServiceProvider);
                if (v) {
                  final available = await biometricService.isBiometricAvailable();
                  if (!available) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometrics not available on this device')));
                    }
                    return;
                  }
                  
                  final authenticated = await biometricService.authenticate();
                  if (authenticated) {
                    setState(() => _biometricEnabled = true);
                    await ref.read(userSessionServiceProvider).saveBiometricPreference(true);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometric Login Enabled')));
                    }
                  }
                } else {
                  // Require re-authentication before disabling
                  final result = await biometricService.authenticateWithResult(
                    reason: 'Verify identity to disable Biometric Login',
                  );
                  
                  if (result == BiometricResult.success) {
                    setState(() => _biometricEnabled = false);
                    await ref.read(userSessionServiceProvider).saveBiometricPreference(false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometric Login Disabled')));
                    }
                  } else if (result == BiometricResult.lockedOut) {
                    final remaining = await biometricService.getRemainingLockoutSeconds();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Too many failed attempts. Try again in ${remaining}s')),
                      );
                    }
                  }
                }
              },
              activeThumbColor: theme.colorScheme.primary,
            ),
          ),
          
          // Vault Lock Toggle (for Personal Vault)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: SwitchListTile(
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.lock_person, color: Colors.amber),
              ),
              title: Text('Vault Lock', style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: theme.textTheme.bodyLarge?.color)),
              subtitle: Text('Require fingerprint for Personal Vault', style: GoogleFonts.outfit(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
              value: _vaultLockEnabled,
              onChanged: (v) async {
                final biometricService = ref.read(biometricServiceProvider);
                if (v) {
                  final available = await biometricService.isBiometricAvailable();
                  if (!available) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometrics not available on this device')));
                    }
                    return;
                  }
                  
                  final authenticated = await biometricService.authenticate();
                  if (authenticated) {
                    setState(() => _vaultLockEnabled = true);
                    await ref.read(userSessionServiceProvider).saveVaultLockPreference(true);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vault Lock Enabled')));
                    }
                  }
                } else {
                  // Require re-authentication before disabling
                  final result = await biometricService.authenticateWithResult(
                    reason: 'Verify identity to disable Vault Lock',
                  );
                  
                  if (result == BiometricResult.success) {
                    setState(() => _vaultLockEnabled = false);
                    await ref.read(userSessionServiceProvider).saveVaultLockPreference(false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vault Lock Disabled')));
                    }
                  } else if (result == BiometricResult.lockedOut) {
                    final remaining = await biometricService.getRemainingLockoutSeconds();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Too many failed attempts. Try again in ${remaining}s')),
                      );
                    }
                  }
                }
              },
              activeThumbColor: Colors.amber,
            ),
          ),
          
           _buildItem(
            context: context,
            icon: Icons.devices,
            title: 'Active Sessions',
             onTap: () => context.push('/owner/settings/security/active-sessions'),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({required BuildContext context, required IconData icon, required String title, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: theme.textTheme.bodyLarge?.color)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.hintColor),
        onTap: onTap,
      ),
    );
  }
}
