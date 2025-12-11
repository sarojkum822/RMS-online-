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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Currency', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
            ),
            child: ListTile(
              onTap: () {
                setState(() => _selectedCurrency = currency['code']!);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Currency changed to ${currency['name']}')));
              },
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                child: Text(currency['symbol']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              title: Text(currency['name']!, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              subtitle: Text(currency['code']!, style: GoogleFonts.outfit(color: Colors.grey)),
              trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.black) : null,
            ),
          );
        },
      ),
    );
  }
}
