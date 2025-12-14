import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/data_providers.dart'; // NEW
import '../owner/tenant/tenant_controller.dart'; 

class TenantLoginScreen extends ConsumerStatefulWidget {
  const TenantLoginScreen({super.key});

  @override
  ConsumerState<TenantLoginScreen> createState() => _TenantLoginScreenState();
}

class _TenantLoginScreenState extends ConsumerState<TenantLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(); // NEW
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Tenant Login', style: GoogleFonts.outfit(color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.bold)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.iconTheme.color),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                        'Welcome Back',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.headlineMedium?.color, // Was 0xFF1E293B
                        ),
                      ),
                const SizedBox(height: 8),
                Text(
                  'Enter your credentials provided by the property owner.',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: theme.textTheme.bodyMedium?.color, // Was 0xFF64748B
                  ),
                ),
                const SizedBox(height: 32),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                ),
                
                const SizedBox(height: 48),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      final email = _emailController.text.trim().toLowerCase();
                      final password = _passwordController.text.trim();
                      
                      if (email.isEmpty || password.isEmpty) {
                         ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter email and password.'))
                         );
                         return;
                      }

                      setState(() => _isLoading = true);

                      try {
                        // Using TenantController to find tenant
                        final tenant = await ref.read(tenantControllerProvider.notifier).login(email, password);
                        
                        if (tenant != null && context.mounted) {
                           final sessionService = ref.read(userSessionServiceProvider);
                           await sessionService.saveSession(role: 'tenant', tenantId: tenant.id);
                           // Save Token for Notifications
                           await sessionService.saveTenantFcmToken(tenant.id);
                           
                           if (context.mounted) context.go('/tenant/dashboard', extra: tenant);
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid Credentials or Account Inactive.'))
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Login Failed: $e'))
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary, // Was Color(0xFF00897B)
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                      'Login',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}
