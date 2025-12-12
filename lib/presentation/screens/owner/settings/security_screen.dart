import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/data_providers.dart';

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
    // Load preference (mock for now, normally from SharedPreferences)
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
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password Change Flow Mock')));
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
                decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.fingerprint, color: Colors.purple),
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
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometric Enabled')));
                      // Save to SharedPreferences here
                    }
                  }
                } else {
                  setState(() => _biometricEnabled = false);
                   // Save to SharedPreferences here
                }
              },
              activeThumbColor: Colors.black,
            ),
          ),
          
           _buildItem(
            icon: Icons.devices,
            title: 'Active Sessions',
             onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Show Active Sessions Mock')));
            },
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
