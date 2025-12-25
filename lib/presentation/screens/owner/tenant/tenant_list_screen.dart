import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../domain/entities/tenant.dart';
import '../../../../domain/entities/tenancy.dart'; // Import Tenancy
import '../../../../domain/entities/house.dart';
import '../../../providers/data_providers.dart';
import '../rent/rent_controller.dart';
import '../settings/owner_controller.dart'; // NEW
import 'tenant_controller.dart';
import 'tenant_detail_screen.dart';
import 'widgets/delete_tenant_dialog.dart'; // NEW
import '../../../widgets/ads/banner_ad_widget.dart';
import '../../../../core/widgets/error_display_widget.dart'; // NEW
import '../../../../core/services/log_service.dart'; // NEW
import '../../../../core/utils/dialog_utils.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/skeleton_loader.dart';
import '../../maintenance/maintenance_controller.dart';
import '../../maintenance/maintenance_reports_screen.dart';
import '../../../../domain/entities/maintenance_request.dart';
import 'package:flutter/services.dart';

// --- UI Model ---
class TenantUiModel {
  final Tenant tenant;
  final String unitName;
  final String propertyName;
  final double rentAmount;
  final bool isPending;
  final bool isOverdue; // New field
  final double totalDue;

  final String? tenancyId; // NEW: Link to current/last tenancy
  
  TenantUiModel({
    required this.tenant,
    required this.unitName,
    required this.propertyName,
    required this.rentAmount,
    required this.isPending,
    required this.isOverdue,
    required this.totalDue,
    this.tenancyId,
  });
}

// --- Local Providers for Type Safety ---
final _tenantsStreamProvider = StreamProvider((ref) => ref.watch(tenantRepositoryProvider).getAllTenants());
final _housesStreamProvider = StreamProvider((ref) => ref.watch(propertyRepositoryProvider).getHouses());
final _tenanciesStreamProvider = StreamProvider((ref) => ref.watch(tenantRepositoryProvider).getAllTenancies());


