import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/user_session_service.dart';
import '../../../core/theme/app_theme.dart';
import '../owner/rent/rent_controller.dart';
import '../../../domain/entities/tenant.dart';
import '../owner/tenant/tenant_controller.dart';
import '../maintenance/maintenance_controller.dart';
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
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Check Session
    final sessionService = UserSessionService();
    final session = await sessionService.getSession();
    
    // 2. Preload Data based on Role
    String initialLocation = '/login';
    Object? initialExtra;

    if (session['role'] == 'owner') {
      initialLocation = '/owner/dashboard';
      
      // PRELOAD OWNER DATA PARALLEL
      final user = ref.read(userSessionServiceProvider).currentUser;
      final uid = user?.uid;
      
      await Future.wait([
        // Rent Controller (Expenses / Bills)
        ref.read(rentControllerProvider.future),
        
        // Dashboard Stats
        ref.read(dashboardStatsProvider.future),
        
        // Tenant List
        ref.read(tenantControllerProvider.future),
        
        // Maintenance Requests
        if (uid != null)
             ref.read(ownerMaintenanceProvider(uid).future),
      ]);
      
    } else if (session['role'] == 'tenant' && session['tenantId'] != null) {
      try {
        final tenantId = session['tenantId'] as int;
        // Fetch Tenant Data
        final snapshot = await FirebaseFirestore.instance
            .collection('tenants')
            .where('id', isEqualTo: tenantId)
            .limit(1)
            .get(); 

        if (snapshot.docs.isNotEmpty) {
           final data = snapshot.docs.first.data();
           final tenant = Tenant(
              id: data['id'],
              houseId: data['houseId'],
              unitId: data['unitId'],
              tenantCode: data['tenantCode'] ?? '', 
              name: data['name'] ?? 'Unknown',
              phone: data['phone'] ?? '',
              email: data['email'],
              imageUrl: data['imageUrl'],
              imageBase64: data['imageBase64'],
              startDate: data['startDate'] != null ? (data['startDate'] as Timestamp).toDate() : DateTime.now(),
              status: (data['isActive'] ?? true) ? TenantStatus.active : TenantStatus.inactive,
              openingBalance: (data['openingBalance'] as num?)?.toDouble() ?? 0.0,
              agreedRent: (data['agreedRent'] as num?)?.toDouble() ?? 0.0,
              password: data['password'],
              ownerId: data['ownerId'] ?? '', 
           );

           if (tenant.status == TenantStatus.active) {
              initialLocation = '/tenant/dashboard';
              initialExtra = tenant;
           }
        }
      } catch (e) {
        debugPrint('Splash Tenant Restore Error: $e');
      }
    }

    if (mounted) {
      context.go(initialLocation, extra: initialExtra);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Or brand color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Placeholder
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.apartment, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'KirayaBook',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 10),
             Text(
              'Manage your properties with ease',
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
