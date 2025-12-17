import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
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
import 'tenant_detail_screen.dart';
import '../../../widgets/ads/banner_ad_widget.dart';

// --- UI Model ---
class TenantUiModel {
  final Tenant tenant;
  final String unitName;
  final String propertyName;
  final double rentAmount;
  final bool isPending;
  final bool isOverdue; // New field
  final double totalDue;

  TenantUiModel({
    required this.tenant,
    required this.unitName,
    required this.propertyName,
    required this.rentAmount,
    required this.isPending,
    required this.isOverdue,
    required this.totalDue,
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
    
    // Map TenantId -> Active Tenancy
    final activeTenancyMap = <String, Tenancy>{}; // TenantId -> Tenancy
    for (var t in tenancies) {
      if (t.status == TenancyStatus.active) {
        activeTenancyMap[t.tenantId] = t;
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
      final tenancy = activeTenancyMap[tenant.id];
      // Use details from active tenancy if available, else placeholders
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
    return AsyncError('Failed to load data', StackTrace.current);
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
  String _filterStatus = 'All Status'; // All Status, Paid, Pending

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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, 
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        titleSpacing: 20,
        leading: null, 
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              'Tenants',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const Spacer(),
// Add proper import at top: import '../settings/owner_controller.dart'; 

            // Add Button
            InkWell(
              onTap: () {
                final tenants = uiDataAsync.valueOrNull ?? [];
                final owner = ref.read(ownerControllerProvider).value;
                final plan = owner?.subscriptionPlan ?? 'free';
                
                int limit = 2; // Free
                if (plan == 'pro') limit = 20;
                if (plan == 'power') limit = 999999;
                
                if (tenants.length >= limit) {
                   showDialog(
                     context: context, 
                     builder: (_) => AlertDialog(
                       title: const Text('Limit Reached'),
                       content: Text('You have reached the limit of $limit tenants for the ${plan.toUpperCase()} plan. Upgrade to add more.'),
                       actions: [
                         TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                         ElevatedButton(
                           onPressed: () {
                             Navigator.pop(context);
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
              },
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
          // --- Controls Section ---
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
                        prefixIcon: Icon(Icons.search, color: theme.iconTheme.color?.withOpacity(0.5)),
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
                // 1. Filter by Tab (Active vs Moved Out)
                final isHistoryTab = _tabController.index == 1;
                final statusFiltered = allTenants.where((uiModel) {
                  final isActive = uiModel.tenant.status == TenantStatus.active;
                  return isHistoryTab ? !isActive : isActive;
                }).toList();

                // 2. Filter by Search & Payment Status
                final fullyFiltered = statusFiltered.where((uiModel) {
                  final matchesSearch = uiModel.tenant.name.toLowerCase().contains(_searchCtrl.text.toLowerCase()) || 
                                        uiModel.tenant.phone.contains(_searchCtrl.text);
                  
                  if (!matchesSearch) return false;

                  if (_filterStatus == 'Paid') return !uiModel.isPending;
                  if (_filterStatus == 'Pending') return uiModel.isPending;
                  return true; // All Status
                }).toList();

                if (fullyFiltered.isEmpty) {
                   return Center(child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(isHistoryTab ? Icons.history : Icons.people_outline, size: 60, color: theme.disabledColor.withOpacity(0.3)),
                       const SizedBox(height: 16),
                       Text(
                         isHistoryTab ? 'No past tenants found' : 'No active tenants',
                         style: GoogleFonts.outfit(color: theme.disabledColor, fontSize: 16),
                       ),
                     ],
                   ));
                }

                return CustomScrollView(
                  slivers: [
                     // Full-width Ad
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
                    
                               if (isHistoryTab) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: _TenantCard(item: item, isHistory: true),
                                  );
                               }

                               return Padding(
                                 padding: const EdgeInsets.only(bottom: 16.0),
                                 child: Dismissible(
                                   key: ValueKey(item.tenant.id),
                                   direction: DismissDirection.endToStart,
                                   background: Container(
                                     alignment: Alignment.centerRight,
                                     padding: const EdgeInsets.only(right: 24),
                                     decoration: BoxDecoration(
                                       color: Colors.green,
                                       borderRadius: BorderRadius.circular(16),
                                     ),
                                     child: const Icon(Icons.phone, color: Colors.white, size: 28),
                                   ),
                                   confirmDismiss: (direction) async {
                                     final phone = item.tenant.phone.replaceAll(RegExp(r'\D'), '');
                                     if (phone.isNotEmpty) {
                                        final url = Uri.parse('tel:$phone');
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url);
                                        } else {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Could not launch dialer')),
                                            );
                                          }
                                        }
                                     }
                                     return false; // Do not dismiss
                                   },
                                   child: _TenantCard(item: item, isHistory: false),
                                 ),
                               );
                            },
                            childCount: fullyFiltered.length,
                          ),
                        ),
                     ),
                     // Bottom padding
                     const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e', style: TextStyle(color: theme.textTheme.bodyMedium?.color))),
            ),
          ),
        ],
      ),
    );
  }
}

