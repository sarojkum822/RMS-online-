import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/data_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal splash screen that performs session checks and navigates immediately.
/// No custom UI is shown - we rely solely on the system splash screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    // No delay - navigate immediately after session check
    if (!mounted) return;

    final container = ProviderScope.containerOf(context);
    final authService = container.read(userSessionServiceProvider);
    
    final user = authService.currentUser;

    if (user != null) {
      context.go('/owner/dashboard'); 
    } else {
      final prefs = await SharedPreferences.getInstance();
      final lastRole = prefs.getString('last_role');
      
      if (lastRole != null) {
         context.go('/login', extra: lastRole);
      } else {
         context.go('/'); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return an empty container - the system splash is already visible
    // and will stay until Flutter draws its first frame (this empty container).
    return const SizedBox.shrink();
  }
}
