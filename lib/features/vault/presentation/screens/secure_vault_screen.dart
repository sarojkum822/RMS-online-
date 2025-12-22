import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../presentation/vault_controller.dart';
import '../../data/vault_repository.dart';
import '../../../../presentation/providers/data_providers.dart';
import '../../../../core/services/biometric_service.dart';

// Session-level provider to track if user has authenticated for the Vault this session
final vaultSessionAuthenticatedProvider = StateProvider<bool>((ref) => false);

// Keys for SharedPreferences
const String _kVaultRecoveryWarningShown = 'k_vault_recovery_warning_shown';

class SecureVaultScreen extends ConsumerStatefulWidget {
  const SecureVaultScreen({super.key});

  @override
  ConsumerState<SecureVaultScreen> createState() => _SecureVaultScreenState();
}

class _SecureVaultScreenState extends ConsumerState<SecureVaultScreen> with WidgetsBindingObserver {
  bool _isAuthenticating = true;
  Timer? _autoLockTimer;
  
  // Auto-lock configuration
  static const int _autoLockDurationSeconds = 120; // 2 minutes
  DateTime? _lastInteractionTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authenticateEntry();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoLockTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Lock vault when app goes to background
      _lockVault();
    } else if (state == AppLifecycleState.resumed) {
      // Check if auto-lock timer expired while backgrounded
      _checkAutoLock();
    }
  }

  void _resetAutoLockTimer() {
    _lastInteractionTime = DateTime.now();
    _autoLockTimer?.cancel();
    _autoLockTimer = Timer(const Duration(seconds: _autoLockDurationSeconds), () {
      _lockVault();
    });
  }

  void _lockVault() {
    _autoLockTimer?.cancel();
    ref.read(vaultSessionAuthenticatedProvider.notifier).state = false;
    if (mounted) {
      setState(() => _isAuthenticating = true);
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _checkAutoLock() {
    if (_lastInteractionTime != null) {
      final elapsed = DateTime.now().difference(_lastInteractionTime!).inSeconds;
      if (elapsed >= _autoLockDurationSeconds) {
        _lockVault();
      }
    }
  }

  Future<void> _showRecoveryWarning() async {
    final prefs = await SharedPreferences.getInstance();
    final warningShown = prefs.getBool(_kVaultRecoveryWarningShown) ?? false;
    
    if (!warningShown && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              const Text('Important Notice'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Text(
                  '⚠️ Data Recovery Warning\n\n'
                  'Your vault documents are encrypted with a key stored ONLY on this device.\n\n'
                  'If you:\n'
                  '• Uninstall the app\n'
                  '• Factory reset your phone\n'
                  '• Lose this device\n\n'
                  'Your encrypted documents will be PERMANENTLY LOST and cannot be recovered.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () async {
                await prefs.setBool(_kVaultRecoveryWarningShown, true);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('I Understand'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _authenticateEntry() async {
    try {
      // Check if already authenticated this session
      final alreadyAuthenticated = ref.read(vaultSessionAuthenticatedProvider);
      if (alreadyAuthenticated) {
        debugPrint('Vault: Already authenticated this session.');
        if (mounted) setState(() { _isAuthenticating = false; });
        _resetAutoLockTimer();
        return;
      }

      // Check if VAULT LOCK is enabled in user settings
      final isVaultLockEnabled = await ref.read(userSessionServiceProvider).isVaultLockEnabled();
      if (!isVaultLockEnabled) {
        debugPrint('Vault: Vault Lock disabled in settings. Skipping prompt.');
        ref.read(vaultSessionAuthenticatedProvider.notifier).state = true;
        if (mounted) setState(() { _isAuthenticating = false; });
        await _showRecoveryWarning();
        _resetAutoLockTimer();
        return;
      }

      // Use centralized BiometricService
      final biometricService = ref.read(biometricServiceProvider);
      final available = await biometricService.isBiometricAvailable();
      
      if (!available) {
        // Fallback for devices without biometrics
        ref.read(vaultSessionAuthenticatedProvider.notifier).state = true;
        if (mounted) setState(() { _isAuthenticating = false; });
        await _showRecoveryWarning();
        _resetAutoLockTimer();
        return;
      }

      final result = await biometricService.authenticateWithResult(
        reason: 'Authenticate to unlock your Personal Vault',
      );

      if (mounted) {
        if (result == BiometricResult.success) {
          ref.read(vaultSessionAuthenticatedProvider.notifier).state = true;
          setState(() { _isAuthenticating = false; });
          await _showRecoveryWarning();
          _resetAutoLockTimer();
        } else if (result == BiometricResult.lockedOut) {
          final remaining = await biometricService.getRemainingLockoutSeconds();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Too many failed attempts. Try again in ${remaining}s')),
          );
          Navigator.pop(context);
        } else {
          Navigator.pop(context); // Go back if failed
        }
      }
    } catch (e) {
      debugPrint('Vault Auth Error: $e');
      if (mounted) {
        ref.read(vaultSessionAuthenticatedProvider.notifier).state = true;
        setState(() { _isAuthenticating = false; });
      }
    }
  }

  Future<void> _addDocument() async {
     final picker = ImagePicker();
     final picked = await picker.pickImage(source: ImageSource.camera);
     if (picked == null) return;

     if (!mounted) return;
     
     // Ask for Title
     final titleCtrl = TextEditingController(text: 'ID Card ${DateFormat('dd-MM').format(DateTime.now())}');
     String? savedTitle;
     
     final shouldSave = await showDialog<bool>(
       context: context,
       builder: (ctx) => AlertDialog(
         title: const Text('Save to Vault'),
         content: TextField(
           controller: titleCtrl,
           decoration: const InputDecoration(labelText: 'Document Name', hintText: 'e.g. Aadhaar Card'),
         ),
         actions: [
           TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
           FilledButton(onPressed: () {
             savedTitle = titleCtrl.text; // Save before closing
             Navigator.pop(ctx, true);
           }, child: const Text('Encrypt & Save')),
         ],
       ),
     );
     
     // Dispose controller after dialog closes
     titleCtrl.dispose();
     
     if (shouldSave == true && mounted && savedTitle != null) {
        try {
           final file = File(picked.path);
           await ref.read(vaultControllerProvider.notifier).addDocument(file, savedTitle!);
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Encrypted & Saved to Vault')));
        } catch (e) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
     }
  }

  Future<void> _viewDocument(String storagePath) async {
     try {
       // Show Loading
       showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
       
       // Decrypt
       final repo = ref.read(vaultRepositoryProvider);
       final file = await repo.downloadAndDecrypt(storagePath);
       
       if (mounted) {
         Navigator.pop(context); // Hide loading
         
         // Show Image
         await showModalBottomSheet(
           context: context, 
           isScrollControlled: true,
           backgroundColor: Colors.black,
           builder: (ctx) => Scaffold(
             backgroundColor: Colors.black,
             appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white, title: const Text("Decrypted View")),
             body: InteractiveViewer(
               child: Center(child: Image.file(file)),
             ),
           )
         );
         
         // Cleanup
         if (await file.exists()) {
            await file.delete(); 
         }
       }
     } catch (e) {
       if (mounted) {
          Navigator.pop(context); // Hide loading
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Decryption Failed: $e')));
       }
     }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(vaultSessionAuthenticatedProvider);
    
    if (_isAuthenticating) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    if (!isAuthenticated) {
       return Scaffold(
         body: Center(
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
               const SizedBox(height: 16),
               const Text("Vault Locked"),
               TextButton(onPressed: _authenticateEntry, child: const Text("Tap to Unlock"))
             ],
           ),
         )
       );
    }

    final docsAsync = ref.watch(vaultControllerProvider);

    return Scaffold(
      appBar: AppBar(
         title: Text('Kiraya Vault', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
         centerTitle: true,
         actions: [
            IconButton(icon: const Icon(Icons.shield), onPressed: () {}, tooltip: 'Secured by AES-256'),
         ],
      ),
      body: docsAsync.when(
        data: (docs) {
           if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Icon(Icons.security, size: 80, color: Colors.grey.withOpacity(0.3)),
                     const SizedBox(height: 16),
                     Text("No Secure Documents", style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey)),
                     const SizedBox(height: 8),
                     const Text("Tap + to scan and encrypt documents"),
                  ],
                ),
              );
           }
           
           return GridView.builder(
             padding: const EdgeInsets.all(16),
             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                 crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.8
             ),
             itemCount: docs.length,
             itemBuilder: (ctx, i) {
                final doc = docs[i];
                return GestureDetector(
                   onTap: () => _viewDocument(doc.storagePath),
                   child: Container(
                      decoration: BoxDecoration(
                         color: Theme.of(context).cardColor,
                         borderRadius: BorderRadius.circular(16),
                         border: Border.all(color: Colors.grey.withOpacity(0.1)),
                         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           const Icon(Icons.lock_person, size: 40, color: Colors.indigo),
                           const SizedBox(height: 12),
                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 8.0),
                             child: Text(doc.title, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,
                               style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                           ),
                           const SizedBox(height: 4),
                           Text(
                             DateFormat('dd MMM yyyy').format(doc.uploadedAt),
                             style: TextStyle(fontSize: 10, color: Colors.grey),
                           )
                        ],
                      ),
                   ),
                );
             },
           );
        },
        error: (e, st) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDocument,
        icon: const Icon(Icons.add_moderator), // Shield icon
        label: const Text("Encrypt New"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }
}