// --- Combined Provider for Performance ---
final tenantListViewModelProvider = Provider.autoDispose<AsyncValue<List<TenantUiModel>>>((ref) {
  final tenantsAsync = ref.watch(_tenantsStreamProvider);
  final unitsAsync = ref.watch(allUnitsProvider);
  final housesAsync = ref.watch(_housesStreamProvider);
  final rentCyclesAsync = ref.watch(rentControllerProvider);
  final tenanciesAsync = ref.watch(_tenanciesStreamProvider);

  // Combine data only when all are available
  if (tenantsAsync is AsyncData && 
      unitsAsync is AsyncData && 
      housesAsync is AsyncData && 
      rentCyclesAsync is AsyncData &&
      tenanciesAsync is AsyncData) {
    
    final tenants = tenantsAsync.value ?? [];
    final units = unitsAsync.value ?? [];
    final houses = housesAsync.value ?? [];
    final cycles = rentCyclesAsync.value ?? [];
    final tenancies = tenanciesAsync.value ?? [];

    // Pre-calculate Maps for O(1) lookup
    final unitMap = { for (var u in units) u.id : u };
    final houseMap = { for (var h in houses) h.id : h };
    final tenancyMap = { for (var t in tenancies) t.id : t };
    
    // Map TenantId -> Latest Tenancy (Active preferred)
    final latestTenancyMap = <String, Tenancy>{}; // TenantId -> Tenancy
    for (var t in tenancies) {
      if (t.status == TenancyStatus.active) {
        latestTenancyMap[t.tenantId] = t;
      } else if (!latestTenancyMap.containsKey(t.tenantId)) {
        // Only keep if no active one found yet (simplified "latest" logic)
        latestTenancyMap[t.tenantId] = t;
      }
    }

    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    
    // Calculate Pending & Overdue Status per Tenant
    final pendingMap = <String, double>{}; // TenantId -> Amount
    final overdueMap = <String, bool>{};   // TenantId -> Bool

    for (var c in cycles) {
      if (c.status.name != 'paid') {
        final t = tenancyMap[c.tenancyId];
        if (t != null) {
          final tenantId = t.tenantId;
          pendingMap[tenantId] = (pendingMap[tenantId] ?? 0) + (c.totalDue - c.totalPaid);
          
          // Check if overdue (month < currentMonth)
          if (c.month.compareTo(currentMonth) < 0) {
             overdueMap[tenantId] = true;
          }
        }
      }
    }

    final uiList = tenants.map((tenant) {
      final tenancy = latestTenancyMap[tenant.id];
      // Use details from active tenancy if available, else last known
      final unit = tenancy != null ? unitMap[tenancy.unitId] : null;
      final house = unit != null ? houseMap[unit.houseId] : null;
      
      final pendingAmount = pendingMap[tenant.id] ?? 0.0;
      final isOver = overdueMap[tenant.id] ?? false;
      
      return TenantUiModel(
        tenant: tenant,
        unitName: unit?.nameOrNumber ?? '-',
        propertyName: house?.name ?? '-',
        rentAmount: tenancy?.agreedRent ?? 0.0,
        isPending: pendingAmount > 0,
        isOverdue: isOver,
        totalDue: pendingAmount,
        tenancyId: tenancy?.id,
      );
    }).toList();

    // Sort: Overdue -> Pending -> Name
    uiList.sort((a, b) {
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;
      if (a.isPending && !b.isPending) return -1;
      if (!a.isPending && b.isPending) return 1;
      return a.tenant.name.compareTo(b.tenant.name);
    });

    return Asyncdata(uiList);
  } else if (tenantsAsync is AsyncError || unitsAsync is AsyncError || housesAsync is AsyncError || rentCyclesAsync is AsyncError || tenanciesAsync is AsyncError) {
    StringBuffer errorMsg = StringBuffer();
    if (tenantsAsync is AsyncError) errorMsg.writeln('Tenants: ${tenantsAsync.error}');
    if (unitsAsync is AsyncError) errorMsg.writeln('Units: ${unitsAsync.error}');
    if (housesAsync is AsyncError) errorMsg.writeln('Houses: ${housesAsync.error}');
    if (rentCyclesAsync is AsyncError) errorMsg.writeln('Rent: ${rentCyclesAsync.error}');
    if (tenanciesAsync is AsyncError) errorMsg.writeln('Tenancies: ${tenanciesAsync.error}');
    
    LogService.logError('Tenant List Data Error: $errorMsg', error: null, stackTrace: StackTrace.current);
    
    return AsyncError('Failed to load data:\n$errorMsg', StackTrace.current);
  } else {
    return const AsyncLoading();
  }
});

// Helper for AsyncData because generic type inference can be tricky
AsyncValue<List<TenantUiModel>> Asyncdata(List<TenantUiModel> data) => AsyncValue.data(data);

class TenantListScreen extends ConsumerStatefulWidget {
  const TenantListScreen({super.key});

  @override
  ConsumerState<TenantListScreen> createState() => _TenantListScreenState();
}

