import 'package:drift/drift.dart';
import 'tables.dart';
import 'connection/connection.dart' if (dart.library.io) 'connection/native.dart' if (dart.library.html) 'connection/web.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Owners,
  Houses,
  Units,
  Tenants,
  RentCycles,
  Payments,
  Expenses,
  ElectricReadings,
  PaymentChannels, // NEW
  OtherCharges, // NEW
  BhkTemplates,
  Tenancies // ADDED
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (Migrator m, int from, int to) async {
       if (from < 2) {
         await m.addColumn(tenants, tenants.password);
       }
       if (from < 3) {
         await m.addColumn(expenses, expenses.receiptPath);
       }
       if (from < 4) {
         // Migration for version 4 (Multiple missing columns)
         await m.addColumn(owners, owners.upiId);
         await m.addColumn(houses, houses.imageUrl);
         await m.addColumn(houses, houses.imageBase64);
         await m.addColumn(houses, houses.unitCount);
         await m.addColumn(units, units.imageUrls);
         await m.addColumn(units, units.imagesBase64);
         await m.addColumn(tenants, tenants.imageUrl);
         await m.addColumn(tenants, tenants.imageBase64);
         await m.addColumn(tenants, tenants.authId);
         await m.addColumn(tenants, tenants.advanceAmount);
         await m.addColumn(tenants, tenants.policeVerification);
         await m.addColumn(tenants, tenants.idProof);
         await m.addColumn(tenants, tenants.address);
         await m.addColumn(tenants, tenants.memberCount);
         await m.addColumn(tenants, tenants.notes);
         await m.addColumn(tenants, tenants.documents); // NEW
         
         
         // Create Tenancies table if not exists (it was missing from previous builds)
         await m.createTable(tenancies);
       }
       if (from < 5) {
         await m.addColumn(houses, houses.propertyType);
       }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    }
  );

  Future<void> clearAllData(String uid) async {
    await (delete(owners)..where((tbl) => tbl.id.equals(uid))).go();
  }
}
