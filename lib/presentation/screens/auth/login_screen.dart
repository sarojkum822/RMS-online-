import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/user_session_service.dart';
import '../owner/settings/owner_controller.dart';
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
      });
      
      // Auto-trigger if enabled and available
      if (_canCheckBiometrics) {
         // Optional: Enable auto-prompt later if needed
      }
    }
  }

  Future<void> _loginWithBiometrics() async {
    final authenticated = await _biometricService.authenticate();
    if (authenticated) {
      final creds = await _storageService.getCredentials();
      if (creds != null) {
        _emailCtrl.text = creds['email']!;
        _passwordCtrl.text = creds['password']!;
        _submit(); 
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
              await auth.signIn(_emailCtrl.text.trim(), _passwordCtrl.text.trim());
            } else {
              await auth.signUp(_emailCtrl.text.trim(), _passwordCtrl.text.trim());
            }
            
            // Sync Profile
            final ownerNotifier = ref.read(ownerControllerProvider.notifier);
            await ref.read(ownerControllerProvider.future); 
            
            await ownerNotifier.updateProfile(
              name: _isLogin ? 'Owner' : 'Owner', 
              email: _emailCtrl.text.trim(),
              phone: '', 
              firestoreId: auth.currentUser?.uid,
            );

            // Re-read to update properly
            final currentOwner = ref.read(ownerControllerProvider).value;
            if (currentOwner != null) {
                await ownerNotifier.updateProfile(
                  name: currentOwner.name == 'My Name' ? 'Owner' : currentOwner.name,
                  email: _emailCtrl.text.trim(),
                  phone: currentOwner.phone ?? '',
                  firestoreId: auth.currentUser?.uid,
                );
            }

            // Save Session
            await ref.read(userSessionServiceProvider).saveSession(role: 'owner');
            
            // Push Notifications
            await ref.read(userSessionServiceProvider).saveFcmToken(auth.currentUser!.uid);
            
            // Save Creds for Biometrics
            await _storageService.saveCredentials(_emailCtrl.text.trim(), _passwordCtrl.text.trim());

            if (mounted) {
              context.go('/owner/dashboard');
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
            final tenant = await tenantRepo.getTenantByAuthId(auth.currentUser!.uid);
            
            if (tenant != null) {
                 await ref.read(userSessionServiceProvider).saveSession(role: 'tenant');
                 await _storageService.saveCredentials(_emailCtrl.text.trim(), _passwordCtrl.text.trim());
                 
                 // Push Notifications
                 await ref.read(userSessionServiceProvider).saveFcmToken(auth.currentUser!.uid);
                 await ref.read(notificationServiceProvider).scheduleMonthlyRentReminder();
                 
                 if (mounted) context.go('/tenant/dashboard', extra: tenant);
            } else {
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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
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
                                  style: GoogleFonts.outfit(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: theme.textTheme.titleLarge?.color),
                                ),
                                Text(
                                  subtitle,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(fontSize: 14, color: theme.textTheme.bodyMedium?.color),
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
                                  decoration: InputDecoration(
                                    labelText: isOwner ? 'Email' : 'Phone / Email', 
                                    prefixIcon: const Icon(Icons.person_outline),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: theme.cardColor,
                                  ),
                                  // Fix: Allow alphabets for Tenants too (Email/User ID)
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) => v!.isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock_outlined),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: theme.cardColor,
                                  ),
                                  obscureText: true,
                                  validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
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
                                
                                SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: _isLoading ? null : () {
                                      HapticFeedback.lightImpact();
                                      _submit();
                                    },
                                    child: _isLoading 
                                      ? const CircularProgressIndicator(color: Colors.white) 
                                      : Text(
                                          _isLogin ? 'Login' : 'Create Account',
                                          style: const TextStyle(fontSize: 16, color: Colors.white),
                                        ),
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
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
