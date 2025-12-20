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
    id: '0',
    ownerId: 'SEED_DATA',
    name: 'Green Valley Apts',
    address: '123, Main Street',
    notes: 'Test Property',
  ));

  // 2. Create Unit
  final units = await houseRepo.getUnits(houseId).first;
  if (units.isEmpty) {
     // Create Unit
     await houseRepo.createUnit(Unit(
       id: '0', 
       houseId: houseId, 
       ownerId: 'SEED_DATA',
       nameOrNumber: 'Flat 101', 
       baseRent: 15000, 
       defaultDueDay: 5
     )); 
  }
  
  // 3. Create Tenant
  await tenantRepo.createTenant(const Tenant(
    id: '0',
    tenantCode: '9876543210',
    name: 'Rahul Sharma',
    phone: '9876543210',
    email: 'rahul@test.com',
    ownerId: 'SEED_DATA', // Placeholder ownerId
  ));
}
