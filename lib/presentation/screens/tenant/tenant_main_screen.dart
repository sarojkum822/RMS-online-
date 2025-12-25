import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Add
import '../../../domain/entities/tenant.dart';
import '../../providers/data_providers.dart'; // Add
import '../owner/tenant/tenant_controller.dart'; // Add
import 'views/tenant_home_view.dart';
import 'views/tenant_payments_view.dart';
import 'views/tenant_services_view.dart';
import 'views/tenant_profile_docs_view.dart';

class TenantMainScreen extends ConsumerStatefulWidget {
  final Tenant tenant;
  const TenantMainScreen({super.key, required this.tenant});

  @override
  ConsumerState<TenantMainScreen> createState() => _TenantMainScreenState();
}

class _TenantMainScreenState extends ConsumerState<TenantMainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _views;

  @override
  void initState() {
    super.initState();
    _views = [
      TenantHomeView(tenant: widget.tenant),
      TenantPaymentsView(tenant: widget.tenant),
      TenantServicesView(tenant: widget.tenant),
      TenantProfileDocsView(tenant: widget.tenant),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Force Logout Listener
    // We watch the current tenant profile. If it becomes null or inactive, we logout.
    ref.listen(activeTenancyForTenantAccessProvider(widget.tenant.id, widget.tenant.ownerId), (prev, next) async {
       // Note: Listening to tenancy might not be enough if the whole tenant is deleted.
       // We should ideally listen to the Tenant Document itself.
    });

    // Better approach: Listen to the single tenant doc stream
    final tenantStream = ref.watch(tenantStreamProvider(widget.tenant.id));

    tenantStream.whenData((tenant) {
      if (tenant == null || !tenant.isActive) { // Deleted or Deactivated
         WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleForcedLogout();
         });
      }
    });

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: _views[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.scaffoldBackgroundColor,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Payments'),
            BottomNavigationBarItem(icon: Icon(Icons.build_circle_rounded), label: 'Services'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Account'),
          ],
        ),
      ),
    );
  }

  Future<void> _handleForcedLogout() async {
     await ref.read(userSessionServiceProvider).clearSession();
     if (mounted) {
       // GoRouter redirect or Go directly
       context.go('/tenant/login');
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
           content: Text('Your access has been revoked by the owner.'),
           backgroundColor: Colors.red,
           duration: Duration(seconds: 5),
         )
       );
     }
  }
}

// Helper provider to watch a single tenant by ID (needs to be created or placed in controller)
final tenantStreamProvider = StreamProvider.family<Tenant?, String>((ref, tenantId) {
  return ref.watch(tenantRepositoryProvider).watchTenant(tenantId); 
});
