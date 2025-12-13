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
  BhkTemplates
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (Migrator m, int from, int to) async {
       if (from < 2) {
         await m.addColumn(tenants, tenants.password);
       }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    }
  );
}
