import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/data_providers.dart';


class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to defer navigation until after the first build is complete
    // This prevents the "setState() called during build" error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Small artificial delay to show branding and loading state as requested
      await Future.delayed(const Duration(seconds: 2));

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('SplashScreen: No user logged in. Redirecting to /login');
        if (mounted) context.go('/login');
        return;
      }

      final sessionService = ref.read(userSessionServiceProvider);
      // Ensure we reload/sync the session data on app start
      final session = await sessionService.getSession();
      final savedRole = session['role'];
      
      debugPrint('SplashScreen: Initializing. UID: ${user.uid}, Saved Role: $savedRole');

      // 1. Prioritize Saved Role if available
      if (savedRole == 'owner') {
        final owner = await ref.read(ownerRepositoryProvider).getOwner();
        if (owner != null) {
          debugPrint('SplashScreen: Owner confirmed. Redirecting to /owner/dashboard');
          if (mounted) context.go('/owner/dashboard');
          return;
        }
      } else if (savedRole == 'tenant') {
        var tenant = await ref.read(tenantRepositoryProvider).getTenantByAuthId(user.uid);
        if (tenant != null && tenant.isActive) {
          debugPrint('SplashScreen: Tenant confirmed. Redirecting to /tenant/dashboard');
          if (mounted) context.go('/tenant/dashboard', extra: tenant);
          return;
        }
      }

      // 2. Fallback: Systematic Detection
      debugPrint('SplashScreen: Saved role inconsistent or missing. Starting systematic detection...');


      // A. Check for Owner Profile FIRST (Primary User Type)
      debugPrint('SplashScreen: Checking for Owner profile...');
      try {
        final ownerProfile = await ref.read(ownerRepositoryProvider).getOwner();
        if (ownerProfile != null) {
          debugPrint('SplashScreen: Owner detected via Firestore. Saving session...');
          await sessionService.saveSession(role: 'owner');
          if (mounted) context.go('/owner/dashboard');
          return;
        }
      } catch (e) {
        debugPrint('SplashScreen: Owner lookup failed: $e');
      }
      
      // B. Check for Tenant Profile SECOND
      debugPrint('SplashScreen: Checking for Tenant profile...');
      try {
        final tenantProfile = await ref.read(tenantRepositoryProvider).getTenantByAuthId(user.uid);
        if (tenantProfile != null) {
          if (tenantProfile.isActive) {
             debugPrint('SplashScreen: Tenant detected via Firestore. Saving session...');
             await sessionService.saveSession(role: 'tenant', tenantId: tenantProfile.id);
             if (mounted) context.go('/tenant/dashboard', extra: tenantProfile);
          } else {
             debugPrint('SplashScreen: Inactive tenant detected. Signing out.');
             await FirebaseAuth.instance.signOut();
             if (mounted) context.go('/login');
          }
          return;
        }
      } catch (e) {
        debugPrint('SplashScreen: Tenant lookup failed: $e');
      }

      // 3. Neither? (Orphaned account or deletion)
      debugPrint('SplashScreen: No valid profile found for UID: ${user.uid}. Signing out.');
      await FirebaseAuth.instance.signOut();
      if (mounted) context.go('/login');

    } catch (e) {
      debugPrint('SplashScreen Error: $e');
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Stack(
        children: [
          // Background Gradient subtle
          if (!isDark)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      const Color(0xFFF8FAFC).withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Branding Logo - Aura Style
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Hero(
                    tag: 'app_logo',
                    child: Icon(
                      Icons.home_work_rounded, 
                      size: 72, 
                      color: isDark ? Colors.white : const Color(0xFF2563EB)
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'KirayaBook',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Professional Estate Management',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Status
          Positioned(
            bottom: 64,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? Colors.white30 : const Color(0xFF2563EB).withValues(alpha: 0.2)
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Initializing Secure Environment',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white24 : Colors.grey.withValues(alpha: 0.5),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}