class _TenantListScreenState extends ConsumerState<TenantListScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  late TabController _tabController;
  // --- Multi-Select State ---
  String _filterStatus = 'All Status'; // Restored
  final Set<String> _selectedIds = {};
  bool get _isSelectionMode => _selectedIds.isNotEmpty;

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
    });
  }

  void _deleteSelectedTenants() async {
     final count = _selectedIds.length;
     if (count == 0) return;

     showDialog(
       context: context,
       builder: (ctx) => DeleteTenantDialog(
         count: count,
         isBatch: true,
         onConfirm: () async {
            Navigator.pop(ctx);
            await DialogUtils.runWithLoading(context, () async {
               await ref.read(tenantControllerProvider.notifier).deleteTenantsBatch(_selectedIds.toList());
               // Force refresh of data
               ref.invalidate(_tenantsStreamProvider);
               ref.invalidate(_housesStreamProvider); 
               ref.invalidate(_tenanciesStreamProvider);
            });
            if (mounted) {
               _clearSelection();
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tenants deleted successfully')));
            }
         },
         onCancel: () => Navigator.pop(ctx),
       ),
     );
  }

  void _onAddTenant() {
    final uiDataAsync = ref.read(tenantListViewModelProvider); // Use read
    final tenants = uiDataAsync.valueOrNull ?? [];
    final owner = ref.read(ownerControllerProvider).value;
    final plan = owner?.subscriptionPlan ?? 'free';
    
    int limit = 2; // Free
    if (plan == 'pro') limit = 20;
    if (plan == 'power') limit = 999999;
    
    if (tenants.length >= limit) {
       showDialog(
         context: context, 
         builder: (dialogContext) => AlertDialog(
           title: const Text('Limit Reached'),
           content: Text('You have reached the limit of $limit tenants for the ${plan.toUpperCase()} plan. Upgrade to add more.'),
           actions: [
             TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
             ElevatedButton(
               onPressed: () {
                 Navigator.pop(dialogContext);
                 context.push('/owner/settings/subscription');
               }, 
               child: const Text('Upgrade')
             ),
           ],
         )
       );
       return;
    }
    
    context.push('/owner/tenants/add');
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uiDataAsync = ref.watch(tenantListViewModelProvider);
    final isDark = theme.brightness == Brightness.dark;

    // Watch Maintenance Requests for Badge
    final user = ref.watch(userSessionServiceProvider).currentUser;
    final maintenanceAsync = user != null ? ref.watch(ownerMaintenanceProvider(user.uid)) : const AsyncValue<List<MaintenanceRequest>>.loading();
    final pendingMaintenanceCount = maintenanceAsync.valueOrNull?.where((r) => r.status == MaintenanceStatus.pending).length ?? 0;

    return WillPopScope( // Handle back button to exit selection mode
      onWillPop: () async {
        if (_isSelectionMode) {
          _clearSelection();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF000000) : Colors.white, 
        appBar: AppBar(
          backgroundColor: _isSelectionMode ? theme.colorScheme.primaryContainer : (isDark ? Colors.black : Colors.white),
          elevation: 0,
          titleSpacing: _isSelectionMode ? 0 : 20,
          leading: _isSelectionMode 
              ? IconButton(
                  icon: const Icon(Icons.close), 
                  onPressed: _clearSelection,
                  tooltip: 'Cancel Selection',
                ) 
              : null,
          automaticallyImplyLeading: false,
          title: _isSelectionMode 
             ? Text('${_selectedIds.length} Selected', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold))
             : Row(
            children: [
              Text(
                'Tenants',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              // Add Button
              InkWell(
                onTap: _onAddTenant,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary, 
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        'Add',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: _isSelectionMode ? [
             IconButton(
               icon: const Icon(Icons.delete_outline, color: Colors.red),
               onPressed: _deleteSelectedTenants,
               tooltip: 'Delete Selected',
             ),
             const SizedBox(width: 16),
          ] : [
            // Notification Icon with Badge
            Badge(
              label: Text('$pendingMaintenanceCount'),
              isLabelVisible: pendingMaintenanceCount > 0,
              offset: const Offset(-4, 4),
              child: IconButton(
                icon: Icon(Icons.notifications_none_rounded, color: theme.textTheme.bodyMedium?.color),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MaintenanceReportsScreen()));
                },
              ),
            ),
            const SizedBox(width: 8),
            // Functional Profile Icon
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/owner/settings');
              },
              child: Container(
                 margin: const EdgeInsets.only(right: 20),
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                   color: theme.colorScheme.primary,
                   shape: BoxShape.circle,
                 ),
                 child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.disabledColor,
            indicatorColor: theme.colorScheme.primary,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Moved Out'),
            ],
          ),
        ),
        body: Column(
          children: [
            // --- Controls Section (Hide in Selection Mode for cleaner look) ---
            if (!_isSelectionMode)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Row(
                  children: [
                    // Search Bar
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (val) => setState(() {}),
                          style: GoogleFonts.outfit(color: theme.textTheme.bodyLarge?.color),
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: GoogleFonts.outfit(color: theme.hintColor),
                            prefixIcon: Icon(Icons.search, color: theme.iconTheme.color?.withValues(alpha: 0.5)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filter Dropdown
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _filterStatus,
                            isExpanded: true,
                            dropdownColor: theme.cardColor,
                            icon: Icon(Icons.filter_list, size: 20, color: theme.iconTheme.color),
                            items: ['All Status', 'Paid', 'Pending'].map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s, style: GoogleFonts.outfit(color: theme.textTheme.bodyLarge?.color, fontSize: 13)),
                            )).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _filterStatus = val);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // --- List Section ---
            Expanded(
              child: uiDataAsync.when(
                data: (allTenants) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildFilteredTenantList(theme, allTenants, false, ref), // Active
                      _buildFilteredTenantList(theme, allTenants, true, ref),  // Moved Out
                    ],
                  );
                },
                loading: () => const SkeletonList(),
                error: (e, s) {
                  return Center(
                    child: ErrorDisplayWidget(
                      error: e,
                      stackTrace: s,
                      onRetry: () => ref.refresh(tenantListViewModelProvider),
                      title: 'Failed to Load Tenants',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredTenantList(ThemeData theme, List<TenantUiModel> allTenants, bool isHistory, WidgetRef ref) {
    final statusFiltered = allTenants.where((uiModel) {
      final isActive = uiModel.tenant.isActive;
      return isHistory ? !isActive : isActive;
    }).toList();

    final fullyFiltered = statusFiltered.where((uiModel) {
      final matchesSearch = uiModel.tenant.name.toLowerCase().contains(_searchCtrl.text.toLowerCase()) || 
                            uiModel.tenant.phone.contains(_searchCtrl.text);
      if (!matchesSearch) return false;
      if (_filterStatus == 'Paid') return !uiModel.isPending;
      if (_filterStatus == 'Pending') return uiModel.isPending;
      return true;
    }).toList();

    if (fullyFiltered.isEmpty) {
       return EmptyStateWidget(
         title: isHistory ? 'No Past Tenants' : 'No Active Tenants',
         subtitle: isHistory 
            ? 'History is clean! No moved-out tenants yet.' 
            : 'Get started by adding your first tenant.',
         icon: isHistory ? Icons.history : Icons.group_add_outlined,
         buttonText: isHistory ? null : 'Add Tenant',
         onButtonPressed: isHistory ? null : _onAddTenant,
       );
    }

    // Show ads only for Free plan users
    final isFreePlan = ref.watch(ownerControllerProvider).valueOrNull?.subscriptionPlan == 'free';

    return CustomScrollView(
      slivers: [
         if (isFreePlan)
           const SliverToBoxAdapter(
             child: Padding(
               padding: EdgeInsets.symmetric(vertical: 16.0),
               child: BannerAdWidget(),
             ),
           ),

         SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                   final item = fullyFiltered[index];
                   final isSelected = _selectedIds.contains(item.tenant.id);
        
                   // Multi-Select Wrapper: Disable dismissal when selecting
                   // If selecting, show checkbox or highlight.
                   // If Not selecting, behave normally (Dismissible)
                   
                   if (_isSelectionMode) {
                       return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TenantCard(
                              item: item, 
                              isHistory: isHistory,
                              isSelected: isSelected,
                              onLongPress: () => _toggleSelection(item.tenant.id),
                              onTap: () => _toggleSelection(item.tenant.id),
                          ),
                       );
                    }
 
                    // Standard Mode
                    if (isHistory) {
                       return Padding(
                         padding: const EdgeInsets.only(bottom: 16.0),
                         child: Dismissible(
                           key: ValueKey('history_${item.tenant.id}'),
                           direction: DismissDirection.startToEnd,
                           background: Container(
                             alignment: Alignment.centerLeft,
                             padding: const EdgeInsets.only(left: 24),
                             decoration: BoxDecoration(
                               color: Colors.blue,
                               borderRadius: BorderRadius.circular(16),
                             ),
                             child: const Row(
                               children: [
                                 Icon(Icons.login, color: Colors.white, size: 28),
                                 SizedBox(width: 8),
                                 Text('Move In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                               ],
                             ),
                           ),
                           confirmDismiss: (direction) async {
                             _showMoveInDialog(context, item);
                             return false;
                           },
                           child: TenantCard(
                               item: item, 
                               isHistory: true, 
                               onLongPress: () => _toggleSelection(item.tenant.id),
                               // Default Tap (Nav) is handled inside Card? 
                               // No, let's lift onTap up or handle inside. Card handles it.
                           ),
                         ),
                       );
                    }
 
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Dismissible(
                         key: ValueKey('active_${item.tenant.id}'),
                         direction: DismissDirection.horizontal,
                         // Swipe Right (startToEnd): Move Out
                         background: Container(
                           alignment: Alignment.centerLeft,
                           padding: const EdgeInsets.only(left: 24),
                           decoration: BoxDecoration(
                             color: Colors.orange,
                             borderRadius: BorderRadius.circular(16),
                           ),
                           child: const Row(
                             children: [
                               Icon(Icons.logout, color: Colors.white, size: 28),
                               SizedBox(width: 8),
                               Text('Move Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                             ],
                           ),
                         ),
                         // Swipe Left (endToStart): Call
                         secondaryBackground: Container(
                           alignment: Alignment.centerRight,
                           padding: const EdgeInsets.only(right: 24),
                           decoration: BoxDecoration(
                             color: Colors.green,
                             borderRadius: BorderRadius.circular(16),
                           ),
                           child: const Row(
                             mainAxisAlignment: MainAxisAlignment.end,
                             children: [
                               Text('Call', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                               SizedBox(width: 8),
                               Icon(Icons.phone, color: Colors.white, size: 28),
                             ],
                           ),
                         ),
                         confirmDismiss: (direction) async {
                           if (direction == DismissDirection.endToStart) {
                             _handleCall(item);
                           } else if (direction == DismissDirection.startToEnd) {
                             _showMoveOutConfirmation(context, item);
                           }
                           return false; // Do not dismiss automatically
                         },
                         child: TenantCard(
                             item: item, 
                             isHistory: false,
                             onLongPress: () => _toggleSelection(item.tenant.id),
                          ),
                       ),
                    );
                },
                childCount: fullyFiltered.length,
              ),
            ),
         ),
         const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }

  // --- Helper Methods for Slide Actions ---
  // (Moving existing helpers here to keep code clean, unchanged)
  Future<void> _handleCall(TenantUiModel item) async {
    final phone = item.tenant.phone.replaceAll(RegExp(r'\D'), '');
    if (phone.isNotEmpty) {
      final url = Uri.parse('tel:$phone');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch dialer')),
          );
        }
      }
    }
  }

  void _showMoveOutConfirmation(BuildContext context, TenantUiModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Move Out ${item.tenant.name}?'),
        content: const Text('This will end their current tenancy and mark them as "Moved Out". The unit will become vacant.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(tenantControllerProvider.notifier).moveOutTenant(item.tenant.id, item.tenancyId);
                if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.tenant.name} moved out.')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Move Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showMoveInDialog(BuildContext context, TenantUiModel item) {
    showDialog(
      context: context,
      builder: (context) {
        final unitsAsync = ref.watch(allUnitsProvider);
        return AlertDialog(
          title: Text('Move In ${item.tenant.name}'),
          content: unitsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error loading units: $err'),
            data: (units) {
              final availableUnits = units.where((u) => !u.isOccupied).cast<Unit>().toList();
              if (availableUnits.isEmpty) {
                return const Text('No vacant units available. Please add or vacate a unit first.');
              }
              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableUnits.length,
                  itemBuilder: (context, idx) {
                    final u = availableUnits[idx];
                    return ListTile(
                      title: Text(u.nameOrNumber),
                      subtitle: Text('Default Rent: ₹${u.editableRent ?? 0}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        Navigator.pop(context);
                        try {
                          await ref.read(tenantControllerProvider.notifier).moveInTenant(
                            tenantId: item.tenant.id,
                            houseId: u.houseId,
                            unitId: u.id,
                            agreedRent: u.editableRent ?? 0.0,
                            startDate: DateTime.now(),
                          );
                          if (mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.tenant.name} is now active.')));
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          }
                        }
                      },
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ],
        );
      },
    );
  }
}

class TenantCard extends StatelessWidget {
  final TenantUiModel item;
  final bool isHistory;
  
  // NEW: Multi-Select Props
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap; // Optional override

  const TenantCard({super.key, 
      required this.item, 
      this.isHistory = false,
      this.isSelected = false,
      this.onLongPress,
      this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tenant = item.tenant;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Formatting
    final currencyFormat = NumberFormat.simpleCurrency(name: 'INR', decimalDigits: 0);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 350;
        
        return InkWell(
          onLongPress: onLongPress,
          onTap: onTap ?? () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => TenantDetailScreen(tenant: tenant))),
          borderRadius: BorderRadius.circular(12),
          child: Stack(
              children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
                          width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(narrow ? 12.0 : 16.0),
                      child: Opacity(
                        opacity: isHistory ? 0.7 : 1.0,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // 1. Profile Image
                            Container(
                              width: narrow ? 40 : 50, height: narrow ? 40 : 50,
                              margin: EdgeInsets.only(right: narrow ? 12 : 16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: theme.dividerColor, width: 1),
                              ),
                              child: CircleAvatar(
                                radius: narrow ? 18 : 24,
                            backgroundColor: theme.colorScheme.surface, 
                            backgroundImage: (tenant.imageBase64 != null && tenant.imageBase64!.isNotEmpty)
                                ? MemoryImage(base64Decode(tenant.imageBase64!))
                                : ((tenant.imageUrl != null && tenant.imageUrl!.isNotEmpty)
                                    ? (tenant.imageUrl!.startsWith('http') 
                                        ? CachedNetworkImageProvider(tenant.imageUrl!) 
                                        : FileImage(File(tenant.imageUrl!))) as ImageProvider
                                    : null),
                            child: (tenant.imageBase64 == null && (tenant.imageUrl == null || tenant.imageUrl!.isEmpty))
                                ? Text(
                                    tenant.name.isNotEmpty ? tenant.name[0].toUpperCase() : '?',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold,
                                      color: theme.textTheme.bodyMedium?.color
                                    ),
                                  )
                                : null,
                          ),
                        ),

                        // 2. Info Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                Text(
                                  tenant.name,
                                  style: GoogleFonts.outfit(
                                    fontSize: narrow ? 14 : 16,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                  maxLines: 1, 
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 4),
                               // Property & ID
                              Row(
                                children: [
                                   Icon(Icons.location_on_outlined, size: 14, color: theme.hintColor),
                                   const SizedBox(width: 4),
                                   Flexible(
                                     child: Text(
                                        '${item.propertyName}, ${item.unitName}',
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          color: theme.hintColor,
                                        ),
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                     ),
                                   ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 3. Amount Column (or Checkbox if selected mode?)
                        // User design preference: Standard look but highlighted. 
                        // Let's keep existing info but maybe checkmark overlay.
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currencyFormat.format(item.rentAmount),
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: theme.textTheme.bodyLarge?.color,
                                letterSpacing: -0.5
                              ),
                            ),
                            Text(
                              '/month',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (!isHistory)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.chevron_left, size: 14, color: theme.disabledColor.withValues(alpha: 0.5)),
                                  const SizedBox(width: 2),
                                  Icon(Icons.phone, size: 12, color: theme.disabledColor.withValues(alpha: 0.5)),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Selected Checkmark Overlay
              if (isSelected)
                 Positioned(
                    top: 8, right: 8,
                    child: Container(
                       decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                       child: Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 24)
                    ),
                 ),
          ],
        ),
      );
    },
   );
  }
}


