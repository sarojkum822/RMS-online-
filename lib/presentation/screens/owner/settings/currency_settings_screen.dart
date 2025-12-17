import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CurrencySettingsScreen extends StatefulWidget {
  const CurrencySettingsScreen({super.key});

  @override
  State<CurrencySettingsScreen> createState() => _CurrencySettingsScreenState();
}

class _CurrencySettingsScreenState extends State<CurrencySettingsScreen> {
  String _selectedCurrency = 'INR';

  final List<Map<String, String>> _currencies = [
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Currency', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _currencies.length,
        itemBuilder: (context, index) {
          final currency = _currencies[index];
          final isSelected = currency['code'] == _selectedCurrency;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: theme.colorScheme.primary, width: 2) : Border.all(color: theme.dividerColor),
            ),
            child: ListTile(
              onTap: () {
                setState(() => _selectedCurrency = currency['code']!);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Currency changed to ${currency['name']}')));
              },
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: theme.dividerColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Text(currency['symbol']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.textTheme.bodyLarge?.color)),
              ),
              title: Text(currency['name']!, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
              subtitle: Text(currency['code']!, style: GoogleFonts.outfit(color: theme.hintColor)),
              trailing: isSelected ? Icon(Icons.check_circle, color: theme.colorScheme.primary) : null,
            ),
          );
        },
      ),
    );
  }
}
