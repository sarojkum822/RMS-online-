import 'package:drift/drift.dart';

// Mixin for Sync
mixin SyncableTable on Table {
  TextColumn get firestoreId => text().nullable().unique()();
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

class Owners extends Table with SyncableTable {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get subscriptionPlan => text().withDefault(const Constant('free'))();
  TextColumn get currency => text().withDefault(const Constant('INR'))();
  TextColumn get timezone => text().nullable()();
  TextColumn get upiId => text().nullable()(); // ADDED
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Houses extends Table with SyncableTable {
  TextColumn get id => text()(); // UUID
  TextColumn get ownerId => text().references(Owners, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get address => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get imageUrl => text().nullable()(); // ADDED
  TextColumn get imageBase64 => text().nullable()(); // ADDED
  TextColumn get propertyType => text().withDefault(const Constant('Apartment'))(); // ADDED
  IntColumn get unitCount => integer().withDefault(const Constant(0))(); // ADDED
  
  @override
  Set<Column> get primaryKey => {id};
}

class BhkTemplates extends Table with SyncableTable {
  TextColumn get id => text()(); // UUID
  TextColumn get houseId => text().references(Houses, #id, onDelete: KeyAction.cascade)();
  TextColumn get bhkType => text()(); // "1BHK", "Studio"
  RealColumn get defaultRent => real()();
  TextColumn get description => text().nullable()();
  IntColumn get roomCount => integer().withDefault(const Constant(1))();
  IntColumn get kitchenCount => integer().withDefault(const Constant(1))();
  IntColumn get hallCount => integer().withDefault(const Constant(1))();
  BoolColumn get hasBalcony => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Units extends Table with SyncableTable {
  TextColumn get id => text()(); // UUID
  TextColumn get houseId => text().references(Houses, #id, onDelete: KeyAction.cascade)();
  TextColumn get ownerId => text().references(Owners, #id, onDelete: KeyAction.cascade)(); // Security
  TextColumn get nameOrNumber => text()(); 
  IntColumn get floor => integer().nullable()();
  
  // BHK Relations
  TextColumn get bhkTemplateId => text().nullable().references(BhkTemplates, #id)(); 
  TextColumn get bhkType => text().nullable()(); // Denormalized for display
  
  // Rents
  RealColumn get baseRent => real()(); // Copied from Template
  RealColumn get editableRent => real().nullable()(); // Tenant specific override

  // Advanced Details
  TextColumn get furnishingStatus => text().nullable()(); // 'Unfurnished', 'Semi', 'Fully'
  RealColumn get carpetArea => real().nullable()(); // Sq Ft
  TextColumn get parkingSlot => text().nullable()(); 
  TextColumn get meterNumber => text().nullable()();

  IntColumn get defaultDueDay => integer().withDefault(const Constant(1))();
  BoolColumn get isOccupied => boolean().withDefault(const Constant(false))();
  
  // NEW: Image storage (using comma separated strings or JSON if needed, but for simplicity text)
  TextColumn get imageUrls => text().nullable()(); // ADDED
  TextColumn get imagesBase64 => text().nullable()(); // ADDED
  
  // Current Tenant Association (Optional optimization)
  TextColumn get currentTenancyId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Tenants extends Table with SyncableTable {
  TextColumn get id => text()(); // UUID
  TextColumn get ownerId => text().references(Owners, #id, onDelete: KeyAction.cascade)(); // Security
  TextColumn get tenantCode => text().unique()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get email => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get password => text().nullable()(); // For Tenant Login
  TextColumn get imageUrl => text().nullable()(); // ADDED
  TextColumn get imageBase64 => text().nullable()(); // ADDED
  TextColumn get authId => text().nullable()(); // ADDED
  RealColumn get advanceAmount => real().withDefault(const Constant(0.0))(); // ADDED
  BoolColumn get policeVerification => boolean().withDefault(const Constant(false))(); // ADDED
  TextColumn get idProof => text().nullable()(); // ADDED
  TextColumn get address => text().nullable()(); // ADDED
  IntColumn get memberCount => integer().withDefault(const Constant(1))(); // ADDED
  TextColumn get notes => text().nullable()(); // ADDED
  TextColumn get documents => text().nullable()(); // ADDED (JSON)

  @override
  Set<Column> get primaryKey => {id};
}

// NEW: Tenancies Table
class Tenancies extends Table with SyncableTable {
  TextColumn get id => text()(); // UUID
  TextColumn get tenantId => text().references(Tenants, #id, onDelete: KeyAction.cascade)();
  TextColumn get unitId => text().references(Units, #id, onDelete: KeyAction.cascade)();
  TextColumn get ownerId => text().references(Owners, #id, onDelete: KeyAction.cascade)();
  
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  
  RealColumn get agreedRent => real()();
  RealColumn get securityDeposit => real().withDefault(const Constant(0.0))();
  RealColumn get openingBalance => real().withDefault(const Constant(0.0))();
  
  IntColumn get status => integer().withDefault(const Constant(0))(); // 0=Active, 1=Ended
  TextColumn get notes => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// Updated RentCycles Table
class RentCycles extends Table with SyncableTable {
  TextColumn get id => text()(); // UUID
  TextColumn get tenancyId => text().references(Tenancies, #id, onDelete: KeyAction.cascade)();
  TextColumn get ownerId => text().references(Owners, #id, onDelete: KeyAction.cascade)();

  TextColumn get month => text()(); // YYYY-MM
  TextColumn get billNumber => text().nullable()(); 
  DateTimeColumn get billPeriodStart => dateTime().nullable()(); 
  DateTimeColumn get billPeriodEnd => dateTime().nullable()(); 
  DateTimeColumn get billGeneratedDate => dateTime().withDefault(currentDateAndTime)(); 
  DateTimeColumn get dueDate => dateTime().nullable()();
  
  RealColumn get baseRent => real()();
  RealColumn get electricAmount => real().withDefault(const Constant(0.0))();
  RealColumn get otherCharges => real().withDefault(const Constant(0.0))();
  RealColumn get discount => real().withDefault(const Constant(0.0))();
  RealColumn get totalDue => real()();
  RealColumn get totalPaid => real().withDefault(const Constant(0.0))();
  
  IntColumn get status => integer()
      .withDefault(const Constant(0))(); // 0 = pending
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Updated Payments Table
class Payments extends Table with SyncableTable {
  TextColumn get id => text()(); // UUID
  TextColumn get rentCycleId => text().references(RentCycles, #id, onDelete: KeyAction.cascade)();
  TextColumn get ownerId => text().references(Owners, #id, onDelete: KeyAction.cascade)();
  
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get method => text()(); // 'Cash', 'UPI', 'Bank', 'Cheque', 'Card'
  IntColumn get channelId => integer().nullable().references(PaymentChannels, #id)(); // Legacy INT
  TextColumn get referenceId => text().nullable()(); 
  TextColumn get collectedBy => text().nullable()(); 
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// PaymentChannels (Keep ID as Int for simplicity or upgrade?)
// Let's keep Int for static lookup tables unless necessary
class PaymentChannels extends Table with SyncableTable {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); 
  TextColumn get type => text()(); 
  TextColumn get details => text().nullable()(); 
}

class OtherCharges extends Table with SyncableTable {
  TextColumn get id => text()(); // UUID
  TextColumn get rentCycleId => text().references(RentCycles, #id, onDelete: KeyAction.cascade)();
  RealColumn get amount => real()();
  TextColumn get category => text()(); 
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Expenses extends Table with SyncableTable {
  TextColumn get id => text()(); // UUID
  TextColumn get ownerId => text().references(Owners, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()(); 
  DateTimeColumn get date => dateTime()();
  RealColumn get amount => real()();
  TextColumn get category => text()();
  TextColumn get description => text().nullable()();
  TextColumn get receiptPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Updated ElectricReadings Table
class ElectricReadings extends Table with SyncableTable {
  TextColumn get id => text()(); // UUID
  TextColumn get unitId => text().references(Units, #id, onDelete: KeyAction.cascade)();
  TextColumn get ownerId => text().references(Owners, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get readingDate => dateTime()();
  TextColumn get meterName => text().nullable()(); 
  RealColumn get prevReading => real().withDefault(const Constant(0.0))(); 
  RealColumn get currentReading => real()();
  RealColumn get ratePerUnit => real().withDefault(const Constant(0.0))(); 
  RealColumn get amount => real()();
  TextColumn get imagePath => text().nullable()(); 
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
