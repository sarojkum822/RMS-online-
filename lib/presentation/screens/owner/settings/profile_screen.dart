import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../domain/entities/owner.dart';
import 'owner_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ownerValue = ref.watch(ownerControllerProvider);
    final owner = ownerValue.value; // Access value directly to persist data during loading/error
    final isLoading = ownerValue.isLoading;

    // Listen for Errors to show SnackBar
    ref.listen<AsyncValue<Owner?>>(ownerControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${next.error}')));
      }
      if (!previous!.hasValue && next.hasValue) {
        // Initial load complete
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Owner Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
        actions: [
          IconButton(
            onPressed: isLoading ? null : () async {
              if (_isEditing) {
                try {
                  // 1. Update Profile in Firestore
                  await ref.read(ownerControllerProvider.notifier).updateProfile(
                    name: _nameController.text, 
                    email: _emailController.text, 
                    phone: _phoneController.text
                  );
                  
                  // REMOVED: auth.updateEmail logic to prevent auth errors/logout.
                  // Contact Email in Firestore can differ from Auth Email.

                  if (context.mounted && !ref.read(ownerControllerProvider).hasError) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Updated Successfully')));
                  }
                } catch (e) {
                   // Error is handled by ref.listen usually, but duplicate catch doesn't hurt
                }
              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            icon: isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(_isEditing ? Icons.check : Icons.edit, color: _isEditing ? Colors.green : theme.iconTheme.color),
          )
        ],
      ),
      body: owner == null 
        ? const Center(child: CircularProgressIndicator()) 
        : Builder(
            builder: (context) {
               // Update controllers if not editing and data changed externally
               if (!_isEditing) {
                 if (_nameController.text != owner.name) _nameController.text = owner.name;
                 if (_emailController.text != (owner.email ?? '')) _emailController.text = owner.email ?? '';
                 if (_phoneController.text != (owner.phone ?? '')) _phoneController.text = owner.phone ?? '';
               }

               final plan = owner.subscriptionPlan ?? 'free';
               final planColor = plan == 'power' ? Colors.purple : (plan == 'pro' ? Colors.blue : Colors.grey);

               return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Profile Picture & Basic Info
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: planColor.withValues(alpha: 0.5), width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: theme.cardColor,
                                  child: Text(
                                    owner.name.isNotEmpty == true ? owner.name[0].toUpperCase() : 'O', 
                                    style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.bold, color: planColor)
                                  ),
                                ),
                              ),
                              if (_isEditing)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: theme.primaryColor,
                                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            owner.name,
                            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color),
                          ),
                          Text(
                            owner.email ?? 'No Email',
                            style: GoogleFonts.outfit(fontSize: 14, color: theme.hintColor),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 2. Subscription Status Section (NEW)
                    Text(
                      'SUBSCRIPTION',
                      style: GoogleFonts.outfit(
                        fontSize: 12, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 1.2,
                        color: theme.hintColor
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: planColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: planColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: planColor.withValues(alpha: 0.2), shape: BoxShape.circle),
                            child: Icon(Icons.star, color: planColor, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${plan.toUpperCase()} PLAN',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: planColor),
                                ),
                                Text(
                                  plan == 'free' ? 'Limited features' : 'All premium features active',
                                  style: GoogleFonts.outfit(fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/owner/settings/subscription'),
                            child: Text(plan == 'free' ? 'Upgrade' : 'Manage', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: planColor)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 3. Contact Details Section
                    Text(
                      'CONTACT DETAILS',
                      style: GoogleFonts.outfit(
                        fontSize: 12, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 1.2,
                        color: theme.hintColor
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField('Full Name', _nameController, Icons.person, theme, isDark, capitalization: TextCapitalization.words),
                    const SizedBox(height: 16),
                    _buildTextField('Email', _emailController, Icons.email, theme, isDark, capitalization: TextCapitalization.none, keyboardType: TextInputType.emailAddress, autocorrect: false),
                    const SizedBox(height: 16),
                    _buildTextField('Phone', _phoneController, Icons.phone, theme, isDark, capitalization: TextCapitalization.none, keyboardType: TextInputType.phone),
                    
                    const SizedBox(height: 20),
                    
                    // 4. Account Settings
                    Text(
                      'ACCOUNT SETTINGS',
                      style: GoogleFonts.outfit(
                        fontSize: 12, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 1.2,
                        color: theme.hintColor
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.lock_reset),
                        label: const Text('Change Password'),
                        onPressed: () => _showChangePasswordDialog(context, ref),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        label: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                        onPressed: () => _showDeleteAccountDialog(context, ref),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
        ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, ThemeData theme, bool isDark, {
    TextCapitalization capitalization = TextCapitalization.none,
    TextInputType? keyboardType,
    bool autocorrect = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      style: theme.textTheme.bodyMedium,
      textCapitalization: capitalization,
      keyboardType: keyboardType,
      autocorrect: autocorrect,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
        prefixIcon: Icon(icon, color: theme.iconTheme.color?.withValues(alpha: 0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        filled: true,
        fillColor: _isEditing 
            ? theme.cardColor 
            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100]),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              decoration: const InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder()),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
                return;
              }
              if (passwordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters')));
                return;
              }
              
              Navigator.pop(ctx); 
              
              try {
                await ref.read(authServiceProvider).updatePassword(passwordController.text.trim());
                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password Changed Successfully')));
                }
              } catch (e) {
                 if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                 }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?', style: TextStyle(color: Colors.red)),
        content: const Text(
          'This action is irreversible. All your data including properties, tenants, and payment history will be permanently deleted.\n\nAre you sure you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('Cancel')
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              
              try {
                // Show loading
                if (context.mounted) {
                  showDialog(
                    context: context, 
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator())
                  );
                }

                await ref.read(authServiceProvider).deleteAccount();
                
                // Navigation to login is usually handled by authStateChanges stream in main.dart or router
                // But we can force pop everything to be safe
                if (context.mounted) {
                   Navigator.of(context).popUntil((route) => route.isFirst); 
                }
              } catch (e) {
                // Remove loading
                if (context.mounted && Navigator.canPop(context)) {
                   Navigator.pop(context);
                }
                
                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}
