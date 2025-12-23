import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/services/auth_service.dart';
import '../owner/settings/owner_controller.dart';
import '../owner/tenant/tenant_controller.dart';
import '../owner/house/house_controller.dart';
import '../owner/rent/rent_controller.dart';
import '../../../core/utils/dialog_utils.dart';
import '../../providers/data_providers.dart';
import '../../../core/services/biometric_service.dart';
import 'package:flutter/services.dart';
import '../../../core/services/secure_storage_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String role; // 'owner' or 'tenant'
  
  const LoginScreen({super.key, this.role = 'owner'});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLogin = true;
  
  // Biometric
  BiometricService get _biometricService => ref.read(biometricServiceProvider);
  SecureStorageService get _storageService => ref.read(secureStorageServiceProvider);
  bool _canCheckBiometrics = false;
  bool _obscurePassword = true; // Password visibility toggle
  bool _biometricPreAuthorized = false; // Flag: Recorded fingerprint but waiting for password login

  bool get isOwner => widget.role == 'owner';

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    
    // Check if this is a first-time login after signup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showBiometricSetupIfNeeded();
    });
  }

  Future<void> _checkBiometrics() async {
    final available = await _biometricService.isBiometricAvailable();
    final enabled = await _storageService.isBiometricEnabled();
    final role = isOwner ? 'owner' : 'tenant';
    final creds = await _storageService.getCredentials(role: role);
    
    if (mounted) {
      setState(() {
        _canCheckBiometrics = available && enabled && creds != null;
        
        
        // AUTOFILL: Populate fields if credentials exist for THIS ROLE
        if (creds != null) {
          _emailCtrl.text = creds['email']!;
          _passwordCtrl.text = creds['password']!;
        }
      });
      
      // Auto-trigger if enabled and available
      if (_canCheckBiometrics) {
         _loginWithBiometrics();
      }
    }
  }

  Future<void> _loginWithBiometrics() async {
    try {
      final authenticated = await _biometricService.authenticate();
      
      if (authenticated) {
        // After biometric success, use full-screen loading for the actual login/network part
        if (mounted) {
          await DialogUtils.runWithLoading(context, () async {
            final role = isOwner ? 'owner' : 'tenant';
            final creds = await _storageService.getCredentials(role: role);
            if (creds != null) {
              _emailCtrl.text = creds['email']!;
              _passwordCtrl.text = creds['password']!;
              await _submit(); // Now _submit is wrapped in loading
            } else {
              throw Exception('No saved credentials found for this account type. Please login with your email and password first.');
            }
          });
        }
      }
      // If cancelled, do nothing - user may want to use password login instead
    } catch (e) {
      // Biometric error - show dialog without logging sensitive details
      if (mounted) {
        DialogUtils.showErrorDialog(
          context, 
          title: 'Authentication Failed', 
          message: e.toString().replaceAll('Exception: ', '')
        );
      }
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Use runWithLoading for better UX (full screen modal)
        await DialogUtils.runWithLoading(context, () async {
          final auth = ref.read(authServiceProvider);
          
          // OWNER LOGIN
          if (isOwner) {
              if (_isLogin) {
                try {
                  await auth.signIn(_emailCtrl.text.trim(), _passwordCtrl.text.trim());
                  await _handleOwnerLoginSuccess(auth);
                } catch (e) {
                  // Specific handling for credential errors (wrong password etc)
                  final errorMessage = e.toString().toLowerCase();
                  if (errorMessage.contains('invalid') || 
                      errorMessage.contains('wrong') ||
                      errorMessage.contains('credential')) {
                    if (mounted) {
                      _showLoginFailedWithOptionsDialog(_emailCtrl.text.trim(), e.toString().replaceAll('Exception: ', ''));
                    }
                    return; // Stop here, dialog handles next steps
                  }
                  rethrow; // For other errors, let outer catch handle it
                }
              } else {
                await auth.signUp(_emailCtrl.text.trim(), _passwordCtrl.text.trim());
                if (mounted) {
                   await showDialog(
                     context: context,
                     builder: (context) => AlertDialog(
                       title: const Text('Account Created'),
                       content: const Text('Your account has been successfully created.\nPlease login with your new credentials to continue.'),
                       actions: [
                         TextButton(
                           onPressed: () {
                             Navigator.pop(context);
                             setState(() {
                               _isLogin = true;
                               _passwordCtrl.clear();
                             });
                             // Trigger Biometric Onboarding immediately after signup -> login transition
                             _showBiometricSetupIfNeeded();
                           }, 
                           child: const Text('Login Now')
                         ),
                       ],
                     ),
                   );
                }
              }
          } else {
              // TENANT LOGIN
              await auth.signIn(_emailCtrl.text.trim(), _passwordCtrl.text.trim());
              
              final tenantRepo = ref.read(tenantRepositoryProvider);
              final tenant = await tenantRepo.getTenantByAuthId(auth.currentUser!.uid);
              
              if (tenant != null) {
                   await ref.read(userSessionServiceProvider).saveSession(role: 'tenant', tenantId: tenant.id);
                   
                   // Save credentials for biometric with UID for identity verification
                   await _storageService.saveCredentials(
                     _emailCtrl.text.trim(), 
                     _passwordCtrl.text.trim(), 
                     role: 'tenant',
                     uid: auth.currentUser!.uid,
                   );
                   // Check for Biometric Setup Completion
                   if (_biometricPreAuthorized) {
                      await _storageService.setBiometricEnabled(true);
                   }
                   
                   // FCM Token saving removed as per user request
                   
                   if (mounted) {
                      context.go('/tenant/dashboard', extra: tenant);
                   }
              } else {
                   if (mounted) {
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Profile Not Found'),
                          content: const Text('This account exists but no tenant profile was found.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
                          ],
                        ),
                      );
                      await auth.signOut();
                   }
              }
          }
        });
      } catch (e) {
        if (mounted) {
          String message = e.toString().replaceAll('Exception: ', '');
          
          // Enhance network error message
          if (message.toLowerCase().contains('network') || 
              message.toLowerCase().contains('connection') ||
              message.toLowerCase().contains('unreachable') ||
              message.toLowerCase().contains('timeout')) {
            message = "Network error detected. Please check your internet connection or try connecting to a different network.";
          }
          
          DialogUtils.showErrorDialog(context, title: 'Authentication Failed', message: message);
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  /// Shows a dialog when login fails with recovery options
  void _showLoginFailedWithOptionsDialog(String email, String errorMessage) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Expanded(child: Text('Login Failed')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.red.shade700, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Having trouble logging in? Try:',
              style: TextStyle(fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 8),
            const Text('• Check your email and password'),
            const Text('• Use "Reset Password" to set a new password'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showForgotPasswordDialog(email);
            },
            child: const Text('Reset Password'),
          ),
        ],
      ),
    );
  }

  /// Shows Forgot Password dialog
  void _showForgotPasswordDialog([String? prefillEmail]) {
    final emailController = TextEditingController(text: prefillEmail ?? _emailCtrl.text);
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);
    final primaryColor = isOwner 
        ? const Color(0xFF4F46E5)
        : const Color(0xFF059669);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email is required';
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(v.trim())) return 'Invalid email format';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );
                
                try {
                  final auth = ref.read(authServiceProvider);
                  await auth.sendPasswordResetEmail(emailController.text.trim());
                  
                  
                  if (context.mounted) {
                    Navigator.pop(context); // Close loading
                    Navigator.pop(context); // Close dialog
                    DialogUtils.showInfoDialog(
                      context,
                      title: 'Email Sent',
                      message: 'A password reset link has been sent to ${emailController.text.trim()}.\n\nPlease check your inbox (and spam folder).',
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context); // Close loading
                    Navigator.pop(context); // Close dialog
                    DialogUtils.showErrorDialog(
                      context,
                      title: 'Error',
                      message: e.toString().replaceAll('Exception: ', ''),
                    );
                  }
                }
              }
            },
            child: const Text('Send Reset Link', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleOwnerLoginSuccess(AuthService auth) async {
      print('DEBUG: _handleOwnerLoginSuccess started');
      try {
        // 1. Save Session (CRITICAL: Do this first so role is available for providers)
        await ref.read(userSessionServiceProvider).saveSession(role: 'owner');
        print('DEBUG: Session saved');
        
        // 2. CRITICAL: Wait for Firebase Auth token to propagate to Firestore
        // This fixes "Failed to Load Tenants" error when switching between users
        await Future.delayed(const Duration(milliseconds: 300));
        print('DEBUG: First delay finished');
        
        // 3. Clear/Refresh ALL Controllers and Repository providers
        // Invalidating the repository providers forces new streams with the new UID
        ref.invalidate(ownerControllerProvider);
        ref.invalidate(tenantControllerProvider);
        ref.invalidate(houseControllerProvider);
        ref.invalidate(rentControllerProvider);
        ref.invalidate(tenantRepositoryProvider);
        ref.invalidate(propertyRepositoryProvider);
        ref.invalidate(allUnitsProvider);
        print('DEBUG: Providers invalidated');

        // 4. Save credentials for next login
        final email = _emailCtrl.text.trim();
        final password = _passwordCtrl.text.trim();
        if (email.isNotEmpty && password.isNotEmpty) {
          await _storageService.saveCredentials(
            email, 
            password, 
            role: 'owner',
            uid: auth.currentUser!.uid,
          );
          print('DEBUG: Credentials saved');
        }

        // 5. Background tasks (don't block the UI transition)
        // FCM Token saving removed as per user request

        // Let the state settle and show a brief success/loading state
        await Future.delayed(const Duration(milliseconds: 1000));
        print('DEBUG: Second delay finished');

        if (mounted) {
          print('DEBUG: Widget still mounted, navigating...');
          if (_biometricPreAuthorized) {
            await _storageService.setBiometricEnabled(true);
          }
          if (mounted) {
            context.go('/owner/dashboard');
          }
        } else {
          print('DEBUG: Widget NOT mounted');
        }
      } catch (e) {
        print('DEBUG: Error in _handleOwnerLoginSuccess: $e');
        if (mounted) {
          context.go('/owner/dashboard'); // Still try to navigate if session was saved or if it's a minor error
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    final title = isOwner ? 'Makaan Malik Login' : 'Kirayedar Login';
    final subtitle = isOwner ? 'Manage your properties' : 'View your rent details';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Define primary color based on role
    final primaryColor = isOwner 
        ? (isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5)) // Lighter Indigo for dark mode
        : (isDark ? const Color(0xFF34D399) : const Color(0xFF059669)); // Lighter Green for dark mode

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => context.go('/'), 
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48, // Adjust for padding
                ),
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'KirayaBook',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    letterSpacing: -1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 18, 
                                    fontWeight: FontWeight.bold, 
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13, 
                                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 48),
                                
                                if (_errorMessage != null)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.red.withValues(alpha: 0.1) : Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: isDark ? Colors.red.withValues(alpha: 0.3) : Colors.red.shade200),
                                    ),
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(color: isDark ? Colors.redAccent : Colors.red.shade800),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
              
                                  TextFormField(
                                    controller: _emailCtrl,
                                    style: GoogleFonts.outfit(fontSize: 15),
                                    decoration: InputDecoration(
                                      labelText: isOwner ? 'Email Address' : 'Phone / Email', 
                                      prefixIcon: const Icon(Icons.person_outline),
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
                                    keyboardType: TextInputType.emailAddress,
                                    textCapitalization: TextCapitalization.none,
                                    autocorrect: false,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Required';
                                      if (isOwner || v.contains('@')) {
                                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                        if (!emailRegex.hasMatch(v.trim())) return 'Invalid email format';
                                      }
                                      return null;
                                    },
                                  ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordCtrl,
                                  style: GoogleFonts.outfit(fontSize: 15),
                                  decoration: InputDecoration(
                                    labelText: 'login.password_label'.tr(),
                                    prefixIcon: const Icon(Icons.lock_outlined),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
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
                                  obscureText: _obscurePassword,
                                  validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
                                ),
                                const SizedBox(height: 8),
                                
                                // Forgot Password Link
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => _showForgotPasswordDialog(),
                                    style: TextButton.styleFrom(
                                      foregroundColor: primaryColor,
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 30),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text('Forgot Password?', style: TextStyle(fontSize: 13)),
                                  ),
                                ),
                                const SizedBox(height: 24),
              
                                // Biometric Button
                                if (_canCheckBiometrics) ...[
                                  SizedBox(
                                    height: 50,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        side: BorderSide(color: primaryColor),
                                        foregroundColor: primaryColor,
                                      ),
                                      onPressed: _isLoading ? null : () {
                                        HapticFeedback.lightImpact();
                                        _loginWithBiometrics();
                                      },
                                      icon: const Icon(Icons.fingerprint, size: 28),
                                      label: const Text("Login with Biometrics"),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                
                                // Main Action Button
                                SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      foregroundColor: isDark ? Colors.black : Colors.white,
                                      elevation: 0,
                                    ),
                                    onPressed: _isLoading ? null : () {
                                      HapticFeedback.lightImpact();
                                      _submit();
                                    },
                                    child: _isLoading 
                                      ? const CircularProgressIndicator(color: Colors.white) 
                                      : Text(
                                          _isLogin ? 'Sign In to KirayaBook' : 'Create New Account',
                                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                  ),
                                ),
                                
                                // Removed: Guest & Social Login options
                                // Keeping only Email/Password authentication

                                const SizedBox(height: 16),
                                if (isOwner)
                                 Row(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                     Text(_isLogin ? "Don't have an account? " : "Already have an account? ", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                                     TextButton(
                                       onPressed: () => setState(() {
                                           _isLogin = !_isLogin;
                                           _errorMessage = null;
                                       }),
                                       style: TextButton.styleFrom(foregroundColor: primaryColor),
                                       child: Text(_isLogin ? 'Sign Up' : 'Login'),
                                     ),
                                   ],
                                 )
                                else
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(
                                      'Note: Only your Makaan Malik (Owner) can create your account. Please ask them for your credentials.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.outfit(color: theme.textTheme.bodySmall?.color, fontSize: 14),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showBiometricSetupIfNeeded() async {
    // Logic: If it's the login form and biometric is available but NOT yet enabled
    final available = await _biometricService.isBiometricAvailable();
    final enabled = await _storageService.isBiometricEnabled();
    
    if (available && !enabled && _isLogin && mounted) {
      _showBiometricSetupSheet();
    }
  }

  void _showBiometricSetupSheet() {
    final theme = Theme.of(context);
    final primaryColor = isOwner 
        ? const Color(0xFF4F46E5)
        : const Color(0xFF059669);

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(Icons.fingerprint, size: 64, color: primaryColor),
            const SizedBox(height: 16),
            Text(
              'Set up Fingerprint Login',
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'For a faster and more secure login next time, you can record your fingerprint now. You will still need to enter your password this one time for security.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 14, color: theme.hintColor),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () async {
                  final success = await _biometricService.authenticate(reason: 'Verify your identity to enable fingerprint login');
                  if (success && mounted) {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    
                    navigator.pop();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Fingerprint recorded! Please log in once with your password to link it.')),
                    );
                    
                    setState(() {
                       _biometricPreAuthorized = true;
                       _canCheckBiometrics = false; // Hide biometric login button for this first time
                    });
                  }
                },
                child: const Text('Record Fingerprint', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Not Now, Maybe Later', style: TextStyle(color: theme.hintColor)),
            ),
          ],
        ),
      ),
    );
  }
}
