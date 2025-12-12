import 'package:drift/drift.dart';

// Mixin for Sync
mixin SyncableTable on Table {
  TextColumn get firestoreId => text().nullable().unique()();
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

class Owners extends Table with SyncableTable {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('INR'))();
  TextColumn get timezone => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Houses extends Table with SyncableTable {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ownerId => integer().references(Owners, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get address => text()();
  TextColumn get notes => text().nullable()();
}

class Units extends Table with SyncableTable {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get houseId => integer().references(Houses, #id, onDelete: KeyAction.cascade)();
  TextColumn get nameOrNumber => text()(); 
  IntColumn get floor => integer().nullable()();
  RealColumn get baseRent => real()();
  IntColumn get defaultDueDay => integer().withDefault(const Constant(1))();
}

class Tenants extends Table with SyncableTable {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get houseId => integer().references(Houses, #id)();
  IntColumn get unitId => integer().references(Units, #id)();
  TextColumn get tenantCode => text().unique()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get email => text().nullable()();
  DateTimeColumn get startDate => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  RealColumn get openingBalance => real().withDefault(const Constant(0.0))();
  RealColumn get agreedRent => real().nullable()(); // NEW: Custom Rent override
  TextColumn get password => text().nullable()(); // For Tenant Login
}

// Updated RentCycles Table
class RentCycles extends Table with SyncableTable {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tenantId => integer().references(Tenants, #id, onDelete: KeyAction.cascade)();
  TextColumn get month => text()(); // YYYY-MM
  TextColumn get billNumber => text().nullable()(); // NEW
  DateTimeColumn get billPeriodStart => dateTime().nullable()(); // NEW
  DateTimeColumn get billPeriodEnd => dateTime().nullable()(); // NEW
  DateTimeColumn get billGeneratedDate => dateTime().withDefault(currentDateAndTime)(); // NEW
  DateTimeColumn get dueDate => dateTime().nullable()();
  
  RealColumn get baseRent => real()();
  RealColumn get electricAmount => real().withDefault(const Constant(0.0))();
  RealColumn get otherCharges => real().withDefault(const Constant(0.0))();
  RealColumn get discount => real().withDefault(const Constant(0.0))();
  RealColumn get totalDue => real()();
  RealColumn get totalPaid => real().withDefault(const Constant(0.0))();
  
  // Changing status to Int for Enum mapping
  IntColumn get status => integer()
      .withDefault(const Constant(0))(); // 0 = pending
  TextColumn get notes => text().nullable()();
}

// Updated Payments Table
class Payments extends Table with SyncableTable {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rentCycleId => integer().references(RentCycles, #id, onDelete: KeyAction.cascade)();
  IntColumn get tenantId => integer().references(Tenants, #id, onDelete: KeyAction.cascade)();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get method => text()(); // 'Cash', 'UPI', 'Bank', 'Cheque', 'Card'
  IntColumn get channelId => integer().nullable().references(PaymentChannels, #id)(); // NEW
  TextColumn get referenceId => text().nullable()(); // NEW (UPI Ref, Cheque No)
  TextColumn get collectedBy => text().nullable()(); // NEW
  TextColumn get notes => text().nullable()(); // NEW
}

// NEW Table
class PaymentChannels extends Table with SyncableTable {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); // e.g. 'PhonePe Personal'
  TextColumn get type => text()(); // 'UPI', 'BANK', 'CASH_COUNTER'
  TextColumn get details => text().nullable()(); // 'upi@id', 'Acc No'
}

// NEW Table
class OtherCharges extends Table with SyncableTable {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rentCycleId => integer().references(RentCycles, #id, onDelete: KeyAction.cascade)();
  RealColumn get amount => real()();
  TextColumn get category => text()(); // 'Maintenance', 'Parking'
  TextColumn get notes => text().nullable()();
}

class Expenses extends Table with SyncableTable {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ownerId => integer().references(Owners, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()(); // NEW
  DateTimeColumn get date => dateTime()();
  RealColumn get amount => real()();
  TextColumn get category => text()();
  TextColumn get description => text().nullable()();
}

// Updated ElectricReadings Table
class ElectricReadings extends Table with SyncableTable {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get unitId => integer().references(Units, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get readingDate => dateTime()();
  TextColumn get meterName => text().nullable()(); // NEW
  RealColumn get prevReading => real().withDefault(const Constant(0.0))(); // NEW
  RealColumn get currentReading => real()();
  RealColumn get ratePerUnit => real().withDefault(const Constant(0.0))(); // NEW
  RealColumn get amount => real()();
  TextColumn get imagePath => text().nullable()(); // NEW: Path to screenshot/image
  TextColumn get notes => text().nullable()(); // NEW
}
