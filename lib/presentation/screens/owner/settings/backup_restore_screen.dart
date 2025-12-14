import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../../../providers/data_providers.dart';
import '../../../routes/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/data_integrity_validator.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Backup & Restore', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.iconTheme,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(theme, 'Data Management'),
                const SizedBox(height: 16),
                _buildActionCard(
                  context,
                  theme,
                  title: 'Create Backup',
                  description: 'Export all your property, tenant, and financial data to a secure JSON file.',
                  icon: Icons.cloud_download_outlined,
                  color: Colors.blue,
                  onTap: _handleCreateBackup,
                ),
                const SizedBox(height: 16),
                _buildActionCard(
                  context,
                  theme,
                  title: 'Restore Backup',
                  description: 'Restore data from a backup file. WARNING: This will replace all current data.',
                  icon: Icons.cloud_upload_outlined,
                  color: Colors.red,
                  isDestructive: true,
                  onTap: _handleRestoreBackup,
                ),

                const SizedBox(height: 32),
                _buildSectionHeader(theme, 'Maintenance'),
                const SizedBox(height: 16),
                 _buildActionCard(
                  context,
                  theme,
                  title: 'Verify Data Integrity',
                  description: 'Scan your current database for missing links or corrupted records.',
                  icon: Icons.fact_check_outlined,
                  color: Colors.orange,
                  onTap: _handleVerifyData,
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: theme.hintColor,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, ThemeData theme, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: isDestructive ? Colors.red : theme.textTheme.titleLarge?.color)),
                      const SizedBox(height: 4),
                      Text(description, style: GoogleFonts.outfit(fontSize: 12, color: theme.textTheme.bodyMedium?.color)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: theme.hintColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleCreateBackup() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(backupServiceProvider).exportData(uid: uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup created successfully!')));
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Backup Failed', e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRestoreBackup() async {
     // 1. Confirm
     final confirm = await showDialog<bool>(
       context: context,
       builder: (context) => AlertDialog(
         title: const Text('Restore Backup?'),
         content: const Text(
           'DANGER: This action will PERMANENTLY DELETE all your current data and replace it with the backup content.\n\nAre you absolutely sure?',
           style: TextStyle(color: Colors.red),
         ),
         actions: [
           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
           FilledButton(
             style: FilledButton.styleFrom(backgroundColor: Colors.red),
             onPressed: () => Navigator.pop(context, true), 
             child: const Text('Yes, Restore'),
           ),
         ],
       ),
     );
     
     if (confirm != true) return;

     // 2. Pick File
     final result = await FilePicker.platform.pickFiles(
       type: FileType.custom,
       allowedExtensions: ['json'],
       withData: true, // Needed for Web
     );

     if (result != null) {
       final fileBytes = result.files.single.bytes; 
       // On mobile, result.files.single.path is available. On web, only bytes.
       // We only need the string content.
       
       String content;
       if (fileBytes != null) {
         content = String.fromCharCodes(fileBytes);
       } else if (result.files.single.path != null) {
         content = await File(result.files.single.path!).readAsString();
       } else {
         return;
       }
       
       final uid = FirebaseAuth.instance.currentUser?.uid;
       if (uid == null) return;

       setState(() => _isLoading = true);
       try {
         await ref.read(migrationServiceProvider).restoreBackup(content, uid);
         if (mounted) {
           await showDialog(
             context: context, 
             builder: (c) => AlertDialog(
               title: const Text('Restore Successful'),
               content: const Text('Your data has been restored successfully.'),
               actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
             )
           );
         }
       } catch (e) {
         if (mounted) {
           _showErrorDialog('Restore Failed', e.toString());
         }
       } finally {
         if (mounted) setState(() => _isLoading = false);
       }
     }
  }
  
  Future<void> _handleVerifyData() async {
     final uid = FirebaseAuth.instance.currentUser?.uid;
     if (uid == null) return;

     setState(() => _isLoading = true);
     
     try {
       // 1. Fetch Live Data
       final data = await ref.read(backupServiceProvider).fetchAllDataAsMap(uid);
       
       // 2. Validate
       final errors = DataIntegrityValidator.validate(data);
       
       if (!mounted) return;

       if (errors.isEmpty) {
         showDialog(
           context: context, 
           builder: (c) => AlertDialog(
             title: const Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 8), Text('Data Integrity Verified')]),
             content: const Text('Your database is healthy. No missing links or corrupted records found.'),
             actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
           )
         );
       } else {
         showDialog(
           context: context, 
           builder: (c) => AlertDialog(
             title: const Row(children: [Icon(Icons.error_outline, color: Colors.red), SizedBox(width: 8), Text('Integrity Issues Found')]),
             content: SizedBox(
               width: double.maxFinite,
               child: ListView.builder(
                 shrinkWrap: true,
                 itemCount: errors.length,
                 itemBuilder: (context, index) => ListTile(
                   leading: const Icon(Icons.warning, color: Colors.orange, size: 20),
                   title: Text(errors[index], style: const TextStyle(fontSize: 13)),
                 ),
               ),
             ),
             actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close'))],
           )
         );
       }

     } catch (e) {
       if (mounted) {
         _showErrorDialog('Verification Failed', e.toString());
       }
     } finally {
       if (mounted) setState(() => _isLoading = false);
     }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context, 
      builder: (c) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Colors.red)),
        content: SingleChildScrollView(child: Text(message)),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close'))],
      )
    );
  }
}
