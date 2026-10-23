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
  TextColumn get syncStatus => text().withDefault(const Constant('SYNCED'))(); // LOCAL, OUTBOX, PENDING, SYNCED, FAILED, CONFLICT
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

@DataClassName('LocalInspectionItem')
class InspectionItemsTable extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get areaId => text()();
  TextColumn get name => text()(); // e.g., Muros, Pisos, Enchufes, Grifería
  TextColumn get category => text()(); // Acabados, Instalaciones, Estructura
  TextColumn get status => text().withDefault(const Constant('PENDING'))(); // CONFORME, NO_CONFORME, NO_APLICA, PENDING
  TextColumn get syncStatus => text().withDefault(const Constant('LOCAL'))();
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
  TextColumn get itemId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get severity => text().withDefault(const Constant('MENOR'))(); // MENOR, MODERADA, MAYOR, CRÍTICA
  TextColumn get status => text().withDefault(const Constant('PENDING'))(); // PENDING, EN_CORRECCIÓN, CORREGIDO, CERRADO
  TextColumn get syncStatus => text().withDefault(const Constant('LOCAL'))();
  TextColumn get hash => text().nullable()(); // SHA-256 state signature for conflict detection
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
  TextColumn get sha256 => text()(); // Cryptographic digest of the local binary
  TextColumn get deviceId => text().nullable()();
  DateTimeColumn get capturedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get sequence => integer().withDefault(const Constant(0))();
  TextColumn get syncStatus => text().withDefault(const Constant('LOCAL'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LocalPropertyPlan')
class PropertyPlansTable extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get propertyId => text()();
  TextColumn get name => text()(); // Planimetría Arquitectura, Eléctrico, Sanitario
  TextColumn get localFilePath => text()();
  TextColumn get storagePath => text().nullable()();
  TextColumn get sha256 => text()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('SYNCED'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LocalPlanMarker')
class ObservationPlanMarkersTable extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get planId => text()();
  TextColumn get observationId => text()();
  RealColumn get xPercent => real()(); // Coordenada normalizada táctil 0.0 a 100.0%
  RealColumn get yPercent => real()(); // Coordenada normalizada táctil 0.0 a 100.0%
  TextColumn get syncStatus => text().withDefault(const Constant('LOCAL'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
