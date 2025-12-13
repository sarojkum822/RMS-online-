import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/house.dart';
import '../../domain/entities/tenant.dart';
import 'data_providers.dart'; 

part 'seed_data_provider.g.dart';

@riverpod
Future<void> seedData(SeedDataRef ref) async {
  final houseRepo = ref.read(propertyRepositoryProvider);
  final tenantRepo = ref.read(tenantRepositoryProvider);
  
  // 1. Create House
  final houseId = await houseRepo.createHouse(const House(
    id: 0,
    name: 'Green Valley Apts',
    address: '123, Main Street',
    notes: 'Test Property',
  ));

  // 2. Create Unit
  final units = await houseRepo.getUnits(houseId);
  int unitId;
  if (units.isNotEmpty) {
     unitId = units.first.id;
  } else {
     // Create Unit
     unitId = await houseRepo.createUnit(Unit(
       id: 0, 
       houseId: houseId, 
       nameOrNumber: 'Flat 101', 
       baseRent: 15000, 
       defaultDueDay: 5
     )); 
  }
  
  // 3. Create Tenant
  await tenantRepo.createTenant(Tenant(
    id: 0,
    houseId: houseId,
    unitId: unitId,
    tenantCode: '9876543210',
    name: 'Rahul Sharma',
    phone: '9876543210',
    email: 'rahul@test.com',
    startDate: DateTime.now(),
    status: TenantStatus.active,
    agreedRent: 15500, // Custom Rent Example
    ownerId: 'SEED_DATA', // Placeholder ownerId
  ));
}
