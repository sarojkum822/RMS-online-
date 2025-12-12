import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For clipboard
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../providers/data_providers.dart';
import '../tenant/tenant_controller.dart';

class TenantAccessScreen extends ConsumerStatefulWidget {
  const TenantAccessScreen({super.key});

  @override
  ConsumerState<TenantAccessScreen> createState() => _TenantAccessScreenState();
}

class _TenantAccessScreenState extends ConsumerState<TenantAccessScreen> {
  // Map to track visibility state of passwords for each tenant ID
  final Map<int, bool> _visiblePasswords = {};

  void _toggleVisibility(int id) {
    setState(() {
      _visiblePasswords[id] = !(_visiblePasswords[id] ?? false);
    });
  }

  void _copyToClipboard(String text, String label) {
    if (text.isEmpty || text == 'N/A') return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied to clipboard')),
    );
  }

  void _shareCredentials(Tenant tenant) {
    final email = tenant.email ?? 'Not Set';
    final password = tenant.password ?? 'Not Set';
    
    final message = '''
Hello ${tenant.name},
Here are your login credentials for the RentPilot Tenant App:

Email: $email
Password: $password

Please download the app and log in.
''';
    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    final tenantsAsync = ref.watch(tenantRepositoryProvider).getAllTenants();

    return Scaffold(
      backgroundColor: Colors.grey[50], // AppTheme.background
      appBar: AppBar(
        title: Text('Tenant Access', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Tenant>>(
        future: tenantsAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final tenants = snapshot.data ?? [];
          if (tenants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                   const SizedBox(height: 16),
                   Text('No tenants found', style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey[600])),
                ],
              ),
            );
          }
          
          // Sort alphabetically
          tenants.sort((a, b) => a.name.compareTo(b.name));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tenants.length,
            itemBuilder: (context, index) {
              final tenant = tenants[index];
              return _buildTenantCard(tenant);
            },
          );
        },
      ),
    );
  }

  Widget _buildTenantCard(Tenant tenant) {
    final isPasswordVisible = _visiblePasswords[tenant.id] ?? false;
    final email = tenant.email ?? 'N/A';
    // Password is now decrypted by repo, so we see plain text here.
    final password = tenant.password ?? 'N/A';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF006B5E).withValues(alpha: 0.1),
                  child: Text(
                    tenant.name.isNotEmpty ? tenant.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Color(0xFF006B5E), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tenant.name,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                  // EDIT BUTTON REMOVED AS PER SECURITY REQUEST (Read-Only Mode)
                  IconButton(
                    icon: const Icon(Icons.share, color: Color(0xFF006B5E)),
                    onPressed: () => _shareCredentials(tenant),
                    tooltip: 'Share Credentials',
                  ),
              ],
            ),
            const Divider(height: 24),
            _buildCredentialRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: email,
              onCopy: () => _copyToClipboard(email, 'Email'),
            ),
            const SizedBox(height: 12),
            _buildCredentialRow(
              icon: Icons.lock_outline,
              label: 'Password',
              value: isPasswordVisible ? password : '••••••••',
              isPassword: true,
              isVisible: isPasswordVisible,
              onToggleVisibility: () => _toggleVisibility(tenant.id),
              onCopy: () => _copyToClipboard(password, 'Password'),
            ),
            
            // Helpful Footer
            const SizedBox(height: 16),
            Container(
               width: double.infinity,
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
               child: Text(
                 'To change password, delete and re-add tenant.',
                 textAlign: TextAlign.center,
                 style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[600]),
               ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onCopy,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[500]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: isPassword && !isVisible 
                    ? const TextStyle(fontSize: 16, color: Colors.black87)
                    : GoogleFonts.outfit(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
        if (isPassword)
          IconButton(
            icon: Icon(
              isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.grey[600],
              size: 20,
            ),
            onPressed: onToggleVisibility,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        if (isPassword) const SizedBox(width: 16),
        InkWell(
          onTap: onCopy,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.copy, size: 18, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  // Edit Dialog REMOVED
}
