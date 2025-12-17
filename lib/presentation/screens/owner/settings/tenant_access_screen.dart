import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../providers/data_providers.dart';

class TenantAccessScreen extends ConsumerStatefulWidget {
  const TenantAccessScreen({super.key});

  @override
  ConsumerState<TenantAccessScreen> createState() => _TenantAccessScreenState();
}

class _TenantAccessScreenState extends ConsumerState<TenantAccessScreen> {
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

  void _shareViaWhatsApp(Tenant tenant) async {
    final email = tenant.email ?? 'Not Set';
    final password = tenant.password ?? 'Not Set';
    
    final message = '''
Hello ${tenant.name},
Here are your login credentials for the RentPilot Tenant App:

Email: $email
Password: $password

Please download the app and log in.
''';

    final url = Uri.parse("whatsapp://send?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if(mounted) {
         Share.share(message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenantsAsync = ref.watch(tenantRepositoryProvider).getAllTenants();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, 
      appBar: AppBar(
        title: Text('Tenant Access', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: StreamBuilder<List<Tenant>>(
        stream: tenantsAsync,
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
                   Icon(Icons.people_outline, size: 64, color: theme.disabledColor),
                   const SizedBox(height: 16),
                   Text('No tenants found', style: GoogleFonts.outfit(fontSize: 18, color: theme.textTheme.bodyMedium?.color)),
                ],
              ),
            );
          }
          
          tenants.sort((a, b) => a.name.compareTo(b.name));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tenants.length,
            itemBuilder: (context, index) {
              final tenant = tenants[index];
              return _buildTenantCard(tenant, theme, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildTenantCard(Tenant tenant, ThemeData theme, bool isDark) {
    final isPasswordVisible = _visiblePasswords[tenant.id] ?? false;
    final email = tenant.email ?? 'N/A';
    final password = tenant.password ?? 'N/A';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
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
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Text(
                    tenant.name.isNotEmpty ? tenant.name[0].toUpperCase() : '?',
                    style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tenant.name,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                  IconButton(
                    icon: const Icon(Icons.mark_chat_unread_rounded, color: Colors.green), 
                    onPressed: () => _shareViaWhatsApp(tenant),
                    tooltip: 'Share via WhatsApp',
                  ),
                  IconButton(
                    icon: Icon(Icons.share, color: theme.colorScheme.primary),
                    onPressed: () => _shareCredentials(tenant),
                    tooltip: 'Share Credentials',
                  ),
              ],
            ),
            Divider(height: 24, color: theme.dividerColor),
            _buildCredentialRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: email,
              onCopy: () => _copyToClipboard(email, 'Email'),
              theme: theme,
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
              theme: theme,
            ),
            
            const SizedBox(height: 16),
            Container(
               width: double.infinity,
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(
                 color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100], 
                 borderRadius: BorderRadius.circular(8)
               ),
               child: Text(
                 'To change password, delete and re-add tenant.',
                 textAlign: TextAlign.center,
                 style: GoogleFonts.outfit(fontSize: 11, color: theme.textTheme.bodySmall?.color),
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
    required ThemeData theme,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.hintColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(fontSize: 12, color: theme.hintColor),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: isPassword && !isVisible 
                    ? TextStyle(fontSize: 16, color: theme.textTheme.bodyLarge?.color)
                    : GoogleFonts.outfit(fontSize: 16, color: theme.textTheme.bodyLarge?.color),
              ),
            ],
          ),
        ),
        if (isPassword)
          IconButton(
            icon: Icon(
              isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: theme.hintColor,
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
            child: Icon(Icons.copy, size: 18, color: theme.hintColor),
          ),
        ),
      ],
    );
  }
}
