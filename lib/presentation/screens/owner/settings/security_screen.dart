import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/data_providers.dart';
import '../../../../core/services/user_session_service.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricPreference();
  }

  Future<void> _loadBiometricPreference() async {
    final enabled = await ref.read(userSessionServiceProvider).isBiometricEnabled();
    setState(() {
      _biometricEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Security', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
           _buildItem(
            icon: Icons.lock,
            title: 'Change Password',
            onTap: () {
               // Implement Change Password Screen or Dialog
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Change Password Feature coming soon')));
               // context.push('/owner/settings/security/change-password');
            },
          ),
          
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.fingerprint, color: Theme.of(context).colorScheme.primary),
              ),
              title: Text('Biometric Auth', style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
              subtitle: Text('Use fingerprint/face ID', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
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
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometric Enabled')));
                    }
                  }
                } else {
                  setState(() => _biometricEnabled = false);
                  await ref.read(userSessionServiceProvider).saveBiometricPreference(false);
                }
              },
              activeThumbColor: Colors.black,
            ),
          ),
          
           _buildItem(
            icon: Icons.devices,
            title: 'Active Sessions',
             onTap: () => context.push('/owner/settings/security/active-sessions'),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
