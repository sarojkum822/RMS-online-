import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../domain/entities/house.dart';
import '../../../../domain/entities/notice.dart';
import '../../../../domain/entities/tenant.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../notice_controller.dart' as notice_ctrl;
import '../../../providers/data_providers.dart' as data_providers;
import '../../../screens/owner/house/house_controller.dart';
import '../../../screens/owner/tenant/tenant_controller.dart';

/// Message templates for quick broadcast creation
class BroadcastTemplate {
  final String name;
  final String icon;
  final String subject;
  final String message;

  const BroadcastTemplate({
    required this.name,
    required this.icon,
    required this.subject,
    required this.message,
  });
}

const _templates = [
  BroadcastTemplate(
    name: 'Maintenance',
    icon: '🔧',
    subject: 'Scheduled Maintenance Notice',
    message: 'Dear Residents,\n\nPlease be informed that maintenance work will be carried out on [DATE] from [TIME] to [TIME].\n\nWe apologize for any inconvenience.',
  ),
  BroadcastTemplate(
    name: 'Rent Reminder',
    icon: '💰',
    subject: 'Monthly Rent Reminder',
    message: 'Dear Residents,\n\nThis is a gentle reminder that rent for the current month is due. Please ensure timely payment to avoid late fees.\n\nThank you for your cooperation.',
  ),
  BroadcastTemplate(
    name: 'Water Supply',
    icon: '💧',
    subject: 'Water Supply Interruption',
    message: 'Dear Residents,\n\nWater supply will be temporarily interrupted on [DATE] from [TIME] to [TIME] due to [REASON].\n\nPlease store water accordingly.',
  ),
  BroadcastTemplate(
    name: 'General',
    icon: '📢',
    subject: '',
    message: '',
  ),
];

const int _maxSubjectLength = 100;
const int _maxMessageLength = 1000;

class BroadcastCenterSheet extends ConsumerStatefulWidget {
  final String? initialHouseId;
  const BroadcastCenterSheet({super.key, this.initialHouseId});

  @override
  ConsumerState<BroadcastCenterSheet> createState() => _BroadcastCenterSheetState();
}

class _BroadcastCenterSheetState extends ConsumerState<BroadcastCenterSheet> {
  late PageController _pageController;
  int _currentPage = 0;

