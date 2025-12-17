// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $OwnersTable extends Owners with TableInfo<$OwnersTable, Owner> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OwnersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _firestoreIdMeta =
      const VerificationMeta('firestoreId');
  @override
  late final GeneratedColumn<String> firestoreId = GeneratedColumn<String>(
      'firestore_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subscriptionPlanMeta =
      const VerificationMeta('subscriptionPlan');
  @override
  late final GeneratedColumn<String> subscriptionPlan = GeneratedColumn<String>(
      'subscription_plan', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('free'));
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('INR'));
  static const VerificationMeta _timezoneMeta =
      const VerificationMeta('timezone');
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
      'timezone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        firestoreId,
        lastUpdated,
        isSynced,
        isDeleted,
        id,
        name,
        phone,
        email,
        subscriptionPlan,
        currency,
        timezone,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'owners';
  @override
  VerificationContext validateIntegrity(Insertable<Owner> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('firestore_id')) {
      context.handle(
          _firestoreIdMeta,
          firestoreId.isAcceptableOrUnknown(
              data['firestore_id']!, _firestoreIdMeta));
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('subscription_plan')) {
      context.handle(
          _subscriptionPlanMeta,
          subscriptionPlan.isAcceptableOrUnknown(
              data['subscription_plan']!, _subscriptionPlanMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('timezone')) {
      context.handle(_timezoneMeta,
          timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Owner map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Owner(
      firestoreId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}firestore_id']),
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      subscriptionPlan: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}subscription_plan'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      timezone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timezone']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $OwnersTable createAlias(String alias) {
    return $OwnersTable(attachedDatabase, alias);
  }
}

class Owner extends DataClass implements Insertable<Owner> {
  final String? firestoreId;
  final DateTime lastUpdated;
  final bool isSynced;
  final bool isDeleted;
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String subscriptionPlan;
  final String currency;
  final String? timezone;
  final DateTime createdAt;
  const Owner(
      {this.firestoreId,
      required this.lastUpdated,
      required this.isSynced,
      required this.isDeleted,
      required this.id,
      required this.name,
      this.phone,
      this.email,
      required this.subscriptionPlan,
      required this.currency,
      this.timezone,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || firestoreId != null) {
      map['firestore_id'] = Variable<String>(firestoreId);
    }
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['subscription_plan'] = Variable<String>(subscriptionPlan);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || timezone != null) {
      map['timezone'] = Variable<String>(timezone);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OwnersCompanion toCompanion(bool nullToAbsent) {
    return OwnersCompanion(
      firestoreId: firestoreId == null && nullToAbsent
          ? const Value.absent()
          : Value(firestoreId),
      lastUpdated: Value(lastUpdated),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      id: Value(id),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      subscriptionPlan: Value(subscriptionPlan),
      currency: Value(currency),
      timezone: timezone == null && nullToAbsent
          ? const Value.absent()
          : Value(timezone),
      createdAt: Value(createdAt),
    );
  }

  factory Owner.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Owner(
      firestoreId: serializer.fromJson<String?>(json['firestoreId']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      subscriptionPlan: serializer.fromJson<String>(json['subscriptionPlan']),
      currency: serializer.fromJson<String>(json['currency']),
      timezone: serializer.fromJson<String?>(json['timezone']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'firestoreId': serializer.toJson<String?>(firestoreId),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'subscriptionPlan': serializer.toJson<String>(subscriptionPlan),
      'currency': serializer.toJson<String>(currency),
      'timezone': serializer.toJson<String?>(timezone),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Owner copyWith(
          {Value<String?> firestoreId = const Value.absent(),
          DateTime? lastUpdated,
          bool? isSynced,
          bool? isDeleted,
          String? id,
          String? name,
          Value<String?> phone = const Value.absent(),
          Value<String?> email = const Value.absent(),
          String? subscriptionPlan,
          String? currency,
          Value<String?> timezone = const Value.absent(),
          DateTime? createdAt}) =>
      Owner(
        firestoreId: firestoreId.present ? firestoreId.value : this.firestoreId,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        isSynced: isSynced ?? this.isSynced,
        isDeleted: isDeleted ?? this.isDeleted,
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        email: email.present ? email.value : this.email,
        subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
        currency: currency ?? this.currency,
        timezone: timezone.present ? timezone.value : this.timezone,
        createdAt: createdAt ?? this.createdAt,
      );
  Owner copyWithCompanion(OwnersCompanion data) {
    return Owner(
      firestoreId:
          data.firestoreId.present ? data.firestoreId.value : this.firestoreId,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      subscriptionPlan: data.subscriptionPlan.present
          ? data.subscriptionPlan.value
          : this.subscriptionPlan,
      currency: data.currency.present ? data.currency.value : this.currency,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Owner(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('subscriptionPlan: $subscriptionPlan, ')
          ..write('currency: $currency, ')
          ..write('timezone: $timezone, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(firestoreId, lastUpdated, isSynced, isDeleted,
      id, name, phone, email, subscriptionPlan, currency, timezone, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Owner &&
          other.firestoreId == this.firestoreId &&
          other.lastUpdated == this.lastUpdated &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.subscriptionPlan == this.subscriptionPlan &&
          other.currency == this.currency &&
          other.timezone == this.timezone &&
          other.createdAt == this.createdAt);
}

class OwnersCompanion extends UpdateCompanion<Owner> {
  final Value<String?> firestoreId;
  final Value<DateTime> lastUpdated;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String> subscriptionPlan;
  final Value<String> currency;
  final Value<String?> timezone;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const OwnersCompanion({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.subscriptionPlan = const Value.absent(),
    this.currency = const Value.absent(),
    this.timezone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OwnersCompanion.insert({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String id,
    required String name,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.subscriptionPlan = const Value.absent(),
    this.currency = const Value.absent(),
    this.timezone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Owner> custom({
    Expression<String>? firestoreId,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? subscriptionPlan,
    Expression<String>? currency,
    Expression<String>? timezone,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (firestoreId != null) 'firestore_id': firestoreId,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (subscriptionPlan != null) 'subscription_plan': subscriptionPlan,
      if (currency != null) 'currency': currency,
      if (timezone != null) 'timezone': timezone,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OwnersCompanion copyWith(
      {Value<String?>? firestoreId,
      Value<DateTime>? lastUpdated,
      Value<bool>? isSynced,
      Value<bool>? isDeleted,
      Value<String>? id,
      Value<String>? name,
      Value<String?>? phone,
      Value<String?>? email,
      Value<String>? subscriptionPlan,
      Value<String>? currency,
      Value<String?>? timezone,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return OwnersCompanion(
      firestoreId: firestoreId ?? this.firestoreId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (firestoreId.present) {
      map['firestore_id'] = Variable<String>(firestoreId.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (subscriptionPlan.present) {
      map['subscription_plan'] = Variable<String>(subscriptionPlan.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OwnersCompanion(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('subscriptionPlan: $subscriptionPlan, ')
          ..write('currency: $currency, ')
          ..write('timezone: $timezone, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HousesTable extends Houses with TableInfo<$HousesTable, House> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HousesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _firestoreIdMeta =
      const VerificationMeta('firestoreId');
  @override
  late final GeneratedColumn<String> firestoreId = GeneratedColumn<String>(
      'firestore_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES owners (id) ON DELETE CASCADE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        firestoreId,
        lastUpdated,
        isSynced,
        isDeleted,
        id,
        ownerId,
        name,
        address,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'houses';
  @override
  VerificationContext validateIntegrity(Insertable<House> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('firestore_id')) {
      context.handle(
          _firestoreIdMeta,
          firestoreId.isAcceptableOrUnknown(
              data['firestore_id']!, _firestoreIdMeta));
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  House map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return House(
      firestoreId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}firestore_id']),
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $HousesTable createAlias(String alias) {
    return $HousesTable(attachedDatabase, alias);
  }
}

class House extends DataClass implements Insertable<House> {
  final String? firestoreId;
  final DateTime lastUpdated;
  final bool isSynced;
  final bool isDeleted;
  final String id;
  final String ownerId;
  final String name;
  final String address;
  final String? notes;
  const House(
      {this.firestoreId,
      required this.lastUpdated,
      required this.isSynced,
      required this.isDeleted,
      required this.id,
      required this.ownerId,
      required this.name,
      required this.address,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || firestoreId != null) {
      map['firestore_id'] = Variable<String>(firestoreId);
    }
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['name'] = Variable<String>(name);
    map['address'] = Variable<String>(address);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  HousesCompanion toCompanion(bool nullToAbsent) {
    return HousesCompanion(
      firestoreId: firestoreId == null && nullToAbsent
          ? const Value.absent()
          : Value(firestoreId),
      lastUpdated: Value(lastUpdated),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      id: Value(id),
      ownerId: Value(ownerId),
      name: Value(name),
      address: Value(address),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory House.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return House(
      firestoreId: serializer.fromJson<String?>(json['firestoreId']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String>(json['address']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'firestoreId': serializer.toJson<String?>(firestoreId),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String>(address),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  House copyWith(
          {Value<String?> firestoreId = const Value.absent(),
          DateTime? lastUpdated,
          bool? isSynced,
          bool? isDeleted,
          String? id,
          String? ownerId,
          String? name,
          String? address,
          Value<String?> notes = const Value.absent()}) =>
      House(
        firestoreId: firestoreId.present ? firestoreId.value : this.firestoreId,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        isSynced: isSynced ?? this.isSynced,
        isDeleted: isDeleted ?? this.isDeleted,
        id: id ?? this.id,
        ownerId: ownerId ?? this.ownerId,
        name: name ?? this.name,
        address: address ?? this.address,
        notes: notes.present ? notes.value : this.notes,
      );
  House copyWithCompanion(HousesCompanion data) {
    return House(
      firestoreId:
          data.firestoreId.present ? data.firestoreId.value : this.firestoreId,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('House(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(firestoreId, lastUpdated, isSynced, isDeleted,
      id, ownerId, name, address, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is House &&
          other.firestoreId == this.firestoreId &&
          other.lastUpdated == this.lastUpdated &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.name == this.name &&
          other.address == this.address &&
          other.notes == this.notes);
}

class HousesCompanion extends UpdateCompanion<House> {
  final Value<String?> firestoreId;
  final Value<DateTime> lastUpdated;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> name;
  final Value<String> address;
  final Value<String?> notes;
  final Value<int> rowid;
  const HousesCompanion({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HousesCompanion.insert({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String id,
    required String ownerId,
    required String name,
    required String address,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        ownerId = Value(ownerId),
        name = Value(name),
        address = Value(address);
  static Insertable<House> custom({
    Expression<String>? firestoreId,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? name,
    Expression<String>? address,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (firestoreId != null) 'firestore_id': firestoreId,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HousesCompanion copyWith(
      {Value<String?>? firestoreId,
      Value<DateTime>? lastUpdated,
      Value<bool>? isSynced,
      Value<bool>? isDeleted,
      Value<String>? id,
      Value<String>? ownerId,
      Value<String>? name,
      Value<String>? address,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return HousesCompanion(
      firestoreId: firestoreId ?? this.firestoreId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (firestoreId.present) {
      map['firestore_id'] = Variable<String>(firestoreId.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HousesCompanion(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BhkTemplatesTable extends BhkTemplates
    with TableInfo<$BhkTemplatesTable, BhkTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BhkTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _firestoreIdMeta =
      const VerificationMeta('firestoreId');
  @override
  late final GeneratedColumn<String> firestoreId = GeneratedColumn<String>(
      'firestore_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _houseIdMeta =
      const VerificationMeta('houseId');
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
      'house_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES houses (id) ON DELETE CASCADE'));
  static const VerificationMeta _bhkTypeMeta =
      const VerificationMeta('bhkType');
  @override
  late final GeneratedColumn<String> bhkType = GeneratedColumn<String>(
      'bhk_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _defaultRentMeta =
      const VerificationMeta('defaultRent');
  @override
  late final GeneratedColumn<double> defaultRent = GeneratedColumn<double>(
      'default_rent', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _roomCountMeta =
      const VerificationMeta('roomCount');
  @override
  late final GeneratedColumn<int> roomCount = GeneratedColumn<int>(
      'room_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _kitchenCountMeta =
      const VerificationMeta('kitchenCount');
  @override
  late final GeneratedColumn<int> kitchenCount = GeneratedColumn<int>(
      'kitchen_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _hallCountMeta =
      const VerificationMeta('hallCount');
  @override
  late final GeneratedColumn<int> hallCount = GeneratedColumn<int>(
      'hall_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _hasBalconyMeta =
      const VerificationMeta('hasBalcony');
  @override
  late final GeneratedColumn<bool> hasBalcony = GeneratedColumn<bool>(
      'has_balcony', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("has_balcony" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        firestoreId,
        lastUpdated,
        isSynced,
        isDeleted,
        id,
        houseId,
        bhkType,
        defaultRent,
        description,
        roomCount,
        kitchenCount,
        hallCount,
        hasBalcony
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bhk_templates';
  @override
  VerificationContext validateIntegrity(Insertable<BhkTemplate> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('firestore_id')) {
      context.handle(
          _firestoreIdMeta,
          firestoreId.isAcceptableOrUnknown(
              data['firestore_id']!, _firestoreIdMeta));
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('house_id')) {
      context.handle(_houseIdMeta,
          houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta));
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('bhk_type')) {
      context.handle(_bhkTypeMeta,
          bhkType.isAcceptableOrUnknown(data['bhk_type']!, _bhkTypeMeta));
    } else if (isInserting) {
      context.missing(_bhkTypeMeta);
    }
    if (data.containsKey('default_rent')) {
      context.handle(
          _defaultRentMeta,
          defaultRent.isAcceptableOrUnknown(
              data['default_rent']!, _defaultRentMeta));
    } else if (isInserting) {
      context.missing(_defaultRentMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('room_count')) {
      context.handle(_roomCountMeta,
          roomCount.isAcceptableOrUnknown(data['room_count']!, _roomCountMeta));
    }
    if (data.containsKey('kitchen_count')) {
      context.handle(
          _kitchenCountMeta,
          kitchenCount.isAcceptableOrUnknown(
              data['kitchen_count']!, _kitchenCountMeta));
    }
    if (data.containsKey('hall_count')) {
      context.handle(_hallCountMeta,
          hallCount.isAcceptableOrUnknown(data['hall_count']!, _hallCountMeta));
    }
    if (data.containsKey('has_balcony')) {
      context.handle(
          _hasBalconyMeta,
          hasBalcony.isAcceptableOrUnknown(
              data['has_balcony']!, _hasBalconyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BhkTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BhkTemplate(
      firestoreId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}firestore_id']),
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      houseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}house_id'])!,
      bhkType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bhk_type'])!,
      defaultRent: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}default_rent'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      roomCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}room_count'])!,
      kitchenCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kitchen_count'])!,
      hallCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hall_count'])!,
      hasBalcony: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_balcony'])!,
    );
  }

  @override
  $BhkTemplatesTable createAlias(String alias) {
    return $BhkTemplatesTable(attachedDatabase, alias);
  }
}

class BhkTemplate extends DataClass implements Insertable<BhkTemplate> {
  final String? firestoreId;
  final DateTime lastUpdated;
  final bool isSynced;
  final bool isDeleted;
  final String id;
  final String houseId;
  final String bhkType;
  final double defaultRent;
  final String? description;
  final int roomCount;
  final int kitchenCount;
  final int hallCount;
  final bool hasBalcony;
  const BhkTemplate(
      {this.firestoreId,
      required this.lastUpdated,
      required this.isSynced,
      required this.isDeleted,
      required this.id,
      required this.houseId,
      required this.bhkType,
      required this.defaultRent,
      this.description,
      required this.roomCount,
      required this.kitchenCount,
      required this.hallCount,
      required this.hasBalcony});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || firestoreId != null) {
      map['firestore_id'] = Variable<String>(firestoreId);
    }
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['id'] = Variable<String>(id);
    map['house_id'] = Variable<String>(houseId);
    map['bhk_type'] = Variable<String>(bhkType);
    map['default_rent'] = Variable<double>(defaultRent);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['room_count'] = Variable<int>(roomCount);
    map['kitchen_count'] = Variable<int>(kitchenCount);
    map['hall_count'] = Variable<int>(hallCount);
    map['has_balcony'] = Variable<bool>(hasBalcony);
    return map;
  }

  BhkTemplatesCompanion toCompanion(bool nullToAbsent) {
    return BhkTemplatesCompanion(
      firestoreId: firestoreId == null && nullToAbsent
          ? const Value.absent()
          : Value(firestoreId),
      lastUpdated: Value(lastUpdated),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      id: Value(id),
      houseId: Value(houseId),
      bhkType: Value(bhkType),
      defaultRent: Value(defaultRent),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      roomCount: Value(roomCount),
      kitchenCount: Value(kitchenCount),
      hallCount: Value(hallCount),
      hasBalcony: Value(hasBalcony),
    );
  }

  factory BhkTemplate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BhkTemplate(
      firestoreId: serializer.fromJson<String?>(json['firestoreId']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      id: serializer.fromJson<String>(json['id']),
      houseId: serializer.fromJson<String>(json['houseId']),
      bhkType: serializer.fromJson<String>(json['bhkType']),
      defaultRent: serializer.fromJson<double>(json['defaultRent']),
      description: serializer.fromJson<String?>(json['description']),
      roomCount: serializer.fromJson<int>(json['roomCount']),
      kitchenCount: serializer.fromJson<int>(json['kitchenCount']),
      hallCount: serializer.fromJson<int>(json['hallCount']),
      hasBalcony: serializer.fromJson<bool>(json['hasBalcony']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'firestoreId': serializer.toJson<String?>(firestoreId),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'id': serializer.toJson<String>(id),
      'houseId': serializer.toJson<String>(houseId),
      'bhkType': serializer.toJson<String>(bhkType),
      'defaultRent': serializer.toJson<double>(defaultRent),
      'description': serializer.toJson<String?>(description),
      'roomCount': serializer.toJson<int>(roomCount),
      'kitchenCount': serializer.toJson<int>(kitchenCount),
      'hallCount': serializer.toJson<int>(hallCount),
      'hasBalcony': serializer.toJson<bool>(hasBalcony),
    };
  }

  BhkTemplate copyWith(
          {Value<String?> firestoreId = const Value.absent(),
          DateTime? lastUpdated,
          bool? isSynced,
          bool? isDeleted,
          String? id,
          String? houseId,
          String? bhkType,
          double? defaultRent,
          Value<String?> description = const Value.absent(),
          int? roomCount,
          int? kitchenCount,
          int? hallCount,
          bool? hasBalcony}) =>
      BhkTemplate(
        firestoreId: firestoreId.present ? firestoreId.value : this.firestoreId,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        isSynced: isSynced ?? this.isSynced,
        isDeleted: isDeleted ?? this.isDeleted,
        id: id ?? this.id,
        houseId: houseId ?? this.houseId,
        bhkType: bhkType ?? this.bhkType,
        defaultRent: defaultRent ?? this.defaultRent,
        description: description.present ? description.value : this.description,
        roomCount: roomCount ?? this.roomCount,
        kitchenCount: kitchenCount ?? this.kitchenCount,
        hallCount: hallCount ?? this.hallCount,
        hasBalcony: hasBalcony ?? this.hasBalcony,
      );
  BhkTemplate copyWithCompanion(BhkTemplatesCompanion data) {
    return BhkTemplate(
      firestoreId:
          data.firestoreId.present ? data.firestoreId.value : this.firestoreId,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      id: data.id.present ? data.id.value : this.id,
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      bhkType: data.bhkType.present ? data.bhkType.value : this.bhkType,
      defaultRent:
          data.defaultRent.present ? data.defaultRent.value : this.defaultRent,
      description:
          data.description.present ? data.description.value : this.description,
      roomCount: data.roomCount.present ? data.roomCount.value : this.roomCount,
      kitchenCount: data.kitchenCount.present
          ? data.kitchenCount.value
          : this.kitchenCount,
      hallCount: data.hallCount.present ? data.hallCount.value : this.hallCount,
      hasBalcony:
          data.hasBalcony.present ? data.hasBalcony.value : this.hasBalcony,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BhkTemplate(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('houseId: $houseId, ')
          ..write('bhkType: $bhkType, ')
          ..write('defaultRent: $defaultRent, ')
          ..write('description: $description, ')
          ..write('roomCount: $roomCount, ')
          ..write('kitchenCount: $kitchenCount, ')
          ..write('hallCount: $hallCount, ')
          ..write('hasBalcony: $hasBalcony')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      firestoreId,
      lastUpdated,
      isSynced,
      isDeleted,
      id,
      houseId,
      bhkType,
      defaultRent,
      description,
      roomCount,
      kitchenCount,
      hallCount,
      hasBalcony);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BhkTemplate &&
          other.firestoreId == this.firestoreId &&
          other.lastUpdated == this.lastUpdated &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.id == this.id &&
          other.houseId == this.houseId &&
          other.bhkType == this.bhkType &&
          other.defaultRent == this.defaultRent &&
          other.description == this.description &&
          other.roomCount == this.roomCount &&
          other.kitchenCount == this.kitchenCount &&
          other.hallCount == this.hallCount &&
          other.hasBalcony == this.hasBalcony);
}

class BhkTemplatesCompanion extends UpdateCompanion<BhkTemplate> {
  final Value<String?> firestoreId;
  final Value<DateTime> lastUpdated;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String> id;
  final Value<String> houseId;
  final Value<String> bhkType;
  final Value<double> defaultRent;
  final Value<String?> description;
  final Value<int> roomCount;
  final Value<int> kitchenCount;
  final Value<int> hallCount;
  final Value<bool> hasBalcony;
  final Value<int> rowid;
  const BhkTemplatesCompanion({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.id = const Value.absent(),
    this.houseId = const Value.absent(),
    this.bhkType = const Value.absent(),
    this.defaultRent = const Value.absent(),
    this.description = const Value.absent(),
    this.roomCount = const Value.absent(),
    this.kitchenCount = const Value.absent(),
    this.hallCount = const Value.absent(),
    this.hasBalcony = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BhkTemplatesCompanion.insert({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String id,
    required String houseId,
    required String bhkType,
    required double defaultRent,
    this.description = const Value.absent(),
    this.roomCount = const Value.absent(),
    this.kitchenCount = const Value.absent(),
    this.hallCount = const Value.absent(),
    this.hasBalcony = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        houseId = Value(houseId),
        bhkType = Value(bhkType),
        defaultRent = Value(defaultRent);
  static Insertable<BhkTemplate> custom({
    Expression<String>? firestoreId,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? id,
    Expression<String>? houseId,
    Expression<String>? bhkType,
    Expression<double>? defaultRent,
    Expression<String>? description,
    Expression<int>? roomCount,
    Expression<int>? kitchenCount,
    Expression<int>? hallCount,
    Expression<bool>? hasBalcony,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (firestoreId != null) 'firestore_id': firestoreId,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (id != null) 'id': id,
      if (houseId != null) 'house_id': houseId,
      if (bhkType != null) 'bhk_type': bhkType,
      if (defaultRent != null) 'default_rent': defaultRent,
      if (description != null) 'description': description,
      if (roomCount != null) 'room_count': roomCount,
      if (kitchenCount != null) 'kitchen_count': kitchenCount,
      if (hallCount != null) 'hall_count': hallCount,
      if (hasBalcony != null) 'has_balcony': hasBalcony,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BhkTemplatesCompanion copyWith(
      {Value<String?>? firestoreId,
      Value<DateTime>? lastUpdated,
      Value<bool>? isSynced,
      Value<bool>? isDeleted,
      Value<String>? id,
      Value<String>? houseId,
      Value<String>? bhkType,
      Value<double>? defaultRent,
      Value<String?>? description,
      Value<int>? roomCount,
      Value<int>? kitchenCount,
      Value<int>? hallCount,
      Value<bool>? hasBalcony,
      Value<int>? rowid}) {
    return BhkTemplatesCompanion(
      firestoreId: firestoreId ?? this.firestoreId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      id: id ?? this.id,
      houseId: houseId ?? this.houseId,
      bhkType: bhkType ?? this.bhkType,
      defaultRent: defaultRent ?? this.defaultRent,
      description: description ?? this.description,
      roomCount: roomCount ?? this.roomCount,
      kitchenCount: kitchenCount ?? this.kitchenCount,
      hallCount: hallCount ?? this.hallCount,
      hasBalcony: hasBalcony ?? this.hasBalcony,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (firestoreId.present) {
      map['firestore_id'] = Variable<String>(firestoreId.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (bhkType.present) {
      map['bhk_type'] = Variable<String>(bhkType.value);
    }
    if (defaultRent.present) {
      map['default_rent'] = Variable<double>(defaultRent.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (roomCount.present) {
      map['room_count'] = Variable<int>(roomCount.value);
    }
    if (kitchenCount.present) {
      map['kitchen_count'] = Variable<int>(kitchenCount.value);
    }
    if (hallCount.present) {
      map['hall_count'] = Variable<int>(hallCount.value);
    }
    if (hasBalcony.present) {
      map['has_balcony'] = Variable<bool>(hasBalcony.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BhkTemplatesCompanion(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('houseId: $houseId, ')
          ..write('bhkType: $bhkType, ')
          ..write('defaultRent: $defaultRent, ')
          ..write('description: $description, ')
          ..write('roomCount: $roomCount, ')
          ..write('kitchenCount: $kitchenCount, ')
          ..write('hallCount: $hallCount, ')
          ..write('hasBalcony: $hasBalcony, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UnitsTable extends Units with TableInfo<$UnitsTable, Unit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _firestoreIdMeta =
      const VerificationMeta('firestoreId');
  @override
  late final GeneratedColumn<String> firestoreId = GeneratedColumn<String>(
      'firestore_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _houseIdMeta =
      const VerificationMeta('houseId');
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
      'house_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES houses (id) ON DELETE CASCADE'));
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES owners (id) ON DELETE CASCADE'));
  static const VerificationMeta _nameOrNumberMeta =
      const VerificationMeta('nameOrNumber');
  @override
  late final GeneratedColumn<String> nameOrNumber = GeneratedColumn<String>(
      'name_or_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _floorMeta = const VerificationMeta('floor');
  @override
  late final GeneratedColumn<int> floor = GeneratedColumn<int>(
      'floor', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _bhkTemplateIdMeta =
      const VerificationMeta('bhkTemplateId');
  @override
  late final GeneratedColumn<String> bhkTemplateId = GeneratedColumn<String>(
      'bhk_template_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES bhk_templates (id)'));
  static const VerificationMeta _bhkTypeMeta =
      const VerificationMeta('bhkType');
  @override
  late final GeneratedColumn<String> bhkType = GeneratedColumn<String>(
      'bhk_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _baseRentMeta =
      const VerificationMeta('baseRent');
  @override
  late final GeneratedColumn<double> baseRent = GeneratedColumn<double>(
      'base_rent', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _editableRentMeta =
      const VerificationMeta('editableRent');
  @override
  late final GeneratedColumn<double> editableRent = GeneratedColumn<double>(
      'editable_rent', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _furnishingStatusMeta =
      const VerificationMeta('furnishingStatus');
  @override
  late final GeneratedColumn<String> furnishingStatus = GeneratedColumn<String>(
      'furnishing_status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _carpetAreaMeta =
      const VerificationMeta('carpetArea');
  @override
  late final GeneratedColumn<double> carpetArea = GeneratedColumn<double>(
      'carpet_area', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _parkingSlotMeta =
      const VerificationMeta('parkingSlot');
  @override
  late final GeneratedColumn<String> parkingSlot = GeneratedColumn<String>(
      'parking_slot', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _meterNumberMeta =
      const VerificationMeta('meterNumber');
  @override
  late final GeneratedColumn<String> meterNumber = GeneratedColumn<String>(
      'meter_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _defaultDueDayMeta =
      const VerificationMeta('defaultDueDay');
  @override
  late final GeneratedColumn<int> defaultDueDay = GeneratedColumn<int>(
      'default_due_day', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _isOccupiedMeta =
      const VerificationMeta('isOccupied');
  @override
  late final GeneratedColumn<bool> isOccupied = GeneratedColumn<bool>(
      'is_occupied', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_occupied" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _currentTenancyIdMeta =
      const VerificationMeta('currentTenancyId');
  @override
  late final GeneratedColumn<String> currentTenancyId = GeneratedColumn<String>(
      'current_tenancy_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        firestoreId,
        lastUpdated,
        isSynced,
        isDeleted,
        id,
        houseId,
        ownerId,
        nameOrNumber,
        floor,
        bhkTemplateId,
        bhkType,
        baseRent,
        editableRent,
        furnishingStatus,
        carpetArea,
        parkingSlot,
        meterNumber,
        defaultDueDay,
        isOccupied,
        currentTenancyId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'units';
  @override
  VerificationContext validateIntegrity(Insertable<Unit> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('firestore_id')) {
      context.handle(
          _firestoreIdMeta,
          firestoreId.isAcceptableOrUnknown(
              data['firestore_id']!, _firestoreIdMeta));
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('house_id')) {
      context.handle(_houseIdMeta,
          houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta));
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('name_or_number')) {
      context.handle(
          _nameOrNumberMeta,
          nameOrNumber.isAcceptableOrUnknown(
              data['name_or_number']!, _nameOrNumberMeta));
    } else if (isInserting) {
      context.missing(_nameOrNumberMeta);
    }
    if (data.containsKey('floor')) {
      context.handle(
          _floorMeta, floor.isAcceptableOrUnknown(data['floor']!, _floorMeta));
    }
    if (data.containsKey('bhk_template_id')) {
      context.handle(
          _bhkTemplateIdMeta,
          bhkTemplateId.isAcceptableOrUnknown(
              data['bhk_template_id']!, _bhkTemplateIdMeta));
    }
    if (data.containsKey('bhk_type')) {
      context.handle(_bhkTypeMeta,
          bhkType.isAcceptableOrUnknown(data['bhk_type']!, _bhkTypeMeta));
    }
    if (data.containsKey('base_rent')) {
      context.handle(_baseRentMeta,
          baseRent.isAcceptableOrUnknown(data['base_rent']!, _baseRentMeta));
    } else if (isInserting) {
      context.missing(_baseRentMeta);
    }
    if (data.containsKey('editable_rent')) {
      context.handle(
          _editableRentMeta,
          editableRent.isAcceptableOrUnknown(
              data['editable_rent']!, _editableRentMeta));
    }
    if (data.containsKey('furnishing_status')) {
      context.handle(
          _furnishingStatusMeta,
          furnishingStatus.isAcceptableOrUnknown(
              data['furnishing_status']!, _furnishingStatusMeta));
    }
    if (data.containsKey('carpet_area')) {
      context.handle(
          _carpetAreaMeta,
          carpetArea.isAcceptableOrUnknown(
              data['carpet_area']!, _carpetAreaMeta));
    }
    if (data.containsKey('parking_slot')) {
      context.handle(
          _parkingSlotMeta,
          parkingSlot.isAcceptableOrUnknown(
              data['parking_slot']!, _parkingSlotMeta));
    }
    if (data.containsKey('meter_number')) {
      context.handle(
          _meterNumberMeta,
          meterNumber.isAcceptableOrUnknown(
              data['meter_number']!, _meterNumberMeta));
    }
    if (data.containsKey('default_due_day')) {
      context.handle(
          _defaultDueDayMeta,
          defaultDueDay.isAcceptableOrUnknown(
              data['default_due_day']!, _defaultDueDayMeta));
    }
    if (data.containsKey('is_occupied')) {
      context.handle(
          _isOccupiedMeta,
          isOccupied.isAcceptableOrUnknown(
              data['is_occupied']!, _isOccupiedMeta));
    }
    if (data.containsKey('current_tenancy_id')) {
      context.handle(
          _currentTenancyIdMeta,
          currentTenancyId.isAcceptableOrUnknown(
              data['current_tenancy_id']!, _currentTenancyIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Unit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Unit(
      firestoreId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}firestore_id']),
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      houseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}house_id'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id'])!,
      nameOrNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_or_number'])!,
      floor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}floor']),
      bhkTemplateId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bhk_template_id']),
      bhkType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bhk_type']),
      baseRent: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}base_rent'])!,
      editableRent: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}editable_rent']),
      furnishingStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}furnishing_status']),
      carpetArea: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carpet_area']),
      parkingSlot: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parking_slot']),
      meterNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meter_number']),
      defaultDueDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}default_due_day'])!,
      isOccupied: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_occupied'])!,
      currentTenancyId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}current_tenancy_id']),
    );
  }

  @override
  $UnitsTable createAlias(String alias) {
    return $UnitsTable(attachedDatabase, alias);
  }
}

class Unit extends DataClass implements Insertable<Unit> {
  final String? firestoreId;
  final DateTime lastUpdated;
  final bool isSynced;
  final bool isDeleted;
  final String id;
  final String houseId;
  final String ownerId;
  final String nameOrNumber;
  final int? floor;
  final String? bhkTemplateId;
  final String? bhkType;
  final double baseRent;
  final double? editableRent;
  final String? furnishingStatus;
  final double? carpetArea;
  final String? parkingSlot;
  final String? meterNumber;
  final int defaultDueDay;
  final bool isOccupied;
  final String? currentTenancyId;
  const Unit(
      {this.firestoreId,
      required this.lastUpdated,
      required this.isSynced,
      required this.isDeleted,
      required this.id,
      required this.houseId,
      required this.ownerId,
      required this.nameOrNumber,
      this.floor,
      this.bhkTemplateId,
      this.bhkType,
      required this.baseRent,
      this.editableRent,
      this.furnishingStatus,
      this.carpetArea,
      this.parkingSlot,
      this.meterNumber,
      required this.defaultDueDay,
      required this.isOccupied,
      this.currentTenancyId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || firestoreId != null) {
      map['firestore_id'] = Variable<String>(firestoreId);
    }
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['id'] = Variable<String>(id);
    map['house_id'] = Variable<String>(houseId);
    map['owner_id'] = Variable<String>(ownerId);
    map['name_or_number'] = Variable<String>(nameOrNumber);
    if (!nullToAbsent || floor != null) {
      map['floor'] = Variable<int>(floor);
    }
    if (!nullToAbsent || bhkTemplateId != null) {
      map['bhk_template_id'] = Variable<String>(bhkTemplateId);
    }
    if (!nullToAbsent || bhkType != null) {
      map['bhk_type'] = Variable<String>(bhkType);
    }
    map['base_rent'] = Variable<double>(baseRent);
    if (!nullToAbsent || editableRent != null) {
      map['editable_rent'] = Variable<double>(editableRent);
    }
    if (!nullToAbsent || furnishingStatus != null) {
      map['furnishing_status'] = Variable<String>(furnishingStatus);
    }
    if (!nullToAbsent || carpetArea != null) {
      map['carpet_area'] = Variable<double>(carpetArea);
    }
    if (!nullToAbsent || parkingSlot != null) {
      map['parking_slot'] = Variable<String>(parkingSlot);
    }
    if (!nullToAbsent || meterNumber != null) {
      map['meter_number'] = Variable<String>(meterNumber);
    }
    map['default_due_day'] = Variable<int>(defaultDueDay);
    map['is_occupied'] = Variable<bool>(isOccupied);
    if (!nullToAbsent || currentTenancyId != null) {
      map['current_tenancy_id'] = Variable<String>(currentTenancyId);
    }
    return map;
  }

  UnitsCompanion toCompanion(bool nullToAbsent) {
    return UnitsCompanion(
      firestoreId: firestoreId == null && nullToAbsent
          ? const Value.absent()
          : Value(firestoreId),
      lastUpdated: Value(lastUpdated),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      id: Value(id),
      houseId: Value(houseId),
      ownerId: Value(ownerId),
      nameOrNumber: Value(nameOrNumber),
      floor:
          floor == null && nullToAbsent ? const Value.absent() : Value(floor),
      bhkTemplateId: bhkTemplateId == null && nullToAbsent
          ? const Value.absent()
          : Value(bhkTemplateId),
      bhkType: bhkType == null && nullToAbsent
          ? const Value.absent()
          : Value(bhkType),
      baseRent: Value(baseRent),
      editableRent: editableRent == null && nullToAbsent
          ? const Value.absent()
          : Value(editableRent),
      furnishingStatus: furnishingStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(furnishingStatus),
      carpetArea: carpetArea == null && nullToAbsent
          ? const Value.absent()
          : Value(carpetArea),
      parkingSlot: parkingSlot == null && nullToAbsent
          ? const Value.absent()
          : Value(parkingSlot),
      meterNumber: meterNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(meterNumber),
      defaultDueDay: Value(defaultDueDay),
      isOccupied: Value(isOccupied),
      currentTenancyId: currentTenancyId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentTenancyId),
    );
  }

  factory Unit.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Unit(
      firestoreId: serializer.fromJson<String?>(json['firestoreId']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      id: serializer.fromJson<String>(json['id']),
      houseId: serializer.fromJson<String>(json['houseId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      nameOrNumber: serializer.fromJson<String>(json['nameOrNumber']),
      floor: serializer.fromJson<int?>(json['floor']),
      bhkTemplateId: serializer.fromJson<String?>(json['bhkTemplateId']),
      bhkType: serializer.fromJson<String?>(json['bhkType']),
      baseRent: serializer.fromJson<double>(json['baseRent']),
      editableRent: serializer.fromJson<double?>(json['editableRent']),
      furnishingStatus: serializer.fromJson<String?>(json['furnishingStatus']),
      carpetArea: serializer.fromJson<double?>(json['carpetArea']),
      parkingSlot: serializer.fromJson<String?>(json['parkingSlot']),
      meterNumber: serializer.fromJson<String?>(json['meterNumber']),
      defaultDueDay: serializer.fromJson<int>(json['defaultDueDay']),
      isOccupied: serializer.fromJson<bool>(json['isOccupied']),
      currentTenancyId: serializer.fromJson<String?>(json['currentTenancyId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'firestoreId': serializer.toJson<String?>(firestoreId),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'id': serializer.toJson<String>(id),
      'houseId': serializer.toJson<String>(houseId),
      'ownerId': serializer.toJson<String>(ownerId),
      'nameOrNumber': serializer.toJson<String>(nameOrNumber),
      'floor': serializer.toJson<int?>(floor),
      'bhkTemplateId': serializer.toJson<String?>(bhkTemplateId),
      'bhkType': serializer.toJson<String?>(bhkType),
      'baseRent': serializer.toJson<double>(baseRent),
      'editableRent': serializer.toJson<double?>(editableRent),
      'furnishingStatus': serializer.toJson<String?>(furnishingStatus),
      'carpetArea': serializer.toJson<double?>(carpetArea),
      'parkingSlot': serializer.toJson<String?>(parkingSlot),
      'meterNumber': serializer.toJson<String?>(meterNumber),
      'defaultDueDay': serializer.toJson<int>(defaultDueDay),
      'isOccupied': serializer.toJson<bool>(isOccupied),
      'currentTenancyId': serializer.toJson<String?>(currentTenancyId),
    };
  }

  Unit copyWith(
          {Value<String?> firestoreId = const Value.absent(),
          DateTime? lastUpdated,
          bool? isSynced,
          bool? isDeleted,
          String? id,
          String? houseId,
          String? ownerId,
          String? nameOrNumber,
          Value<int?> floor = const Value.absent(),
          Value<String?> bhkTemplateId = const Value.absent(),
          Value<String?> bhkType = const Value.absent(),
          double? baseRent,
          Value<double?> editableRent = const Value.absent(),
          Value<String?> furnishingStatus = const Value.absent(),
          Value<double?> carpetArea = const Value.absent(),
          Value<String?> parkingSlot = const Value.absent(),
          Value<String?> meterNumber = const Value.absent(),
          int? defaultDueDay,
          bool? isOccupied,
          Value<String?> currentTenancyId = const Value.absent()}) =>
      Unit(
        firestoreId: firestoreId.present ? firestoreId.value : this.firestoreId,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        isSynced: isSynced ?? this.isSynced,
        isDeleted: isDeleted ?? this.isDeleted,
        id: id ?? this.id,
        houseId: houseId ?? this.houseId,
        ownerId: ownerId ?? this.ownerId,
        nameOrNumber: nameOrNumber ?? this.nameOrNumber,
        floor: floor.present ? floor.value : this.floor,
        bhkTemplateId:
            bhkTemplateId.present ? bhkTemplateId.value : this.bhkTemplateId,
        bhkType: bhkType.present ? bhkType.value : this.bhkType,
        baseRent: baseRent ?? this.baseRent,
        editableRent:
            editableRent.present ? editableRent.value : this.editableRent,
        furnishingStatus: furnishingStatus.present
            ? furnishingStatus.value
            : this.furnishingStatus,
        carpetArea: carpetArea.present ? carpetArea.value : this.carpetArea,
        parkingSlot: parkingSlot.present ? parkingSlot.value : this.parkingSlot,
        meterNumber: meterNumber.present ? meterNumber.value : this.meterNumber,
        defaultDueDay: defaultDueDay ?? this.defaultDueDay,
        isOccupied: isOccupied ?? this.isOccupied,
        currentTenancyId: currentTenancyId.present
            ? currentTenancyId.value
            : this.currentTenancyId,
      );
  Unit copyWithCompanion(UnitsCompanion data) {
    return Unit(
      firestoreId:
          data.firestoreId.present ? data.firestoreId.value : this.firestoreId,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      id: data.id.present ? data.id.value : this.id,
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      nameOrNumber: data.nameOrNumber.present
          ? data.nameOrNumber.value
          : this.nameOrNumber,
      floor: data.floor.present ? data.floor.value : this.floor,
      bhkTemplateId: data.bhkTemplateId.present
          ? data.bhkTemplateId.value
          : this.bhkTemplateId,
      bhkType: data.bhkType.present ? data.bhkType.value : this.bhkType,
      baseRent: data.baseRent.present ? data.baseRent.value : this.baseRent,
      editableRent: data.editableRent.present
          ? data.editableRent.value
          : this.editableRent,
      furnishingStatus: data.furnishingStatus.present
          ? data.furnishingStatus.value
          : this.furnishingStatus,
      carpetArea:
          data.carpetArea.present ? data.carpetArea.value : this.carpetArea,
      parkingSlot:
          data.parkingSlot.present ? data.parkingSlot.value : this.parkingSlot,
      meterNumber:
          data.meterNumber.present ? data.meterNumber.value : this.meterNumber,
      defaultDueDay: data.defaultDueDay.present
          ? data.defaultDueDay.value
          : this.defaultDueDay,
      isOccupied:
          data.isOccupied.present ? data.isOccupied.value : this.isOccupied,
      currentTenancyId: data.currentTenancyId.present
          ? data.currentTenancyId.value
          : this.currentTenancyId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Unit(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('houseId: $houseId, ')
          ..write('ownerId: $ownerId, ')
          ..write('nameOrNumber: $nameOrNumber, ')
          ..write('floor: $floor, ')
          ..write('bhkTemplateId: $bhkTemplateId, ')
          ..write('bhkType: $bhkType, ')
          ..write('baseRent: $baseRent, ')
          ..write('editableRent: $editableRent, ')
          ..write('furnishingStatus: $furnishingStatus, ')
          ..write('carpetArea: $carpetArea, ')
          ..write('parkingSlot: $parkingSlot, ')
          ..write('meterNumber: $meterNumber, ')
          ..write('defaultDueDay: $defaultDueDay, ')
          ..write('isOccupied: $isOccupied, ')
          ..write('currentTenancyId: $currentTenancyId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      firestoreId,
      lastUpdated,
      isSynced,
      isDeleted,
      id,
      houseId,
      ownerId,
      nameOrNumber,
      floor,
      bhkTemplateId,
      bhkType,
      baseRent,
      editableRent,
      furnishingStatus,
      carpetArea,
      parkingSlot,
      meterNumber,
      defaultDueDay,
      isOccupied,
      currentTenancyId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Unit &&
          other.firestoreId == this.firestoreId &&
          other.lastUpdated == this.lastUpdated &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.id == this.id &&
          other.houseId == this.houseId &&
          other.ownerId == this.ownerId &&
          other.nameOrNumber == this.nameOrNumber &&
          other.floor == this.floor &&
          other.bhkTemplateId == this.bhkTemplateId &&
          other.bhkType == this.bhkType &&
          other.baseRent == this.baseRent &&
          other.editableRent == this.editableRent &&
          other.furnishingStatus == this.furnishingStatus &&
          other.carpetArea == this.carpetArea &&
          other.parkingSlot == this.parkingSlot &&
          other.meterNumber == this.meterNumber &&
          other.defaultDueDay == this.defaultDueDay &&
          other.isOccupied == this.isOccupied &&
          other.currentTenancyId == this.currentTenancyId);
}

class UnitsCompanion extends UpdateCompanion<Unit> {
  final Value<String?> firestoreId;
  final Value<DateTime> lastUpdated;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String> id;
  final Value<String> houseId;
  final Value<String> ownerId;
  final Value<String> nameOrNumber;
  final Value<int?> floor;
  final Value<String?> bhkTemplateId;
  final Value<String?> bhkType;
  final Value<double> baseRent;
  final Value<double?> editableRent;
  final Value<String?> furnishingStatus;
  final Value<double?> carpetArea;
  final Value<String?> parkingSlot;
  final Value<String?> meterNumber;
  final Value<int> defaultDueDay;
  final Value<bool> isOccupied;
  final Value<String?> currentTenancyId;
  final Value<int> rowid;
  const UnitsCompanion({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.id = const Value.absent(),
    this.houseId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.nameOrNumber = const Value.absent(),
    this.floor = const Value.absent(),
    this.bhkTemplateId = const Value.absent(),
    this.bhkType = const Value.absent(),
    this.baseRent = const Value.absent(),
    this.editableRent = const Value.absent(),
    this.furnishingStatus = const Value.absent(),
    this.carpetArea = const Value.absent(),
    this.parkingSlot = const Value.absent(),
    this.meterNumber = const Value.absent(),
    this.defaultDueDay = const Value.absent(),
    this.isOccupied = const Value.absent(),
    this.currentTenancyId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnitsCompanion.insert({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String id,
    required String houseId,
    required String ownerId,
    required String nameOrNumber,
    this.floor = const Value.absent(),
    this.bhkTemplateId = const Value.absent(),
    this.bhkType = const Value.absent(),
    required double baseRent,
    this.editableRent = const Value.absent(),
    this.furnishingStatus = const Value.absent(),
    this.carpetArea = const Value.absent(),
    this.parkingSlot = const Value.absent(),
    this.meterNumber = const Value.absent(),
    this.defaultDueDay = const Value.absent(),
    this.isOccupied = const Value.absent(),
    this.currentTenancyId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        houseId = Value(houseId),
        ownerId = Value(ownerId),
        nameOrNumber = Value(nameOrNumber),
        baseRent = Value(baseRent);
  static Insertable<Unit> custom({
    Expression<String>? firestoreId,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? id,
    Expression<String>? houseId,
    Expression<String>? ownerId,
    Expression<String>? nameOrNumber,
    Expression<int>? floor,
    Expression<String>? bhkTemplateId,
    Expression<String>? bhkType,
    Expression<double>? baseRent,
    Expression<double>? editableRent,
    Expression<String>? furnishingStatus,
    Expression<double>? carpetArea,
    Expression<String>? parkingSlot,
    Expression<String>? meterNumber,
    Expression<int>? defaultDueDay,
    Expression<bool>? isOccupied,
    Expression<String>? currentTenancyId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (firestoreId != null) 'firestore_id': firestoreId,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (id != null) 'id': id,
      if (houseId != null) 'house_id': houseId,
      if (ownerId != null) 'owner_id': ownerId,
      if (nameOrNumber != null) 'name_or_number': nameOrNumber,
      if (floor != null) 'floor': floor,
      if (bhkTemplateId != null) 'bhk_template_id': bhkTemplateId,
      if (bhkType != null) 'bhk_type': bhkType,
      if (baseRent != null) 'base_rent': baseRent,
      if (editableRent != null) 'editable_rent': editableRent,
      if (furnishingStatus != null) 'furnishing_status': furnishingStatus,
      if (carpetArea != null) 'carpet_area': carpetArea,
      if (parkingSlot != null) 'parking_slot': parkingSlot,
      if (meterNumber != null) 'meter_number': meterNumber,
      if (defaultDueDay != null) 'default_due_day': defaultDueDay,
      if (isOccupied != null) 'is_occupied': isOccupied,
      if (currentTenancyId != null) 'current_tenancy_id': currentTenancyId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnitsCompanion copyWith(
      {Value<String?>? firestoreId,
      Value<DateTime>? lastUpdated,
      Value<bool>? isSynced,
      Value<bool>? isDeleted,
      Value<String>? id,
      Value<String>? houseId,
      Value<String>? ownerId,
      Value<String>? nameOrNumber,
      Value<int?>? floor,
      Value<String?>? bhkTemplateId,
      Value<String?>? bhkType,
      Value<double>? baseRent,
      Value<double?>? editableRent,
      Value<String?>? furnishingStatus,
      Value<double?>? carpetArea,
      Value<String?>? parkingSlot,
      Value<String?>? meterNumber,
      Value<int>? defaultDueDay,
      Value<bool>? isOccupied,
      Value<String?>? currentTenancyId,
      Value<int>? rowid}) {
    return UnitsCompanion(
      firestoreId: firestoreId ?? this.firestoreId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      id: id ?? this.id,
      houseId: houseId ?? this.houseId,
      ownerId: ownerId ?? this.ownerId,
      nameOrNumber: nameOrNumber ?? this.nameOrNumber,
      floor: floor ?? this.floor,
      bhkTemplateId: bhkTemplateId ?? this.bhkTemplateId,
      bhkType: bhkType ?? this.bhkType,
      baseRent: baseRent ?? this.baseRent,
      editableRent: editableRent ?? this.editableRent,
      furnishingStatus: furnishingStatus ?? this.furnishingStatus,
      carpetArea: carpetArea ?? this.carpetArea,
      parkingSlot: parkingSlot ?? this.parkingSlot,
      meterNumber: meterNumber ?? this.meterNumber,
      defaultDueDay: defaultDueDay ?? this.defaultDueDay,
      isOccupied: isOccupied ?? this.isOccupied,
      currentTenancyId: currentTenancyId ?? this.currentTenancyId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (firestoreId.present) {
      map['firestore_id'] = Variable<String>(firestoreId.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (nameOrNumber.present) {
      map['name_or_number'] = Variable<String>(nameOrNumber.value);
    }
    if (floor.present) {
      map['floor'] = Variable<int>(floor.value);
    }
    if (bhkTemplateId.present) {
      map['bhk_template_id'] = Variable<String>(bhkTemplateId.value);
    }
    if (bhkType.present) {
      map['bhk_type'] = Variable<String>(bhkType.value);
    }
    if (baseRent.present) {
      map['base_rent'] = Variable<double>(baseRent.value);
    }
    if (editableRent.present) {
      map['editable_rent'] = Variable<double>(editableRent.value);
    }
    if (furnishingStatus.present) {
      map['furnishing_status'] = Variable<String>(furnishingStatus.value);
    }
    if (carpetArea.present) {
      map['carpet_area'] = Variable<double>(carpetArea.value);
    }
    if (parkingSlot.present) {
      map['parking_slot'] = Variable<String>(parkingSlot.value);
    }
    if (meterNumber.present) {
      map['meter_number'] = Variable<String>(meterNumber.value);
    }
    if (defaultDueDay.present) {
      map['default_due_day'] = Variable<int>(defaultDueDay.value);
    }
    if (isOccupied.present) {
      map['is_occupied'] = Variable<bool>(isOccupied.value);
    }
    if (currentTenancyId.present) {
      map['current_tenancy_id'] = Variable<String>(currentTenancyId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnitsCompanion(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('houseId: $houseId, ')
          ..write('ownerId: $ownerId, ')
          ..write('nameOrNumber: $nameOrNumber, ')
          ..write('floor: $floor, ')
          ..write('bhkTemplateId: $bhkTemplateId, ')
          ..write('bhkType: $bhkType, ')
          ..write('baseRent: $baseRent, ')
          ..write('editableRent: $editableRent, ')
          ..write('furnishingStatus: $furnishingStatus, ')
          ..write('carpetArea: $carpetArea, ')
          ..write('parkingSlot: $parkingSlot, ')
          ..write('meterNumber: $meterNumber, ')
          ..write('defaultDueDay: $defaultDueDay, ')
          ..write('isOccupied: $isOccupied, ')
          ..write('currentTenancyId: $currentTenancyId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TenantsTable extends Tenants with TableInfo<$TenantsTable, Tenant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TenantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _firestoreIdMeta =
      const VerificationMeta('firestoreId');
  @override
  late final GeneratedColumn<String> firestoreId = GeneratedColumn<String>(
      'firestore_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES owners (id) ON DELETE CASCADE'));
  static const VerificationMeta _tenantCodeMeta =
      const VerificationMeta('tenantCode');
  @override
  late final GeneratedColumn<String> tenantCode = GeneratedColumn<String>(
      'tenant_code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _passwordMeta =
      const VerificationMeta('password');
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
      'password', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        firestoreId,
        lastUpdated,
        isSynced,
        isDeleted,
        id,
        ownerId,
        tenantCode,
        name,
        phone,
        email,
        isActive,
        password
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tenants';
  @override
  VerificationContext validateIntegrity(Insertable<Tenant> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('firestore_id')) {
      context.handle(
          _firestoreIdMeta,
          firestoreId.isAcceptableOrUnknown(
              data['firestore_id']!, _firestoreIdMeta));
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('tenant_code')) {
      context.handle(
          _tenantCodeMeta,
          tenantCode.isAcceptableOrUnknown(
              data['tenant_code']!, _tenantCodeMeta));
    } else if (isInserting) {
      context.missing(_tenantCodeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('password')) {
      context.handle(_passwordMeta,
          password.isAcceptableOrUnknown(data['password']!, _passwordMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tenant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tenant(
      firestoreId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}firestore_id']),
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id'])!,
      tenantCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      password: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password']),
    );
  }

  @override
  $TenantsTable createAlias(String alias) {
    return $TenantsTable(attachedDatabase, alias);
  }
}

class Tenant extends DataClass implements Insertable<Tenant> {
  final String? firestoreId;
  final DateTime lastUpdated;
  final bool isSynced;
  final bool isDeleted;
  final String id;
  final String ownerId;
  final String tenantCode;
  final String name;
  final String phone;
  final String? email;
  final bool isActive;
  final String? password;
  const Tenant(
      {this.firestoreId,
      required this.lastUpdated,
      required this.isSynced,
      required this.isDeleted,
      required this.id,
      required this.ownerId,
      required this.tenantCode,
      required this.name,
      required this.phone,
      this.email,
      required this.isActive,
      this.password});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || firestoreId != null) {
      map['firestore_id'] = Variable<String>(firestoreId);
    }
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['tenant_code'] = Variable<String>(tenantCode);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || password != null) {
      map['password'] = Variable<String>(password);
    }
    return map;
  }

  TenantsCompanion toCompanion(bool nullToAbsent) {
    return TenantsCompanion(
      firestoreId: firestoreId == null && nullToAbsent
          ? const Value.absent()
          : Value(firestoreId),
      lastUpdated: Value(lastUpdated),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      id: Value(id),
      ownerId: Value(ownerId),
      tenantCode: Value(tenantCode),
      name: Value(name),
      phone: Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      isActive: Value(isActive),
      password: password == null && nullToAbsent
          ? const Value.absent()
          : Value(password),
    );
  }

  factory Tenant.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tenant(
      firestoreId: serializer.fromJson<String?>(json['firestoreId']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      tenantCode: serializer.fromJson<String>(json['tenantCode']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      password: serializer.fromJson<String?>(json['password']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'firestoreId': serializer.toJson<String?>(firestoreId),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'tenantCode': serializer.toJson<String>(tenantCode),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String?>(email),
      'isActive': serializer.toJson<bool>(isActive),
      'password': serializer.toJson<String?>(password),
    };
  }

  Tenant copyWith(
          {Value<String?> firestoreId = const Value.absent(),
          DateTime? lastUpdated,
          bool? isSynced,
          bool? isDeleted,
          String? id,
          String? ownerId,
          String? tenantCode,
          String? name,
          String? phone,
          Value<String?> email = const Value.absent(),
          bool? isActive,
          Value<String?> password = const Value.absent()}) =>
      Tenant(
        firestoreId: firestoreId.present ? firestoreId.value : this.firestoreId,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        isSynced: isSynced ?? this.isSynced,
        isDeleted: isDeleted ?? this.isDeleted,
        id: id ?? this.id,
        ownerId: ownerId ?? this.ownerId,
        tenantCode: tenantCode ?? this.tenantCode,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email.present ? email.value : this.email,
        isActive: isActive ?? this.isActive,
        password: password.present ? password.value : this.password,
      );
  Tenant copyWithCompanion(TenantsCompanion data) {
    return Tenant(
      firestoreId:
          data.firestoreId.present ? data.firestoreId.value : this.firestoreId,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      tenantCode:
          data.tenantCode.present ? data.tenantCode.value : this.tenantCode,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      password: data.password.present ? data.password.value : this.password,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tenant(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('tenantCode: $tenantCode, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('isActive: $isActive, ')
          ..write('password: $password')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(firestoreId, lastUpdated, isSynced, isDeleted,
      id, ownerId, tenantCode, name, phone, email, isActive, password);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tenant &&
          other.firestoreId == this.firestoreId &&
          other.lastUpdated == this.lastUpdated &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.tenantCode == this.tenantCode &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.isActive == this.isActive &&
          other.password == this.password);
}

class TenantsCompanion extends UpdateCompanion<Tenant> {
  final Value<String?> firestoreId;
  final Value<DateTime> lastUpdated;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> tenantCode;
  final Value<String> name;
  final Value<String> phone;
  final Value<String?> email;
  final Value<bool> isActive;
  final Value<String?> password;
  final Value<int> rowid;
  const TenantsCompanion({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.tenantCode = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.isActive = const Value.absent(),
    this.password = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TenantsCompanion.insert({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String id,
    required String ownerId,
    required String tenantCode,
    required String name,
    required String phone,
    this.email = const Value.absent(),
    this.isActive = const Value.absent(),
    this.password = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        ownerId = Value(ownerId),
        tenantCode = Value(tenantCode),
        name = Value(name),
        phone = Value(phone);
  static Insertable<Tenant> custom({
    Expression<String>? firestoreId,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? tenantCode,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<bool>? isActive,
    Expression<String>? password,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (firestoreId != null) 'firestore_id': firestoreId,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (tenantCode != null) 'tenant_code': tenantCode,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (isActive != null) 'is_active': isActive,
      if (password != null) 'password': password,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TenantsCompanion copyWith(
      {Value<String?>? firestoreId,
      Value<DateTime>? lastUpdated,
      Value<bool>? isSynced,
      Value<bool>? isDeleted,
      Value<String>? id,
      Value<String>? ownerId,
      Value<String>? tenantCode,
      Value<String>? name,
      Value<String>? phone,
      Value<String?>? email,
      Value<bool>? isActive,
      Value<String?>? password,
      Value<int>? rowid}) {
    return TenantsCompanion(
      firestoreId: firestoreId ?? this.firestoreId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      tenantCode: tenantCode ?? this.tenantCode,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      password: password ?? this.password,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (firestoreId.present) {
      map['firestore_id'] = Variable<String>(firestoreId.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (tenantCode.present) {
      map['tenant_code'] = Variable<String>(tenantCode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TenantsCompanion(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('tenantCode: $tenantCode, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('isActive: $isActive, ')
          ..write('password: $password, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TenanciesTable extends Tenancies
    with TableInfo<$TenanciesTable, Tenancy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TenanciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _firestoreIdMeta =
      const VerificationMeta('firestoreId');
  @override
  late final GeneratedColumn<String> firestoreId = GeneratedColumn<String>(
      'firestore_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tenants (id) ON DELETE CASCADE'));
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
      'unit_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES units (id) ON DELETE CASCADE'));
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES owners (id) ON DELETE CASCADE'));
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _agreedRentMeta =
      const VerificationMeta('agreedRent');
  @override
  late final GeneratedColumn<double> agreedRent = GeneratedColumn<double>(
      'agreed_rent', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _securityDepositMeta =
      const VerificationMeta('securityDeposit');
  @override
  late final GeneratedColumn<double> securityDeposit = GeneratedColumn<double>(
      'security_deposit', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _openingBalanceMeta =
      const VerificationMeta('openingBalance');
  @override
  late final GeneratedColumn<double> openingBalance = GeneratedColumn<double>(
      'opening_balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        firestoreId,
        lastUpdated,
        isSynced,
        isDeleted,
        id,
        tenantId,
        unitId,
        ownerId,
        startDate,
        endDate,
        agreedRent,
        securityDeposit,
        openingBalance,
        status,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tenancies';
  @override
  VerificationContext validateIntegrity(Insertable<Tenancy> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('firestore_id')) {
      context.handle(
          _firestoreIdMeta,
          firestoreId.isAcceptableOrUnknown(
              data['firestore_id']!, _firestoreIdMeta));
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('unit_id')) {
      context.handle(_unitIdMeta,
          unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta));
    } else if (isInserting) {
      context.missing(_unitIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('agreed_rent')) {
      context.handle(
          _agreedRentMeta,
          agreedRent.isAcceptableOrUnknown(
              data['agreed_rent']!, _agreedRentMeta));
    } else if (isInserting) {
      context.missing(_agreedRentMeta);
    }
    if (data.containsKey('security_deposit')) {
      context.handle(
          _securityDepositMeta,
          securityDeposit.isAcceptableOrUnknown(
              data['security_deposit']!, _securityDepositMeta));
    }
    if (data.containsKey('opening_balance')) {
      context.handle(
          _openingBalanceMeta,
          openingBalance.isAcceptableOrUnknown(
              data['opening_balance']!, _openingBalanceMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tenancy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tenancy(
      firestoreId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}firestore_id']),
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      unitId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit_id'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      agreedRent: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}agreed_rent'])!,
      securityDeposit: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}security_deposit'])!,
      openingBalance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}opening_balance'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $TenanciesTable createAlias(String alias) {
    return $TenanciesTable(attachedDatabase, alias);
  }
}

class Tenancy extends DataClass implements Insertable<Tenancy> {
  final String? firestoreId;
  final DateTime lastUpdated;
  final bool isSynced;
  final bool isDeleted;
  final String id;
  final String tenantId;
  final String unitId;
  final String ownerId;
  final DateTime startDate;
  final DateTime? endDate;
  final double agreedRent;
  final double securityDeposit;
  final double openingBalance;
  final int status;
  final String? notes;
  const Tenancy(
      {this.firestoreId,
      required this.lastUpdated,
      required this.isSynced,
      required this.isDeleted,
      required this.id,
      required this.tenantId,
      required this.unitId,
      required this.ownerId,
      required this.startDate,
      this.endDate,
      required this.agreedRent,
      required this.securityDeposit,
      required this.openingBalance,
      required this.status,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || firestoreId != null) {
      map['firestore_id'] = Variable<String>(firestoreId);
    }
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['unit_id'] = Variable<String>(unitId);
    map['owner_id'] = Variable<String>(ownerId);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['agreed_rent'] = Variable<double>(agreedRent);
    map['security_deposit'] = Variable<double>(securityDeposit);
    map['opening_balance'] = Variable<double>(openingBalance);
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  TenanciesCompanion toCompanion(bool nullToAbsent) {
    return TenanciesCompanion(
      firestoreId: firestoreId == null && nullToAbsent
          ? const Value.absent()
          : Value(firestoreId),
      lastUpdated: Value(lastUpdated),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      id: Value(id),
      tenantId: Value(tenantId),
      unitId: Value(unitId),
      ownerId: Value(ownerId),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      agreedRent: Value(agreedRent),
      securityDeposit: Value(securityDeposit),
      openingBalance: Value(openingBalance),
      status: Value(status),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory Tenancy.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tenancy(
      firestoreId: serializer.fromJson<String?>(json['firestoreId']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      unitId: serializer.fromJson<String>(json['unitId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      agreedRent: serializer.fromJson<double>(json['agreedRent']),
      securityDeposit: serializer.fromJson<double>(json['securityDeposit']),
      openingBalance: serializer.fromJson<double>(json['openingBalance']),
      status: serializer.fromJson<int>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'firestoreId': serializer.toJson<String?>(firestoreId),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'unitId': serializer.toJson<String>(unitId),
      'ownerId': serializer.toJson<String>(ownerId),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'agreedRent': serializer.toJson<double>(agreedRent),
      'securityDeposit': serializer.toJson<double>(securityDeposit),
      'openingBalance': serializer.toJson<double>(openingBalance),
      'status': serializer.toJson<int>(status),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Tenancy copyWith(
          {Value<String?> firestoreId = const Value.absent(),
          DateTime? lastUpdated,
          bool? isSynced,
          bool? isDeleted,
          String? id,
          String? tenantId,
          String? unitId,
          String? ownerId,
          DateTime? startDate,
          Value<DateTime?> endDate = const Value.absent(),
          double? agreedRent,
          double? securityDeposit,
          double? openingBalance,
          int? status,
          Value<String?> notes = const Value.absent()}) =>
      Tenancy(
        firestoreId: firestoreId.present ? firestoreId.value : this.firestoreId,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        isSynced: isSynced ?? this.isSynced,
        isDeleted: isDeleted ?? this.isDeleted,
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        unitId: unitId ?? this.unitId,
        ownerId: ownerId ?? this.ownerId,
        startDate: startDate ?? this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        agreedRent: agreedRent ?? this.agreedRent,
        securityDeposit: securityDeposit ?? this.securityDeposit,
        openingBalance: openingBalance ?? this.openingBalance,
        status: status ?? this.status,
        notes: notes.present ? notes.value : this.notes,
      );
  Tenancy copyWithCompanion(TenanciesCompanion data) {
    return Tenancy(
      firestoreId:
          data.firestoreId.present ? data.firestoreId.value : this.firestoreId,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      agreedRent:
          data.agreedRent.present ? data.agreedRent.value : this.agreedRent,
      securityDeposit: data.securityDeposit.present
          ? data.securityDeposit.value
          : this.securityDeposit,
      openingBalance: data.openingBalance.present
          ? data.openingBalance.value
          : this.openingBalance,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tenancy(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('unitId: $unitId, ')
          ..write('ownerId: $ownerId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('agreedRent: $agreedRent, ')
          ..write('securityDeposit: $securityDeposit, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('status: $status, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      firestoreId,
      lastUpdated,
      isSynced,
      isDeleted,
      id,
      tenantId,
      unitId,
      ownerId,
      startDate,
      endDate,
      agreedRent,
      securityDeposit,
      openingBalance,
      status,
      notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tenancy &&
          other.firestoreId == this.firestoreId &&
          other.lastUpdated == this.lastUpdated &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.unitId == this.unitId &&
          other.ownerId == this.ownerId &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.agreedRent == this.agreedRent &&
          other.securityDeposit == this.securityDeposit &&
          other.openingBalance == this.openingBalance &&
          other.status == this.status &&
          other.notes == this.notes);
}

class TenanciesCompanion extends UpdateCompanion<Tenancy> {
  final Value<String?> firestoreId;
  final Value<DateTime> lastUpdated;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> unitId;
  final Value<String> ownerId;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<double> agreedRent;
  final Value<double> securityDeposit;
  final Value<double> openingBalance;
  final Value<int> status;
  final Value<String?> notes;
  final Value<int> rowid;
  const TenanciesCompanion({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.unitId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.agreedRent = const Value.absent(),
    this.securityDeposit = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TenanciesCompanion.insert({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String id,
    required String tenantId,
    required String unitId,
    required String ownerId,
    required DateTime startDate,
    this.endDate = const Value.absent(),
    required double agreedRent,
    this.securityDeposit = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        unitId = Value(unitId),
        ownerId = Value(ownerId),
        startDate = Value(startDate),
        agreedRent = Value(agreedRent);
  static Insertable<Tenancy> custom({
    Expression<String>? firestoreId,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? unitId,
    Expression<String>? ownerId,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<double>? agreedRent,
    Expression<double>? securityDeposit,
    Expression<double>? openingBalance,
    Expression<int>? status,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (firestoreId != null) 'firestore_id': firestoreId,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (unitId != null) 'unit_id': unitId,
      if (ownerId != null) 'owner_id': ownerId,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (agreedRent != null) 'agreed_rent': agreedRent,
      if (securityDeposit != null) 'security_deposit': securityDeposit,
      if (openingBalance != null) 'opening_balance': openingBalance,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TenanciesCompanion copyWith(
      {Value<String?>? firestoreId,
      Value<DateTime>? lastUpdated,
      Value<bool>? isSynced,
      Value<bool>? isDeleted,
      Value<String>? id,
      Value<String>? tenantId,
      Value<String>? unitId,
      Value<String>? ownerId,
      Value<DateTime>? startDate,
      Value<DateTime?>? endDate,
      Value<double>? agreedRent,
      Value<double>? securityDeposit,
      Value<double>? openingBalance,
      Value<int>? status,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return TenanciesCompanion(
      firestoreId: firestoreId ?? this.firestoreId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      unitId: unitId ?? this.unitId,
      ownerId: ownerId ?? this.ownerId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      agreedRent: agreedRent ?? this.agreedRent,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      openingBalance: openingBalance ?? this.openingBalance,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (firestoreId.present) {
      map['firestore_id'] = Variable<String>(firestoreId.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (agreedRent.present) {
      map['agreed_rent'] = Variable<double>(agreedRent.value);
    }
    if (securityDeposit.present) {
      map['security_deposit'] = Variable<double>(securityDeposit.value);
    }
    if (openingBalance.present) {
      map['opening_balance'] = Variable<double>(openingBalance.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TenanciesCompanion(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('unitId: $unitId, ')
          ..write('ownerId: $ownerId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('agreedRent: $agreedRent, ')
          ..write('securityDeposit: $securityDeposit, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RentCyclesTable extends RentCycles
    with TableInfo<$RentCyclesTable, RentCycle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RentCyclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _firestoreIdMeta =
      const VerificationMeta('firestoreId');
  @override
  late final GeneratedColumn<String> firestoreId = GeneratedColumn<String>(
      'firestore_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenancyIdMeta =
      const VerificationMeta('tenancyId');
  @override
  late final GeneratedColumn<String> tenancyId = GeneratedColumn<String>(
      'tenancy_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tenancies (id) ON DELETE CASCADE'));
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES owners (id) ON DELETE CASCADE'));
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
      'month', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _billNumberMeta =
      const VerificationMeta('billNumber');
  @override
  late final GeneratedColumn<String> billNumber = GeneratedColumn<String>(
      'bill_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _billPeriodStartMeta =
      const VerificationMeta('billPeriodStart');
  @override
  late final GeneratedColumn<DateTime> billPeriodStart =
      GeneratedColumn<DateTime>('bill_period_start', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _billPeriodEndMeta =
      const VerificationMeta('billPeriodEnd');
  @override
  late final GeneratedColumn<DateTime> billPeriodEnd =
      GeneratedColumn<DateTime>('bill_period_end', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _billGeneratedDateMeta =
      const VerificationMeta('billGeneratedDate');
  @override
  late final GeneratedColumn<DateTime> billGeneratedDate =
      GeneratedColumn<DateTime>('bill_generated_date', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _baseRentMeta =
      const VerificationMeta('baseRent');
  @override
  late final GeneratedColumn<double> baseRent = GeneratedColumn<double>(
      'base_rent', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _electricAmountMeta =
      const VerificationMeta('electricAmount');
  @override
  late final GeneratedColumn<double> electricAmount = GeneratedColumn<double>(
      'electric_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _otherChargesMeta =
      const VerificationMeta('otherCharges');
  @override
  late final GeneratedColumn<double> otherCharges = GeneratedColumn<double>(
      'other_charges', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _discountMeta =
      const VerificationMeta('discount');
  @override
  late final GeneratedColumn<double> discount = GeneratedColumn<double>(
      'discount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _totalDueMeta =
      const VerificationMeta('totalDue');
  @override
  late final GeneratedColumn<double> totalDue = GeneratedColumn<double>(
      'total_due', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalPaidMeta =
      const VerificationMeta('totalPaid');
  @override
  late final GeneratedColumn<double> totalPaid = GeneratedColumn<double>(
      'total_paid', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        firestoreId,
        lastUpdated,
        isSynced,
        isDeleted,
        id,
        tenancyId,
        ownerId,
        month,
        billNumber,
        billPeriodStart,
        billPeriodEnd,
        billGeneratedDate,
        dueDate,
        baseRent,
        electricAmount,
        otherCharges,
        discount,
        totalDue,
        totalPaid,
        status,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rent_cycles';
  @override
  VerificationContext validateIntegrity(Insertable<RentCycle> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('firestore_id')) {
      context.handle(
          _firestoreIdMeta,
          firestoreId.isAcceptableOrUnknown(
              data['firestore_id']!, _firestoreIdMeta));
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenancy_id')) {
      context.handle(_tenancyIdMeta,
          tenancyId.isAcceptableOrUnknown(data['tenancy_id']!, _tenancyIdMeta));
    } else if (isInserting) {
      context.missing(_tenancyIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
          _monthMeta, month.isAcceptableOrUnknown(data['month']!, _monthMeta));
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('bill_number')) {
      context.handle(
          _billNumberMeta,
          billNumber.isAcceptableOrUnknown(
              data['bill_number']!, _billNumberMeta));
    }
    if (data.containsKey('bill_period_start')) {
      context.handle(
          _billPeriodStartMeta,
          billPeriodStart.isAcceptableOrUnknown(
              data['bill_period_start']!, _billPeriodStartMeta));
    }
    if (data.containsKey('bill_period_end')) {
      context.handle(
          _billPeriodEndMeta,
          billPeriodEnd.isAcceptableOrUnknown(
              data['bill_period_end']!, _billPeriodEndMeta));
    }
    if (data.containsKey('bill_generated_date')) {
      context.handle(
          _billGeneratedDateMeta,
          billGeneratedDate.isAcceptableOrUnknown(
              data['bill_generated_date']!, _billGeneratedDateMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('base_rent')) {
      context.handle(_baseRentMeta,
          baseRent.isAcceptableOrUnknown(data['base_rent']!, _baseRentMeta));
    } else if (isInserting) {
      context.missing(_baseRentMeta);
    }
    if (data.containsKey('electric_amount')) {
      context.handle(
          _electricAmountMeta,
          electricAmount.isAcceptableOrUnknown(
              data['electric_amount']!, _electricAmountMeta));
    }
    if (data.containsKey('other_charges')) {
      context.handle(
          _otherChargesMeta,
          otherCharges.isAcceptableOrUnknown(
              data['other_charges']!, _otherChargesMeta));
    }
    if (data.containsKey('discount')) {
      context.handle(_discountMeta,
          discount.isAcceptableOrUnknown(data['discount']!, _discountMeta));
    }
    if (data.containsKey('total_due')) {
      context.handle(_totalDueMeta,
          totalDue.isAcceptableOrUnknown(data['total_due']!, _totalDueMeta));
    } else if (isInserting) {
      context.missing(_totalDueMeta);
    }
    if (data.containsKey('total_paid')) {
      context.handle(_totalPaidMeta,
          totalPaid.isAcceptableOrUnknown(data['total_paid']!, _totalPaidMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RentCycle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RentCycle(
      firestoreId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}firestore_id']),
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenancyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenancy_id'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id'])!,
      month: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}month'])!,
      billNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bill_number']),
      billPeriodStart: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}bill_period_start']),
      billPeriodEnd: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}bill_period_end']),
      billGeneratedDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}bill_generated_date'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      baseRent: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}base_rent'])!,
      electricAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}electric_amount'])!,
      otherCharges: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}other_charges'])!,
      discount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}discount'])!,
      totalDue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_due'])!,
      totalPaid: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_paid'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $RentCyclesTable createAlias(String alias) {
    return $RentCyclesTable(attachedDatabase, alias);
  }
}

class RentCycle extends DataClass implements Insertable<RentCycle> {
  final String? firestoreId;
  final DateTime lastUpdated;
  final bool isSynced;
  final bool isDeleted;
  final String id;
  final String tenancyId;
  final String ownerId;
  final String month;
  final String? billNumber;
  final DateTime? billPeriodStart;
  final DateTime? billPeriodEnd;
  final DateTime billGeneratedDate;
  final DateTime? dueDate;
  final double baseRent;
  final double electricAmount;
  final double otherCharges;
  final double discount;
  final double totalDue;
  final double totalPaid;
  final int status;
  final String? notes;
  const RentCycle(
      {this.firestoreId,
      required this.lastUpdated,
      required this.isSynced,
      required this.isDeleted,
      required this.id,
      required this.tenancyId,
      required this.ownerId,
      required this.month,
      this.billNumber,
      this.billPeriodStart,
      this.billPeriodEnd,
      required this.billGeneratedDate,
      this.dueDate,
      required this.baseRent,
      required this.electricAmount,
      required this.otherCharges,
      required this.discount,
      required this.totalDue,
      required this.totalPaid,
      required this.status,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || firestoreId != null) {
      map['firestore_id'] = Variable<String>(firestoreId);
    }
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['id'] = Variable<String>(id);
    map['tenancy_id'] = Variable<String>(tenancyId);
    map['owner_id'] = Variable<String>(ownerId);
    map['month'] = Variable<String>(month);
    if (!nullToAbsent || billNumber != null) {
      map['bill_number'] = Variable<String>(billNumber);
    }
    if (!nullToAbsent || billPeriodStart != null) {
      map['bill_period_start'] = Variable<DateTime>(billPeriodStart);
    }
    if (!nullToAbsent || billPeriodEnd != null) {
      map['bill_period_end'] = Variable<DateTime>(billPeriodEnd);
    }
    map['bill_generated_date'] = Variable<DateTime>(billGeneratedDate);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['base_rent'] = Variable<double>(baseRent);
    map['electric_amount'] = Variable<double>(electricAmount);
    map['other_charges'] = Variable<double>(otherCharges);
    map['discount'] = Variable<double>(discount);
    map['total_due'] = Variable<double>(totalDue);
    map['total_paid'] = Variable<double>(totalPaid);
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  RentCyclesCompanion toCompanion(bool nullToAbsent) {
    return RentCyclesCompanion(
      firestoreId: firestoreId == null && nullToAbsent
          ? const Value.absent()
          : Value(firestoreId),
      lastUpdated: Value(lastUpdated),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      id: Value(id),
      tenancyId: Value(tenancyId),
      ownerId: Value(ownerId),
      month: Value(month),
      billNumber: billNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(billNumber),
      billPeriodStart: billPeriodStart == null && nullToAbsent
          ? const Value.absent()
          : Value(billPeriodStart),
      billPeriodEnd: billPeriodEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(billPeriodEnd),
      billGeneratedDate: Value(billGeneratedDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      baseRent: Value(baseRent),
      electricAmount: Value(electricAmount),
      otherCharges: Value(otherCharges),
      discount: Value(discount),
      totalDue: Value(totalDue),
      totalPaid: Value(totalPaid),
      status: Value(status),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory RentCycle.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RentCycle(
      firestoreId: serializer.fromJson<String?>(json['firestoreId']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      id: serializer.fromJson<String>(json['id']),
      tenancyId: serializer.fromJson<String>(json['tenancyId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      month: serializer.fromJson<String>(json['month']),
      billNumber: serializer.fromJson<String?>(json['billNumber']),
      billPeriodStart: serializer.fromJson<DateTime?>(json['billPeriodStart']),
      billPeriodEnd: serializer.fromJson<DateTime?>(json['billPeriodEnd']),
      billGeneratedDate:
          serializer.fromJson<DateTime>(json['billGeneratedDate']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      baseRent: serializer.fromJson<double>(json['baseRent']),
      electricAmount: serializer.fromJson<double>(json['electricAmount']),
      otherCharges: serializer.fromJson<double>(json['otherCharges']),
      discount: serializer.fromJson<double>(json['discount']),
      totalDue: serializer.fromJson<double>(json['totalDue']),
      totalPaid: serializer.fromJson<double>(json['totalPaid']),
      status: serializer.fromJson<int>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'firestoreId': serializer.toJson<String?>(firestoreId),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'id': serializer.toJson<String>(id),
      'tenancyId': serializer.toJson<String>(tenancyId),
      'ownerId': serializer.toJson<String>(ownerId),
      'month': serializer.toJson<String>(month),
      'billNumber': serializer.toJson<String?>(billNumber),
      'billPeriodStart': serializer.toJson<DateTime?>(billPeriodStart),
      'billPeriodEnd': serializer.toJson<DateTime?>(billPeriodEnd),
      'billGeneratedDate': serializer.toJson<DateTime>(billGeneratedDate),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'baseRent': serializer.toJson<double>(baseRent),
      'electricAmount': serializer.toJson<double>(electricAmount),
      'otherCharges': serializer.toJson<double>(otherCharges),
      'discount': serializer.toJson<double>(discount),
      'totalDue': serializer.toJson<double>(totalDue),
      'totalPaid': serializer.toJson<double>(totalPaid),
      'status': serializer.toJson<int>(status),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  RentCycle copyWith(
          {Value<String?> firestoreId = const Value.absent(),
          DateTime? lastUpdated,
          bool? isSynced,
          bool? isDeleted,
          String? id,
          String? tenancyId,
          String? ownerId,
          String? month,
          Value<String?> billNumber = const Value.absent(),
          Value<DateTime?> billPeriodStart = const Value.absent(),
          Value<DateTime?> billPeriodEnd = const Value.absent(),
          DateTime? billGeneratedDate,
          Value<DateTime?> dueDate = const Value.absent(),
          double? baseRent,
          double? electricAmount,
          double? otherCharges,
          double? discount,
          double? totalDue,
          double? totalPaid,
          int? status,
          Value<String?> notes = const Value.absent()}) =>
      RentCycle(
        firestoreId: firestoreId.present ? firestoreId.value : this.firestoreId,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        isSynced: isSynced ?? this.isSynced,
        isDeleted: isDeleted ?? this.isDeleted,
        id: id ?? this.id,
        tenancyId: tenancyId ?? this.tenancyId,
        ownerId: ownerId ?? this.ownerId,
        month: month ?? this.month,
        billNumber: billNumber.present ? billNumber.value : this.billNumber,
        billPeriodStart: billPeriodStart.present
            ? billPeriodStart.value
            : this.billPeriodStart,
        billPeriodEnd:
            billPeriodEnd.present ? billPeriodEnd.value : this.billPeriodEnd,
        billGeneratedDate: billGeneratedDate ?? this.billGeneratedDate,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        baseRent: baseRent ?? this.baseRent,
        electricAmount: electricAmount ?? this.electricAmount,
        otherCharges: otherCharges ?? this.otherCharges,
        discount: discount ?? this.discount,
        totalDue: totalDue ?? this.totalDue,
        totalPaid: totalPaid ?? this.totalPaid,
        status: status ?? this.status,
        notes: notes.present ? notes.value : this.notes,
      );
  RentCycle copyWithCompanion(RentCyclesCompanion data) {
    return RentCycle(
      firestoreId:
          data.firestoreId.present ? data.firestoreId.value : this.firestoreId,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      id: data.id.present ? data.id.value : this.id,
      tenancyId: data.tenancyId.present ? data.tenancyId.value : this.tenancyId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      month: data.month.present ? data.month.value : this.month,
      billNumber:
          data.billNumber.present ? data.billNumber.value : this.billNumber,
      billPeriodStart: data.billPeriodStart.present
          ? data.billPeriodStart.value
          : this.billPeriodStart,
      billPeriodEnd: data.billPeriodEnd.present
          ? data.billPeriodEnd.value
          : this.billPeriodEnd,
      billGeneratedDate: data.billGeneratedDate.present
          ? data.billGeneratedDate.value
          : this.billGeneratedDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      baseRent: data.baseRent.present ? data.baseRent.value : this.baseRent,
      electricAmount: data.electricAmount.present
          ? data.electricAmount.value
          : this.electricAmount,
      otherCharges: data.otherCharges.present
          ? data.otherCharges.value
          : this.otherCharges,
      discount: data.discount.present ? data.discount.value : this.discount,
      totalDue: data.totalDue.present ? data.totalDue.value : this.totalDue,
      totalPaid: data.totalPaid.present ? data.totalPaid.value : this.totalPaid,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RentCycle(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('tenancyId: $tenancyId, ')
          ..write('ownerId: $ownerId, ')
          ..write('month: $month, ')
          ..write('billNumber: $billNumber, ')
          ..write('billPeriodStart: $billPeriodStart, ')
          ..write('billPeriodEnd: $billPeriodEnd, ')
          ..write('billGeneratedDate: $billGeneratedDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('baseRent: $baseRent, ')
          ..write('electricAmount: $electricAmount, ')
          ..write('otherCharges: $otherCharges, ')
          ..write('discount: $discount, ')
          ..write('totalDue: $totalDue, ')
          ..write('totalPaid: $totalPaid, ')
          ..write('status: $status, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        firestoreId,
        lastUpdated,
        isSynced,
        isDeleted,
        id,
        tenancyId,
        ownerId,
        month,
        billNumber,
        billPeriodStart,
        billPeriodEnd,
        billGeneratedDate,
        dueDate,
        baseRent,
        electricAmount,
        otherCharges,
        discount,
        totalDue,
        totalPaid,
        status,
        notes
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RentCycle &&
          other.firestoreId == this.firestoreId &&
          other.lastUpdated == this.lastUpdated &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.id == this.id &&
          other.tenancyId == this.tenancyId &&
          other.ownerId == this.ownerId &&
          other.month == this.month &&
          other.billNumber == this.billNumber &&
          other.billPeriodStart == this.billPeriodStart &&
          other.billPeriodEnd == this.billPeriodEnd &&
          other.billGeneratedDate == this.billGeneratedDate &&
          other.dueDate == this.dueDate &&
          other.baseRent == this.baseRent &&
          other.electricAmount == this.electricAmount &&
          other.otherCharges == this.otherCharges &&
          other.discount == this.discount &&
          other.totalDue == this.totalDue &&
          other.totalPaid == this.totalPaid &&
          other.status == this.status &&
          other.notes == this.notes);
}

class RentCyclesCompanion extends UpdateCompanion<RentCycle> {
  final Value<String?> firestoreId;
  final Value<DateTime> lastUpdated;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String> id;
  final Value<String> tenancyId;
  final Value<String> ownerId;
  final Value<String> month;
  final Value<String?> billNumber;
  final Value<DateTime?> billPeriodStart;
  final Value<DateTime?> billPeriodEnd;
  final Value<DateTime> billGeneratedDate;
  final Value<DateTime?> dueDate;
  final Value<double> baseRent;
  final Value<double> electricAmount;
  final Value<double> otherCharges;
  final Value<double> discount;
  final Value<double> totalDue;
  final Value<double> totalPaid;
  final Value<int> status;
  final Value<String?> notes;
  final Value<int> rowid;
  const RentCyclesCompanion({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.id = const Value.absent(),
    this.tenancyId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.month = const Value.absent(),
    this.billNumber = const Value.absent(),
    this.billPeriodStart = const Value.absent(),
    this.billPeriodEnd = const Value.absent(),
    this.billGeneratedDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.baseRent = const Value.absent(),
    this.electricAmount = const Value.absent(),
    this.otherCharges = const Value.absent(),
    this.discount = const Value.absent(),
    this.totalDue = const Value.absent(),
    this.totalPaid = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RentCyclesCompanion.insert({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String id,
    required String tenancyId,
    required String ownerId,
    required String month,
    this.billNumber = const Value.absent(),
    this.billPeriodStart = const Value.absent(),
    this.billPeriodEnd = const Value.absent(),
    this.billGeneratedDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    required double baseRent,
    this.electricAmount = const Value.absent(),
    this.otherCharges = const Value.absent(),
    this.discount = const Value.absent(),
    required double totalDue,
    this.totalPaid = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenancyId = Value(tenancyId),
        ownerId = Value(ownerId),
        month = Value(month),
        baseRent = Value(baseRent),
        totalDue = Value(totalDue);
  static Insertable<RentCycle> custom({
    Expression<String>? firestoreId,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? id,
    Expression<String>? tenancyId,
    Expression<String>? ownerId,
    Expression<String>? month,
    Expression<String>? billNumber,
    Expression<DateTime>? billPeriodStart,
    Expression<DateTime>? billPeriodEnd,
    Expression<DateTime>? billGeneratedDate,
    Expression<DateTime>? dueDate,
    Expression<double>? baseRent,
    Expression<double>? electricAmount,
    Expression<double>? otherCharges,
    Expression<double>? discount,
    Expression<double>? totalDue,
    Expression<double>? totalPaid,
    Expression<int>? status,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (firestoreId != null) 'firestore_id': firestoreId,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (id != null) 'id': id,
      if (tenancyId != null) 'tenancy_id': tenancyId,
      if (ownerId != null) 'owner_id': ownerId,
      if (month != null) 'month': month,
      if (billNumber != null) 'bill_number': billNumber,
      if (billPeriodStart != null) 'bill_period_start': billPeriodStart,
      if (billPeriodEnd != null) 'bill_period_end': billPeriodEnd,
      if (billGeneratedDate != null) 'bill_generated_date': billGeneratedDate,
      if (dueDate != null) 'due_date': dueDate,
      if (baseRent != null) 'base_rent': baseRent,
      if (electricAmount != null) 'electric_amount': electricAmount,
      if (otherCharges != null) 'other_charges': otherCharges,
      if (discount != null) 'discount': discount,
      if (totalDue != null) 'total_due': totalDue,
      if (totalPaid != null) 'total_paid': totalPaid,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RentCyclesCompanion copyWith(
      {Value<String?>? firestoreId,
      Value<DateTime>? lastUpdated,
      Value<bool>? isSynced,
      Value<bool>? isDeleted,
      Value<String>? id,
      Value<String>? tenancyId,
      Value<String>? ownerId,
      Value<String>? month,
      Value<String?>? billNumber,
      Value<DateTime?>? billPeriodStart,
      Value<DateTime?>? billPeriodEnd,
      Value<DateTime>? billGeneratedDate,
      Value<DateTime?>? dueDate,
      Value<double>? baseRent,
      Value<double>? electricAmount,
      Value<double>? otherCharges,
      Value<double>? discount,
      Value<double>? totalDue,
      Value<double>? totalPaid,
      Value<int>? status,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return RentCyclesCompanion(
      firestoreId: firestoreId ?? this.firestoreId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      id: id ?? this.id,
      tenancyId: tenancyId ?? this.tenancyId,
      ownerId: ownerId ?? this.ownerId,
      month: month ?? this.month,
      billNumber: billNumber ?? this.billNumber,
      billPeriodStart: billPeriodStart ?? this.billPeriodStart,
      billPeriodEnd: billPeriodEnd ?? this.billPeriodEnd,
      billGeneratedDate: billGeneratedDate ?? this.billGeneratedDate,
      dueDate: dueDate ?? this.dueDate,
      baseRent: baseRent ?? this.baseRent,
      electricAmount: electricAmount ?? this.electricAmount,
      otherCharges: otherCharges ?? this.otherCharges,
      discount: discount ?? this.discount,
      totalDue: totalDue ?? this.totalDue,
      totalPaid: totalPaid ?? this.totalPaid,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (firestoreId.present) {
      map['firestore_id'] = Variable<String>(firestoreId.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenancyId.present) {
      map['tenancy_id'] = Variable<String>(tenancyId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (billNumber.present) {
      map['bill_number'] = Variable<String>(billNumber.value);
    }
    if (billPeriodStart.present) {
      map['bill_period_start'] = Variable<DateTime>(billPeriodStart.value);
    }
    if (billPeriodEnd.present) {
      map['bill_period_end'] = Variable<DateTime>(billPeriodEnd.value);
    }
    if (billGeneratedDate.present) {
      map['bill_generated_date'] = Variable<DateTime>(billGeneratedDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (baseRent.present) {
      map['base_rent'] = Variable<double>(baseRent.value);
    }
    if (electricAmount.present) {
      map['electric_amount'] = Variable<double>(electricAmount.value);
    }
    if (otherCharges.present) {
      map['other_charges'] = Variable<double>(otherCharges.value);
    }
    if (discount.present) {
      map['discount'] = Variable<double>(discount.value);
    }
    if (totalDue.present) {
      map['total_due'] = Variable<double>(totalDue.value);
    }
    if (totalPaid.present) {
      map['total_paid'] = Variable<double>(totalPaid.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RentCyclesCompanion(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('tenancyId: $tenancyId, ')
          ..write('ownerId: $ownerId, ')
          ..write('month: $month, ')
          ..write('billNumber: $billNumber, ')
          ..write('billPeriodStart: $billPeriodStart, ')
          ..write('billPeriodEnd: $billPeriodEnd, ')
          ..write('billGeneratedDate: $billGeneratedDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('baseRent: $baseRent, ')
          ..write('electricAmount: $electricAmount, ')
          ..write('otherCharges: $otherCharges, ')
          ..write('discount: $discount, ')
          ..write('totalDue: $totalDue, ')
          ..write('totalPaid: $totalPaid, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentChannelsTable extends PaymentChannels
    with TableInfo<$PaymentChannelsTable, PaymentChannel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentChannelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _firestoreIdMeta =
      const VerificationMeta('firestoreId');
  @override
  late final GeneratedColumn<String> firestoreId = GeneratedColumn<String>(
      'firestore_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _detailsMeta =
      const VerificationMeta('details');
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
      'details', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [firestoreId, lastUpdated, isSynced, isDeleted, id, name, type, details];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_channels';
  @override
  VerificationContext validateIntegrity(Insertable<PaymentChannel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('firestore_id')) {
      context.handle(
          _firestoreIdMeta,
          firestoreId.isAcceptableOrUnknown(
              data['firestore_id']!, _firestoreIdMeta));
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('details')) {
      context.handle(_detailsMeta,
          details.isAcceptableOrUnknown(data['details']!, _detailsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentChannel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentChannel(
      firestoreId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}firestore_id']),
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      details: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}details']),
    );
  }

  @override
  $PaymentChannelsTable createAlias(String alias) {
    return $PaymentChannelsTable(attachedDatabase, alias);
  }
}

class PaymentChannel extends DataClass implements Insertable<PaymentChannel> {
  final String? firestoreId;
  final DateTime lastUpdated;
  final bool isSynced;
  final bool isDeleted;
  final int id;
  final String name;
  final String type;
  final String? details;
  const PaymentChannel(
      {this.firestoreId,
      required this.lastUpdated,
      required this.isSynced,
      required this.isDeleted,
      required this.id,
      required this.name,
      required this.type,
      this.details});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || firestoreId != null) {
      map['firestore_id'] = Variable<String>(firestoreId);
    }
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    return map;
  }

  PaymentChannelsCompanion toCompanion(bool nullToAbsent) {
    return PaymentChannelsCompanion(
      firestoreId: firestoreId == null && nullToAbsent
          ? const Value.absent()
          : Value(firestoreId),
      lastUpdated: Value(lastUpdated),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      id: Value(id),
      name: Value(name),
      type: Value(type),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
    );
  }

  factory PaymentChannel.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentChannel(
      firestoreId: serializer.fromJson<String?>(json['firestoreId']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      details: serializer.fromJson<String?>(json['details']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'firestoreId': serializer.toJson<String?>(firestoreId),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'details': serializer.toJson<String?>(details),
    };
  }

  PaymentChannel copyWith(
          {Value<String?> firestoreId = const Value.absent(),
          DateTime? lastUpdated,
          bool? isSynced,
          bool? isDeleted,
          int? id,
          String? name,
          String? type,
          Value<String?> details = const Value.absent()}) =>
      PaymentChannel(
        firestoreId: firestoreId.present ? firestoreId.value : this.firestoreId,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        isSynced: isSynced ?? this.isSynced,
        isDeleted: isDeleted ?? this.isDeleted,
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        details: details.present ? details.value : this.details,
      );
  PaymentChannel copyWithCompanion(PaymentChannelsCompanion data) {
    return PaymentChannel(
      firestoreId:
          data.firestoreId.present ? data.firestoreId.value : this.firestoreId,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      details: data.details.present ? data.details.value : this.details,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentChannel(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('details: $details')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      firestoreId, lastUpdated, isSynced, isDeleted, id, name, type, details);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentChannel &&
          other.firestoreId == this.firestoreId &&
          other.lastUpdated == this.lastUpdated &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.details == this.details);
}

class PaymentChannelsCompanion extends UpdateCompanion<PaymentChannel> {
  final Value<String?> firestoreId;
  final Value<DateTime> lastUpdated;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> details;
  const PaymentChannelsCompanion({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.details = const Value.absent(),
  });
  PaymentChannelsCompanion.insert({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.id = const Value.absent(),
    required String name,
    required String type,
    this.details = const Value.absent(),
  })  : name = Value(name),
        type = Value(type);
  static Insertable<PaymentChannel> custom({
    Expression<String>? firestoreId,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? details,
  }) {
    return RawValuesInsertable({
      if (firestoreId != null) 'firestore_id': firestoreId,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (details != null) 'details': details,
    });
  }

  PaymentChannelsCompanion copyWith(
      {Value<String?>? firestoreId,
      Value<DateTime>? lastUpdated,
      Value<bool>? isSynced,
      Value<bool>? isDeleted,
      Value<int>? id,
      Value<String>? name,
      Value<String>? type,
      Value<String?>? details}) {
    return PaymentChannelsCompanion(
      firestoreId: firestoreId ?? this.firestoreId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      details: details ?? this.details,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (firestoreId.present) {
      map['firestore_id'] = Variable<String>(firestoreId.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentChannelsCompanion(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('details: $details')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _firestoreIdMeta =
      const VerificationMeta('firestoreId');
  @override
  late final GeneratedColumn<String> firestoreId = GeneratedColumn<String>(
      'firestore_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rentCycleIdMeta =
      const VerificationMeta('rentCycleId');
  @override
  late final GeneratedColumn<String> rentCycleId = GeneratedColumn<String>(
      'rent_cycle_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES rent_cycles (id) ON DELETE CASCADE'));
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES owners (id) ON DELETE CASCADE'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
      'method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _channelIdMeta =
      const VerificationMeta('channelId');
  @override
  late final GeneratedColumn<int> channelId = GeneratedColumn<int>(
      'channel_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES payment_channels (id)'));
  static const VerificationMeta _referenceIdMeta =
      const VerificationMeta('referenceId');
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
      'reference_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _collectedByMeta =
      const VerificationMeta('collectedBy');
  @override
  late final GeneratedColumn<String> collectedBy = GeneratedColumn<String>(
      'collected_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        firestoreId,
        lastUpdated,
        isSynced,
        isDeleted,
        id,
        rentCycleId,
        ownerId,
        amount,
        date,
        method,
        channelId,
        referenceId,
        collectedBy,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(Insertable<Payment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('firestore_id')) {
      context.handle(
          _firestoreIdMeta,
          firestoreId.isAcceptableOrUnknown(
              data['firestore_id']!, _firestoreIdMeta));
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('rent_cycle_id')) {
      context.handle(
          _rentCycleIdMeta,
          rentCycleId.isAcceptableOrUnknown(
              data['rent_cycle_id']!, _rentCycleIdMeta));
    } else if (isInserting) {
      context.missing(_rentCycleIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('method')) {
      context.handle(_methodMeta,
          method.isAcceptableOrUnknown(data['method']!, _methodMeta));
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('channel_id')) {
      context.handle(_channelIdMeta,
          channelId.isAcceptableOrUnknown(data['channel_id']!, _channelIdMeta));
    }
    if (data.containsKey('reference_id')) {
      context.handle(
          _referenceIdMeta,
          referenceId.isAcceptableOrUnknown(
              data['reference_id']!, _referenceIdMeta));
    }
    if (data.containsKey('collected_by')) {
      context.handle(
          _collectedByMeta,
          collectedBy.isAcceptableOrUnknown(
              data['collected_by']!, _collectedByMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      firestoreId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}firestore_id']),
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      rentCycleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rent_cycle_id'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      method: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method'])!,
      channelId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}channel_id']),
      referenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_id']),
      collectedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}collected_by']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final String? firestoreId;
  final DateTime lastUpdated;
  final bool isSynced;
  final bool isDeleted;
  final String id;
  final String rentCycleId;
  final String ownerId;
  final double amount;
  final DateTime date;
  final String method;
  final int? channelId;
  final String? referenceId;
  final String? collectedBy;
  final String? notes;
  const Payment(
      {this.firestoreId,
      required this.lastUpdated,
      required this.isSynced,
      required this.isDeleted,
      required this.id,
      required this.rentCycleId,
      required this.ownerId,
      required this.amount,
      required this.date,
      required this.method,
      this.channelId,
      this.referenceId,
      this.collectedBy,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || firestoreId != null) {
      map['firestore_id'] = Variable<String>(firestoreId);
    }
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['id'] = Variable<String>(id);
    map['rent_cycle_id'] = Variable<String>(rentCycleId);
    map['owner_id'] = Variable<String>(ownerId);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    map['method'] = Variable<String>(method);
    if (!nullToAbsent || channelId != null) {
      map['channel_id'] = Variable<int>(channelId);
    }
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<String>(referenceId);
    }
    if (!nullToAbsent || collectedBy != null) {
      map['collected_by'] = Variable<String>(collectedBy);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      firestoreId: firestoreId == null && nullToAbsent
          ? const Value.absent()
          : Value(firestoreId),
      lastUpdated: Value(lastUpdated),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      id: Value(id),
      rentCycleId: Value(rentCycleId),
      ownerId: Value(ownerId),
      amount: Value(amount),
      date: Value(date),
      method: Value(method),
      channelId: channelId == null && nullToAbsent
          ? const Value.absent()
          : Value(channelId),
      referenceId: referenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceId),
      collectedBy: collectedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(collectedBy),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      firestoreId: serializer.fromJson<String?>(json['firestoreId']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      id: serializer.fromJson<String>(json['id']),
      rentCycleId: serializer.fromJson<String>(json['rentCycleId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      method: serializer.fromJson<String>(json['method']),
      channelId: serializer.fromJson<int?>(json['channelId']),
      referenceId: serializer.fromJson<String?>(json['referenceId']),
      collectedBy: serializer.fromJson<String?>(json['collectedBy']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'firestoreId': serializer.toJson<String?>(firestoreId),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'id': serializer.toJson<String>(id),
      'rentCycleId': serializer.toJson<String>(rentCycleId),
      'ownerId': serializer.toJson<String>(ownerId),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'method': serializer.toJson<String>(method),
      'channelId': serializer.toJson<int?>(channelId),
      'referenceId': serializer.toJson<String?>(referenceId),
      'collectedBy': serializer.toJson<String?>(collectedBy),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Payment copyWith(
          {Value<String?> firestoreId = const Value.absent(),
          DateTime? lastUpdated,
          bool? isSynced,
          bool? isDeleted,
          String? id,
          String? rentCycleId,
          String? ownerId,
          double? amount,
          DateTime? date,
          String? method,
          Value<int?> channelId = const Value.absent(),
          Value<String?> referenceId = const Value.absent(),
          Value<String?> collectedBy = const Value.absent(),
          Value<String?> notes = const Value.absent()}) =>
      Payment(
        firestoreId: firestoreId.present ? firestoreId.value : this.firestoreId,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        isSynced: isSynced ?? this.isSynced,
        isDeleted: isDeleted ?? this.isDeleted,
        id: id ?? this.id,
        rentCycleId: rentCycleId ?? this.rentCycleId,
        ownerId: ownerId ?? this.ownerId,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        method: method ?? this.method,
        channelId: channelId.present ? channelId.value : this.channelId,
        referenceId: referenceId.present ? referenceId.value : this.referenceId,
        collectedBy: collectedBy.present ? collectedBy.value : this.collectedBy,
        notes: notes.present ? notes.value : this.notes,
      );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      firestoreId:
          data.firestoreId.present ? data.firestoreId.value : this.firestoreId,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      id: data.id.present ? data.id.value : this.id,
      rentCycleId:
          data.rentCycleId.present ? data.rentCycleId.value : this.rentCycleId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      method: data.method.present ? data.method.value : this.method,
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      referenceId:
          data.referenceId.present ? data.referenceId.value : this.referenceId,
      collectedBy:
          data.collectedBy.present ? data.collectedBy.value : this.collectedBy,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('rentCycleId: $rentCycleId, ')
          ..write('ownerId: $ownerId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('method: $method, ')
          ..write('channelId: $channelId, ')
          ..write('referenceId: $referenceId, ')
          ..write('collectedBy: $collectedBy, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      firestoreId,
      lastUpdated,
      isSynced,
      isDeleted,
      id,
      rentCycleId,
      ownerId,
      amount,
      date,
      method,
      channelId,
      referenceId,
      collectedBy,
      notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.firestoreId == this.firestoreId &&
          other.lastUpdated == this.lastUpdated &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.id == this.id &&
          other.rentCycleId == this.rentCycleId &&
          other.ownerId == this.ownerId &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.method == this.method &&
          other.channelId == this.channelId &&
          other.referenceId == this.referenceId &&
          other.collectedBy == this.collectedBy &&
          other.notes == this.notes);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<String?> firestoreId;
  final Value<DateTime> lastUpdated;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String> id;
  final Value<String> rentCycleId;
  final Value<String> ownerId;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<String> method;
  final Value<int?> channelId;
  final Value<String?> referenceId;
  final Value<String?> collectedBy;
  final Value<String?> notes;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.id = const Value.absent(),
    this.rentCycleId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.method = const Value.absent(),
    this.channelId = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.collectedBy = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String id,
    required String rentCycleId,
    required String ownerId,
    required double amount,
    required DateTime date,
    required String method,
    this.channelId = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.collectedBy = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        rentCycleId = Value(rentCycleId),
        ownerId = Value(ownerId),
        amount = Value(amount),
        date = Value(date),
        method = Value(method);
  static Insertable<Payment> custom({
    Expression<String>? firestoreId,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? id,
    Expression<String>? rentCycleId,
    Expression<String>? ownerId,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<String>? method,
    Expression<int>? channelId,
    Expression<String>? referenceId,
    Expression<String>? collectedBy,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (firestoreId != null) 'firestore_id': firestoreId,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (id != null) 'id': id,
      if (rentCycleId != null) 'rent_cycle_id': rentCycleId,
      if (ownerId != null) 'owner_id': ownerId,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (method != null) 'method': method,
      if (channelId != null) 'channel_id': channelId,
      if (referenceId != null) 'reference_id': referenceId,
      if (collectedBy != null) 'collected_by': collectedBy,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith(
      {Value<String?>? firestoreId,
      Value<DateTime>? lastUpdated,
      Value<bool>? isSynced,
      Value<bool>? isDeleted,
      Value<String>? id,
      Value<String>? rentCycleId,
      Value<String>? ownerId,
      Value<double>? amount,
      Value<DateTime>? date,
      Value<String>? method,
      Value<int?>? channelId,
      Value<String?>? referenceId,
      Value<String?>? collectedBy,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return PaymentsCompanion(
      firestoreId: firestoreId ?? this.firestoreId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      id: id ?? this.id,
      rentCycleId: rentCycleId ?? this.rentCycleId,
      ownerId: ownerId ?? this.ownerId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      method: method ?? this.method,
      channelId: channelId ?? this.channelId,
      referenceId: referenceId ?? this.referenceId,
      collectedBy: collectedBy ?? this.collectedBy,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (firestoreId.present) {
      map['firestore_id'] = Variable<String>(firestoreId.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (rentCycleId.present) {
      map['rent_cycle_id'] = Variable<String>(rentCycleId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (channelId.present) {
      map['channel_id'] = Variable<int>(channelId.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (collectedBy.present) {
      map['collected_by'] = Variable<String>(collectedBy.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('rentCycleId: $rentCycleId, ')
          ..write('ownerId: $ownerId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('method: $method, ')
          ..write('channelId: $channelId, ')
          ..write('referenceId: $referenceId, ')
          ..write('collectedBy: $collectedBy, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _firestoreIdMeta =
      const VerificationMeta('firestoreId');
  @override
  late final GeneratedColumn<String> firestoreId = GeneratedColumn<String>(
      'firestore_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES owners (id) ON DELETE CASCADE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        firestoreId,
        lastUpdated,
        isSynced,
        isDeleted,
        id,
        ownerId,
        title,
        date,
        amount,
        category,
        description
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(Insertable<Expense> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('firestore_id')) {
      context.handle(
          _firestoreIdMeta,
          firestoreId.isAcceptableOrUnknown(
              data['firestore_id']!, _firestoreIdMeta));
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      firestoreId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}firestore_id']),
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final String? firestoreId;
  final DateTime lastUpdated;
  final bool isSynced;
  final bool isDeleted;
  final String id;
  final String ownerId;
  final String title;
  final DateTime date;
  final double amount;
  final String category;
  final String? description;
  const Expense(
      {this.firestoreId,
      required this.lastUpdated,
      required this.isSynced,
      required this.isDeleted,
      required this.id,
      required this.ownerId,
      required this.title,
      required this.date,
      required this.amount,
      required this.category,
      this.description});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || firestoreId != null) {
      map['firestore_id'] = Variable<String>(firestoreId);
    }
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['title'] = Variable<String>(title);
    map['date'] = Variable<DateTime>(date);
    map['amount'] = Variable<double>(amount);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      firestoreId: firestoreId == null && nullToAbsent
          ? const Value.absent()
          : Value(firestoreId),
      lastUpdated: Value(lastUpdated),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      id: Value(id),
      ownerId: Value(ownerId),
      title: Value(title),
      date: Value(date),
      amount: Value(amount),
      category: Value(category),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      firestoreId: serializer.fromJson<String?>(json['firestoreId']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<DateTime>(json['date']),
      amount: serializer.fromJson<double>(json['amount']),
      category: serializer.fromJson<String>(json['category']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'firestoreId': serializer.toJson<String?>(firestoreId),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<DateTime>(date),
      'amount': serializer.toJson<double>(amount),
      'category': serializer.toJson<String>(category),
      'description': serializer.toJson<String?>(description),
    };
  }

  Expense copyWith(
          {Value<String?> firestoreId = const Value.absent(),
          DateTime? lastUpdated,
          bool? isSynced,
          bool? isDeleted,
          String? id,
          String? ownerId,
          String? title,
          DateTime? date,
          double? amount,
          String? category,
          Value<String?> description = const Value.absent()}) =>
      Expense(
        firestoreId: firestoreId.present ? firestoreId.value : this.firestoreId,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        isSynced: isSynced ?? this.isSynced,
        isDeleted: isDeleted ?? this.isDeleted,
        id: id ?? this.id,
        ownerId: ownerId ?? this.ownerId,
        title: title ?? this.title,
        date: date ?? this.date,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        description: description.present ? description.value : this.description,
      );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      firestoreId:
          data.firestoreId.present ? data.firestoreId.value : this.firestoreId,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
      amount: data.amount.present ? data.amount.value : this.amount,
      category: data.category.present ? data.category.value : this.category,
      description:
          data.description.present ? data.description.value : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(firestoreId, lastUpdated, isSynced, isDeleted,
      id, ownerId, title, date, amount, category, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.firestoreId == this.firestoreId &&
          other.lastUpdated == this.lastUpdated &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.title == this.title &&
          other.date == this.date &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.description == this.description);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<String?> firestoreId;
  final Value<DateTime> lastUpdated;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> title;
  final Value<DateTime> date;
  final Value<double> amount;
  final Value<String> category;
  final Value<String?> description;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String id,
    required String ownerId,
    required String title,
    required DateTime date,
    required double amount,
    required String category,
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        ownerId = Value(ownerId),
        title = Value(title),
        date = Value(date),
        amount = Value(amount),
        category = Value(category);
  static Insertable<Expense> custom({
    Expression<String>? firestoreId,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? title,
    Expression<DateTime>? date,
    Expression<double>? amount,
    Expression<String>? category,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (firestoreId != null) 'firestore_id': firestoreId,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith(
      {Value<String?>? firestoreId,
      Value<DateTime>? lastUpdated,
      Value<bool>? isSynced,
      Value<bool>? isDeleted,
      Value<String>? id,
      Value<String>? ownerId,
      Value<String>? title,
      Value<DateTime>? date,
      Value<double>? amount,
      Value<String>? category,
      Value<String?>? description,
      Value<int>? rowid}) {
    return ExpensesCompanion(
      firestoreId: firestoreId ?? this.firestoreId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (firestoreId.present) {
      map['firestore_id'] = Variable<String>(firestoreId.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ElectricReadingsTable extends ElectricReadings
    with TableInfo<$ElectricReadingsTable, ElectricReading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ElectricReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _firestoreIdMeta =
      const VerificationMeta('firestoreId');
  @override
  late final GeneratedColumn<String> firestoreId = GeneratedColumn<String>(
      'firestore_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
      'unit_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES units (id) ON DELETE CASCADE'));
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES owners (id) ON DELETE CASCADE'));
  static const VerificationMeta _readingDateMeta =
      const VerificationMeta('readingDate');
  @override
  late final GeneratedColumn<DateTime> readingDate = GeneratedColumn<DateTime>(
      'reading_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _meterNameMeta =
      const VerificationMeta('meterName');
  @override
  late final GeneratedColumn<String> meterName = GeneratedColumn<String>(
      'meter_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _prevReadingMeta =
      const VerificationMeta('prevReading');
  @override
  late final GeneratedColumn<double> prevReading = GeneratedColumn<double>(
      'prev_reading', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _currentReadingMeta =
      const VerificationMeta('currentReading');
  @override
  late final GeneratedColumn<double> currentReading = GeneratedColumn<double>(
      'current_reading', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _ratePerUnitMeta =
      const VerificationMeta('ratePerUnit');
  @override
  late final GeneratedColumn<double> ratePerUnit = GeneratedColumn<double>(
      'rate_per_unit', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        firestoreId,
        lastUpdated,
        isSynced,
        isDeleted,
        id,
        unitId,
        ownerId,
        readingDate,
        meterName,
        prevReading,
        currentReading,
        ratePerUnit,
        amount,
        imagePath,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'electric_readings';
  @override
  VerificationContext validateIntegrity(Insertable<ElectricReading> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('firestore_id')) {
      context.handle(
          _firestoreIdMeta,
          firestoreId.isAcceptableOrUnknown(
              data['firestore_id']!, _firestoreIdMeta));
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('unit_id')) {
      context.handle(_unitIdMeta,
          unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta));
    } else if (isInserting) {
      context.missing(_unitIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('reading_date')) {
      context.handle(
          _readingDateMeta,
          readingDate.isAcceptableOrUnknown(
              data['reading_date']!, _readingDateMeta));
    } else if (isInserting) {
      context.missing(_readingDateMeta);
    }
    if (data.containsKey('meter_name')) {
      context.handle(_meterNameMeta,
          meterName.isAcceptableOrUnknown(data['meter_name']!, _meterNameMeta));
    }
    if (data.containsKey('prev_reading')) {
      context.handle(
          _prevReadingMeta,
          prevReading.isAcceptableOrUnknown(
              data['prev_reading']!, _prevReadingMeta));
    }
    if (data.containsKey('current_reading')) {
      context.handle(
          _currentReadingMeta,
          currentReading.isAcceptableOrUnknown(
              data['current_reading']!, _currentReadingMeta));
    } else if (isInserting) {
      context.missing(_currentReadingMeta);
    }
    if (data.containsKey('rate_per_unit')) {
      context.handle(
          _ratePerUnitMeta,
          ratePerUnit.isAcceptableOrUnknown(
              data['rate_per_unit']!, _ratePerUnitMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ElectricReading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ElectricReading(
      firestoreId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}firestore_id']),
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      unitId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit_id'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id'])!,
      readingDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}reading_date'])!,
      meterName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meter_name']),
      prevReading: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}prev_reading'])!,
      currentReading: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}current_reading'])!,
      ratePerUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rate_per_unit'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $ElectricReadingsTable createAlias(String alias) {
    return $ElectricReadingsTable(attachedDatabase, alias);
  }
}

class ElectricReading extends DataClass implements Insertable<ElectricReading> {
  final String? firestoreId;
  final DateTime lastUpdated;
  final bool isSynced;
  final bool isDeleted;
  final String id;
  final String unitId;
  final String ownerId;
  final DateTime readingDate;
  final String? meterName;
  final double prevReading;
  final double currentReading;
  final double ratePerUnit;
  final double amount;
  final String? imagePath;
  final String? notes;
  const ElectricReading(
      {this.firestoreId,
      required this.lastUpdated,
      required this.isSynced,
      required this.isDeleted,
      required this.id,
      required this.unitId,
      required this.ownerId,
      required this.readingDate,
      this.meterName,
      required this.prevReading,
      required this.currentReading,
      required this.ratePerUnit,
      required this.amount,
      this.imagePath,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || firestoreId != null) {
      map['firestore_id'] = Variable<String>(firestoreId);
    }
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['id'] = Variable<String>(id);
    map['unit_id'] = Variable<String>(unitId);
    map['owner_id'] = Variable<String>(ownerId);
    map['reading_date'] = Variable<DateTime>(readingDate);
    if (!nullToAbsent || meterName != null) {
      map['meter_name'] = Variable<String>(meterName);
    }
    map['prev_reading'] = Variable<double>(prevReading);
    map['current_reading'] = Variable<double>(currentReading);
    map['rate_per_unit'] = Variable<double>(ratePerUnit);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  ElectricReadingsCompanion toCompanion(bool nullToAbsent) {
    return ElectricReadingsCompanion(
      firestoreId: firestoreId == null && nullToAbsent
          ? const Value.absent()
          : Value(firestoreId),
      lastUpdated: Value(lastUpdated),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      id: Value(id),
      unitId: Value(unitId),
      ownerId: Value(ownerId),
      readingDate: Value(readingDate),
      meterName: meterName == null && nullToAbsent
          ? const Value.absent()
          : Value(meterName),
      prevReading: Value(prevReading),
      currentReading: Value(currentReading),
      ratePerUnit: Value(ratePerUnit),
      amount: Value(amount),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory ElectricReading.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ElectricReading(
      firestoreId: serializer.fromJson<String?>(json['firestoreId']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      id: serializer.fromJson<String>(json['id']),
      unitId: serializer.fromJson<String>(json['unitId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      readingDate: serializer.fromJson<DateTime>(json['readingDate']),
      meterName: serializer.fromJson<String?>(json['meterName']),
      prevReading: serializer.fromJson<double>(json['prevReading']),
      currentReading: serializer.fromJson<double>(json['currentReading']),
      ratePerUnit: serializer.fromJson<double>(json['ratePerUnit']),
      amount: serializer.fromJson<double>(json['amount']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'firestoreId': serializer.toJson<String?>(firestoreId),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'id': serializer.toJson<String>(id),
      'unitId': serializer.toJson<String>(unitId),
      'ownerId': serializer.toJson<String>(ownerId),
      'readingDate': serializer.toJson<DateTime>(readingDate),
      'meterName': serializer.toJson<String?>(meterName),
      'prevReading': serializer.toJson<double>(prevReading),
      'currentReading': serializer.toJson<double>(currentReading),
      'ratePerUnit': serializer.toJson<double>(ratePerUnit),
      'amount': serializer.toJson<double>(amount),
      'imagePath': serializer.toJson<String?>(imagePath),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  ElectricReading copyWith(
          {Value<String?> firestoreId = const Value.absent(),
          DateTime? lastUpdated,
          bool? isSynced,
          bool? isDeleted,
          String? id,
          String? unitId,
          String? ownerId,
          DateTime? readingDate,
          Value<String?> meterName = const Value.absent(),
          double? prevReading,
          double? currentReading,
          double? ratePerUnit,
          double? amount,
          Value<String?> imagePath = const Value.absent(),
          Value<String?> notes = const Value.absent()}) =>
      ElectricReading(
        firestoreId: firestoreId.present ? firestoreId.value : this.firestoreId,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        isSynced: isSynced ?? this.isSynced,
        isDeleted: isDeleted ?? this.isDeleted,
        id: id ?? this.id,
        unitId: unitId ?? this.unitId,
        ownerId: ownerId ?? this.ownerId,
        readingDate: readingDate ?? this.readingDate,
        meterName: meterName.present ? meterName.value : this.meterName,
        prevReading: prevReading ?? this.prevReading,
        currentReading: currentReading ?? this.currentReading,
        ratePerUnit: ratePerUnit ?? this.ratePerUnit,
        amount: amount ?? this.amount,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        notes: notes.present ? notes.value : this.notes,
      );
  ElectricReading copyWithCompanion(ElectricReadingsCompanion data) {
    return ElectricReading(
      firestoreId:
          data.firestoreId.present ? data.firestoreId.value : this.firestoreId,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      id: data.id.present ? data.id.value : this.id,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      readingDate:
          data.readingDate.present ? data.readingDate.value : this.readingDate,
      meterName: data.meterName.present ? data.meterName.value : this.meterName,
      prevReading:
          data.prevReading.present ? data.prevReading.value : this.prevReading,
      currentReading: data.currentReading.present
          ? data.currentReading.value
          : this.currentReading,
      ratePerUnit:
          data.ratePerUnit.present ? data.ratePerUnit.value : this.ratePerUnit,
      amount: data.amount.present ? data.amount.value : this.amount,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ElectricReading(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('unitId: $unitId, ')
          ..write('ownerId: $ownerId, ')
          ..write('readingDate: $readingDate, ')
          ..write('meterName: $meterName, ')
          ..write('prevReading: $prevReading, ')
          ..write('currentReading: $currentReading, ')
          ..write('ratePerUnit: $ratePerUnit, ')
          ..write('amount: $amount, ')
          ..write('imagePath: $imagePath, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      firestoreId,
      lastUpdated,
      isSynced,
      isDeleted,
      id,
      unitId,
      ownerId,
      readingDate,
      meterName,
      prevReading,
      currentReading,
      ratePerUnit,
      amount,
      imagePath,
      notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ElectricReading &&
          other.firestoreId == this.firestoreId &&
          other.lastUpdated == this.lastUpdated &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.id == this.id &&
          other.unitId == this.unitId &&
          other.ownerId == this.ownerId &&
          other.readingDate == this.readingDate &&
          other.meterName == this.meterName &&
          other.prevReading == this.prevReading &&
          other.currentReading == this.currentReading &&
          other.ratePerUnit == this.ratePerUnit &&
          other.amount == this.amount &&
          other.imagePath == this.imagePath &&
          other.notes == this.notes);
}

class ElectricReadingsCompanion extends UpdateCompanion<ElectricReading> {
  final Value<String?> firestoreId;
  final Value<DateTime> lastUpdated;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String> id;
  final Value<String> unitId;
  final Value<String> ownerId;
  final Value<DateTime> readingDate;
  final Value<String?> meterName;
  final Value<double> prevReading;
  final Value<double> currentReading;
  final Value<double> ratePerUnit;
  final Value<double> amount;
  final Value<String?> imagePath;
  final Value<String?> notes;
  final Value<int> rowid;
  const ElectricReadingsCompanion({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.id = const Value.absent(),
    this.unitId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.readingDate = const Value.absent(),
    this.meterName = const Value.absent(),
    this.prevReading = const Value.absent(),
    this.currentReading = const Value.absent(),
    this.ratePerUnit = const Value.absent(),
    this.amount = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ElectricReadingsCompanion.insert({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String id,
    required String unitId,
    required String ownerId,
    required DateTime readingDate,
    this.meterName = const Value.absent(),
    this.prevReading = const Value.absent(),
    required double currentReading,
    this.ratePerUnit = const Value.absent(),
    required double amount,
    this.imagePath = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        unitId = Value(unitId),
        ownerId = Value(ownerId),
        readingDate = Value(readingDate),
        currentReading = Value(currentReading),
        amount = Value(amount);
  static Insertable<ElectricReading> custom({
    Expression<String>? firestoreId,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? id,
    Expression<String>? unitId,
    Expression<String>? ownerId,
    Expression<DateTime>? readingDate,
    Expression<String>? meterName,
    Expression<double>? prevReading,
    Expression<double>? currentReading,
    Expression<double>? ratePerUnit,
    Expression<double>? amount,
    Expression<String>? imagePath,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (firestoreId != null) 'firestore_id': firestoreId,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (id != null) 'id': id,
      if (unitId != null) 'unit_id': unitId,
      if (ownerId != null) 'owner_id': ownerId,
      if (readingDate != null) 'reading_date': readingDate,
      if (meterName != null) 'meter_name': meterName,
      if (prevReading != null) 'prev_reading': prevReading,
      if (currentReading != null) 'current_reading': currentReading,
      if (ratePerUnit != null) 'rate_per_unit': ratePerUnit,
      if (amount != null) 'amount': amount,
      if (imagePath != null) 'image_path': imagePath,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ElectricReadingsCompanion copyWith(
      {Value<String?>? firestoreId,
      Value<DateTime>? lastUpdated,
      Value<bool>? isSynced,
      Value<bool>? isDeleted,
      Value<String>? id,
      Value<String>? unitId,
      Value<String>? ownerId,
      Value<DateTime>? readingDate,
      Value<String?>? meterName,
      Value<double>? prevReading,
      Value<double>? currentReading,
      Value<double>? ratePerUnit,
      Value<double>? amount,
      Value<String?>? imagePath,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return ElectricReadingsCompanion(
      firestoreId: firestoreId ?? this.firestoreId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      ownerId: ownerId ?? this.ownerId,
      readingDate: readingDate ?? this.readingDate,
      meterName: meterName ?? this.meterName,
      prevReading: prevReading ?? this.prevReading,
      currentReading: currentReading ?? this.currentReading,
      ratePerUnit: ratePerUnit ?? this.ratePerUnit,
      amount: amount ?? this.amount,
      imagePath: imagePath ?? this.imagePath,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (firestoreId.present) {
      map['firestore_id'] = Variable<String>(firestoreId.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (readingDate.present) {
      map['reading_date'] = Variable<DateTime>(readingDate.value);
    }
    if (meterName.present) {
      map['meter_name'] = Variable<String>(meterName.value);
    }
    if (prevReading.present) {
      map['prev_reading'] = Variable<double>(prevReading.value);
    }
    if (currentReading.present) {
      map['current_reading'] = Variable<double>(currentReading.value);
    }
    if (ratePerUnit.present) {
      map['rate_per_unit'] = Variable<double>(ratePerUnit.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ElectricReadingsCompanion(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('unitId: $unitId, ')
          ..write('ownerId: $ownerId, ')
          ..write('readingDate: $readingDate, ')
          ..write('meterName: $meterName, ')
          ..write('prevReading: $prevReading, ')
          ..write('currentReading: $currentReading, ')
          ..write('ratePerUnit: $ratePerUnit, ')
          ..write('amount: $amount, ')
          ..write('imagePath: $imagePath, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OtherChargesTable extends OtherCharges
    with TableInfo<$OtherChargesTable, OtherCharge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OtherChargesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _firestoreIdMeta =
      const VerificationMeta('firestoreId');
  @override
  late final GeneratedColumn<String> firestoreId = GeneratedColumn<String>(
      'firestore_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rentCycleIdMeta =
      const VerificationMeta('rentCycleId');
  @override
  late final GeneratedColumn<String> rentCycleId = GeneratedColumn<String>(
      'rent_cycle_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES rent_cycles (id) ON DELETE CASCADE'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        firestoreId,
        lastUpdated,
        isSynced,
        isDeleted,
        id,
        rentCycleId,
        amount,
        category,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'other_charges';
  @override
  VerificationContext validateIntegrity(Insertable<OtherCharge> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('firestore_id')) {
      context.handle(
          _firestoreIdMeta,
          firestoreId.isAcceptableOrUnknown(
              data['firestore_id']!, _firestoreIdMeta));
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('rent_cycle_id')) {
      context.handle(
          _rentCycleIdMeta,
          rentCycleId.isAcceptableOrUnknown(
              data['rent_cycle_id']!, _rentCycleIdMeta));
    } else if (isInserting) {
      context.missing(_rentCycleIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OtherCharge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OtherCharge(
      firestoreId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}firestore_id']),
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      rentCycleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rent_cycle_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $OtherChargesTable createAlias(String alias) {
    return $OtherChargesTable(attachedDatabase, alias);
  }
}

class OtherCharge extends DataClass implements Insertable<OtherCharge> {
  final String? firestoreId;
  final DateTime lastUpdated;
  final bool isSynced;
  final bool isDeleted;
  final String id;
  final String rentCycleId;
  final double amount;
  final String category;
  final String? notes;
  const OtherCharge(
      {this.firestoreId,
      required this.lastUpdated,
      required this.isSynced,
      required this.isDeleted,
      required this.id,
      required this.rentCycleId,
      required this.amount,
      required this.category,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || firestoreId != null) {
      map['firestore_id'] = Variable<String>(firestoreId);
    }
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['id'] = Variable<String>(id);
    map['rent_cycle_id'] = Variable<String>(rentCycleId);
    map['amount'] = Variable<double>(amount);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  OtherChargesCompanion toCompanion(bool nullToAbsent) {
    return OtherChargesCompanion(
      firestoreId: firestoreId == null && nullToAbsent
          ? const Value.absent()
          : Value(firestoreId),
      lastUpdated: Value(lastUpdated),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      id: Value(id),
      rentCycleId: Value(rentCycleId),
      amount: Value(amount),
      category: Value(category),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory OtherCharge.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OtherCharge(
      firestoreId: serializer.fromJson<String?>(json['firestoreId']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      id: serializer.fromJson<String>(json['id']),
      rentCycleId: serializer.fromJson<String>(json['rentCycleId']),
      amount: serializer.fromJson<double>(json['amount']),
      category: serializer.fromJson<String>(json['category']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'firestoreId': serializer.toJson<String?>(firestoreId),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'id': serializer.toJson<String>(id),
      'rentCycleId': serializer.toJson<String>(rentCycleId),
      'amount': serializer.toJson<double>(amount),
      'category': serializer.toJson<String>(category),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  OtherCharge copyWith(
          {Value<String?> firestoreId = const Value.absent(),
          DateTime? lastUpdated,
          bool? isSynced,
          bool? isDeleted,
          String? id,
          String? rentCycleId,
          double? amount,
          String? category,
          Value<String?> notes = const Value.absent()}) =>
      OtherCharge(
        firestoreId: firestoreId.present ? firestoreId.value : this.firestoreId,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        isSynced: isSynced ?? this.isSynced,
        isDeleted: isDeleted ?? this.isDeleted,
        id: id ?? this.id,
        rentCycleId: rentCycleId ?? this.rentCycleId,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        notes: notes.present ? notes.value : this.notes,
      );
  OtherCharge copyWithCompanion(OtherChargesCompanion data) {
    return OtherCharge(
      firestoreId:
          data.firestoreId.present ? data.firestoreId.value : this.firestoreId,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      id: data.id.present ? data.id.value : this.id,
      rentCycleId:
          data.rentCycleId.present ? data.rentCycleId.value : this.rentCycleId,
      amount: data.amount.present ? data.amount.value : this.amount,
      category: data.category.present ? data.category.value : this.category,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OtherCharge(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('rentCycleId: $rentCycleId, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(firestoreId, lastUpdated, isSynced, isDeleted,
      id, rentCycleId, amount, category, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OtherCharge &&
          other.firestoreId == this.firestoreId &&
          other.lastUpdated == this.lastUpdated &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.id == this.id &&
          other.rentCycleId == this.rentCycleId &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.notes == this.notes);
}

class OtherChargesCompanion extends UpdateCompanion<OtherCharge> {
  final Value<String?> firestoreId;
  final Value<DateTime> lastUpdated;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<String> id;
  final Value<String> rentCycleId;
  final Value<double> amount;
  final Value<String> category;
  final Value<String?> notes;
  final Value<int> rowid;
  const OtherChargesCompanion({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.id = const Value.absent(),
    this.rentCycleId = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OtherChargesCompanion.insert({
    this.firestoreId = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required String id,
    required String rentCycleId,
    required double amount,
    required String category,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        rentCycleId = Value(rentCycleId),
        amount = Value(amount),
        category = Value(category);
  static Insertable<OtherCharge> custom({
    Expression<String>? firestoreId,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<String>? id,
    Expression<String>? rentCycleId,
    Expression<double>? amount,
    Expression<String>? category,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (firestoreId != null) 'firestore_id': firestoreId,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (id != null) 'id': id,
      if (rentCycleId != null) 'rent_cycle_id': rentCycleId,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OtherChargesCompanion copyWith(
      {Value<String?>? firestoreId,
      Value<DateTime>? lastUpdated,
      Value<bool>? isSynced,
      Value<bool>? isDeleted,
      Value<String>? id,
      Value<String>? rentCycleId,
      Value<double>? amount,
      Value<String>? category,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return OtherChargesCompanion(
      firestoreId: firestoreId ?? this.firestoreId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      id: id ?? this.id,
      rentCycleId: rentCycleId ?? this.rentCycleId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (firestoreId.present) {
      map['firestore_id'] = Variable<String>(firestoreId.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (rentCycleId.present) {
      map['rent_cycle_id'] = Variable<String>(rentCycleId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OtherChargesCompanion(')
          ..write('firestoreId: $firestoreId, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('id: $id, ')
          ..write('rentCycleId: $rentCycleId, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OwnersTable owners = $OwnersTable(this);
  late final $HousesTable houses = $HousesTable(this);
  late final $BhkTemplatesTable bhkTemplates = $BhkTemplatesTable(this);
  late final $UnitsTable units = $UnitsTable(this);
  late final $TenantsTable tenants = $TenantsTable(this);
  late final $TenanciesTable tenancies = $TenanciesTable(this);
  late final $RentCyclesTable rentCycles = $RentCyclesTable(this);
  late final $PaymentChannelsTable paymentChannels =
      $PaymentChannelsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $ElectricReadingsTable electricReadings =
      $ElectricReadingsTable(this);
  late final $OtherChargesTable otherCharges = $OtherChargesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        owners,
        houses,
        bhkTemplates,
        units,
        tenants,
        tenancies,
        rentCycles,
        paymentChannels,
        payments,
        expenses,
        electricReadings,
        otherCharges
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('owners',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('houses', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('houses',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('bhk_templates', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('houses',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('units', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('owners',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('units', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('owners',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('tenants', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tenants',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('tenancies', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('units',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('tenancies', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('owners',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('tenancies', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tenancies',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('rent_cycles', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('owners',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('rent_cycles', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('rent_cycles',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('payments', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('owners',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('payments', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('owners',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('expenses', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('units',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('electric_readings', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('owners',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('electric_readings', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('rent_cycles',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('other_charges', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$OwnersTableCreateCompanionBuilder = OwnersCompanion Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  required String id,
  required String name,
  Value<String?> phone,
  Value<String?> email,
  Value<String> subscriptionPlan,
  Value<String> currency,
  Value<String?> timezone,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$OwnersTableUpdateCompanionBuilder = OwnersCompanion Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  Value<String> id,
  Value<String> name,
  Value<String?> phone,
  Value<String?> email,
  Value<String> subscriptionPlan,
  Value<String> currency,
  Value<String?> timezone,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$OwnersTableReferences
    extends BaseReferences<_$AppDatabase, $OwnersTable, Owner> {
  $$OwnersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HousesTable, List<House>> _housesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.houses,
          aliasName: $_aliasNameGenerator(db.owners.id, db.houses.ownerId));

  $$HousesTableProcessedTableManager get housesRefs {
    final manager = $$HousesTableTableManager($_db, $_db.houses)
        .filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_housesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$UnitsTable, List<Unit>> _unitsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.units,
          aliasName: $_aliasNameGenerator(db.owners.id, db.units.ownerId));

  $$UnitsTableProcessedTableManager get unitsRefs {
    final manager = $$UnitsTableTableManager($_db, $_db.units)
        .filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_unitsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TenantsTable, List<Tenant>> _tenantsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tenants,
          aliasName: $_aliasNameGenerator(db.owners.id, db.tenants.ownerId));

  $$TenantsTableProcessedTableManager get tenantsRefs {
    final manager = $$TenantsTableTableManager($_db, $_db.tenants)
        .filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tenantsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TenanciesTable, List<Tenancy>>
      _tenanciesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.tenancies,
          aliasName: $_aliasNameGenerator(db.owners.id, db.tenancies.ownerId));

  $$TenanciesTableProcessedTableManager get tenanciesRefs {
    final manager = $$TenanciesTableTableManager($_db, $_db.tenancies)
        .filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tenanciesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RentCyclesTable, List<RentCycle>>
      _rentCyclesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.rentCycles,
          aliasName: $_aliasNameGenerator(db.owners.id, db.rentCycles.ownerId));

  $$RentCyclesTableProcessedTableManager get rentCyclesRefs {
    final manager = $$RentCyclesTableTableManager($_db, $_db.rentCycles)
        .filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_rentCyclesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.payments,
          aliasName: $_aliasNameGenerator(db.owners.id, db.payments.ownerId));

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager($_db, $_db.payments)
        .filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.expenses,
          aliasName: $_aliasNameGenerator(db.owners.id, db.expenses.ownerId));

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager($_db, $_db.expenses)
        .filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ElectricReadingsTable, List<ElectricReading>>
      _electricReadingsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.electricReadings,
              aliasName: $_aliasNameGenerator(
                  db.owners.id, db.electricReadings.ownerId));

  $$ElectricReadingsTableProcessedTableManager get electricReadingsRefs {
    final manager =
        $$ElectricReadingsTableTableManager($_db, $_db.electricReadings)
            .filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_electricReadingsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$OwnersTableFilterComposer
    extends Composer<_$AppDatabase, $OwnersTable> {
  $$OwnersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subscriptionPlan => $composableBuilder(
      column: $table.subscriptionPlan,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> housesRefs(
      Expression<bool> Function($$HousesTableFilterComposer f) f) {
    final $$HousesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.houses,
        getReferencedColumn: (t) => t.ownerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HousesTableFilterComposer(
              $db: $db,
              $table: $db.houses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> unitsRefs(
      Expression<bool> Function($$UnitsTableFilterComposer f) f) {
    final $$UnitsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.units,
        getReferencedColumn: (t) => t.ownerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UnitsTableFilterComposer(
              $db: $db,
              $table: $db.units,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> tenantsRefs(
      Expression<bool> Function($$TenantsTableFilterComposer f) f) {
    final $$TenantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tenants,
        getReferencedColumn: (t) => t.ownerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TenantsTableFilterComposer(
              $db: $db,
              $table: $db.tenants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> tenanciesRefs(
      Expression<bool> Function($$TenanciesTableFilterComposer f) f) {
    final $$TenanciesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tenancies,
        getReferencedColumn: (t) => t.ownerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TenanciesTableFilterComposer(
              $db: $db,
              $table: $db.tenancies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> rentCyclesRefs(
      Expression<bool> Function($$RentCyclesTableFilterComposer f) f) {
    final $$RentCyclesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.rentCycles,
        getReferencedColumn: (t) => t.ownerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RentCyclesTableFilterComposer(
              $db: $db,
              $table: $db.rentCycles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> paymentsRefs(
      Expression<bool> Function($$PaymentsTableFilterComposer f) f) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.ownerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableFilterComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> expensesRefs(
      Expression<bool> Function($$ExpensesTableFilterComposer f) f) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.ownerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableFilterComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> electricReadingsRefs(
      Expression<bool> Function($$ElectricReadingsTableFilterComposer f) f) {
    final $$ElectricReadingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.electricReadings,
        getReferencedColumn: (t) => t.ownerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ElectricReadingsTableFilterComposer(
              $db: $db,
              $table: $db.electricReadings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$OwnersTableOrderingComposer
    extends Composer<_$AppDatabase, $OwnersTable> {
  $$OwnersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subscriptionPlan => $composableBuilder(
      column: $table.subscriptionPlan,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$OwnersTableAnnotationComposer
    extends Composer<_$AppDatabase, $OwnersTable> {
  $$OwnersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get subscriptionPlan => $composableBuilder(
      column: $table.subscriptionPlan, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> housesRefs<T extends Object>(
      Expression<T> Function($$HousesTableAnnotationComposer a) f) {
    final $$HousesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.houses,
        getReferencedColumn: (t) => t.ownerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HousesTableAnnotationComposer(
              $db: $db,
              $table: $db.houses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> unitsRefs<T extends Object>(
      Expression<T> Function($$UnitsTableAnnotationComposer a) f) {
    final $$UnitsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.units,
        getReferencedColumn: (t) => t.ownerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UnitsTableAnnotationComposer(
              $db: $db,
              $table: $db.units,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> tenantsRefs<T extends Object>(
      Expression<T> Function($$TenantsTableAnnotationComposer a) f) {
    final $$TenantsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tenants,
        getReferencedColumn: (t) => t.ownerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TenantsTableAnnotationComposer(
              $db: $db,
              $table: $db.tenants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> tenanciesRefs<T extends Object>(
      Expression<T> Function($$TenanciesTableAnnotationComposer a) f) {
    final $$TenanciesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tenancies,
        getReferencedColumn: (t) => t.ownerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TenanciesTableAnnotationComposer(
              $db: $db,
              $table: $db.tenancies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> rentCyclesRefs<T extends Object>(
      Expression<T> Function($$RentCyclesTableAnnotationComposer a) f) {
    final $$RentCyclesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.rentCycles,
        getReferencedColumn: (t) => t.ownerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RentCyclesTableAnnotationComposer(
              $db: $db,
              $table: $db.rentCycles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(
      Expression<T> Function($$PaymentsTableAnnotationComposer a) f) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.ownerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableAnnotationComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
      Expression<T> Function($$ExpensesTableAnnotationComposer a) f) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.ownerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableAnnotationComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> electricReadingsRefs<T extends Object>(
      Expression<T> Function($$ElectricReadingsTableAnnotationComposer a) f) {
    final $$ElectricReadingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.electricReadings,
        getReferencedColumn: (t) => t.ownerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ElectricReadingsTableAnnotationComposer(
              $db: $db,
              $table: $db.electricReadings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$OwnersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OwnersTable,
    Owner,
    $$OwnersTableFilterComposer,
    $$OwnersTableOrderingComposer,
    $$OwnersTableAnnotationComposer,
    $$OwnersTableCreateCompanionBuilder,
    $$OwnersTableUpdateCompanionBuilder,
    (Owner, $$OwnersTableReferences),
    Owner,
    PrefetchHooks Function(
        {bool housesRefs,
        bool unitsRefs,
        bool tenantsRefs,
        bool tenanciesRefs,
        bool rentCyclesRefs,
        bool paymentsRefs,
        bool expensesRefs,
        bool electricReadingsRefs})> {
  $$OwnersTableTableManager(_$AppDatabase db, $OwnersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OwnersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OwnersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OwnersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String> subscriptionPlan = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<String?> timezone = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OwnersCompanion(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            name: name,
            phone: phone,
            email: email,
            subscriptionPlan: subscriptionPlan,
            currency: currency,
            timezone: timezone,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            required String id,
            required String name,
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String> subscriptionPlan = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<String?> timezone = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OwnersCompanion.insert(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            name: name,
            phone: phone,
            email: email,
            subscriptionPlan: subscriptionPlan,
            currency: currency,
            timezone: timezone,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$OwnersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {housesRefs = false,
              unitsRefs = false,
              tenantsRefs = false,
              tenanciesRefs = false,
              rentCyclesRefs = false,
              paymentsRefs = false,
              expensesRefs = false,
              electricReadingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (housesRefs) db.houses,
                if (unitsRefs) db.units,
                if (tenantsRefs) db.tenants,
                if (tenanciesRefs) db.tenancies,
                if (rentCyclesRefs) db.rentCycles,
                if (paymentsRefs) db.payments,
                if (expensesRefs) db.expenses,
                if (electricReadingsRefs) db.electricReadings
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (housesRefs)
                    await $_getPrefetchedData<Owner, $OwnersTable, House>(
                        currentTable: table,
                        referencedTable:
                            $$OwnersTableReferences._housesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$OwnersTableReferences(db, table, p0).housesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.ownerId == item.id),
                        typedResults: items),
                  if (unitsRefs)
                    await $_getPrefetchedData<Owner, $OwnersTable, Unit>(
                        currentTable: table,
                        referencedTable:
                            $$OwnersTableReferences._unitsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$OwnersTableReferences(db, table, p0).unitsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.ownerId == item.id),
                        typedResults: items),
                  if (tenantsRefs)
                    await $_getPrefetchedData<Owner, $OwnersTable, Tenant>(
                        currentTable: table,
                        referencedTable:
                            $$OwnersTableReferences._tenantsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$OwnersTableReferences(db, table, p0).tenantsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.ownerId == item.id),
                        typedResults: items),
                  if (tenanciesRefs)
                    await $_getPrefetchedData<Owner, $OwnersTable, Tenancy>(
                        currentTable: table,
                        referencedTable:
                            $$OwnersTableReferences._tenanciesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$OwnersTableReferences(db, table, p0)
                                .tenanciesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.ownerId == item.id),
                        typedResults: items),
                  if (rentCyclesRefs)
                    await $_getPrefetchedData<Owner, $OwnersTable, RentCycle>(
                        currentTable: table,
                        referencedTable:
                            $$OwnersTableReferences._rentCyclesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$OwnersTableReferences(db, table, p0)
                                .rentCyclesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.ownerId == item.id),
                        typedResults: items),
                  if (paymentsRefs)
                    await $_getPrefetchedData<Owner, $OwnersTable, Payment>(
                        currentTable: table,
                        referencedTable:
                            $$OwnersTableReferences._paymentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$OwnersTableReferences(db, table, p0).paymentsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.ownerId == item.id),
                        typedResults: items),
                  if (expensesRefs)
                    await $_getPrefetchedData<Owner, $OwnersTable, Expense>(
                        currentTable: table,
                        referencedTable:
                            $$OwnersTableReferences._expensesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$OwnersTableReferences(db, table, p0).expensesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.ownerId == item.id),
                        typedResults: items),
                  if (electricReadingsRefs)
                    await $_getPrefetchedData<Owner, $OwnersTable,
                            ElectricReading>(
                        currentTable: table,
                        referencedTable: $$OwnersTableReferences
                            ._electricReadingsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$OwnersTableReferences(db, table, p0)
                                .electricReadingsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.ownerId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$OwnersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OwnersTable,
    Owner,
    $$OwnersTableFilterComposer,
    $$OwnersTableOrderingComposer,
    $$OwnersTableAnnotationComposer,
    $$OwnersTableCreateCompanionBuilder,
    $$OwnersTableUpdateCompanionBuilder,
    (Owner, $$OwnersTableReferences),
    Owner,
    PrefetchHooks Function(
        {bool housesRefs,
        bool unitsRefs,
        bool tenantsRefs,
        bool tenanciesRefs,
        bool rentCyclesRefs,
        bool paymentsRefs,
        bool expensesRefs,
        bool electricReadingsRefs})>;
typedef $$HousesTableCreateCompanionBuilder = HousesCompanion Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  required String id,
  required String ownerId,
  required String name,
  required String address,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$HousesTableUpdateCompanionBuilder = HousesCompanion Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  Value<String> id,
  Value<String> ownerId,
  Value<String> name,
  Value<String> address,
  Value<String?> notes,
  Value<int> rowid,
});

final class $$HousesTableReferences
    extends BaseReferences<_$AppDatabase, $HousesTable, House> {
  $$HousesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OwnersTable _ownerIdTable(_$AppDatabase db) => db.owners
      .createAlias($_aliasNameGenerator(db.houses.ownerId, db.owners.id));

  $$OwnersTableProcessedTableManager get ownerId {
    final $_column = $_itemColumn<String>('owner_id')!;

    final manager = $$OwnersTableTableManager($_db, $_db.owners)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$BhkTemplatesTable, List<BhkTemplate>>
      _bhkTemplatesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.bhkTemplates,
              aliasName:
                  $_aliasNameGenerator(db.houses.id, db.bhkTemplates.houseId));

  $$BhkTemplatesTableProcessedTableManager get bhkTemplatesRefs {
    final manager = $$BhkTemplatesTableTableManager($_db, $_db.bhkTemplates)
        .filter((f) => f.houseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_bhkTemplatesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$UnitsTable, List<Unit>> _unitsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.units,
          aliasName: $_aliasNameGenerator(db.houses.id, db.units.houseId));

  $$UnitsTableProcessedTableManager get unitsRefs {
    final manager = $$UnitsTableTableManager($_db, $_db.units)
        .filter((f) => f.houseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_unitsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$HousesTableFilterComposer
    extends Composer<_$AppDatabase, $HousesTable> {
  $$HousesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  $$OwnersTableFilterComposer get ownerId {
    final $$OwnersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableFilterComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> bhkTemplatesRefs(
      Expression<bool> Function($$BhkTemplatesTableFilterComposer f) f) {
    final $$BhkTemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bhkTemplates,
        getReferencedColumn: (t) => t.houseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BhkTemplatesTableFilterComposer(
              $db: $db,
              $table: $db.bhkTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> unitsRefs(
      Expression<bool> Function($$UnitsTableFilterComposer f) f) {
    final $$UnitsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.units,
        getReferencedColumn: (t) => t.houseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UnitsTableFilterComposer(
              $db: $db,
              $table: $db.units,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$HousesTableOrderingComposer
    extends Composer<_$AppDatabase, $HousesTable> {
  $$HousesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  $$OwnersTableOrderingComposer get ownerId {
    final $$OwnersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableOrderingComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$HousesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HousesTable> {
  $$HousesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$OwnersTableAnnotationComposer get ownerId {
    final $$OwnersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableAnnotationComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> bhkTemplatesRefs<T extends Object>(
      Expression<T> Function($$BhkTemplatesTableAnnotationComposer a) f) {
    final $$BhkTemplatesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bhkTemplates,
        getReferencedColumn: (t) => t.houseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BhkTemplatesTableAnnotationComposer(
              $db: $db,
              $table: $db.bhkTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> unitsRefs<T extends Object>(
      Expression<T> Function($$UnitsTableAnnotationComposer a) f) {
    final $$UnitsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.units,
        getReferencedColumn: (t) => t.houseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UnitsTableAnnotationComposer(
              $db: $db,
              $table: $db.units,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$HousesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HousesTable,
    House,
    $$HousesTableFilterComposer,
    $$HousesTableOrderingComposer,
    $$HousesTableAnnotationComposer,
    $$HousesTableCreateCompanionBuilder,
    $$HousesTableUpdateCompanionBuilder,
    (House, $$HousesTableReferences),
    House,
    PrefetchHooks Function(
        {bool ownerId, bool bhkTemplatesRefs, bool unitsRefs})> {
  $$HousesTableTableManager(_$AppDatabase db, $HousesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HousesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HousesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HousesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> ownerId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HousesCompanion(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            ownerId: ownerId,
            name: name,
            address: address,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            required String id,
            required String ownerId,
            required String name,
            required String address,
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HousesCompanion.insert(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            ownerId: ownerId,
            name: name,
            address: address,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$HousesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {ownerId = false, bhkTemplatesRefs = false, unitsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (bhkTemplatesRefs) db.bhkTemplates,
                if (unitsRefs) db.units
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (ownerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ownerId,
                    referencedTable: $$HousesTableReferences._ownerIdTable(db),
                    referencedColumn:
                        $$HousesTableReferences._ownerIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bhkTemplatesRefs)
                    await $_getPrefetchedData<House, $HousesTable, BhkTemplate>(
                        currentTable: table,
                        referencedTable:
                            $$HousesTableReferences._bhkTemplatesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$HousesTableReferences(db, table, p0)
                                .bhkTemplatesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.houseId == item.id),
                        typedResults: items),
                  if (unitsRefs)
                    await $_getPrefetchedData<House, $HousesTable, Unit>(
                        currentTable: table,
                        referencedTable:
                            $$HousesTableReferences._unitsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$HousesTableReferences(db, table, p0).unitsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.houseId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$HousesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HousesTable,
    House,
    $$HousesTableFilterComposer,
    $$HousesTableOrderingComposer,
    $$HousesTableAnnotationComposer,
    $$HousesTableCreateCompanionBuilder,
    $$HousesTableUpdateCompanionBuilder,
    (House, $$HousesTableReferences),
    House,
    PrefetchHooks Function(
        {bool ownerId, bool bhkTemplatesRefs, bool unitsRefs})>;
typedef $$BhkTemplatesTableCreateCompanionBuilder = BhkTemplatesCompanion
    Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  required String id,
  required String houseId,
  required String bhkType,
  required double defaultRent,
  Value<String?> description,
  Value<int> roomCount,
  Value<int> kitchenCount,
  Value<int> hallCount,
  Value<bool> hasBalcony,
  Value<int> rowid,
});
typedef $$BhkTemplatesTableUpdateCompanionBuilder = BhkTemplatesCompanion
    Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  Value<String> id,
  Value<String> houseId,
  Value<String> bhkType,
  Value<double> defaultRent,
  Value<String?> description,
  Value<int> roomCount,
  Value<int> kitchenCount,
  Value<int> hallCount,
  Value<bool> hasBalcony,
  Value<int> rowid,
});

final class $$BhkTemplatesTableReferences
    extends BaseReferences<_$AppDatabase, $BhkTemplatesTable, BhkTemplate> {
  $$BhkTemplatesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HousesTable _houseIdTable(_$AppDatabase db) => db.houses
      .createAlias($_aliasNameGenerator(db.bhkTemplates.houseId, db.houses.id));

  $$HousesTableProcessedTableManager get houseId {
    final $_column = $_itemColumn<String>('house_id')!;

    final manager = $$HousesTableTableManager($_db, $_db.houses)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_houseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$UnitsTable, List<Unit>> _unitsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.units,
          aliasName:
              $_aliasNameGenerator(db.bhkTemplates.id, db.units.bhkTemplateId));

  $$UnitsTableProcessedTableManager get unitsRefs {
    final manager = $$UnitsTableTableManager($_db, $_db.units).filter(
        (f) => f.bhkTemplateId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_unitsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BhkTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $BhkTemplatesTable> {
  $$BhkTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bhkType => $composableBuilder(
      column: $table.bhkType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get defaultRent => $composableBuilder(
      column: $table.defaultRent, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get roomCount => $composableBuilder(
      column: $table.roomCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get kitchenCount => $composableBuilder(
      column: $table.kitchenCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hallCount => $composableBuilder(
      column: $table.hallCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasBalcony => $composableBuilder(
      column: $table.hasBalcony, builder: (column) => ColumnFilters(column));

  $$HousesTableFilterComposer get houseId {
    final $$HousesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HousesTableFilterComposer(
              $db: $db,
              $table: $db.houses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> unitsRefs(
      Expression<bool> Function($$UnitsTableFilterComposer f) f) {
    final $$UnitsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.units,
        getReferencedColumn: (t) => t.bhkTemplateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UnitsTableFilterComposer(
              $db: $db,
              $table: $db.units,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BhkTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $BhkTemplatesTable> {
  $$BhkTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bhkType => $composableBuilder(
      column: $table.bhkType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get defaultRent => $composableBuilder(
      column: $table.defaultRent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get roomCount => $composableBuilder(
      column: $table.roomCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kitchenCount => $composableBuilder(
      column: $table.kitchenCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hallCount => $composableBuilder(
      column: $table.hallCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasBalcony => $composableBuilder(
      column: $table.hasBalcony, builder: (column) => ColumnOrderings(column));

  $$HousesTableOrderingComposer get houseId {
    final $$HousesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HousesTableOrderingComposer(
              $db: $db,
              $table: $db.houses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BhkTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BhkTemplatesTable> {
  $$BhkTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bhkType =>
      $composableBuilder(column: $table.bhkType, builder: (column) => column);

  GeneratedColumn<double> get defaultRent => $composableBuilder(
      column: $table.defaultRent, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get roomCount =>
      $composableBuilder(column: $table.roomCount, builder: (column) => column);

  GeneratedColumn<int> get kitchenCount => $composableBuilder(
      column: $table.kitchenCount, builder: (column) => column);

  GeneratedColumn<int> get hallCount =>
      $composableBuilder(column: $table.hallCount, builder: (column) => column);

  GeneratedColumn<bool> get hasBalcony => $composableBuilder(
      column: $table.hasBalcony, builder: (column) => column);

  $$HousesTableAnnotationComposer get houseId {
    final $$HousesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HousesTableAnnotationComposer(
              $db: $db,
              $table: $db.houses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> unitsRefs<T extends Object>(
      Expression<T> Function($$UnitsTableAnnotationComposer a) f) {
    final $$UnitsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.units,
        getReferencedColumn: (t) => t.bhkTemplateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UnitsTableAnnotationComposer(
              $db: $db,
              $table: $db.units,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BhkTemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BhkTemplatesTable,
    BhkTemplate,
    $$BhkTemplatesTableFilterComposer,
    $$BhkTemplatesTableOrderingComposer,
    $$BhkTemplatesTableAnnotationComposer,
    $$BhkTemplatesTableCreateCompanionBuilder,
    $$BhkTemplatesTableUpdateCompanionBuilder,
    (BhkTemplate, $$BhkTemplatesTableReferences),
    BhkTemplate,
    PrefetchHooks Function({bool houseId, bool unitsRefs})> {
  $$BhkTemplatesTableTableManager(_$AppDatabase db, $BhkTemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BhkTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BhkTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BhkTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> houseId = const Value.absent(),
            Value<String> bhkType = const Value.absent(),
            Value<double> defaultRent = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> roomCount = const Value.absent(),
            Value<int> kitchenCount = const Value.absent(),
            Value<int> hallCount = const Value.absent(),
            Value<bool> hasBalcony = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BhkTemplatesCompanion(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            houseId: houseId,
            bhkType: bhkType,
            defaultRent: defaultRent,
            description: description,
            roomCount: roomCount,
            kitchenCount: kitchenCount,
            hallCount: hallCount,
            hasBalcony: hasBalcony,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            required String id,
            required String houseId,
            required String bhkType,
            required double defaultRent,
            Value<String?> description = const Value.absent(),
            Value<int> roomCount = const Value.absent(),
            Value<int> kitchenCount = const Value.absent(),
            Value<int> hallCount = const Value.absent(),
            Value<bool> hasBalcony = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BhkTemplatesCompanion.insert(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            houseId: houseId,
            bhkType: bhkType,
            defaultRent: defaultRent,
            description: description,
            roomCount: roomCount,
            kitchenCount: kitchenCount,
            hallCount: hallCount,
            hasBalcony: hasBalcony,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BhkTemplatesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({houseId = false, unitsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (unitsRefs) db.units],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (houseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.houseId,
                    referencedTable:
                        $$BhkTemplatesTableReferences._houseIdTable(db),
                    referencedColumn:
                        $$BhkTemplatesTableReferences._houseIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (unitsRefs)
                    await $_getPrefetchedData<BhkTemplate, $BhkTemplatesTable,
                            Unit>(
                        currentTable: table,
                        referencedTable:
                            $$BhkTemplatesTableReferences._unitsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BhkTemplatesTableReferences(db, table, p0)
                                .unitsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.bhkTemplateId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BhkTemplatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BhkTemplatesTable,
    BhkTemplate,
    $$BhkTemplatesTableFilterComposer,
    $$BhkTemplatesTableOrderingComposer,
    $$BhkTemplatesTableAnnotationComposer,
    $$BhkTemplatesTableCreateCompanionBuilder,
    $$BhkTemplatesTableUpdateCompanionBuilder,
    (BhkTemplate, $$BhkTemplatesTableReferences),
    BhkTemplate,
    PrefetchHooks Function({bool houseId, bool unitsRefs})>;
typedef $$UnitsTableCreateCompanionBuilder = UnitsCompanion Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  required String id,
  required String houseId,
  required String ownerId,
  required String nameOrNumber,
  Value<int?> floor,
  Value<String?> bhkTemplateId,
  Value<String?> bhkType,
  required double baseRent,
  Value<double?> editableRent,
  Value<String?> furnishingStatus,
  Value<double?> carpetArea,
  Value<String?> parkingSlot,
  Value<String?> meterNumber,
  Value<int> defaultDueDay,
  Value<bool> isOccupied,
  Value<String?> currentTenancyId,
  Value<int> rowid,
});
typedef $$UnitsTableUpdateCompanionBuilder = UnitsCompanion Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  Value<String> id,
  Value<String> houseId,
  Value<String> ownerId,
  Value<String> nameOrNumber,
  Value<int?> floor,
  Value<String?> bhkTemplateId,
  Value<String?> bhkType,
  Value<double> baseRent,
  Value<double?> editableRent,
  Value<String?> furnishingStatus,
  Value<double?> carpetArea,
  Value<String?> parkingSlot,
  Value<String?> meterNumber,
  Value<int> defaultDueDay,
  Value<bool> isOccupied,
  Value<String?> currentTenancyId,
  Value<int> rowid,
});

final class $$UnitsTableReferences
    extends BaseReferences<_$AppDatabase, $UnitsTable, Unit> {
  $$UnitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HousesTable _houseIdTable(_$AppDatabase db) => db.houses
      .createAlias($_aliasNameGenerator(db.units.houseId, db.houses.id));

  $$HousesTableProcessedTableManager get houseId {
    final $_column = $_itemColumn<String>('house_id')!;

    final manager = $$HousesTableTableManager($_db, $_db.houses)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_houseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $OwnersTable _ownerIdTable(_$AppDatabase db) => db.owners
      .createAlias($_aliasNameGenerator(db.units.ownerId, db.owners.id));

  $$OwnersTableProcessedTableManager get ownerId {
    final $_column = $_itemColumn<String>('owner_id')!;

    final manager = $$OwnersTableTableManager($_db, $_db.owners)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $BhkTemplatesTable _bhkTemplateIdTable(_$AppDatabase db) =>
      db.bhkTemplates.createAlias(
          $_aliasNameGenerator(db.units.bhkTemplateId, db.bhkTemplates.id));

  $$BhkTemplatesTableProcessedTableManager? get bhkTemplateId {
    final $_column = $_itemColumn<String>('bhk_template_id');
    if ($_column == null) return null;
    final manager = $$BhkTemplatesTableTableManager($_db, $_db.bhkTemplates)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bhkTemplateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TenanciesTable, List<Tenancy>>
      _tenanciesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.tenancies,
          aliasName: $_aliasNameGenerator(db.units.id, db.tenancies.unitId));

  $$TenanciesTableProcessedTableManager get tenanciesRefs {
    final manager = $$TenanciesTableTableManager($_db, $_db.tenancies)
        .filter((f) => f.unitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tenanciesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ElectricReadingsTable, List<ElectricReading>>
      _electricReadingsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.electricReadings,
              aliasName: $_aliasNameGenerator(
                  db.units.id, db.electricReadings.unitId));

  $$ElectricReadingsTableProcessedTableManager get electricReadingsRefs {
    final manager =
        $$ElectricReadingsTableTableManager($_db, $_db.electricReadings)
            .filter((f) => f.unitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_electricReadingsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UnitsTableFilterComposer extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameOrNumber => $composableBuilder(
      column: $table.nameOrNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get floor => $composableBuilder(
      column: $table.floor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bhkType => $composableBuilder(
      column: $table.bhkType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get baseRent => $composableBuilder(
      column: $table.baseRent, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get editableRent => $composableBuilder(
      column: $table.editableRent, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get furnishingStatus => $composableBuilder(
      column: $table.furnishingStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carpetArea => $composableBuilder(
      column: $table.carpetArea, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parkingSlot => $composableBuilder(
      column: $table.parkingSlot, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get meterNumber => $composableBuilder(
      column: $table.meterNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get defaultDueDay => $composableBuilder(
      column: $table.defaultDueDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isOccupied => $composableBuilder(
      column: $table.isOccupied, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currentTenancyId => $composableBuilder(
      column: $table.currentTenancyId,
      builder: (column) => ColumnFilters(column));

  $$HousesTableFilterComposer get houseId {
    final $$HousesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HousesTableFilterComposer(
              $db: $db,
              $table: $db.houses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$OwnersTableFilterComposer get ownerId {
    final $$OwnersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableFilterComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BhkTemplatesTableFilterComposer get bhkTemplateId {
    final $$BhkTemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bhkTemplateId,
        referencedTable: $db.bhkTemplates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BhkTemplatesTableFilterComposer(
              $db: $db,
              $table: $db.bhkTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> tenanciesRefs(
      Expression<bool> Function($$TenanciesTableFilterComposer f) f) {
    final $$TenanciesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tenancies,
        getReferencedColumn: (t) => t.unitId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TenanciesTableFilterComposer(
              $db: $db,
              $table: $db.tenancies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> electricReadingsRefs(
      Expression<bool> Function($$ElectricReadingsTableFilterComposer f) f) {
    final $$ElectricReadingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.electricReadings,
        getReferencedColumn: (t) => t.unitId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ElectricReadingsTableFilterComposer(
              $db: $db,
              $table: $db.electricReadings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UnitsTableOrderingComposer
    extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameOrNumber => $composableBuilder(
      column: $table.nameOrNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get floor => $composableBuilder(
      column: $table.floor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bhkType => $composableBuilder(
      column: $table.bhkType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get baseRent => $composableBuilder(
      column: $table.baseRent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get editableRent => $composableBuilder(
      column: $table.editableRent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get furnishingStatus => $composableBuilder(
      column: $table.furnishingStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get carpetArea => $composableBuilder(
      column: $table.carpetArea, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parkingSlot => $composableBuilder(
      column: $table.parkingSlot, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get meterNumber => $composableBuilder(
      column: $table.meterNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get defaultDueDay => $composableBuilder(
      column: $table.defaultDueDay,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isOccupied => $composableBuilder(
      column: $table.isOccupied, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currentTenancyId => $composableBuilder(
      column: $table.currentTenancyId,
      builder: (column) => ColumnOrderings(column));

  $$HousesTableOrderingComposer get houseId {
    final $$HousesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HousesTableOrderingComposer(
              $db: $db,
              $table: $db.houses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$OwnersTableOrderingComposer get ownerId {
    final $$OwnersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableOrderingComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BhkTemplatesTableOrderingComposer get bhkTemplateId {
    final $$BhkTemplatesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bhkTemplateId,
        referencedTable: $db.bhkTemplates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BhkTemplatesTableOrderingComposer(
              $db: $db,
              $table: $db.bhkTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UnitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameOrNumber => $composableBuilder(
      column: $table.nameOrNumber, builder: (column) => column);

  GeneratedColumn<int> get floor =>
      $composableBuilder(column: $table.floor, builder: (column) => column);

  GeneratedColumn<String> get bhkType =>
      $composableBuilder(column: $table.bhkType, builder: (column) => column);

  GeneratedColumn<double> get baseRent =>
      $composableBuilder(column: $table.baseRent, builder: (column) => column);

  GeneratedColumn<double> get editableRent => $composableBuilder(
      column: $table.editableRent, builder: (column) => column);

  GeneratedColumn<String> get furnishingStatus => $composableBuilder(
      column: $table.furnishingStatus, builder: (column) => column);

  GeneratedColumn<double> get carpetArea => $composableBuilder(
      column: $table.carpetArea, builder: (column) => column);

  GeneratedColumn<String> get parkingSlot => $composableBuilder(
      column: $table.parkingSlot, builder: (column) => column);

  GeneratedColumn<String> get meterNumber => $composableBuilder(
      column: $table.meterNumber, builder: (column) => column);

  GeneratedColumn<int> get defaultDueDay => $composableBuilder(
      column: $table.defaultDueDay, builder: (column) => column);

  GeneratedColumn<bool> get isOccupied => $composableBuilder(
      column: $table.isOccupied, builder: (column) => column);

  GeneratedColumn<String> get currentTenancyId => $composableBuilder(
      column: $table.currentTenancyId, builder: (column) => column);

  $$HousesTableAnnotationComposer get houseId {
    final $$HousesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HousesTableAnnotationComposer(
              $db: $db,
              $table: $db.houses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$OwnersTableAnnotationComposer get ownerId {
    final $$OwnersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableAnnotationComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BhkTemplatesTableAnnotationComposer get bhkTemplateId {
    final $$BhkTemplatesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bhkTemplateId,
        referencedTable: $db.bhkTemplates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BhkTemplatesTableAnnotationComposer(
              $db: $db,
              $table: $db.bhkTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> tenanciesRefs<T extends Object>(
      Expression<T> Function($$TenanciesTableAnnotationComposer a) f) {
    final $$TenanciesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tenancies,
        getReferencedColumn: (t) => t.unitId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TenanciesTableAnnotationComposer(
              $db: $db,
              $table: $db.tenancies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> electricReadingsRefs<T extends Object>(
      Expression<T> Function($$ElectricReadingsTableAnnotationComposer a) f) {
    final $$ElectricReadingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.electricReadings,
        getReferencedColumn: (t) => t.unitId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ElectricReadingsTableAnnotationComposer(
              $db: $db,
              $table: $db.electricReadings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UnitsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UnitsTable,
    Unit,
    $$UnitsTableFilterComposer,
    $$UnitsTableOrderingComposer,
    $$UnitsTableAnnotationComposer,
    $$UnitsTableCreateCompanionBuilder,
    $$UnitsTableUpdateCompanionBuilder,
    (Unit, $$UnitsTableReferences),
    Unit,
    PrefetchHooks Function(
        {bool houseId,
        bool ownerId,
        bool bhkTemplateId,
        bool tenanciesRefs,
        bool electricReadingsRefs})> {
  $$UnitsTableTableManager(_$AppDatabase db, $UnitsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> houseId = const Value.absent(),
            Value<String> ownerId = const Value.absent(),
            Value<String> nameOrNumber = const Value.absent(),
            Value<int?> floor = const Value.absent(),
            Value<String?> bhkTemplateId = const Value.absent(),
            Value<String?> bhkType = const Value.absent(),
            Value<double> baseRent = const Value.absent(),
            Value<double?> editableRent = const Value.absent(),
            Value<String?> furnishingStatus = const Value.absent(),
            Value<double?> carpetArea = const Value.absent(),
            Value<String?> parkingSlot = const Value.absent(),
            Value<String?> meterNumber = const Value.absent(),
            Value<int> defaultDueDay = const Value.absent(),
            Value<bool> isOccupied = const Value.absent(),
            Value<String?> currentTenancyId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UnitsCompanion(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            houseId: houseId,
            ownerId: ownerId,
            nameOrNumber: nameOrNumber,
            floor: floor,
            bhkTemplateId: bhkTemplateId,
            bhkType: bhkType,
            baseRent: baseRent,
            editableRent: editableRent,
            furnishingStatus: furnishingStatus,
            carpetArea: carpetArea,
            parkingSlot: parkingSlot,
            meterNumber: meterNumber,
            defaultDueDay: defaultDueDay,
            isOccupied: isOccupied,
            currentTenancyId: currentTenancyId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            required String id,
            required String houseId,
            required String ownerId,
            required String nameOrNumber,
            Value<int?> floor = const Value.absent(),
            Value<String?> bhkTemplateId = const Value.absent(),
            Value<String?> bhkType = const Value.absent(),
            required double baseRent,
            Value<double?> editableRent = const Value.absent(),
            Value<String?> furnishingStatus = const Value.absent(),
            Value<double?> carpetArea = const Value.absent(),
            Value<String?> parkingSlot = const Value.absent(),
            Value<String?> meterNumber = const Value.absent(),
            Value<int> defaultDueDay = const Value.absent(),
            Value<bool> isOccupied = const Value.absent(),
            Value<String?> currentTenancyId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UnitsCompanion.insert(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            houseId: houseId,
            ownerId: ownerId,
            nameOrNumber: nameOrNumber,
            floor: floor,
            bhkTemplateId: bhkTemplateId,
            bhkType: bhkType,
            baseRent: baseRent,
            editableRent: editableRent,
            furnishingStatus: furnishingStatus,
            carpetArea: carpetArea,
            parkingSlot: parkingSlot,
            meterNumber: meterNumber,
            defaultDueDay: defaultDueDay,
            isOccupied: isOccupied,
            currentTenancyId: currentTenancyId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$UnitsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {houseId = false,
              ownerId = false,
              bhkTemplateId = false,
              tenanciesRefs = false,
              electricReadingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tenanciesRefs) db.tenancies,
                if (electricReadingsRefs) db.electricReadings
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (houseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.houseId,
                    referencedTable: $$UnitsTableReferences._houseIdTable(db),
                    referencedColumn:
                        $$UnitsTableReferences._houseIdTable(db).id,
                  ) as T;
                }
                if (ownerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ownerId,
                    referencedTable: $$UnitsTableReferences._ownerIdTable(db),
                    referencedColumn:
                        $$UnitsTableReferences._ownerIdTable(db).id,
                  ) as T;
                }
                if (bhkTemplateId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.bhkTemplateId,
                    referencedTable:
                        $$UnitsTableReferences._bhkTemplateIdTable(db),
                    referencedColumn:
                        $$UnitsTableReferences._bhkTemplateIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tenanciesRefs)
                    await $_getPrefetchedData<Unit, $UnitsTable, Tenancy>(
                        currentTable: table,
                        referencedTable:
                            $$UnitsTableReferences._tenanciesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UnitsTableReferences(db, table, p0).tenanciesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.unitId == item.id),
                        typedResults: items),
                  if (electricReadingsRefs)
                    await $_getPrefetchedData<Unit, $UnitsTable,
                            ElectricReading>(
                        currentTable: table,
                        referencedTable: $$UnitsTableReferences
                            ._electricReadingsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UnitsTableReferences(db, table, p0)
                                .electricReadingsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.unitId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UnitsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UnitsTable,
    Unit,
    $$UnitsTableFilterComposer,
    $$UnitsTableOrderingComposer,
    $$UnitsTableAnnotationComposer,
    $$UnitsTableCreateCompanionBuilder,
    $$UnitsTableUpdateCompanionBuilder,
    (Unit, $$UnitsTableReferences),
    Unit,
    PrefetchHooks Function(
        {bool houseId,
        bool ownerId,
        bool bhkTemplateId,
        bool tenanciesRefs,
        bool electricReadingsRefs})>;
typedef $$TenantsTableCreateCompanionBuilder = TenantsCompanion Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  required String id,
  required String ownerId,
  required String tenantCode,
  required String name,
  required String phone,
  Value<String?> email,
  Value<bool> isActive,
  Value<String?> password,
  Value<int> rowid,
});
typedef $$TenantsTableUpdateCompanionBuilder = TenantsCompanion Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  Value<String> id,
  Value<String> ownerId,
  Value<String> tenantCode,
  Value<String> name,
  Value<String> phone,
  Value<String?> email,
  Value<bool> isActive,
  Value<String?> password,
  Value<int> rowid,
});

final class $$TenantsTableReferences
    extends BaseReferences<_$AppDatabase, $TenantsTable, Tenant> {
  $$TenantsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OwnersTable _ownerIdTable(_$AppDatabase db) => db.owners
      .createAlias($_aliasNameGenerator(db.tenants.ownerId, db.owners.id));

  $$OwnersTableProcessedTableManager get ownerId {
    final $_column = $_itemColumn<String>('owner_id')!;

    final manager = $$OwnersTableTableManager($_db, $_db.owners)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TenanciesTable, List<Tenancy>>
      _tenanciesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.tenancies,
              aliasName:
                  $_aliasNameGenerator(db.tenants.id, db.tenancies.tenantId));

  $$TenanciesTableProcessedTableManager get tenanciesRefs {
    final manager = $$TenanciesTableTableManager($_db, $_db.tenancies)
        .filter((f) => f.tenantId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tenanciesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TenantsTableFilterComposer
    extends Composer<_$AppDatabase, $TenantsTable> {
  $$TenantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantCode => $composableBuilder(
      column: $table.tenantCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnFilters(column));

  $$OwnersTableFilterComposer get ownerId {
    final $$OwnersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableFilterComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> tenanciesRefs(
      Expression<bool> Function($$TenanciesTableFilterComposer f) f) {
    final $$TenanciesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tenancies,
        getReferencedColumn: (t) => t.tenantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TenanciesTableFilterComposer(
              $db: $db,
              $table: $db.tenancies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TenantsTableOrderingComposer
    extends Composer<_$AppDatabase, $TenantsTable> {
  $$TenantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantCode => $composableBuilder(
      column: $table.tenantCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnOrderings(column));

  $$OwnersTableOrderingComposer get ownerId {
    final $$OwnersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableOrderingComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TenantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TenantsTable> {
  $$TenantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantCode => $composableBuilder(
      column: $table.tenantCode, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  $$OwnersTableAnnotationComposer get ownerId {
    final $$OwnersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableAnnotationComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> tenanciesRefs<T extends Object>(
      Expression<T> Function($$TenanciesTableAnnotationComposer a) f) {
    final $$TenanciesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tenancies,
        getReferencedColumn: (t) => t.tenantId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TenanciesTableAnnotationComposer(
              $db: $db,
              $table: $db.tenancies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TenantsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TenantsTable,
    Tenant,
    $$TenantsTableFilterComposer,
    $$TenantsTableOrderingComposer,
    $$TenantsTableAnnotationComposer,
    $$TenantsTableCreateCompanionBuilder,
    $$TenantsTableUpdateCompanionBuilder,
    (Tenant, $$TenantsTableReferences),
    Tenant,
    PrefetchHooks Function({bool ownerId, bool tenanciesRefs})> {
  $$TenantsTableTableManager(_$AppDatabase db, $TenantsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TenantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TenantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TenantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> ownerId = const Value.absent(),
            Value<String> tenantCode = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> password = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TenantsCompanion(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            ownerId: ownerId,
            tenantCode: tenantCode,
            name: name,
            phone: phone,
            email: email,
            isActive: isActive,
            password: password,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            required String id,
            required String ownerId,
            required String tenantCode,
            required String name,
            required String phone,
            Value<String?> email = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> password = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TenantsCompanion.insert(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            ownerId: ownerId,
            tenantCode: tenantCode,
            name: name,
            phone: phone,
            email: email,
            isActive: isActive,
            password: password,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TenantsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({ownerId = false, tenanciesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tenanciesRefs) db.tenancies],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (ownerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ownerId,
                    referencedTable: $$TenantsTableReferences._ownerIdTable(db),
                    referencedColumn:
                        $$TenantsTableReferences._ownerIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tenanciesRefs)
                    await $_getPrefetchedData<Tenant, $TenantsTable, Tenancy>(
                        currentTable: table,
                        referencedTable:
                            $$TenantsTableReferences._tenanciesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TenantsTableReferences(db, table, p0)
                                .tenanciesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.tenantId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TenantsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TenantsTable,
    Tenant,
    $$TenantsTableFilterComposer,
    $$TenantsTableOrderingComposer,
    $$TenantsTableAnnotationComposer,
    $$TenantsTableCreateCompanionBuilder,
    $$TenantsTableUpdateCompanionBuilder,
    (Tenant, $$TenantsTableReferences),
    Tenant,
    PrefetchHooks Function({bool ownerId, bool tenanciesRefs})>;
typedef $$TenanciesTableCreateCompanionBuilder = TenanciesCompanion Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  required String id,
  required String tenantId,
  required String unitId,
  required String ownerId,
  required DateTime startDate,
  Value<DateTime?> endDate,
  required double agreedRent,
  Value<double> securityDeposit,
  Value<double> openingBalance,
  Value<int> status,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$TenanciesTableUpdateCompanionBuilder = TenanciesCompanion Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  Value<String> id,
  Value<String> tenantId,
  Value<String> unitId,
  Value<String> ownerId,
  Value<DateTime> startDate,
  Value<DateTime?> endDate,
  Value<double> agreedRent,
  Value<double> securityDeposit,
  Value<double> openingBalance,
  Value<int> status,
  Value<String?> notes,
  Value<int> rowid,
});

final class $$TenanciesTableReferences
    extends BaseReferences<_$AppDatabase, $TenanciesTable, Tenancy> {
  $$TenanciesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TenantsTable _tenantIdTable(_$AppDatabase db) => db.tenants
      .createAlias($_aliasNameGenerator(db.tenancies.tenantId, db.tenants.id));

  $$TenantsTableProcessedTableManager get tenantId {
    final $_column = $_itemColumn<String>('tenant_id')!;

    final manager = $$TenantsTableTableManager($_db, $_db.tenants)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tenantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $UnitsTable _unitIdTable(_$AppDatabase db) => db.units
      .createAlias($_aliasNameGenerator(db.tenancies.unitId, db.units.id));

  $$UnitsTableProcessedTableManager get unitId {
    final $_column = $_itemColumn<String>('unit_id')!;

    final manager = $$UnitsTableTableManager($_db, $_db.units)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_unitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $OwnersTable _ownerIdTable(_$AppDatabase db) => db.owners
      .createAlias($_aliasNameGenerator(db.tenancies.ownerId, db.owners.id));

  $$OwnersTableProcessedTableManager get ownerId {
    final $_column = $_itemColumn<String>('owner_id')!;

    final manager = $$OwnersTableTableManager($_db, $_db.owners)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$RentCyclesTable, List<RentCycle>>
      _rentCyclesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.rentCycles,
          aliasName:
              $_aliasNameGenerator(db.tenancies.id, db.rentCycles.tenancyId));

  $$RentCyclesTableProcessedTableManager get rentCyclesRefs {
    final manager = $$RentCyclesTableTableManager($_db, $_db.rentCycles)
        .filter((f) => f.tenancyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_rentCyclesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TenanciesTableFilterComposer
    extends Composer<_$AppDatabase, $TenanciesTable> {
  $$TenanciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get agreedRent => $composableBuilder(
      column: $table.agreedRent, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get securityDeposit => $composableBuilder(
      column: $table.securityDeposit,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get openingBalance => $composableBuilder(
      column: $table.openingBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  $$TenantsTableFilterComposer get tenantId {
    final $$TenantsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tenantId,
        referencedTable: $db.tenants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TenantsTableFilterComposer(
              $db: $db,
              $table: $db.tenants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UnitsTableFilterComposer get unitId {
    final $$UnitsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.unitId,
        referencedTable: $db.units,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UnitsTableFilterComposer(
              $db: $db,
              $table: $db.units,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$OwnersTableFilterComposer get ownerId {
    final $$OwnersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableFilterComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> rentCyclesRefs(
      Expression<bool> Function($$RentCyclesTableFilterComposer f) f) {
    final $$RentCyclesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.rentCycles,
        getReferencedColumn: (t) => t.tenancyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RentCyclesTableFilterComposer(
              $db: $db,
              $table: $db.rentCycles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TenanciesTableOrderingComposer
    extends Composer<_$AppDatabase, $TenanciesTable> {
  $$TenanciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get agreedRent => $composableBuilder(
      column: $table.agreedRent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get securityDeposit => $composableBuilder(
      column: $table.securityDeposit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get openingBalance => $composableBuilder(
      column: $table.openingBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  $$TenantsTableOrderingComposer get tenantId {
    final $$TenantsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tenantId,
        referencedTable: $db.tenants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TenantsTableOrderingComposer(
              $db: $db,
              $table: $db.tenants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UnitsTableOrderingComposer get unitId {
    final $$UnitsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.unitId,
        referencedTable: $db.units,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UnitsTableOrderingComposer(
              $db: $db,
              $table: $db.units,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$OwnersTableOrderingComposer get ownerId {
    final $$OwnersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableOrderingComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TenanciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TenanciesTable> {
  $$TenanciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<double> get agreedRent => $composableBuilder(
      column: $table.agreedRent, builder: (column) => column);

  GeneratedColumn<double> get securityDeposit => $composableBuilder(
      column: $table.securityDeposit, builder: (column) => column);

  GeneratedColumn<double> get openingBalance => $composableBuilder(
      column: $table.openingBalance, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$TenantsTableAnnotationComposer get tenantId {
    final $$TenantsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tenantId,
        referencedTable: $db.tenants,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TenantsTableAnnotationComposer(
              $db: $db,
              $table: $db.tenants,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$UnitsTableAnnotationComposer get unitId {
    final $$UnitsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.unitId,
        referencedTable: $db.units,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UnitsTableAnnotationComposer(
              $db: $db,
              $table: $db.units,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$OwnersTableAnnotationComposer get ownerId {
    final $$OwnersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableAnnotationComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> rentCyclesRefs<T extends Object>(
      Expression<T> Function($$RentCyclesTableAnnotationComposer a) f) {
    final $$RentCyclesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.rentCycles,
        getReferencedColumn: (t) => t.tenancyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RentCyclesTableAnnotationComposer(
              $db: $db,
              $table: $db.rentCycles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TenanciesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TenanciesTable,
    Tenancy,
    $$TenanciesTableFilterComposer,
    $$TenanciesTableOrderingComposer,
    $$TenanciesTableAnnotationComposer,
    $$TenanciesTableCreateCompanionBuilder,
    $$TenanciesTableUpdateCompanionBuilder,
    (Tenancy, $$TenanciesTableReferences),
    Tenancy,
    PrefetchHooks Function(
        {bool tenantId, bool unitId, bool ownerId, bool rentCyclesRefs})> {
  $$TenanciesTableTableManager(_$AppDatabase db, $TenanciesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TenanciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TenanciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TenanciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String> unitId = const Value.absent(),
            Value<String> ownerId = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<double> agreedRent = const Value.absent(),
            Value<double> securityDeposit = const Value.absent(),
            Value<double> openingBalance = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TenanciesCompanion(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            tenantId: tenantId,
            unitId: unitId,
            ownerId: ownerId,
            startDate: startDate,
            endDate: endDate,
            agreedRent: agreedRent,
            securityDeposit: securityDeposit,
            openingBalance: openingBalance,
            status: status,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            required String id,
            required String tenantId,
            required String unitId,
            required String ownerId,
            required DateTime startDate,
            Value<DateTime?> endDate = const Value.absent(),
            required double agreedRent,
            Value<double> securityDeposit = const Value.absent(),
            Value<double> openingBalance = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TenanciesCompanion.insert(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            tenantId: tenantId,
            unitId: unitId,
            ownerId: ownerId,
            startDate: startDate,
            endDate: endDate,
            agreedRent: agreedRent,
            securityDeposit: securityDeposit,
            openingBalance: openingBalance,
            status: status,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TenanciesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {tenantId = false,
              unitId = false,
              ownerId = false,
              rentCyclesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (rentCyclesRefs) db.rentCycles],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (tenantId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tenantId,
                    referencedTable:
                        $$TenanciesTableReferences._tenantIdTable(db),
                    referencedColumn:
                        $$TenanciesTableReferences._tenantIdTable(db).id,
                  ) as T;
                }
                if (unitId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.unitId,
                    referencedTable:
                        $$TenanciesTableReferences._unitIdTable(db),
                    referencedColumn:
                        $$TenanciesTableReferences._unitIdTable(db).id,
                  ) as T;
                }
                if (ownerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ownerId,
                    referencedTable:
                        $$TenanciesTableReferences._ownerIdTable(db),
                    referencedColumn:
                        $$TenanciesTableReferences._ownerIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (rentCyclesRefs)
                    await $_getPrefetchedData<Tenancy, $TenanciesTable,
                            RentCycle>(
                        currentTable: table,
                        referencedTable:
                            $$TenanciesTableReferences._rentCyclesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TenanciesTableReferences(db, table, p0)
                                .rentCyclesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.tenancyId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TenanciesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TenanciesTable,
    Tenancy,
    $$TenanciesTableFilterComposer,
    $$TenanciesTableOrderingComposer,
    $$TenanciesTableAnnotationComposer,
    $$TenanciesTableCreateCompanionBuilder,
    $$TenanciesTableUpdateCompanionBuilder,
    (Tenancy, $$TenanciesTableReferences),
    Tenancy,
    PrefetchHooks Function(
        {bool tenantId, bool unitId, bool ownerId, bool rentCyclesRefs})>;
typedef $$RentCyclesTableCreateCompanionBuilder = RentCyclesCompanion Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  required String id,
  required String tenancyId,
  required String ownerId,
  required String month,
  Value<String?> billNumber,
  Value<DateTime?> billPeriodStart,
  Value<DateTime?> billPeriodEnd,
  Value<DateTime> billGeneratedDate,
  Value<DateTime?> dueDate,
  required double baseRent,
  Value<double> electricAmount,
  Value<double> otherCharges,
  Value<double> discount,
  required double totalDue,
  Value<double> totalPaid,
  Value<int> status,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$RentCyclesTableUpdateCompanionBuilder = RentCyclesCompanion Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  Value<String> id,
  Value<String> tenancyId,
  Value<String> ownerId,
  Value<String> month,
  Value<String?> billNumber,
  Value<DateTime?> billPeriodStart,
  Value<DateTime?> billPeriodEnd,
  Value<DateTime> billGeneratedDate,
  Value<DateTime?> dueDate,
  Value<double> baseRent,
  Value<double> electricAmount,
  Value<double> otherCharges,
  Value<double> discount,
  Value<double> totalDue,
  Value<double> totalPaid,
  Value<int> status,
  Value<String?> notes,
  Value<int> rowid,
});

final class $$RentCyclesTableReferences
    extends BaseReferences<_$AppDatabase, $RentCyclesTable, RentCycle> {
  $$RentCyclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TenanciesTable _tenancyIdTable(_$AppDatabase db) =>
      db.tenancies.createAlias(
          $_aliasNameGenerator(db.rentCycles.tenancyId, db.tenancies.id));

  $$TenanciesTableProcessedTableManager get tenancyId {
    final $_column = $_itemColumn<String>('tenancy_id')!;

    final manager = $$TenanciesTableTableManager($_db, $_db.tenancies)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tenancyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $OwnersTable _ownerIdTable(_$AppDatabase db) => db.owners
      .createAlias($_aliasNameGenerator(db.rentCycles.ownerId, db.owners.id));

  $$OwnersTableProcessedTableManager get ownerId {
    final $_column = $_itemColumn<String>('owner_id')!;

    final manager = $$OwnersTableTableManager($_db, $_db.owners)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.payments,
          aliasName:
              $_aliasNameGenerator(db.rentCycles.id, db.payments.rentCycleId));

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager($_db, $_db.payments)
        .filter((f) => f.rentCycleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$OtherChargesTable, List<OtherCharge>>
      _otherChargesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.otherCharges,
              aliasName: $_aliasNameGenerator(
                  db.rentCycles.id, db.otherCharges.rentCycleId));

  $$OtherChargesTableProcessedTableManager get otherChargesRefs {
    final manager = $$OtherChargesTableTableManager($_db, $_db.otherCharges)
        .filter((f) => f.rentCycleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_otherChargesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RentCyclesTableFilterComposer
    extends Composer<_$AppDatabase, $RentCyclesTable> {
  $$RentCyclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get month => $composableBuilder(
      column: $table.month, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get billNumber => $composableBuilder(
      column: $table.billNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get billPeriodStart => $composableBuilder(
      column: $table.billPeriodStart,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get billPeriodEnd => $composableBuilder(
      column: $table.billPeriodEnd, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get billGeneratedDate => $composableBuilder(
      column: $table.billGeneratedDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get baseRent => $composableBuilder(
      column: $table.baseRent, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get electricAmount => $composableBuilder(
      column: $table.electricAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get otherCharges => $composableBuilder(
      column: $table.otherCharges, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalDue => $composableBuilder(
      column: $table.totalDue, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalPaid => $composableBuilder(
      column: $table.totalPaid, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  $$TenanciesTableFilterComposer get tenancyId {
    final $$TenanciesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tenancyId,
        referencedTable: $db.tenancies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TenanciesTableFilterComposer(
              $db: $db,
              $table: $db.tenancies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$OwnersTableFilterComposer get ownerId {
    final $$OwnersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableFilterComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> paymentsRefs(
      Expression<bool> Function($$PaymentsTableFilterComposer f) f) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.rentCycleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableFilterComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> otherChargesRefs(
      Expression<bool> Function($$OtherChargesTableFilterComposer f) f) {
    final $$OtherChargesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.otherCharges,
        getReferencedColumn: (t) => t.rentCycleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OtherChargesTableFilterComposer(
              $db: $db,
              $table: $db.otherCharges,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RentCyclesTableOrderingComposer
    extends Composer<_$AppDatabase, $RentCyclesTable> {
  $$RentCyclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get month => $composableBuilder(
      column: $table.month, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get billNumber => $composableBuilder(
      column: $table.billNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get billPeriodStart => $composableBuilder(
      column: $table.billPeriodStart,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get billPeriodEnd => $composableBuilder(
      column: $table.billPeriodEnd,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get billGeneratedDate => $composableBuilder(
      column: $table.billGeneratedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get baseRent => $composableBuilder(
      column: $table.baseRent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get electricAmount => $composableBuilder(
      column: $table.electricAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get otherCharges => $composableBuilder(
      column: $table.otherCharges,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalDue => $composableBuilder(
      column: $table.totalDue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalPaid => $composableBuilder(
      column: $table.totalPaid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  $$TenanciesTableOrderingComposer get tenancyId {
    final $$TenanciesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tenancyId,
        referencedTable: $db.tenancies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TenanciesTableOrderingComposer(
              $db: $db,
              $table: $db.tenancies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$OwnersTableOrderingComposer get ownerId {
    final $$OwnersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableOrderingComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RentCyclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RentCyclesTable> {
  $$RentCyclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<String> get billNumber => $composableBuilder(
      column: $table.billNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get billPeriodStart => $composableBuilder(
      column: $table.billPeriodStart, builder: (column) => column);

  GeneratedColumn<DateTime> get billPeriodEnd => $composableBuilder(
      column: $table.billPeriodEnd, builder: (column) => column);

  GeneratedColumn<DateTime> get billGeneratedDate => $composableBuilder(
      column: $table.billGeneratedDate, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<double> get baseRent =>
      $composableBuilder(column: $table.baseRent, builder: (column) => column);

  GeneratedColumn<double> get electricAmount => $composableBuilder(
      column: $table.electricAmount, builder: (column) => column);

  GeneratedColumn<double> get otherCharges => $composableBuilder(
      column: $table.otherCharges, builder: (column) => column);

  GeneratedColumn<double> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<double> get totalDue =>
      $composableBuilder(column: $table.totalDue, builder: (column) => column);

  GeneratedColumn<double> get totalPaid =>
      $composableBuilder(column: $table.totalPaid, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$TenanciesTableAnnotationComposer get tenancyId {
    final $$TenanciesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tenancyId,
        referencedTable: $db.tenancies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TenanciesTableAnnotationComposer(
              $db: $db,
              $table: $db.tenancies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$OwnersTableAnnotationComposer get ownerId {
    final $$OwnersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableAnnotationComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> paymentsRefs<T extends Object>(
      Expression<T> Function($$PaymentsTableAnnotationComposer a) f) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.rentCycleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableAnnotationComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> otherChargesRefs<T extends Object>(
      Expression<T> Function($$OtherChargesTableAnnotationComposer a) f) {
    final $$OtherChargesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.otherCharges,
        getReferencedColumn: (t) => t.rentCycleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OtherChargesTableAnnotationComposer(
              $db: $db,
              $table: $db.otherCharges,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RentCyclesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RentCyclesTable,
    RentCycle,
    $$RentCyclesTableFilterComposer,
    $$RentCyclesTableOrderingComposer,
    $$RentCyclesTableAnnotationComposer,
    $$RentCyclesTableCreateCompanionBuilder,
    $$RentCyclesTableUpdateCompanionBuilder,
    (RentCycle, $$RentCyclesTableReferences),
    RentCycle,
    PrefetchHooks Function(
        {bool tenancyId,
        bool ownerId,
        bool paymentsRefs,
        bool otherChargesRefs})> {
  $$RentCyclesTableTableManager(_$AppDatabase db, $RentCyclesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RentCyclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RentCyclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RentCyclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> tenancyId = const Value.absent(),
            Value<String> ownerId = const Value.absent(),
            Value<String> month = const Value.absent(),
            Value<String?> billNumber = const Value.absent(),
            Value<DateTime?> billPeriodStart = const Value.absent(),
            Value<DateTime?> billPeriodEnd = const Value.absent(),
            Value<DateTime> billGeneratedDate = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<double> baseRent = const Value.absent(),
            Value<double> electricAmount = const Value.absent(),
            Value<double> otherCharges = const Value.absent(),
            Value<double> discount = const Value.absent(),
            Value<double> totalDue = const Value.absent(),
            Value<double> totalPaid = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RentCyclesCompanion(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            tenancyId: tenancyId,
            ownerId: ownerId,
            month: month,
            billNumber: billNumber,
            billPeriodStart: billPeriodStart,
            billPeriodEnd: billPeriodEnd,
            billGeneratedDate: billGeneratedDate,
            dueDate: dueDate,
            baseRent: baseRent,
            electricAmount: electricAmount,
            otherCharges: otherCharges,
            discount: discount,
            totalDue: totalDue,
            totalPaid: totalPaid,
            status: status,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            required String id,
            required String tenancyId,
            required String ownerId,
            required String month,
            Value<String?> billNumber = const Value.absent(),
            Value<DateTime?> billPeriodStart = const Value.absent(),
            Value<DateTime?> billPeriodEnd = const Value.absent(),
            Value<DateTime> billGeneratedDate = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            required double baseRent,
            Value<double> electricAmount = const Value.absent(),
            Value<double> otherCharges = const Value.absent(),
            Value<double> discount = const Value.absent(),
            required double totalDue,
            Value<double> totalPaid = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RentCyclesCompanion.insert(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            tenancyId: tenancyId,
            ownerId: ownerId,
            month: month,
            billNumber: billNumber,
            billPeriodStart: billPeriodStart,
            billPeriodEnd: billPeriodEnd,
            billGeneratedDate: billGeneratedDate,
            dueDate: dueDate,
            baseRent: baseRent,
            electricAmount: electricAmount,
            otherCharges: otherCharges,
            discount: discount,
            totalDue: totalDue,
            totalPaid: totalPaid,
            status: status,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RentCyclesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {tenancyId = false,
              ownerId = false,
              paymentsRefs = false,
              otherChargesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (paymentsRefs) db.payments,
                if (otherChargesRefs) db.otherCharges
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (tenancyId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tenancyId,
                    referencedTable:
                        $$RentCyclesTableReferences._tenancyIdTable(db),
                    referencedColumn:
                        $$RentCyclesTableReferences._tenancyIdTable(db).id,
                  ) as T;
                }
                if (ownerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ownerId,
                    referencedTable:
                        $$RentCyclesTableReferences._ownerIdTable(db),
                    referencedColumn:
                        $$RentCyclesTableReferences._ownerIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (paymentsRefs)
                    await $_getPrefetchedData<RentCycle, $RentCyclesTable,
                            Payment>(
                        currentTable: table,
                        referencedTable:
                            $$RentCyclesTableReferences._paymentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RentCyclesTableReferences(db, table, p0)
                                .paymentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.rentCycleId == item.id),
                        typedResults: items),
                  if (otherChargesRefs)
                    await $_getPrefetchedData<RentCycle, $RentCyclesTable,
                            OtherCharge>(
                        currentTable: table,
                        referencedTable: $$RentCyclesTableReferences
                            ._otherChargesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RentCyclesTableReferences(db, table, p0)
                                .otherChargesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.rentCycleId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RentCyclesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RentCyclesTable,
    RentCycle,
    $$RentCyclesTableFilterComposer,
    $$RentCyclesTableOrderingComposer,
    $$RentCyclesTableAnnotationComposer,
    $$RentCyclesTableCreateCompanionBuilder,
    $$RentCyclesTableUpdateCompanionBuilder,
    (RentCycle, $$RentCyclesTableReferences),
    RentCycle,
    PrefetchHooks Function(
        {bool tenancyId,
        bool ownerId,
        bool paymentsRefs,
        bool otherChargesRefs})>;
typedef $$PaymentChannelsTableCreateCompanionBuilder = PaymentChannelsCompanion
    Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  Value<int> id,
  required String name,
  required String type,
  Value<String?> details,
});
typedef $$PaymentChannelsTableUpdateCompanionBuilder = PaymentChannelsCompanion
    Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  Value<int> id,
  Value<String> name,
  Value<String> type,
  Value<String?> details,
});

final class $$PaymentChannelsTableReferences extends BaseReferences<
    _$AppDatabase, $PaymentChannelsTable, PaymentChannel> {
  $$PaymentChannelsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.payments,
          aliasName: $_aliasNameGenerator(
              db.paymentChannels.id, db.payments.channelId));

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager($_db, $_db.payments)
        .filter((f) => f.channelId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PaymentChannelsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentChannelsTable> {
  $$PaymentChannelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get details => $composableBuilder(
      column: $table.details, builder: (column) => ColumnFilters(column));

  Expression<bool> paymentsRefs(
      Expression<bool> Function($$PaymentsTableFilterComposer f) f) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.channelId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableFilterComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PaymentChannelsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentChannelsTable> {
  $$PaymentChannelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get details => $composableBuilder(
      column: $table.details, builder: (column) => ColumnOrderings(column));
}

class $$PaymentChannelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentChannelsTable> {
  $$PaymentChannelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  Expression<T> paymentsRefs<T extends Object>(
      Expression<T> Function($$PaymentsTableAnnotationComposer a) f) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.channelId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableAnnotationComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PaymentChannelsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PaymentChannelsTable,
    PaymentChannel,
    $$PaymentChannelsTableFilterComposer,
    $$PaymentChannelsTableOrderingComposer,
    $$PaymentChannelsTableAnnotationComposer,
    $$PaymentChannelsTableCreateCompanionBuilder,
    $$PaymentChannelsTableUpdateCompanionBuilder,
    (PaymentChannel, $$PaymentChannelsTableReferences),
    PaymentChannel,
    PrefetchHooks Function({bool paymentsRefs})> {
  $$PaymentChannelsTableTableManager(
      _$AppDatabase db, $PaymentChannelsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentChannelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentChannelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentChannelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> details = const Value.absent(),
          }) =>
              PaymentChannelsCompanion(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            name: name,
            type: type,
            details: details,
          ),
          createCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> id = const Value.absent(),
            required String name,
            required String type,
            Value<String?> details = const Value.absent(),
          }) =>
              PaymentChannelsCompanion.insert(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            name: name,
            type: type,
            details: details,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PaymentChannelsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({paymentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (paymentsRefs) db.payments],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (paymentsRefs)
                    await $_getPrefetchedData<PaymentChannel,
                            $PaymentChannelsTable, Payment>(
                        currentTable: table,
                        referencedTable: $$PaymentChannelsTableReferences
                            ._paymentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PaymentChannelsTableReferences(db, table, p0)
                                .paymentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.channelId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PaymentChannelsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PaymentChannelsTable,
    PaymentChannel,
    $$PaymentChannelsTableFilterComposer,
    $$PaymentChannelsTableOrderingComposer,
    $$PaymentChannelsTableAnnotationComposer,
    $$PaymentChannelsTableCreateCompanionBuilder,
    $$PaymentChannelsTableUpdateCompanionBuilder,
    (PaymentChannel, $$PaymentChannelsTableReferences),
    PaymentChannel,
    PrefetchHooks Function({bool paymentsRefs})>;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  required String id,
  required String rentCycleId,
  required String ownerId,
  required double amount,
  required DateTime date,
  required String method,
  Value<int?> channelId,
  Value<String?> referenceId,
  Value<String?> collectedBy,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  Value<String> id,
  Value<String> rentCycleId,
  Value<String> ownerId,
  Value<double> amount,
  Value<DateTime> date,
  Value<String> method,
  Value<int?> channelId,
  Value<String?> referenceId,
  Value<String?> collectedBy,
  Value<String?> notes,
  Value<int> rowid,
});

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, Payment> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RentCyclesTable _rentCycleIdTable(_$AppDatabase db) =>
      db.rentCycles.createAlias(
          $_aliasNameGenerator(db.payments.rentCycleId, db.rentCycles.id));

  $$RentCyclesTableProcessedTableManager get rentCycleId {
    final $_column = $_itemColumn<String>('rent_cycle_id')!;

    final manager = $$RentCyclesTableTableManager($_db, $_db.rentCycles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rentCycleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $OwnersTable _ownerIdTable(_$AppDatabase db) => db.owners
      .createAlias($_aliasNameGenerator(db.payments.ownerId, db.owners.id));

  $$OwnersTableProcessedTableManager get ownerId {
    final $_column = $_itemColumn<String>('owner_id')!;

    final manager = $$OwnersTableTableManager($_db, $_db.owners)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $PaymentChannelsTable _channelIdTable(_$AppDatabase db) =>
      db.paymentChannels.createAlias(
          $_aliasNameGenerator(db.payments.channelId, db.paymentChannels.id));

  $$PaymentChannelsTableProcessedTableManager? get channelId {
    final $_column = $_itemColumn<int>('channel_id');
    if ($_column == null) return null;
    final manager =
        $$PaymentChannelsTableTableManager($_db, $_db.paymentChannels)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_channelIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collectedBy => $composableBuilder(
      column: $table.collectedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  $$RentCyclesTableFilterComposer get rentCycleId {
    final $$RentCyclesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rentCycleId,
        referencedTable: $db.rentCycles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RentCyclesTableFilterComposer(
              $db: $db,
              $table: $db.rentCycles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$OwnersTableFilterComposer get ownerId {
    final $$OwnersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableFilterComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PaymentChannelsTableFilterComposer get channelId {
    final $$PaymentChannelsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.channelId,
        referencedTable: $db.paymentChannels,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentChannelsTableFilterComposer(
              $db: $db,
              $table: $db.paymentChannels,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collectedBy => $composableBuilder(
      column: $table.collectedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  $$RentCyclesTableOrderingComposer get rentCycleId {
    final $$RentCyclesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rentCycleId,
        referencedTable: $db.rentCycles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RentCyclesTableOrderingComposer(
              $db: $db,
              $table: $db.rentCycles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$OwnersTableOrderingComposer get ownerId {
    final $$OwnersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableOrderingComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PaymentChannelsTableOrderingComposer get channelId {
    final $$PaymentChannelsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.channelId,
        referencedTable: $db.paymentChannels,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentChannelsTableOrderingComposer(
              $db: $db,
              $table: $db.paymentChannels,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get referenceId => $composableBuilder(
      column: $table.referenceId, builder: (column) => column);

  GeneratedColumn<String> get collectedBy => $composableBuilder(
      column: $table.collectedBy, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$RentCyclesTableAnnotationComposer get rentCycleId {
    final $$RentCyclesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rentCycleId,
        referencedTable: $db.rentCycles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RentCyclesTableAnnotationComposer(
              $db: $db,
              $table: $db.rentCycles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$OwnersTableAnnotationComposer get ownerId {
    final $$OwnersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableAnnotationComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PaymentChannelsTableAnnotationComposer get channelId {
    final $$PaymentChannelsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.channelId,
        referencedTable: $db.paymentChannels,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentChannelsTableAnnotationComposer(
              $db: $db,
              $table: $db.paymentChannels,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, $$PaymentsTableReferences),
    Payment,
    PrefetchHooks Function({bool rentCycleId, bool ownerId, bool channelId})> {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> rentCycleId = const Value.absent(),
            Value<String> ownerId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> method = const Value.absent(),
            Value<int?> channelId = const Value.absent(),
            Value<String?> referenceId = const Value.absent(),
            Value<String?> collectedBy = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsCompanion(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            rentCycleId: rentCycleId,
            ownerId: ownerId,
            amount: amount,
            date: date,
            method: method,
            channelId: channelId,
            referenceId: referenceId,
            collectedBy: collectedBy,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            required String id,
            required String rentCycleId,
            required String ownerId,
            required double amount,
            required DateTime date,
            required String method,
            Value<int?> channelId = const Value.absent(),
            Value<String?> referenceId = const Value.absent(),
            Value<String?> collectedBy = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsCompanion.insert(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            rentCycleId: rentCycleId,
            ownerId: ownerId,
            amount: amount,
            date: date,
            method: method,
            channelId: channelId,
            referenceId: referenceId,
            collectedBy: collectedBy,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PaymentsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {rentCycleId = false, ownerId = false, channelId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (rentCycleId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.rentCycleId,
                    referencedTable:
                        $$PaymentsTableReferences._rentCycleIdTable(db),
                    referencedColumn:
                        $$PaymentsTableReferences._rentCycleIdTable(db).id,
                  ) as T;
                }
                if (ownerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ownerId,
                    referencedTable:
                        $$PaymentsTableReferences._ownerIdTable(db),
                    referencedColumn:
                        $$PaymentsTableReferences._ownerIdTable(db).id,
                  ) as T;
                }
                if (channelId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.channelId,
                    referencedTable:
                        $$PaymentsTableReferences._channelIdTable(db),
                    referencedColumn:
                        $$PaymentsTableReferences._channelIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PaymentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, $$PaymentsTableReferences),
    Payment,
    PrefetchHooks Function({bool rentCycleId, bool ownerId, bool channelId})>;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  required String id,
  required String ownerId,
  required String title,
  required DateTime date,
  required double amount,
  required String category,
  Value<String?> description,
  Value<int> rowid,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  Value<String> id,
  Value<String> ownerId,
  Value<String> title,
  Value<DateTime> date,
  Value<double> amount,
  Value<String> category,
  Value<String?> description,
  Value<int> rowid,
});

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, Expense> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OwnersTable _ownerIdTable(_$AppDatabase db) => db.owners
      .createAlias($_aliasNameGenerator(db.expenses.ownerId, db.owners.id));

  $$OwnersTableProcessedTableManager get ownerId {
    final $_column = $_itemColumn<String>('owner_id')!;

    final manager = $$OwnersTableTableManager($_db, $_db.owners)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  $$OwnersTableFilterComposer get ownerId {
    final $$OwnersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableFilterComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  $$OwnersTableOrderingComposer get ownerId {
    final $$OwnersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableOrderingComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  $$OwnersTableAnnotationComposer get ownerId {
    final $$OwnersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableAnnotationComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpensesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpensesTable,
    Expense,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (Expense, $$ExpensesTableReferences),
    Expense,
    PrefetchHooks Function({bool ownerId})> {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> ownerId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpensesCompanion(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            ownerId: ownerId,
            title: title,
            date: date,
            amount: amount,
            category: category,
            description: description,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            required String id,
            required String ownerId,
            required String title,
            required DateTime date,
            required double amount,
            required String category,
            Value<String?> description = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpensesCompanion.insert(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            ownerId: ownerId,
            title: title,
            date: date,
            amount: amount,
            category: category,
            description: description,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ExpensesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({ownerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (ownerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ownerId,
                    referencedTable:
                        $$ExpensesTableReferences._ownerIdTable(db),
                    referencedColumn:
                        $$ExpensesTableReferences._ownerIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ExpensesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExpensesTable,
    Expense,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (Expense, $$ExpensesTableReferences),
    Expense,
    PrefetchHooks Function({bool ownerId})>;
typedef $$ElectricReadingsTableCreateCompanionBuilder
    = ElectricReadingsCompanion Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  required String id,
  required String unitId,
  required String ownerId,
  required DateTime readingDate,
  Value<String?> meterName,
  Value<double> prevReading,
  required double currentReading,
  Value<double> ratePerUnit,
  required double amount,
  Value<String?> imagePath,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$ElectricReadingsTableUpdateCompanionBuilder
    = ElectricReadingsCompanion Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  Value<String> id,
  Value<String> unitId,
  Value<String> ownerId,
  Value<DateTime> readingDate,
  Value<String?> meterName,
  Value<double> prevReading,
  Value<double> currentReading,
  Value<double> ratePerUnit,
  Value<double> amount,
  Value<String?> imagePath,
  Value<String?> notes,
  Value<int> rowid,
});

final class $$ElectricReadingsTableReferences extends BaseReferences<
    _$AppDatabase, $ElectricReadingsTable, ElectricReading> {
  $$ElectricReadingsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $UnitsTable _unitIdTable(_$AppDatabase db) => db.units.createAlias(
      $_aliasNameGenerator(db.electricReadings.unitId, db.units.id));

  $$UnitsTableProcessedTableManager get unitId {
    final $_column = $_itemColumn<String>('unit_id')!;

    final manager = $$UnitsTableTableManager($_db, $_db.units)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_unitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $OwnersTable _ownerIdTable(_$AppDatabase db) => db.owners.createAlias(
      $_aliasNameGenerator(db.electricReadings.ownerId, db.owners.id));

  $$OwnersTableProcessedTableManager get ownerId {
    final $_column = $_itemColumn<String>('owner_id')!;

    final manager = $$OwnersTableTableManager($_db, $_db.owners)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ElectricReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $ElectricReadingsTable> {
  $$ElectricReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get readingDate => $composableBuilder(
      column: $table.readingDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get meterName => $composableBuilder(
      column: $table.meterName, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get prevReading => $composableBuilder(
      column: $table.prevReading, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get currentReading => $composableBuilder(
      column: $table.currentReading,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get ratePerUnit => $composableBuilder(
      column: $table.ratePerUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  $$UnitsTableFilterComposer get unitId {
    final $$UnitsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.unitId,
        referencedTable: $db.units,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UnitsTableFilterComposer(
              $db: $db,
              $table: $db.units,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$OwnersTableFilterComposer get ownerId {
    final $$OwnersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableFilterComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ElectricReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ElectricReadingsTable> {
  $$ElectricReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get readingDate => $composableBuilder(
      column: $table.readingDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get meterName => $composableBuilder(
      column: $table.meterName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get prevReading => $composableBuilder(
      column: $table.prevReading, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentReading => $composableBuilder(
      column: $table.currentReading,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get ratePerUnit => $composableBuilder(
      column: $table.ratePerUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  $$UnitsTableOrderingComposer get unitId {
    final $$UnitsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.unitId,
        referencedTable: $db.units,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UnitsTableOrderingComposer(
              $db: $db,
              $table: $db.units,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$OwnersTableOrderingComposer get ownerId {
    final $$OwnersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableOrderingComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ElectricReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ElectricReadingsTable> {
  $$ElectricReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get readingDate => $composableBuilder(
      column: $table.readingDate, builder: (column) => column);

  GeneratedColumn<String> get meterName =>
      $composableBuilder(column: $table.meterName, builder: (column) => column);

  GeneratedColumn<double> get prevReading => $composableBuilder(
      column: $table.prevReading, builder: (column) => column);

  GeneratedColumn<double> get currentReading => $composableBuilder(
      column: $table.currentReading, builder: (column) => column);

  GeneratedColumn<double> get ratePerUnit => $composableBuilder(
      column: $table.ratePerUnit, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$UnitsTableAnnotationComposer get unitId {
    final $$UnitsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.unitId,
        referencedTable: $db.units,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UnitsTableAnnotationComposer(
              $db: $db,
              $table: $db.units,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$OwnersTableAnnotationComposer get ownerId {
    final $$OwnersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ownerId,
        referencedTable: $db.owners,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OwnersTableAnnotationComposer(
              $db: $db,
              $table: $db.owners,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ElectricReadingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ElectricReadingsTable,
    ElectricReading,
    $$ElectricReadingsTableFilterComposer,
    $$ElectricReadingsTableOrderingComposer,
    $$ElectricReadingsTableAnnotationComposer,
    $$ElectricReadingsTableCreateCompanionBuilder,
    $$ElectricReadingsTableUpdateCompanionBuilder,
    (ElectricReading, $$ElectricReadingsTableReferences),
    ElectricReading,
    PrefetchHooks Function({bool unitId, bool ownerId})> {
  $$ElectricReadingsTableTableManager(
      _$AppDatabase db, $ElectricReadingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ElectricReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ElectricReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ElectricReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> unitId = const Value.absent(),
            Value<String> ownerId = const Value.absent(),
            Value<DateTime> readingDate = const Value.absent(),
            Value<String?> meterName = const Value.absent(),
            Value<double> prevReading = const Value.absent(),
            Value<double> currentReading = const Value.absent(),
            Value<double> ratePerUnit = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ElectricReadingsCompanion(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            unitId: unitId,
            ownerId: ownerId,
            readingDate: readingDate,
            meterName: meterName,
            prevReading: prevReading,
            currentReading: currentReading,
            ratePerUnit: ratePerUnit,
            amount: amount,
            imagePath: imagePath,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            required String id,
            required String unitId,
            required String ownerId,
            required DateTime readingDate,
            Value<String?> meterName = const Value.absent(),
            Value<double> prevReading = const Value.absent(),
            required double currentReading,
            Value<double> ratePerUnit = const Value.absent(),
            required double amount,
            Value<String?> imagePath = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ElectricReadingsCompanion.insert(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            unitId: unitId,
            ownerId: ownerId,
            readingDate: readingDate,
            meterName: meterName,
            prevReading: prevReading,
            currentReading: currentReading,
            ratePerUnit: ratePerUnit,
            amount: amount,
            imagePath: imagePath,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ElectricReadingsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({unitId = false, ownerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (unitId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.unitId,
                    referencedTable:
                        $$ElectricReadingsTableReferences._unitIdTable(db),
                    referencedColumn:
                        $$ElectricReadingsTableReferences._unitIdTable(db).id,
                  ) as T;
                }
                if (ownerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ownerId,
                    referencedTable:
                        $$ElectricReadingsTableReferences._ownerIdTable(db),
                    referencedColumn:
                        $$ElectricReadingsTableReferences._ownerIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ElectricReadingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ElectricReadingsTable,
    ElectricReading,
    $$ElectricReadingsTableFilterComposer,
    $$ElectricReadingsTableOrderingComposer,
    $$ElectricReadingsTableAnnotationComposer,
    $$ElectricReadingsTableCreateCompanionBuilder,
    $$ElectricReadingsTableUpdateCompanionBuilder,
    (ElectricReading, $$ElectricReadingsTableReferences),
    ElectricReading,
    PrefetchHooks Function({bool unitId, bool ownerId})>;
typedef $$OtherChargesTableCreateCompanionBuilder = OtherChargesCompanion
    Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  required String id,
  required String rentCycleId,
  required double amount,
  required String category,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$OtherChargesTableUpdateCompanionBuilder = OtherChargesCompanion
    Function({
  Value<String?> firestoreId,
  Value<DateTime> lastUpdated,
  Value<bool> isSynced,
  Value<bool> isDeleted,
  Value<String> id,
  Value<String> rentCycleId,
  Value<double> amount,
  Value<String> category,
  Value<String?> notes,
  Value<int> rowid,
});

final class $$OtherChargesTableReferences
    extends BaseReferences<_$AppDatabase, $OtherChargesTable, OtherCharge> {
  $$OtherChargesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RentCyclesTable _rentCycleIdTable(_$AppDatabase db) =>
      db.rentCycles.createAlias(
          $_aliasNameGenerator(db.otherCharges.rentCycleId, db.rentCycles.id));

  $$RentCyclesTableProcessedTableManager get rentCycleId {
    final $_column = $_itemColumn<String>('rent_cycle_id')!;

    final manager = $$RentCyclesTableTableManager($_db, $_db.rentCycles)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rentCycleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$OtherChargesTableFilterComposer
    extends Composer<_$AppDatabase, $OtherChargesTable> {
  $$OtherChargesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  $$RentCyclesTableFilterComposer get rentCycleId {
    final $$RentCyclesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rentCycleId,
        referencedTable: $db.rentCycles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RentCyclesTableFilterComposer(
              $db: $db,
              $table: $db.rentCycles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OtherChargesTableOrderingComposer
    extends Composer<_$AppDatabase, $OtherChargesTable> {
  $$OtherChargesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  $$RentCyclesTableOrderingComposer get rentCycleId {
    final $$RentCyclesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rentCycleId,
        referencedTable: $db.rentCycles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RentCyclesTableOrderingComposer(
              $db: $db,
              $table: $db.rentCycles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OtherChargesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OtherChargesTable> {
  $$OtherChargesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get firestoreId => $composableBuilder(
      column: $table.firestoreId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$RentCyclesTableAnnotationComposer get rentCycleId {
    final $$RentCyclesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.rentCycleId,
        referencedTable: $db.rentCycles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RentCyclesTableAnnotationComposer(
              $db: $db,
              $table: $db.rentCycles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$OtherChargesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OtherChargesTable,
    OtherCharge,
    $$OtherChargesTableFilterComposer,
    $$OtherChargesTableOrderingComposer,
    $$OtherChargesTableAnnotationComposer,
    $$OtherChargesTableCreateCompanionBuilder,
    $$OtherChargesTableUpdateCompanionBuilder,
    (OtherCharge, $$OtherChargesTableReferences),
    OtherCharge,
    PrefetchHooks Function({bool rentCycleId})> {
  $$OtherChargesTableTableManager(_$AppDatabase db, $OtherChargesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OtherChargesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OtherChargesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OtherChargesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> rentCycleId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OtherChargesCompanion(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            rentCycleId: rentCycleId,
            amount: amount,
            category: category,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String?> firestoreId = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            required String id,
            required String rentCycleId,
            required double amount,
            required String category,
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OtherChargesCompanion.insert(
            firestoreId: firestoreId,
            lastUpdated: lastUpdated,
            isSynced: isSynced,
            isDeleted: isDeleted,
            id: id,
            rentCycleId: rentCycleId,
            amount: amount,
            category: category,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$OtherChargesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({rentCycleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (rentCycleId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.rentCycleId,
                    referencedTable:
                        $$OtherChargesTableReferences._rentCycleIdTable(db),
                    referencedColumn:
                        $$OtherChargesTableReferences._rentCycleIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$OtherChargesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OtherChargesTable,
    OtherCharge,
    $$OtherChargesTableFilterComposer,
    $$OtherChargesTableOrderingComposer,
    $$OtherChargesTableAnnotationComposer,
    $$OtherChargesTableCreateCompanionBuilder,
    $$OtherChargesTableUpdateCompanionBuilder,
    (OtherCharge, $$OtherChargesTableReferences),
    OtherCharge,
    PrefetchHooks Function({bool rentCycleId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OwnersTableTableManager get owners =>
      $$OwnersTableTableManager(_db, _db.owners);
  $$HousesTableTableManager get houses =>
      $$HousesTableTableManager(_db, _db.houses);
  $$BhkTemplatesTableTableManager get bhkTemplates =>
      $$BhkTemplatesTableTableManager(_db, _db.bhkTemplates);
  $$UnitsTableTableManager get units =>
      $$UnitsTableTableManager(_db, _db.units);
  $$TenantsTableTableManager get tenants =>
      $$TenantsTableTableManager(_db, _db.tenants);
  $$TenanciesTableTableManager get tenancies =>
      $$TenanciesTableTableManager(_db, _db.tenancies);
  $$RentCyclesTableTableManager get rentCycles =>
      $$RentCyclesTableTableManager(_db, _db.rentCycles);
  $$PaymentChannelsTableTableManager get paymentChannels =>
      $$PaymentChannelsTableTableManager(_db, _db.paymentChannels);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$ElectricReadingsTableTableManager get electricReadings =>
      $$ElectricReadingsTableTableManager(_db, _db.electricReadings);
  $$OtherChargesTableTableManager get otherCharges =>
      $$OtherChargesTableTableManager(_db, _db.otherCharges);
}
