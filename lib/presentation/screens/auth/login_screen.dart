import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final _biometricService = BiometricService();
  final _storageService = SecureStorageService();
  bool _canCheckBiometrics = false;
  bool _isBiometricEnabled = false;

  bool get isOwner => widget.role == 'owner';

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final available = await _biometricService.isBiometricAvailable();
    final enabled = await _storageService.isBiometricEnabled();
    final creds = await _storageService.getCredentials();
    
    if (mounted) {
      setState(() {
        _canCheckBiometrics = available && enabled && creds != null;
        
        _isBiometricEnabled = enabled; // Track preference
        
        // AUTOFILL: Populate fields if credentials exist
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
        final creds = await _storageService.getCredentials();
        if (creds != null) {
          _emailCtrl.text = creds['email']!;
          _passwordCtrl.text = creds['password']!;
          _submit(); 
        }
      }
    } catch (e) {
      debugPrint('Biometric login skipped/failed: $e');
      // Optional: Show snackbar or silent fail. 
      // Since it's auto-login, maybe silent fail is better or a small toast.
      if (mounted) {
         // Only show error if manual trigger, hard to distinguish here unless we pass a param.
         // But for now, let's keep it silent or debug print as to not annoy user on startup.
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
        final auth = ref.read(authServiceProvider);
        
        // OWNER LOGIN
        if (isOwner) {
            if (_isLogin) {
              try {
                await auth.signIn(_emailCtrl.text.trim(), _passwordCtrl.text.trim());
                _handleOwnerLoginSuccess(auth);
              } catch (e) {
                // Smart error handling: Show helpful dialog with recovery options
                final email = _emailCtrl.text.trim();
                final errorMessage = e.toString().toLowerCase();
                
                // Check if this is a credential error (wrong password or no password provider)
                if (errorMessage.contains('invalid') || 
                    errorMessage.contains('wrong') ||
                    errorMessage.contains('credential')) {
                  // Show dialog with recovery options
                  if (mounted) {
                    _showLoginFailedWithOptionsDialog(email, e.toString().replaceAll('Exception: ', ''));
                  }
                  return;
                }
                rethrow; // Let outer catch handle other errors
              }
            } else {
              await auth.signUp(_emailCtrl.text.trim(), _passwordCtrl.text.trim());
              
              if (mounted) {
                 await showDialog(
                   context: context,
                   builder: (context) => AlertDialog(
                     title: const Text('Account Created'),
                     content: const Text('Your account has been successfully created.\n\nPlease login with your new credentials to continue.'),
                     actions: [
                       TextButton(
                         onPressed: () {
                           Navigator.pop(context);
                           setState(() {
                             _isLogin = true;
                             _passwordCtrl.clear();
                           });
                         }, 
                         child: const Text('Login Now')
                       ),
                     ],
                   ),
                 );
                 // Stop further execution, let user login manually
                 return;
              }
            }
        } else {
            // TENANT LOGIN
            try {
              await auth.signIn(_emailCtrl.text.trim(), _passwordCtrl.text.trim());
            } catch (e) {
               // Rethrow to catch block (Invalid Credential etc)
               rethrow;
            }
            
            // Verify Tenant Profile
            final tenantRepo = ref.read(tenantRepositoryProvider);
            print('LoginScreen: Fetching tenant profile for Auth UID: ${auth.currentUser!.uid}');
            final tenant = await tenantRepo.getTenantByAuthId(auth.currentUser!.uid);
            
            if (tenant != null) {
                 print('LoginScreen: Tenant found: ${tenant.name}. Saving session...');
                 await ref.read(userSessionServiceProvider).saveSession(role: 'tenant', tenantId: tenant.id);
                 
                 // Save credentials and enable biometric for next login
                 final email = _emailCtrl.text.trim();
                 final password = _passwordCtrl.text.trim();
                 if (email.isNotEmpty && password.isNotEmpty) {
                   await _storageService.saveCredentials(email, password);
                   if (await _biometricService.isBiometricAvailable()) {
                     await _storageService.setBiometricEnabled(true);
                   }
                 }
                 
                 // Push Notifications
                 await ref.read(userSessionServiceProvider).saveFcmToken(auth.currentUser!.uid);
                 await ref.read(notificationServiceProvider).scheduleMonthlyRentReminder();
                 
                 print('LoginScreen: Navigating to Tenant Dashboard');
                 if (mounted) context.go('/tenant/dashboard', extra: tenant);
            } else {
                 print('LoginScreen: Tenant profile NOT FOUND in Firestore for UID: ${auth.currentUser!.uid}');
                 // ORPHANED ACCOUNT DETECTED
                 // The Auth User exists, but the Firestore Profile is gone (likely deleted by Owner).
                 if (mounted) {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Account Mismatch'),
                        content: const Text(
                          'This login exists, but your Tenant Profile was not found (it may have been deleted by the Owner).\n\n'
                          'Do you want to DELETE this login account so you can allow the Owner to register this email again?',
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true), 
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Delete Account'),
                          ),
                        ],
                      ),
                    );

                    if (shouldDelete == true) {
                       await auth.currentUser?.delete();
                       DialogUtils.showInfoDialog(context, title: 'Account Deleted', message: 'The email is now free to be registered again.');
                    } else {
                       await auth.signOut();
                    }
                 }
                 // Return to stop further processing, loading state will be cleared in finally
                 return;
            }
        }
        
        } catch (e) {
        if (mounted) {
          final message = e.toString().replaceAll('Exception: ', '');
          DialogUtils.showErrorDialog(context, title: 'Authentication Failed', message: message);
          setState(() { _errorMessage = null; });
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
                  debugPrint('Sending password reset to: ${emailController.text.trim()}');
                  final auth = ref.read(authServiceProvider);
                  await auth.sendPasswordResetEmail(emailController.text.trim());
                  debugPrint('Password reset email sent successfully');
                  
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
                  debugPrint('Password reset error: $e');
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
      debugPrint('LoginScreen: Owner login successful. Initializing session...');
      
      try {
        // 1. Save Session (CRITICAL: Do this first so role is available for providers)
        await ref.read(userSessionServiceProvider).saveSession(role: 'owner');
        
        // 2. CRITICAL: Wait for Firebase Auth token to propagate to Firestore
        // This fixes "Failed to Load Tenants" error when switching between users
        await Future.delayed(const Duration(milliseconds: 300));
        
        // 3. Clear/Refresh ALL Controllers and Repository providers
        // Invalidating the repository providers forces new streams with the new UID
        ref.invalidate(ownerControllerProvider);
        ref.invalidate(tenantControllerProvider);
        ref.invalidate(houseControllerProvider);
        ref.invalidate(rentControllerProvider);
        ref.invalidate(tenantRepositoryProvider);
        ref.invalidate(propertyRepositoryProvider);
        ref.invalidate(allUnitsProvider);

        // 4. Save credentials for next login
        final email = _emailCtrl.text.trim();
        final password = _passwordCtrl.text.trim();
        if (email.isNotEmpty && password.isNotEmpty) {
          await _storageService.saveCredentials(email, password);
        }

        // 5. Background tasks (don't block the UI transition)
        unawaited(ref.read(userSessionServiceProvider).saveFcmToken(auth.currentUser!.uid));

        // Let the state settle and show a brief success/loading state
        await Future.delayed(const Duration(milliseconds: 1000));

        if (mounted) {
          debugPrint('LoginScreen: Navigating to Owner Dashboard');
          context.go('/owner/dashboard');
        }
      } catch (e) {
        debugPrint('LoginScreen: Error in post-login initialization: $e');
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
                                    labelText: 'Secure Password',
                                    prefixIcon: const Icon(Icons.lock_outlined),
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
                                  obscureText: true,
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
                                      onPressed: _isLoading ? null : () async {
                                        HapticFeedback.lightImpact();
                                        try {
                                           await _loginWithBiometrics();
                                        } catch (e) {
                                           if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Auth Error: ${e.toString()}')));
                                           }
                                        }
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
}
