import 'package:intl/intl.dart';

class CurrencyUtils {
  static String formatNumber(num value) {
    final formatter = NumberFormat.decimalPattern();
    return formatter.format(value);
  }
  
  /// Format number in compact form (e.g., 45000 → 45K, 100000 → 1L)
  static String formatCompact(num value) {
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(1)}Cr';
    } else if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
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
