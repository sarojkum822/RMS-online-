import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/tenant.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
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
}
