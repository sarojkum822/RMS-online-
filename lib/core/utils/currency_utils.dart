import 'package:intl/intl.dart';

class CurrencyUtils {
  static String formatNumber(num value) {
    final formatter = NumberFormat.decimalPattern();
    return formatter.format(value);
  }
  static const List<Map<String, String>> currencies = [
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
    {'code': 'CAD', 'symbol': 'C\$', 'name': 'Canadian Dollar'},
    {'code': 'AED', 'symbol': 'AED', 'name': 'UAE Dirham'},
    {'code': 'SAR', 'symbol': 'SAR', 'name': 'Saudi Riyal'},
  ];

  static String getSymbol(String? code) {
    if (code == null) return '₹';
    final currency = currencies.firstWhere(
      (c) => c['code'] == code,
      orElse: () => {'symbol': code}, // Fallback to code if not found
    );
    return currency['symbol']!;
  }
}
