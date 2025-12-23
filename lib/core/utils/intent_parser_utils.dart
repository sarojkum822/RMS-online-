import 'package:intl/intl.dart';

enum KirayaIntent {
  addTenant,
  addProperty,
  checkPendingRent,
  getRevenue,
  getOccupancy,
  openVault,
  showReports,
  unknown,
}

class VoiceAction {
  final KirayaIntent intent;
  final Map<String, dynamic> entities;

  VoiceAction({required this.intent, this.entities = const {}});
}

class IntentParserUtils {
  static VoiceAction parse(String text) {
    final lowerText = text.toLowerCase();

    // 1. Add Tenant Intent
    if (lowerText.contains('add tenant') || lowerText.contains('new tenant') || lowerText.contains('register tenant')) {
      final entities = <String, dynamic>{};
      
      // Extract Name (Basic heuristic: after "named" or "name is")
      final nameReg = RegExp(r'(?:named|name is|tenant)\s+([a-zA-Z\s]+?)(?:\s+with|\s+rent|\s+starting|$)');
      final nameMatch = nameReg.firstMatch(lowerText);
      if (nameMatch != null) {
        entities['name'] = nameMatch.group(1)?.trim();
      }

      // Extract Rent Amount
      final rentReg = RegExp(r'(?:rent|amount)\s+(?:of\s+)?(?:rs\.?\s*|rupees\s*)?(\d+)');
      final rentMatch = rentReg.firstMatch(lowerText);
      if (rentMatch != null) {
        entities['rent'] = double.tryParse(rentMatch.group(1) ?? '');
      }

      return VoiceAction(intent: KirayaIntent.addTenant, entities: entities);
    }

    // 2. Add Property Intent
    if (lowerText.contains('add property') || lowerText.contains('new house') || lowerText.contains('add house')) {
      return VoiceAction(intent: KirayaIntent.addProperty);
    }

    // 3. Check Pending Rent Intent
    if (lowerText.contains('pending rent') || lowerText.contains('who hasn\'t paid') || lowerText.contains('unpaid rent')) {
      return VoiceAction(intent: KirayaIntent.checkPendingRent);
    }

    // 4. Get Revenue Intent
    if (lowerText.contains('how much earned') || lowerText.contains('total collection') || lowerText.contains('revenue')) {
      return VoiceAction(intent: KirayaIntent.getRevenue);
    }

    // 5. Get Occupancy Intent
    if (lowerText.contains('how many tenants') || lowerText.contains('occupancy') || lowerText.contains('filled rooms')) {
      return VoiceAction(intent: KirayaIntent.getOccupancy);
    }

    // 6. Open Vault Intent
    if (lowerText.contains('show reports') || lowerText.contains('view earnings') || lowerText.contains('how much earned')) {
      return VoiceAction(intent: KirayaIntent.showReports);
    }

    return VoiceAction(intent: KirayaIntent.unknown);
  }
}
