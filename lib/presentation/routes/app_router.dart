import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/tenant.dart';
import '../../domain/entities/house.dart';
import '../screens/role_selection_screen.dart';
import '../screens/owner/owner_dashboard_screen.dart';
import '../screens/tenant/tenant_login_screen.dart';
import '../screens/tenant/tenant_dashboard_screen.dart';
import '../screens/owner/house/house_form_screen.dart';
import '../screens/owner/tenant/tenant_form_screen.dart';
import '../screens/owner/house/house_detail_screen.dart';


// Settings Screens
import '../screens/owner/settings/profile_screen.dart';
import '../screens/owner/settings/notification_settings_screen.dart';
import '../screens/owner/settings/currency_settings_screen.dart';
import '../screens/owner/settings/security_screen.dart';
import '../screens/owner/settings/support_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/owner/dashboard', 
      builder: (context, state) => const OwnerDashboardScreen(),
    ),
    GoRoute(
      path: '/owner/houses/add',
      builder: (context, state) => const HouseFormScreen(),
    ),
    GoRoute(
      path: '/owner/houses/:id',
      builder: (context, state) {
        final house = state.extra as House;
        return HouseDetailScreen(house: house);
      },
    ),
     GoRoute(
      path: '/owner/tenants/add',

      builder: (context, state) => const TenantFormScreen(),
    ),
    
    // Settings Routes
    GoRoute(
      path: '/owner/settings/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/owner/settings/notifications',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
     GoRoute(
      path: '/owner/settings/currency',
      builder: (context, state) => const CurrencySettingsScreen(),
    ),
     GoRoute(
      path: '/owner/settings/security',
      builder: (context, state) => const SecurityScreen(),
    ),
     GoRoute(
      path: '/owner/settings/support',
      builder: (context, state) => const SupportScreen(),
    ),
    
    // Tenant Routes
    GoRoute(
      path: '/tenant/login',
      builder: (context, state) => const TenantLoginScreen(),
    ),
    GoRoute(
      path: '/tenant/dashboard',
      builder: (context, state) {
        final tenant = state.extra as Tenant; 
        return TenantDashboardScreen(tenant: tenant);
      },
    ),
  ],
);
