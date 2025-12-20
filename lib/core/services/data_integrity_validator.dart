class DataIntegrityValidator {
  
  /// Validates the backup data structure and relationships.
  /// Returns a list of error messages. Empty list means valid.
  static List<String> validate(Map<String, dynamic> backup) {
    final errors = <String>[];
    
    // 1. Basic Schema Check
    if (!backup.containsKey('metadata') || !backup.containsKey('data')) {
      errors.add('Invalid Backup Format: Missing metadata or data section.');
      return errors; // Critical failure, cannot proceed
    }
    
    final data = backup['data'] as Map<String, dynamic>;
    final houses = (data['houses'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final units = (data['units'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final tenants = (data['tenants'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final contracts = (data['contracts'] as List?)?.cast<Map<String, dynamic>>() ?? []; // NEW
    final rentCycles = (data['rentCycles'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final payments = (data['payments'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    // 2. Foreign Key Integrity
    
    // Check Unit -> House
    final houseIds = houses.map((h) => h['id']).toSet();
    for (final unit in units) {
      if (!houseIds.contains(unit['houseId'])) {
        errors.add('Integrity Error: Unit ${unit['title']} points to missing House ID ${unit['houseId']}');
      }
    }
    
    // Check Contract -> Unit & Tenant
    final unitIds = units.map((u) => u['id']).toSet();
    final tenantIds = tenants.map((t) => t['id']).toSet();
    
    for (final contract in contracts) {
       if (!unitIds.contains(contract['unitId'])) {
         errors.add('Integrity Error: Contract ${contract['id']} points to missing Unit ID ${contract['unitId']}');
       }
       if (!tenantIds.contains(contract['tenantId'])) {
         errors.add('Integrity Error: Contract ${contract['id']} points to missing Tenant ID ${contract['tenantId']}');
       }
    }
    
    // Check RentCycle -> Contract (Tenancy)
    final contractIds = contracts.map((c) => c['id']).toSet();
    for (final cycle in rentCycles) {
      if (!contractIds.contains(cycle['tenancyId'])) {
        // Fallback: Check tenantId if tenancyId is missing (Legacy)
        if (cycle['tenancyId'] == null && !tenantIds.contains(cycle['tenantId'])) {
           errors.add('Integrity Error: RentCycle ${cycle['id']} has no valid Tenancy or Tenant link.');
        } else if (cycle['tenancyId'] != null) {
           errors.add('Integrity Error: RentCycle ${cycle['id']} points to missing Contract ID ${cycle['tenancyId']}');
        }
      }
    }

    // Check Payment -> RentCycle (Optional, as payment can exist without cycle theoretically but usually linked)
    // Actually payment has rentCycleId.
    final rentCycleIds = rentCycles.map((r) => r['id']).toSet();
    for (final payment in payments) {
      if (payment['rentCycleId'] != null && payment['rentCycleId'] != 0) { // Assuming 0 is null/adhoc
          if (!rentCycleIds.contains(payment['rentCycleId'])) {
             errors.add('Integrity Error: Payment ${payment['id']} points to missing RentCycle ID ${payment['rentCycleId']}');
          }
      }
    }

    return errors;
  }
}
