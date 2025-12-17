import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/auth_service.dart';
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
    final ownerAsync = ref.watch(ownerControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Owner Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
        actions: [
          IconButton(
            onPressed: () async {
              if (_isEditing) {
                try {
                  // 1. Update Profile in Firestore
                  await ref.read(ownerControllerProvider.notifier).updateProfile(
                    name: _nameController.text, 
                    email: _emailController.text, 
                    phone: _phoneController.text
                  );
                  
                  // 2. Update Email in Firebase Auth if changed
                  final auth = ref.read(authServiceProvider);
                  final currentEmail = auth.currentUser?.email;
                  if (currentEmail != null && currentEmail != _emailController.text.trim()) {
                      await auth.updateEmail(_emailController.text.trim());
                  }

                  if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Updated Successfully')));
                  }
                } catch (e) {
                   if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                   }
                }
              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            icon: Icon(_isEditing ? Icons.check : Icons.edit, color: _isEditing ? Colors.green : theme.iconTheme.color),
          )
        ],
      ),
      body: ownerAsync.when(
        data: (owner) {
          if (owner != null && !_isEditing && _nameController.text.isEmpty) {
             _nameController.text = owner.name;
             _emailController.text = owner.email ?? '';
             _phoneController.text = owner.phone ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: theme.cardColor,
                        child: Text(
                          owner?.name.substring(0, 1).toUpperCase() ?? 'O', 
                          style: GoogleFonts.outfit(fontSize: 40, color: theme.primaryColor)
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
                ),
                const SizedBox(height: 32),
                
                _buildTextField('Full Name', _nameController, Icons.person, theme, isDark),
                const SizedBox(height: 16),
                _buildTextField('Email', _emailController, Icons.email, theme, isDark),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                _buildTextField('Phone', _phoneController, Icons.phone, theme, isDark),
                
                const SizedBox(height: 32),
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
                
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                    onPressed: () => _showDeleteAccountDialog(context, ref),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      )
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, ThemeData theme, bool isDark) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
        prefixIcon: Icon(icon, color: theme.iconTheme.color?.withOpacity(0.7)),
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
            : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]),
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
