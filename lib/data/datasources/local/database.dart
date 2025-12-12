import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

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
  OtherCharges // NEW
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

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

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'rentpilotpro.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
