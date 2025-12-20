import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'owner_controller.dart';
import '../../../../core/utils/snackbar_utils.dart';

class TimezoneSettingsScreen extends ConsumerStatefulWidget {
  const TimezoneSettingsScreen({super.key});

  @override
  ConsumerState<TimezoneSettingsScreen> createState() => _TimezoneSettingsScreenState();
}

class _TimezoneSettingsScreenState extends ConsumerState<TimezoneSettingsScreen> {
  // Common Timezones
  final List<Map<String, String>> _timezones = [
    {'code': 'UTC', 'name': 'Coordinated Universal Time (UTC)'},
    {'code': 'Asia/Kolkata', 'name': 'India Standard Time (IST)'},
    {'code': 'America/New_York', 'name': 'Eastern Standard Time (EST)'},
    {'code': 'America/Los_Angeles', 'name': 'Pacific Standard Time (PST)'},
    {'code': 'Europe/London', 'name': 'Greenwich Mean Time (GMT)'},
    {'code': 'Europe/Paris', 'name': 'Central European Time (CET)'},
    {'code': 'Asia/Dubai', 'name': 'Gulf Standard Time (GST)'},
    {'code': 'Asia/Tokyo', 'name': 'Japan Standard Time (JST)'},
    {'code': 'Australia/Sydney', 'name': 'Australian Eastern Time (AEST)'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ownerAsync = ref.watch(ownerControllerProvider);
    final currentTimezone = ownerAsync.value?.timezone ?? 'UTC'; // Default to UTC if null

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Timezone', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: ownerAsync.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _timezones.length,
              itemBuilder: (context, index) {
                final tz = _timezones[index];
                final code = tz['code']!;
                final isSelected = code == currentTimezone;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? Border.all(color: theme.colorScheme.primary, width: 2) : Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                  ),
                  child: ListTile(
                    onTap: () async {
                      if (isSelected) return;
                      final owner = ownerAsync.value;
                      if (owner != null) {
                         await ref.read(ownerControllerProvider.notifier).updateProfile(
                           name: owner.name,
                           email: owner.email ?? '',
                           phone: owner.phone ?? '',
                           timezone: code,
                         );
                         if (mounted) {
                            SnackbarUtils.showSuccess(context, 'Timezone updated to ${tz['name']}');
                         }
                      }
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: theme.dividerColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(Icons.public, color: theme.colorScheme.primary),
                    ),
                    title: Text(tz['name']!, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
                    subtitle: Text(code, style: GoogleFonts.outfit(color: theme.hintColor)),
                    trailing: isSelected ? Icon(Icons.check_circle, color: theme.colorScheme.primary) : null,
                  ),
                );
              },
            ),
    );
  }
}
