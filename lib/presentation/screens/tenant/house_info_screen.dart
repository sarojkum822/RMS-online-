import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kirayabook/presentation/providers/data_providers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/tenant.dart';
import '../../../domain/entities/house.dart';

class HouseInfoScreen extends ConsumerWidget {
  final Tenant tenant;
  final House house;
  final Unit unit;

  const HouseInfoScreen({
    super.key,
    required this.tenant,
    required this.house,
    required this.unit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('tenant.property_info'.tr(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // House Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.home_work_rounded, color: theme.colorScheme.primary, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(house.name, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    house.address,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(color: theme.textTheme.bodySmall?.color),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${'tenant.unit'.tr()}: ${unit.nameOrNumber}',
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Emergency Contacts
            Text('tenant.emergency_contacts'.tr(), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildContactGrid(context, ref),

            const SizedBox(height: 32),

            // House Rules
            Text('tenant.house_rules'.tr(), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildRulesList(theme),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContactGrid(BuildContext context, WidgetRef ref) {
    final ownerAsync = ref.watch(ownerByIdProvider(tenant.ownerId));
    final owner = ownerAsync.valueOrNull;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _buildContactCard(
          context, 
          'tenant.landlord'.tr(), 
          owner?.name ?? 'common.loading'.tr(), 
          Icons.person_outline,
          onTap: owner?.phone != null ? () => _makeCall(owner!.phone!) : null,
        ),
        _buildContactCard(context, 'tenant.electrician'.tr(), 'Nearby', Icons.electric_bolt_outlined),
        _buildContactCard(context, 'tenant.plumber'.tr(), 'Nearby', Icons.water_drop_outlined),
        _buildContactCard(context, 'tenant.security'.tr(), 'Main Gate', Icons.admin_panel_settings_outlined),
      ],
    );
  }

  Widget _buildContactCard(BuildContext context, String label, String value, IconData icon, {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap ?? () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Calling $label...')));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(value, style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRulesList(ThemeData theme) {
    final rules = [
      'tenant.rule_1'.tr(),
      'tenant.rule_2'.tr(),
      'tenant.rule_3'.tr(),
      'tenant.rule_4'.tr(),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: rules.map((rule) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline_rounded, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(rule, style: GoogleFonts.outfit(height: 1.4))),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
