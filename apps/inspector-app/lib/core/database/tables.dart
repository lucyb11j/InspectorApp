import 'package:drift/drift.dart';

@DataClassName('LocalInspection')
class InspectionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get propertyId => text()();
  TextColumn get clientId => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('SCHEDULED'))();
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('SYNCED'))(); // SYNCED, PENDING_SYNC, CONFLICT
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LocalArea')
class AreasTable extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get inspectionId => text()();
  TextColumn get name => text()();
  IntColumn get sequence => integer().withDefault(const Constant(0))();
  TextColumn get syncStatus => text().withDefault(const Constant('SYNCED'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LocalObservation')
class ObservationsTable extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get inspectionId => text()();
  TextColumn get areaId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get severity => text().withDefault(const Constant('MENOR'))();
  TextColumn get status => text().withDefault(const Constant('PENDING'))();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING_SYNC'))();
  TextColumn get hash => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LocalEvidence')
class EvidenceTable extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get observationId => text()();
  TextColumn get localFilePath => text()();
  TextColumn get storagePath => text().nullable()();
  TextColumn get fileName => text()();
  TextColumn get mimeType => text()();
  IntColumn get fileSizeBytes => integer()();
  TextColumn get sha256 => text()();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING_SYNC'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