  // Compose State
  final _titleController = TextEditingController();
  final _msgController = TextEditingController();
  String _selectedPriority = 'medium';
  String _mainTarget = 'all'; // all or property
  String? _selectedHouseId;
  String _propertyScope = 'building'; // building or flat
  String? _selectedUnitId;
  bool _isLoading = false;
  int _selectedTemplateIndex = 3; // Default to "General" (blank)

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.initialHouseId != null) {
      _mainTarget = 'property';
      _selectedHouseId = widget.initialHouseId;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _msgController.dispose();
    super.dispose();
  }

  void _applyTemplate(int index) {
    final template = _templates[index];
    setState(() {
      _selectedTemplateIndex = index;
      _titleController.text = template.subject;
      _msgController.text = template.message;
    });
  }

  Future<bool> _showConfirmationDialog() async {
    final targetDescription = _mainTarget == 'all'
        ? 'all tenants across all properties'
        : _propertyScope == 'building'
            ? 'all tenants in the selected property'
            : 'the selected flat';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Text('broadcast.confirm_title'.tr(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('broadcast.confirm_message'.tr()),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subject: ${_titleController.text}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('To: $targetDescription', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Priority: ${_selectedPriority.toUpperCase()}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.send, size: 18),
            label: Text('broadcast.send'.tr()),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _onSave() async {
    if (_isLoading) return;
    
    // Validation
    if (_titleController.text.isEmpty) {
      SnackbarUtils.showError(context, 'broadcast.error_subject'.tr());
      return;
    }
    if (_msgController.text.isEmpty) {
      SnackbarUtils.showError(context, 'broadcast.error_message'.tr());
      return;
    }
    if (_mainTarget == 'property' && _selectedHouseId == null) {
      SnackbarUtils.showError(context, 'broadcast.error_property'.tr());
      return;
    }
    if (_mainTarget == 'property' && _propertyScope == 'flat' && _selectedUnitId == null) {
      SnackbarUtils.showError(context, 'broadcast.error_flat'.tr());
      return;
    }

    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    final user = ref.read(data_providers.userSessionServiceProvider).currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('broadcast.sending'.tr(), style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );

    String targetType = 'all';
    String? targetId;
    
    if (_mainTarget == 'property') {
      if (_propertyScope == 'building') {
        targetType = 'house';
        targetId = _selectedHouseId;
      } else {
        targetType = 'unit';
        targetId = _selectedUnitId;
      }
    }

    try {
      await ref.read(notice_ctrl.noticeControllerProvider.notifier).sendNotice(
        houseId: _selectedHouseId ?? 'global',
        ownerId: user.uid,
        subject: _titleController.text.trim(),
        message: _msgController.text.trim(),
        priority: _selectedPriority,
        targetType: targetType,
        targetId: targetId,
      );
      
      if (mounted) {
        Navigator.pop(context); // Close loading
        
        // Store what was sent for success message
        final sentSubject = _titleController.text.trim();
        
        // Clear form to prevent duplicate sends
        _titleController.clear();
        _msgController.clear();
        setState(() {
          _selectedTemplateIndex = 3;
          _selectedPriority = 'medium';
          _isLoading = false;
        });
        
        // Show success with subject confirmation
        SnackbarUtils.showSuccess(context, '"$sentSubject" sent successfully!');
        
        // Close sheet after delay so user sees message
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        setState(() => _isLoading = false);
        SnackbarUtils.showError(context, 'broadcast.failed'.tr(args: [e.toString().replaceAll('Exception: ', '')]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withAlpha(50), borderRadius: BorderRadius.circular(2))),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
            child: Row(
              children: [
                _buildTab('broadcast.compose'.tr(), 0),
                const SizedBox(width: 16),
                _buildTab('broadcast.history'.tr(), 1),
              ],
            ),
          ),
          
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (idx) => setState(() => _currentPage = idx),
              children: [
                _buildComposeView(),
                _buildHistoryView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _currentPage == index;
    return GestureDetector(
      onTap: () => _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 18, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey)),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: isSelected ? 40 : 0,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(2)),
          )
        ],
      ),
    );
  }

  Widget _buildComposeView() {
    final theme = Theme.of(context);
    final housesAsync = ref.watch(houseControllerProvider);
    final unitsAsync = (_selectedHouseId != null) 
        ? ref.watch(houseUnitsProvider(_selectedHouseId!)) 
        : const AsyncValue<List<Unit>>.data([]);
    final tenanciesAsync = ref.watch(data_providers.allTenanciesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Templates Section
          Text('broadcast.templates'.tr(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _templates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, idx) {
                final template = _templates[idx];
                final isSelected = _selectedTemplateIndex == idx;
                return FilterChip(
                  label: Text('${template.icon} ${template.name}'),
                  selected: isSelected,
                  onSelected: (_) => _applyTemplate(idx),
                  selectedColor: theme.colorScheme.primary.withAlpha(30),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          
          // Subject with character counter
          TextFormField(
            controller: _titleController,
            maxLength: _maxSubjectLength,
            decoration: InputDecoration(
              labelText: 'broadcast.subject'.tr(),
              prefixIcon: const Icon(Icons.title),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              counterText: '${_titleController.text.length}/$_maxSubjectLength',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          
          // Message with character counter
          TextFormField(
            controller: _msgController,
            maxLines: 4,
            maxLength: _maxMessageLength,
            decoration: InputDecoration(
              labelText: 'broadcast.message'.tr(),
              alignLabelWithHint: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              counterText: '${_msgController.text.length}/$_maxMessageLength',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          
          Text('broadcast.scope'.tr(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTargetChip('broadcast.all_properties'.tr(), 'all', Icons.public),
              const SizedBox(width: 12),
              _buildTargetChip('broadcast.specific_property'.tr(), 'property', Icons.apartment),
            ],
          ),

          if (_mainTarget == 'property') ...[
            const SizedBox(height: 16),
            housesAsync.when(
              data: (houses) => DropdownButtonFormField<String>(
                initialValue: _selectedHouseId,
                decoration: InputDecoration(
                  labelText: 'broadcast.select_property'.tr(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                items: houses.map((h) => DropdownMenuItem(value: h.id, child: Text(h.name))).toList(),
                onChanged: (val) => setState(() {
                  _selectedHouseId = val;
                  _selectedUnitId = null;
                }),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e,__) => Text('Error: $e'),
            ),
          ],

          if (_mainTarget == 'property' && _selectedHouseId != null) ...[
            const SizedBox(height: 24),
            Text('broadcast.refine_target'.tr(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildScopeChip('broadcast.entire_building'.tr(), 'building', Icons.home_work),
                const SizedBox(width: 12),
                _buildScopeChip('broadcast.specific_flat'.tr(), 'flat', Icons.door_front_door),
              ],
            ),

            if (_propertyScope == 'flat') ...[
               const SizedBox(height: 16),
               unitsAsync.when(
                 data: (units) {
                   return tenanciesAsync.when(
                     data: (tenancies) {
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedUnitId,
                          decoration: InputDecoration(
                            labelText: 'broadcast.select_flat'.tr(),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          items: units.map((u) {
                            final activeTenancy = tenancies.where(
                              (t) => t.unitId == u.id && t.status.name == 'active',
                            ).firstOrNull;
                            final tenantName = activeTenancy == null ? 'Vacant' : 'Occupied';
                            return DropdownMenuItem(
                              value: u.id, 
                              child: Text('${u.nameOrNumber} ($tenantName)')
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedUnitId = val),
                        );
                     },
                     loading: () => const LinearProgressIndicator(),
                     error: (e,__) => Text('Error: $e'),
                   );
                 },
                 loading: () => const LinearProgressIndicator(),
                 error: (e,__) => Text('Error: $e'),
              ),
            ],
          ],

          const SizedBox(height: 24),
          Text('broadcast.priority'.tr(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPriorityChip('Low', 'low', Colors.green),
              const SizedBox(width: 8),
              _buildPriorityChip('Medium', 'medium', Colors.orange),
              const SizedBox(width: 8),
              _buildPriorityChip('High', 'high', Colors.red),
            ],
          ),

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: Text('broadcast.send'.tr()),
              onPressed: _isLoading ? null : _onSave,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetChip(String label, String value, IconData icon) {
    final isSelected = _mainTarget == value;
    return Expanded(
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) => setState(() {
          _mainTarget = value;
          if (value == 'all') _selectedHouseId = null;
        }),
        avatar: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildScopeChip(String label, String value, IconData icon) {
    final isSelected = _propertyScope == value;
    return Expanded(
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) => setState(() {
          _propertyScope = value;
          if (value == 'building') _selectedUnitId = null;
        }),
        avatar: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildPriorityChip(String label, String value, Color color) {
    final isSelected = _selectedPriority == value;
    return Expanded(
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) => setState(() => _selectedPriority = value),
        selectedColor: color.withAlpha(50),
        checkmarkColor: color,
        labelStyle: TextStyle(color: isSelected ? color : null),
      ),
    );
  }

  Widget _buildHistoryView() {
    final user = ref.read(data_providers.userSessionServiceProvider).currentUser;
    if (user == null) return Center(child: Text('common.please_login'.tr()));

    final noticesAsync = ref.watch(data_providers.allOwnerNoticesProvider(user.uid));
    final tenantsAsync = ref.watch(tenantControllerProvider);

    return noticesAsync.when(
      data: (notices) {
        if (notices.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.campaign_outlined, size: 80, color: Colors.grey.withAlpha(100)),
                const SizedBox(height: 16),
                Text('broadcast.no_history'.tr(), style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 8),
                Text('broadcast.no_history_hint'.tr(), style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.withAlpha(150))),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: notices.length,
          itemBuilder: (ctx, idx) {
            final notice = notices[idx];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                title: Text(notice.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormat('dd MMM, yyyy').format(notice.date)),
                trailing: _buildPriorityLevel(notice.priority),
                onTap: () => _showReadStatus(notice, tenantsAsync.valueOrNull ?? []),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e,__) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildPriorityLevel(String priority) {
    Color color = Colors.green;
    if (priority == 'high') color = Colors.red;
    if (priority == 'medium') color = Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withAlpha(50), borderRadius: BorderRadius.circular(12)),
      child: Text(priority.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _showReadStatus(Notice notice, List<Tenant> allTenants) {
    // Create tenant lookup map
    final tenantMap = <String, Tenant>{};
    for (final t in allTenants) {
      tenantMap[t.id] = t;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: 400,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.visibility, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text('broadcast.read_status'.tr(), style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${notice.readBy.length} ${notice.readBy.length == 1 ? 'tenant' : 'tenants'} read this notice',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: notice.readAt.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.visibility_off, size: 48, color: Colors.grey.withAlpha(100)),
                        const SizedBox(height: 12),
                        Text('broadcast.not_read'.tr(), style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  )
                : ListView(
                    children: notice.readAt.entries.map((e) {
                      final tenant = tenantMap[e.key];
                      final tenantName = tenant?.name ?? 'Unknown Tenant';
                      final readTime = DateFormat('dd MMM yyyy, hh:mm a').format(e.value);
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(30),
                          child: Text(
                            tenantName.isNotEmpty ? tenantName[0].toUpperCase() : '?',
                            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(tenantName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('Read: $readTime'),
                      );
                    }).toList(),
                  ),
            )
          ],
        ),
      ),
    );
  }
}