class _TenantCard extends StatelessWidget {
  final TenantUiModel item;
  final bool isHistory;

  const _TenantCard({required this.item, this.isHistory = false});

  @override
  Widget build(BuildContext context) {
    final tenant = item.tenant;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Formatting
    final currencyFormat = NumberFormat.simpleCurrency(name: 'INR', decimalDigits: 0);
    
    // Status Badge Logic
    Color statusBg;
    Color statusTx;
    String statusLabel;

    if (isHistory) {
      statusBg = isDark ? Colors.white10 : Colors.grey.shade200;
      statusTx = isDark ? Colors.grey : Colors.grey.shade700;
      statusLabel = 'MOVED OUT';
    } else {
       if (item.isOverdue) {
          statusBg = isDark ? Colors.red.withOpacity(0.2) : const Color(0xFFFECACA); // Red
          statusTx = isDark ? Colors.redAccent : const Color(0xFFDC2626);
          statusLabel = 'OVERDUE';
       } else if (item.isPending) {
          statusBg = isDark ? Colors.amber.withOpacity(0.2) : const Color(0xFFFEF3C7); // Amber
          statusTx = isDark ? Colors.amberAccent : const Color(0xFFD97706);
          statusLabel = 'DUE';
       } else {
          statusBg = isDark ? Colors.green.withOpacity(0.2) : const Color(0xFFDCFCE7); // Green
          statusTx = isDark ? Colors.greenAccent : const Color(0xFF16A34A);
          statusLabel = 'PAID';
       }
    }

    // Border: Highlight Overdue/Due vs Normal
    final borderDecoration = (!isHistory && (item.isPending || item.isOverdue)) 
      ? Border.all(color: item.isOverdue ? Colors.red.withOpacity(0.5) : Colors.amber.withOpacity(0.5), width: 1)
      : Border.all(color: theme.dividerColor);

    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => TenantDetailScreen(tenant: tenant))),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isHistory ? theme.cardColor.withOpacity(0.6) : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: borderDecoration,
          boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
               blurRadius: 8,
               offset: const Offset(0, 2),
             )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Opacity(
            opacity: isHistory ? 0.7 : 1.0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Profile Image (Moved Left)
                Container(
                  width: 50, height: 50,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.dividerColor, width: 1),
                  ),
                  child: CircleAvatar(
                    radius: 24,
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
                      Row(
                         children: [
                            Flexible(
                              child: Text(
                                tenant.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Compact Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                statusLabel,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: statusTx,
                                  letterSpacing: 0.5
                                ),
                              ),
                            ),
                         ]
                      ),
                      const SizedBox(height: 4),
                       // Property & ID (Integrated)
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

                // 3. Amount Column
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
                          Icon(Icons.chevron_left, size: 14, color: theme.disabledColor.withOpacity(0.5)),
                          const SizedBox(width: 2),
                          Icon(Icons.phone, size: 12, color: theme.disabledColor.withOpacity(0.5)),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


