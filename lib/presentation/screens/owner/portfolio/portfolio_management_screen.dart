import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../house/house_list_screen.dart';
import '../house/house_controller.dart';
import '../tenant/tenant_list_screen.dart';
import '../../../widgets/empty_state_widget.dart';

class PortfolioManagementScreen extends ConsumerStatefulWidget {
  const PortfolioManagementScreen({super.key});

  @override
  ConsumerState<PortfolioManagementScreen> createState() => _PortfolioManagementScreenState();
}

class _PortfolioManagementScreenState extends ConsumerState<PortfolioManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add to Portfolio',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildOptionTile(
              context,
              'New Property',
              'Houses, Apartments, or Rooms',
              Icons.add_business_rounded,
              const Color(0xFF2563EB),
              () {
                context.pop();
                context.push('/owner/houses/add');
              },
            ),
            const SizedBox(height: 12),
            _buildOptionTile(
              context,
              'New Tenant',
              'Onboard a resident to a unit',
              Icons.person_add_rounded,
              const Color(0xFF6366F1),
              () {
                context.pop();
                context.push('/owner/tenants/add');
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: GoogleFonts.outfit(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6), fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.hintColor),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Portfolio Hub', 
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold, 
            fontSize: 22, 
            color: isDark ? Colors.white : Colors.black87,
            letterSpacing: -0.5,
          )
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.label,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 3, color: theme.colorScheme.primary),
            borderRadius: BorderRadius.circular(3),
          ),
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
          unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 16),
          tabs: const [
            Tab(text: 'Properties'),
            Tab(text: 'Tenants'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          HouseListPanel(), 
          TenantListPanel(), 
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddOptions(context),
          label: Text('Quick Add', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
          icon: const Icon(Icons.add, color: Colors.white),
          backgroundColor: theme.colorScheme.primary,
          elevation: 0,
        ),
      ),
    );
  }
}

// House List Panel Implementation
class HouseListPanel extends ConsumerWidget {
  const HouseListPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final housesAsync = ref.watch(houseControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return housesAsync.when(
      data: (houses) {
        if (houses.isEmpty) {
          return Center(
            child: EmptyStateWidget(
              title: 'properties.empty_title'.tr(),
              subtitle: 'properties.empty_subtitle'.tr(),
              icon: Icons.home_work_outlined,
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: houses.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: ModernPropertyCard(house: houses[index], isDark: isDark, theme: theme, ref: ref),
            );
          },
        );
      },
      error: (e, st) => Center(child: Text('Error: $e')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

// Tenant List Panel Implementation
class TenantListPanel extends ConsumerStatefulWidget {
  const TenantListPanel({super.key});

  @override
  ConsumerState<TenantListPanel> createState() => _TenantListPanelState();
}

class _TenantListPanelState extends ConsumerState<TenantListPanel> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _filterStatus = 'All Status';
  int _selectedSubTab = 0; // 0: Active, 1: Moved Out

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiDataAsync = ref.watch(tenantListViewModelProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        // Compact search and filter
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (val) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filterStatus,
                    icon: const Icon(Icons.filter_list, size: 18),
                    items: ['All Status', 'Paid', 'Pending'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) { if (val != null) setState(() => _filterStatus = val); },
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Custom Sub-Tabs (State-based, non-swipable to allow outer swipe)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: theme.dividerColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildSubTab(0, 'Active'),
                _buildSubTab(1, 'Moved Out'),
              ],
            ),
          ),
        ),

        Expanded(
          child: uiDataAsync.when(
            data: (allTenants) => _buildFilteredList(allTenants, _selectedSubTab == 1),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildSubTab(int index, String label) {
    final theme = Theme.of(context);
    final isSelected = _selectedSubTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSubTab = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilteredList(List<TenantUiModel> allTenants, bool isHistory) {
    final filtered = allTenants.where((ui) {
      final isActive = ui.tenant.isActive;
      if (isHistory && isActive) return false;
      if (!isHistory && !isActive) return false;
      
      final matchesSearch = ui.tenant.name.toLowerCase().contains(_searchCtrl.text.toLowerCase());
      if (!matchesSearch) return false;

      if (_filterStatus == 'Paid') return !ui.isPending;
      if (_filterStatus == 'Pending') return ui.isPending;
      
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_rounded, size: 48, color: Theme.of(context).hintColor.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              isHistory ? 'No records' : 'No active tenants', 
              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16)
            ),
          ],
        )
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TenantCard(item: filtered[index], isHistory: isHistory),
        );
      },
    );
  }
}
