import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class WhatsappHelper {
  static Future<void> sendReminder(String phone, String tenantName, double amount, String month) async {
    // 1. Format Phone
    String formattedPhone = phone.replaceAll(RegExp(r'\D'), ''); // Remove non-digits
    if (!formattedPhone.startsWith('91') && formattedPhone.length == 10) {
      formattedPhone = '91$formattedPhone'; // Assume India if not specified
    }

    // 2. Create Message
    final message = "Hello $tenantName, this is a gentle reminder that your rent of ₹$amount for $month is pending. Please pay at your earliest convenience. Thank you!";
    
    // 3. Launch URL
    final Uri url;
    if (Platform.isAndroid) {
        // Android often works better with specific intent or query params
        url = Uri.parse("whatsapp://send?phone=$formattedPhone&text=${Uri.encodeComponent(message)}");
    } else {
        // iOS / Web
        url = Uri.parse("https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}");
    }

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        // Fallback to web link if app not installed
        final webUrl = Uri.parse("https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}");
        if (await canLaunchUrl(webUrl)) await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Could not launch WhatsApp: $e');
    }
  }
}
