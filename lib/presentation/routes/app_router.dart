import 'package:go_router/go_router.dart';
import '../../domain/entities/tenant.dart';
import '../../domain/entities/house.dart';
import '../../domain/entities/notice.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/owner/owner_dashboard_screen.dart';
import '../screens/tenant/tenant_login_screen.dart';
import '../screens/tenant/tenant_main_screen.dart';
import '../screens/owner/house/house_form_screen.dart';
import '../screens/owner/tenant/tenant_form_screen.dart';
import '../screens/owner/tenant/tenant_detail_screen.dart';
import '../screens/owner/house/house_detail_container.dart';
import '../screens/owner/expense/expense_screens.dart'; // NEW
import '../screens/owner/rent/pending_payments_screen.dart'; // NEW
import '../screens/owner/portfolio/portfolio_management_screen.dart'; // NEW
import '../screens/tenant/notice_history_screen.dart';
import '../screens/tenant/maintenance_detail_screen.dart';
import '../screens/tenant/house_info_screen.dart';
import '../screens/tenant/document_viewer_screen.dart';
import '../../../domain/entities/maintenance_request.dart';
import 'dart:typed_data';

// Settings Screens
import '../screens/owner/settings/profile_screen.dart';
import '../screens/owner/settings/notification_settings_screen.dart';
import '../screens/owner/settings/currency_settings_screen.dart';
import '../screens/owner/settings/timezone_settings_screen.dart'; // NEW
import '../screens/owner/settings/security_screen.dart';
import '../screens/owner/settings/support_screen.dart';
import '../screens/owner/settings/tenant_access_screen.dart';
import '../screens/owner/settings/active_sessions_screen.dart';
import '../screens/owner/settings/backup_restore_screen.dart'; // NEW
import '../screens/owner/settings/subscription_screen.dart'; // NEW
import '../screens/owner/settings/tekirayabook_privacy_screen.dart';
import '../screens/owner/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart'; // NEW


GoRouter createRouter({required String initialLocation, Object? initialExtra}) {
  return GoRouter(
    initialLocation: initialLocation,
    initialExtra: initialExtra,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
           final role = state.extra as String? ?? 'owner';
           return LoginScreen(role: role);
        },
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
        path: '/owner/houses/edit/:id',
        builder: (context, state) {
          final house = state.extra as House;
          return HouseFormScreen(house: house);
        },
      ),
      GoRoute(
        path: '/owner/houses/:id',
        builder: (context, state) {
          final house = state.extra as House?;
          final id = state.pathParameters['id']!;
          return HouseDetailContainer(houseId: id, house: house);
        },
      ),
      GoRoute(
        path: '/owner/tenants/add',
        builder: (context, state) => const TenantFormScreen(),
      ),
      GoRoute(
        path: '/owner/tenants/:id',
        builder: (context, state) {
          final tenant = state.extra as Tenant;
          return TenantDetailScreen(tenant: tenant);
        },
      ),
      GoRoute(
        path: '/owner/expenses',
        builder: (context, state) => const ExpenseListScreen(),
      ),
      GoRoute(
        path: '/owner/expenses/add',
        builder: (context, state) => const AddExpenseScreen(),
      ),

      GoRoute(
        path: '/owner/rent/pending',
        builder: (context, state) => const PendingPaymentsScreen(),
      ),
      GoRoute(
        path: '/owner/portfolio',
        builder: (context, state) => const PortfolioManagementScreen(),
      ),

      GoRoute(
        path: '/owner/settings',
        builder: (context, state) => const SettingsScreen(),
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
        path: '/owner/settings/timezone',
        builder: (context, state) => const TimezoneSettingsScreen(),
      ),
      GoRoute(
        path: '/owner/settings/security',
        builder: (context, state) => const SecurityScreen(),
        routes: [
           GoRoute(
            path: 'active-sessions',
            builder: (context, state) => const ActiveSessionsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/owner/settings/support',
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: '/owner/settings/tenant-access',
        builder: (context, state) => const TenantAccessScreen(),
      ),
      GoRoute(
        path: '/owner/settings/backup',
        builder: (context, state) => const BackupRestoreScreen(),
      ),
      GoRoute(
        path: '/owner/settings/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/owner/settings/tekirayabook',
        builder: (context, state) => const TekirayabookPrivacyScreen(),
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
          return TenantMainScreen(tenant: tenant);
        },
      ),
      GoRoute(
        path: '/tenant/notices',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return NoticeHistoryScreen(
            tenant: data['tenant'] as Tenant,
            notices: data['notices'] as List<Notice>,
          );
        },
      ),
      GoRoute(
        path: '/tenant/maintenance/:id',
        builder: (context, state) {
          final request = state.extra as MaintenanceRequest;
          return MaintenanceDetailScreen(request: request);
        },
      ),
      GoRoute(
        path: '/tenant/house-info',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return HouseInfoScreen(
            tenant: data['tenant'] as Tenant,
            house: data['house'] as House,
            unit: data['unit'] as Unit,
          );
        },
      ),
      GoRoute(
        path: '/tenant/document-viewer',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return DocumentViewerScreen(
            title: data['title'] as String,
            content: data['content'] as String?,
            pdfBytes: data['pdfBytes'] as Uint8List?,
          );
        },
      ),
    ],
  );
}
