import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'owner_controller.dart';
import '../../../../core/utils/snackbar_utils.dart'; // Assuming this exists from Phase 2
import '../../../../core/utils/currency_utils.dart';

class CurrencySettingsScreen extends ConsumerStatefulWidget {
  const CurrencySettingsScreen({super.key});

  @override
  ConsumerState<CurrencySettingsScreen> createState() => _CurrencySettingsScreenState();
}

class _CurrencySettingsScreenState extends ConsumerState<CurrencySettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ownerAsync = ref.watch(ownerControllerProvider);
    final currentCurrency = ownerAsync.value?.currency ?? 'INR';
    final currencies = CurrencyUtils.currencies;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Currency', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: ownerAsync.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final currency = currencies[index];
                final code = currency['code']!;
                final isSelected = code == currentCurrency;
                
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
                      // Update Profile
                      final owner = ownerAsync.value;
                      if (owner != null) {
                         await ref.read(ownerControllerProvider.notifier).updateProfile(
                           name: owner.name,
                           email: owner.email ?? '',
                           phone: owner.phone ?? '',
                           currency: code,
                         );
                         if (mounted) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Currency updated to ${currency['name']}'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              )
                            );
                         }
                      }
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: theme.dividerColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Text(currency['symbol']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.textTheme.bodyLarge?.color)),
                    ),
                    title: Text(currency['name']!, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
                    subtitle: Text(code, style: GoogleFonts.outfit(color: theme.hintColor)),
                    trailing: isSelected ? Icon(Icons.check_circle, color: theme.colorScheme.primary) : null,
                  ),
                );
              },
            ),
    );
  }
}
