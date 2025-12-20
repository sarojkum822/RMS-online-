import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/data_providers.dart'; // NEW
import '../../../core/services/secure_storage_service.dart';
import '../owner/tenant/tenant_controller.dart'; 
import '../../../core/services/biometric_service.dart'; // NEW
import 'package:flutter/services.dart'; // NEW 

class TenantLoginScreen extends ConsumerStatefulWidget {
  const TenantLoginScreen({super.key});

  @override
  ConsumerState<TenantLoginScreen> createState() => _TenantLoginScreenState();
}

class _TenantLoginScreenState extends ConsumerState<TenantLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(); // NEW
  final _storageService = SecureStorageService();
  final _biometricService = BiometricService(); // NEW
  bool _isLoading = false;
  bool _canCheckBiometrics = false; // NEW
  bool _isBiometricEnabled = false; // NEW

  @override
  void initState() {
    super.initState();
    _checkBiometrics(); // NEW: Combined check
  }

  Future<void> _checkBiometrics() async {
    final available = await _biometricService.isBiometricAvailable();
    final enabled = await _storageService.isBiometricEnabled();
    final creds = await _storageService.getCredentials();
    
    if (mounted) {
      setState(() {
        _canCheckBiometrics = available && enabled && creds != null;
        _isBiometricEnabled = enabled;
        
        if (creds != null) {
          _emailController.text = creds['email']!;
          _passwordController.text = creds['password']!;
        }
      });
      
      // Auto-trigger if enabled
       if (_canCheckBiometrics) {
          _loginWithBiometrics();
       }
    }
  }

  Future<void> _loginWithBiometrics() async {
    final authenticated = await _biometricService.authenticate();
    if (authenticated) {
      final creds = await _storageService.getCredentials();
      if (creds != null) {
        _emailController.text = creds['email']!;
        _passwordController.text = creds['password']!;
        _submitLogin(); 
      }
    }
  }

  Future<void> _submitLogin() async {
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
                           await _storageService.saveCredentials(email, password); // SAVE CREDS

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
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : Colors.white,
      appBar: AppBar(
        title: Text('Resident Portal', 
          style: GoogleFonts.playfairDisplay(
            color: isDark ? Colors.white : const Color(0xFF0F172A), 
            fontWeight: FontWeight.bold,
            fontSize: 22,
          )
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black),
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
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Securely access your residence portal.',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 32),

                TextField(
                  controller: _emailController,
                  style: GoogleFonts.outfit(fontSize: 15),
                  decoration: InputDecoration(
                    labelText: 'Register Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF8FAFC),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: GoogleFonts.outfit(fontSize: 15),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF8FAFC),
                  ),
                ),
                
                const SizedBox(height: 24),

                if (_canCheckBiometrics) ...[
                   SizedBox(
                     height: 56,
                     width: double.infinity,
                     child: OutlinedButton.icon(
                       style: OutlinedButton.styleFrom(
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                         side: BorderSide(color: theme.primaryColor),
                       ),
                       onPressed: _isLoading ? null : () {
                         HapticFeedback.lightImpact();
                         _loginWithBiometrics();
                       },
                       icon: const Icon(Icons.fingerprint, size: 28),
                       label: const Text("Login with Face ID / Fingerprint"),
                     ),
                   ),
                   const SizedBox(height: 16),
                ],

                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () {
                      HapticFeedback.lightImpact();
                      _submitLogin();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                      'Sign In to Dashboard',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                
                // Note for tenants
                Center(
                  child: Text(
                    'Credentials are provided by your property owner.\nContact them if you need login access.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: theme.hintColor,
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
